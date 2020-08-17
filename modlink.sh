#!/bin/bash

: <<LICENSE

MIT License

Copyright (c) 2018 Vitalii B.

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.

LICENSE

LC_ALL=C

if [[ -z "$(which dialog)" ]]; then
  echo "Missing 'dialog'! Please, run 'apt install -y dialog' to install it."
  exit 1
elif [[ -z "$(which xmlstarlet)" ]]; then
  echo "Missing 'xmlstarlet'! Please, run 'apt install -y xmlstarlet' to install it."
  exit 1
fi


if [[ ! -z "$1" ]]; then
  echo "Just run it! :)"
  exit 99
fi

# Variables
ARMA_SERVER_DIR=
SELECTED_SERVER=server_hosting
ARMA_PATH="${ARMA_SERVER_DIR:-server}"
DEF_SRV="${SELECTED_SERVER:-${ARMA_PATH}}"
DIALOG=${DIALOG=dialog}
INSTALLED_LIST=$(tempfile 2>/dev/null) || tempfile=/tmp/test$$
TMPFILE=$(tempfile 2>/dev/null) || tempfile=/tmp/test$$
trap cleanup 0 1 2 6 15
STEAM_DIR="${HOME}"/Steam/steamapps/workshop/content/107410

cleanup() {
  rm -f $TMPFILE $INSTALLED_LIST
}

SERVERS_LIST() {
  for server in ${HOME}/${ARMA_PATH}*; do
    SRV=$(echo ${server} | cut -d '/' -f 4)
    SRV_NAME=${SRV}
    if [[ ${SRV} = ${DEF_SRV} ]]; then
      echo "${SRV} $SRV_NAME ON"
    else
      echo "${SRV} $SRV_NAME off"
    fi
  done
}

echo ${SERVER_LIST}

$DIALOG --backtitle "" \
  --keep-tite \
  --keep-window \
  --no-tags \
  --title "Select Server to link MODs" --clear \
  --radiolist "Link to... " 20 50 30 \
  $(SERVERS_LIST) 2>$TMPFILE

retval=$?
srv_choice=$(cat ${TMPFILE})

case $retval in
0)
  DEF_SRV=$srv_choice
  ;;
1)
  echo "Canceled."
  exit 1
  ;;
255)
  echo "ESC key is pressed."
  exit 1
  ;;
esac

SRV_PATH=${HOME}/${DEF_SRV}/serverfiles
LGSM_CFG=${HOME}/${DEF_SRV}/lgsm/config-lgsm/arma3server

# Check for a "key/keys" directory in a linked MOD's directory and create symbolic links for all keys in it to a server's "keys" directory
linkkeys() {
  if [[ -d "${SRV_PATH}"/@"${name}"/keys ]]; then
    ln -s "${SRV_PATH}"/@"${name}"/keys/* "${SRV_PATH}"/keys/ 2>/dev/null
  elif [[ -d "${SRV_PATH}"/@"${name}"/key ]]; then
    ln -s "${SRV_PATH}"/@"${name}"/key/* "${SRV_PATH}"/keys/ 2>/dev/null
  else
    return
  fi
}

# Get MODs list from Steam directory
for M_DIR in $(ls -1 ${STEAM_DIR} | grep -vE "*_old_*"); do
  # Get MOD name and ID
  if [[ -f "${STEAM_DIR}"/"${M_DIR}"/meta.cpp ]]; then
    MOD_NAME=$(grep -h "name" "${STEAM_DIR}"/"${M_DIR}"/meta.cpp |
      awk -F'"' '{print $2}' |
      tr -d "[:punct:]" |
#      tr [:upper:] [:lower:] |
      sed -E 's/\s{1,}/_/g')
    if [[ -n ${MOD_NAME} ]]; then true; else MOD_NAME='NO_NAME_is_DEFINED'; fi
    MOD_ID=$(grep -h "publishedid" "${STEAM_DIR}"/"${M_DIR}"/meta.cpp | awk '{print $3}' | tr -d [:punct:] | tr -d '\015')
    if [[ ${MOD_ID} = "1998821941" ]]; then
      MOD_NAME="$(echo ${MOD_NAME} | sed 's/^/00-/g')"
    fi
  fi
  # Check if MOD is already linked into the game directory and write it to the list
  if [[ -d "${SRV_PATH}"/@${MOD_NAME} ]] || [[ -L "${SRV_PATH}"/@${MOD_NAME} ]]; then
    echo -e "${MOD_NAME} ${MOD_ID} ON" >>${INSTALLED_LIST}
  else
    echo -e "${MOD_NAME} ${MOD_ID} off" >>${INSTALLED_LIST}
  fi
done

# Construct pseudograpchical interface
modsel() {
  $DIALOG --backtitle "" \
    --title "MOD selection" --clear \
    --keep-tite \
    --keep-window \
    --ok-label "Link mods" \
    --extra-button \
    --extra-label "More actions" \
    --checklist "Select MOD(s) to connect it in game. Remove selection to remove MOD" 80 80 50 \
    $(sort ${INSTALLED_LIST}) 2>$TMPFILE

  retval=$?

  # Find a switched off MODs
  choice_id_list=$(for name in $(cat ${TMPFILE}); do cat ${INSTALLED_LIST} | grep "^${name} " | awk '{ print $2 }'; done)
}

while true; do

  modsel

  case $retval in
    0)
      mods=""
      find "${SRV_PATH}/" -maxdepth 1 -name '@*' -type l -delete
      find "${SRV_PATH}/keys/" -maxdepth 1 -type l -delete
      for mod_id in ${choice_id_list[@]}; do
        for name in $(grep ${mod_id} $INSTALLED_LIST | awk '{ print $1 }'); do
          if [[ -z $mods ]]; then
            mods="@${name}"
          else
            mods="${mods}\\\;@${name}"
          fi
          if [[ -d "${SRV_PATH}"/@"${name}" ]] || [[ -L "${SRV_PATH}"/@"${name}" ]]; then
            linkkeys
            continue
          else
            # Link MOD's Steam path to Server directory by its name
            ln -s "${STEAM_DIR}"/"${mod_id}" "${SRV_PATH}"/@"${name}" 2>/dev/null
            linkkeys
          fi
        done
      done
      find "${LGSM_CFG}" -maxdepth 1 -type f -name 'arma3server*.cfg' -exec sed -i s/^mods=.*$/mods=\"${mods}\"/g {} \;
      clear
      exit 0
      ;;
    1)
      echo "Canceled."
      exit 1
      ;;
    3)
      $DIALOG --keep-tite \
        --keep-window \
        --title "Select action" \
        --clear \
        --no-tags \
        --radiolist "Select action." 10 50 2 \
        "1" "Unselect all MODs" ON \
        "2" "Select HTML file with mod compilation" off 2>${TMPFILE}
      value=$?
      case $value in
        0)
          if [[ $(cat ${TMPFILE}) = 1 ]]; then
            sed -i 's/ON/off/g' ${INSTALLED_LIST}
          elif [[ $(cat ${TMPFILE}) = 2 ]]; then
            FILE_LIST=($(for item in $(dirname $0)/html/*.html; do echo "${item} $(basename ${item}) off"; done))
            MOD_COMPILATION=$($DIALOG --keep-tite \
              --keep-window \
              --title "Select file:" \
              --clear \
              --no-tags \
              --radiolist "Select a file from list:" 15 50 5 \
              "${FILE_LIST[@]}" \
              3>&1 1>&2 2>&3)
            fselectval=$?
            case $fselectval in
              0)
                sed -i 's/ON/off/g' ${INSTALLED_LIST}
                LIST=$(xmlstarlet sel -T -t -v "  html/body/div/table/tr/td/a" ${MOD_COMPILATION} | awk -F= '{  print $2 }')
                for id in ${LIST[@]}; do
                  grep ${id} ${INSTALLED_LIST} \
                  || dialog --colors --title "\Zb\Z1Error! Not found.\Zn" \
                    --keep-window \
                    --msgbox \
                    "\Zb\Z1Error!\ZB \Z0Mod id ${id} not found on server. Download it first!\Zn" 10 50
                  sed -i "s/${id} off/${id} ON/g" ${INSTALLED_LIST}
                done
                ;;
              1)
                false
                ;;
              255)
                false
                ;;
            esac
          fi
          ;;
        1)
          false
          ;;
        255)
          false
          ;;
      esac
      ;;
    255)
      echo "ESC key pressed."
      exit 1
      ;;
  esac
done

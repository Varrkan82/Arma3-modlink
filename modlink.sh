#!/bin/bash

DIALOG=${DIALOG=dialog}
INSTALLED_LIST=$(tempfile 2>/dev/null) || tempfile=/tmp/test$$
tempfile=$(tempfile 2>/dev/null) || tempfile=/tmp/test$$

SRV_PATH="${HOME}"/server/serverfiles
STEAM_DIR="${HOME}"/mods/steam
 
for M_DIR in $(ls -1 ${STEAM_DIR} | grep -vE "*_old_*"); do
    if [[ -f "${STEAM_DIR}"/"${M_DIR}"/meta.cpp ]]; then
	MOD_NAME=$(grep -h "name" "${STEAM_DIR}"/"${M_DIR}"/meta.cpp | \
	awk -F'"' '{print $2}' | \
	tr -d "[:punct:]" | \
	tr "[:upper:]" "[:lower:]" | \
	sed -E 's/\s{1,}/_/g' | \
	sed 's/^/\@/g')
	MOD_ID=$(grep -h "publishedid" "${STEAM_DIR}"/"${M_DIR}"/meta.cpp | awk '{print $3}' | tr -d [:punct:])
    fi
    if [[ -d "${SRV_PATH}"/${MOD_NAME} ]] || [[ -h "${SRV_PATH}"/${MOD_NAME} ]]; then
	echo -e "${MOD_NAME} ${MOD_ID} ON" >>${INSTALLED_LIST}
    else
	echo -e "${MOD_NAME} ${MOD_ID} off" >>${INSTALLED_LIST}
    fi
done

$DIALOG --backtitle "Select MOD to connect" \
	--keep-tite \
        --title "MOD selection" --clear \
        --checklist "Selected MODs... " 70 70 25 \
	$(cat ${INSTALLED_LIST}) 2>$tempfile

retval=$?

choice_id_list="$(for name in $(cat ${tempfile}); do grep -v ON ${INSTALLED_LIST} | grep ${name} ${INSTALLED_LIST} | awk '{ print $2 }'; done)"

case $retval in
  0)
    for mod_id in ${choice_id_list[@]}; do 
	for name in $(grep ${mod_id%$'\r'} $INSTALLED_LIST | awk '{ print $1 }'); do
	    if [[ -d "${SRV_PATH}"/${name%$'\r'} ]] || [[ -h "${SRV_PATH}"/${name%$'\r'} ]]; then
		continue
	    else
		ln -s ${STEAM_DIR}/${mod_id%$'\r'} "${SRV_PATH}"/${name%$'\r'} 2>/dev/null
		ln -s "${SRV_PATH}"/${name%$'\r'}/keys/* "${SRV_PATH}"/keys/ 2>/dev/null
	    fi
	done
    done
    ;;
  1)
    echo "Canceled."
    ;;
  255)
    echo "ESC key pressed."
    ;;
esac

exit 0
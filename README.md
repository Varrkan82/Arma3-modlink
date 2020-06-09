# ArmA3-modlink description
This tool is created to work with LGSM tool!

This is a simple pseudographical SHELL tool to create/remove the symbolic links of a selected MODs from Steam Workshop directory to a directory with the ArmA dedicated server on Linux.\
It is creates the symbolyc links of an all files in a "keys" directory of a linked MOD to your server's "keys" directory. And it can remove these links if mod removed from server path (with the current tool by unmarking the mod in list).

It also can add an enabled mods to the commandline parameter "mods=" in LGSM server configuration file. (Great thanks to brezerk!)

## Dependencies

* dialog
* LGSM Tool (https://linuxgsm.com/)

## Usage
###### PRE

``mods=""`` variable should present and to be uncommented and empty in */home/steam/server/lgsm/config-lgsm/arma3server/arma3server.cfg* file (the same thing for any other server).

Before using - please update a following variables for your own:

``STEAM_DIR`` - this is a path to your Steam directory with a mods.

``ARMA_PATH`` - default server path name in your home directory. (*/home/steam/server* by default).

#### How to use
The default server name is "server" which is located in "/home/$USER" directory. All other server directories should start with the "server" string to be included in a list of servers for choosing.

Just start the script - and you'll see all you need.

You can select the server you want to link a MODs to in a first step. And the MODs which you're need to link/unlink in the second step.

Use and arrows on your keyboard to navigate and the SPACE key to select/unselect a punct under your cursor position.

Added: option to remove selection from all mods.
Added: option to load mod compilation from XML file, saved from ArmA Launcher.

Use "More actions" button on a MOD selection screen.

```
mkdir modlink
cd modlink
git clone https://github.com/Varrkan82/ArmA3-modlink.git .
./modlink.sh
```

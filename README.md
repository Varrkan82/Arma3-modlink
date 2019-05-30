# ArmA3-modlink description
This tool created to work with LGSM tool! \
\
This is a simple pseudographical SHELL tool to create/remove the symbolic links of a selected MODs from Steam Workshop directory to a directory with the ArmA dedicated server on Linux.\
It is creates the symbolyc links of an all files in a "keys" directory of a linked MOD to your server's "keys" directory. And it can remove these links if mod removed from server path (with the current tool by unmarking the mod in list).

It also can add an enabled mods to the commandline parameter "mods=" in LGSM server configuration file. (Great thanks to brezerk!)

## Dependencies

* dialog
* LGSM Tool (https://linuxgsm.com/)

## Usage
###### PRE
Before using - please update variables ``SRV_PATH`` and 
``STEAM_DIR`` in *modlink.sh* to your own.
#### How to use
The default server name is "server" which is located in "/home/$USER" directory. The other server name could be passed as a startup argument for a script.
```./modlink.sh server_SECOND```\
In this case all changes will be done in directory "/home/$USER/server_SECOND"\
Just start the script - and you'll see all you need.

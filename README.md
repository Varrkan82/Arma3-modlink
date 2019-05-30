# ArmA3-modlink description
This tool created to work with LGSM tool!
This is a simple pseudographical SHELL tool to create the symbolic links of a selected MODs from Steam Workshop directory to a directory with the ArmA dedicated server on Linux.

Currently - this script can only to create a symbolic links of MODs to your game server directory and to list and show an already present MODs in a game server directory.

Also it is creates the symbolyc links of an all files in a "keys" directory of a linked MOD to your server's "keys" directory.

To remove an already linked MOD I recomend to proceed manually the following steps:
- Remove the symbolic link of the MOD from your server directory
- Remove a deprecated symbolic links to keys from your server "keys" directory

## Dependencies

* dialog

## Usage
###### PRE
Before using - please update variables ``SRV_PATH`` and 
``STEAM_DIR`` in *modlink.sh* to your own.
#### How to use
The default server name is "server" which is located in "/home/$USER" directory. The other server name could be passed as a startup argument for a script.
```./modlink.sh server_SECOND```
In this case all changes will be done in directory "/home/$USER/server_SECOND"
Just start the script - and you'll see all you need.

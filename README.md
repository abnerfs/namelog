# [ANY] Name log

![Downloads](https://img.shields.io/github/downloads/abnerfs/namelog/total) ![Last commit](https://img.shields.io/github/last-commit/abnerfs/namelog "Last commit") ![Open issues](https://img.shields.io/github/issues/abnerfs/namelog "Open Issues") ![Closed issues](https://img.shields.io/github/issues-closed/abnerfs/namelog "Closed Issues") ![Size](https://img.shields.io/github/repo-size/abnerfs/dontpad-api "Size")

This is a simple plugin to registry the names used by players and access them easily via a menu.


# Commands (ADMFLAG_SLAY NEEDED)

- **sm_namelog <name>** - Search players that uses a name and display in a menu, when you select an option in the menu you can see the Name, SteamID and AuthID of the player.
- **sm_steamlog <steamid/authid>** - Search all names used by a specific AuthID or SteamID and display in a menu.
- **sm_iplog <ip>** - Search all names used by an IP.

# Installation

- Put the compiled .smx file in your addons/sourcemod/plugins folder.
- Open the file addons/sourcemod/configs/databases.cfg
- Add this code before the last }

```
"namelog"
{
    "driver"      "sqlite"
    "database"    "namelog"
}
```
- Restart your server. 

# Support 
- AlliedModders: https://forums.alliedmods.net/showthread.php?p=2420873
- TecnoHardClan: http://www.tecnohardclan.com/forum/index.php/topic/5196-any-abner-namelog/

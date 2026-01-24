## Synergy HMW GSC Menu

HorizonMW GSC Mod Menu

This Menu is a Work-in-Progress, so expect changes and possibly some Bugs

If you use any Code from my Menu, your Menu also has to be Open-Source as per the [GNU GPLv3 License](https://github.com/SyndiShanX/Synergy-HMW-GSC-Menu/blob/main/LICENSE.md)

If you have any Issues/Suggestions, please Submit them in [Issues](https://github.com/SyndiShanX/Synergy-HMW-GSC-Menu/issues)

#### Youtube Showcase:

[![Showcase](https://syndishanx.github.io/Synergy-HMW-GSC-Menu/Youtube-Thumbnail.png)](https://www.youtube.com/watch?v=iz3NUkdHwq4 "Horizon MW | Synergy GSC Mod Menu | Unlock All + Rainbow Classes")

### Requirements: [HorizonMW](https://horizonmw.org/)

### Installation:

#### Private Match:

* Download the [After Patch DLL](https://syndishanx.github.io/Synergy-HMW-GSC-Menu/After-Patch-GSC-v1.6.1.dll)

* Inject it either using [Process Hacker 2](https://sourceforge.net/projects/processhacker/files/processhacker2/processhacker-2.39-setup.exe/download) or [Xenos](https://github.com/DarthTon/Xenos/releases/tag/2.3.2)

* Download [Synergy.gsc](https://syndishanx.github.io/Synergy-HMW-GSC-Menu/Synergy.gsc)

* Place it into `hmw-mod/scripts/mp`, then Load into a Private Match and Enjoy

* If you aren't the Host of the Game the Menu won't work

##### Dedicated Server:

* Make a copy of your HMW Installation (Using your existing installation won't work due to the Client not allowing Custom Scripts)

* Download the [Server Files](https://syndishanx.github.io/Synergy-HMW-GSC-Menu/Server/Server_Files.zip), extract and place the files in that new installation folder (Next to `hmw-mod.exe`)

* You can change the Server Settings in `main/server_default.cfg` at the bottom if you want to change the maps/modes

* Run `server_default.bat` and wait for the Server to Start

* Launch your Game, and Connect using `connect 127.0.0.1:27017` in the ingame console (Tilde Key (~), to the left of 1 on your keyboard)

* Any Player that joins wil have the Menu

###### Optional File Deletion:

You can delete the following files in your server installation to save some space:
 - Any file ending in `.pak`
 - Any `.dll` file except `amd_ags_x64.dll`, `bink2w64.dll`, and `steam_api64.dll`
 - Any folder besides `hmw-mod`, `hmw-usermaps`, `main`, `user_scripts`, and `zone`
 - All `.ff` in `zone` files starting with `mp_head`, `mp_lm`, `mp_shirt`, `mp_vm`, `mp_wm`, and `mp_viewarm`
 
You can use `move_extra_files.bat` to move them into `EXTRA_FILES` so you can see what was moved and just delete that

## Credits

This menu is based on [M203](https://github.com/Xeirh/M203) by [Xeirh](https://github.com/Xeirh)

- Apparition Structure Team:
  * `CF4_99` Main developer
  * `Extinct` Ideas, suggestions, constructive criticism
  * `ItsFebiven` Some ideas and suggestions
  * `Joel` Suggestions
	
Some functions are from [Retropack](https://github.com/justinabellera/retro-pack) by [Rtros](https://github.com/justinabellera)

The After Patch DLL was made by [EFKMODZ](https://www.unknowncheats.me/forum/members/2263667.html)
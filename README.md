# THE EPIC PLATFORM RACING 2 EXPERIENCE SIMULATOR v1.0.0

**PLEASE READ THE README BEFORE ASKING ANY QUESTIONS**
... but I will answer any questions you have regardless..  
Sorry, this only runs on windows OS  
MANY MORE FEATURES TO COME

---

The EPIC PLATFORM RACING 2 EXPERIENCE SIMULATOR is an all-in-one AutoHotkey script that will boot your PR2 instances, position them, hide them (to your desktop), log you in, find the sim level, and run the sim... all at the press of a single key (well.. sorta).

### Notable Features:
- **Happy hour locator!!** Automatically Log into happy hours as they appear for BIG exp
- **Outfit Pieces!!** Collects the random outfit rewards from races due to my * *ultra speical
- **Anti-disconnect!!** Any issue that the instance encounters while simming will force a reboot and fix the sim
- **Varying-connection tolerable!!** Inputs are made taking your ping/server connection into consideration
- **Input isolation!!** You can still control your computer while the sim runs and will soon forget that they're there at all. PR2 servers allow a single IP FIVE accounts logged in at once so.. 4 sims, 1 gamer. Go crazy
- **Hide instances!!** Your PR2 instances can be hidden behind whatever window you are actively using. Zero interruptions!
- **Setup dialogue!!** Just answer the questions prompted by the script correctly, and you're good to go

## INSTRUCTIONS
- Download [AutoHotkey](https://www.autohotkey.com/)
- Install AutoHotkey
- Download MEGAEPICPR2SIM and FindText (locate them together within one folder/location, i.e 'Desktop'
- Run MEGAEPICPR2SIM
- Profit
  
**(OPTIONAL)** Create a copy of the SIM levels so that you can hide them, change the background color, or make any additions you'd like. This can be accomplished by loading and saving the level within blockeditor, a program made by Pr2FreeRunner: [Block Editor](https://github.com/Pr2FreeRunner/BlockEditor/releases/tag/Release)

## HOTKEYS
-Windows+F12: begin the sim  
-Windows+F11: reload the script  
-Windows+F10: pause the script  
-Windows+F9: end the script  
-Windows+h: show all hotkeys  
  
### NOTES/KNOWN ISSUES:
- DPI scaling mid-script is not currently supported, and neither is using a secondary monitor with anything other than default DPI settings
- Resizing the instances is not currently supported.
- Holding left-click while the script is entering/exiting a level will pause the script until the button is released
- Minimizing the PR2 windows is not supported. If you do, they will unminimize themselves and position at their bootup location
- Moving the instances is ALLOWED, but moving them while they are receiving input from the script will cause them to fail and reboot
- I AM NOT GONNA STEAL YOUR LOGIN INFO (lol) There is only ONE single communication that the script makes which is necessary to collect the happy hour data. Info is saved locally to 'EPICsimDetails.ini, for you only. If you are concerned, just read through the code yourself (mega spaghetti-code, approved by jiggmin)  (:
- Sometimes the sim will restart shortly after boot (unsure why). Don't panic, it'll be fine
- ~~Currently, the script will copy values pasted in the text box during the race, which will mess with you at times. Anything you copied will be placed back in your clipboard after the script is finished with the clipboard.~~ (oldpr2sim, epicpr2sim)
- ~~Excessive sleep(delay) calls while booting and setting up instances to account for server instability and PR2 input jank. Will be optimized later through automatic calibration and/or image processing~~ (optimized in MEGAEPICPR2SIM)
- ~~Pressing control (ctrl) at very specific moments is known to cause issues. There are many fail-safes for this, but more work will need to be done.~~ (oldpr2sim, epicpr2sim)
- ~~If your input is pressed at the exact same moment the script presses an input, the single instance might soft lock, depending on your input. The user input is always prioritized, as the sim can always fix itself if needed.~~
- ~~If holding shift while the script is logging in, your shift press will be undone and you will need to press shift again~~
- ~~If the script is breaking often, reach out to me and I will help troubleshoot the issue. I have found that a computer restart fixes things sometimes, as certain function keys (ctrl, windows, shift) will get 'stuck'. I added code to prevent this. Please let me know if you can't solve your issue. PR2 servers aren't inconsistent, and there are gamers worldwide, with varying computer processing power as well. Delays may be inaccurate, but are accommodated somewhat.~~ (not an issue anymore?)


### Future (large) Plans
- ~~Calibration mode to allow the script to adapt to processing power/ internet~~ (accomplished)
- ~~Image processing for no downtime~~ (accomplished)
- ~~COMPLETE input isolation, removing those rare~~ (mostly accomplished)
- ~~Will implement macroExperimental (seen in code) which quits the sim faster and/or gives outfit rewards~~ (accomplished)

Please let me know if you find any issues or if you have any other features you might like me to add (:


Thanks for reading me! Long live Platform Racing

-YaBoiTroi, EpicMidget, Troy

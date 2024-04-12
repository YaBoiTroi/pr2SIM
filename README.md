# THE EPIC PLATFORM RACING 2 EXPERIENCE SIMULATOR

**PLEASE READ THE README BEFORE ASKING ANY QUESTIONS**
... but I will answer any questions you have regardless..  
Sorry, this only runs on windows OS  
  
  
  
The EPIC PLATFORM RACING 2 EXPERIENCE SIMULATOR is an all-in-one AutoHotkey script that will boot your PR2 instances, position them, hide them (to your desktop), log you in, find the sim level, and run the sim... all at the press of a single key (well.. sorta).
  
## Notable Features
- **Happy hour locator!!** Automatically Log into happy hours as they appear for BIG exp
- **Outfit Pieces!!** Collects the random outfit rewards from races due to the **ultra special** custom made sim level
- **Anti-disconnect!!** Any issue that the instance encounters while simming will force a reboot and fix the sim
- **Varying-connection tolerable!!** Inputs are made taking your ping/server connection into consideration
- **Input isolation!!** You can still control your computer while the sim runs and will soon forget that they're there at all. PR2 servers allow a single IP FIVE accounts logged in at once so.. 4 sims, 1 gamer. Go crazy
- **Hide instances!!** Your PR2 instances can be hidden behind whatever window you are actively using, or with Windows+F8 to hide them for reals. Zero interruptions!
- **Setup dialogue!!** Just answer the questions prompted by the script correctly, and you're good to go
- **Update Checker!** The script will check for updates and ask if you'd like to download them. No more tedious trips to github
  
## INSTRUCTIONS
- Download [AutoHotkey](https://www.autohotkey.com/)
- Install AutoHotkey
- Download MEGAEPICPR2SIM and FindText (locate them together within one folder/location, i.e 'Desktop')
- Run MEGAEPICPR2SIM
- Profit
  
**(OPTIONAL)** Create a copy of the SIM levels so that you can hide them. DO NOT CHANGE THE BACKGROUND!! This can be accomplished by loading and saving the level within blockeditor, a program made by Pr2FreeRunner: [Block Editor](https://github.com/Pr2FreeRunner/BlockEditor/releases/tag/Release)
.  
## HOTKEYS
-Windows+F12: begin the sim  
-Windows+F11: reload the script  
-Windows+F10: pause the script  
-Windows+F9: end the script  
-Windows+F8: Hide all instances (script continues working)  
-Windows+h: show all hotkeys  
.  
## NOTES/KNOWN ISSUES
**IMPORTANT**  
- Do NOT let your monitor's screen shut off. This 'minimizes' the instances, making them inaccessible. Your screen will naturally try to turn off  
- Do NOT run the pr2 instances as admin. This will only happen if you have that box checked within properties --> compatibility  
- Alternative DPI is supported, but you must tick both boxes in the {PR2EXE(r_click) --> properties --> compatibility -> change high DPI settings} menu  
- DPI scaling mid-script is not currently supported, and neither is using a secondary monitor with anything other than default DPI settings
- You MUST have exp hats on your 4 sim accounts (will fix at a future date, outfit sim to get exp hat)
    
    
    
    
    
    
    
- Varying window sizes may be used, but the sim will likely fail and reboot if they are unreasonably small
- Holding left-click while the script is entering/exiting a level will pause the script until the button is released
- Minimizing the PR2 windows is not supported. If you do, they will unminimize themselves and position at their bootup location
- Moving the instances is ALLOWED, but moving them while they are receiving input from the script may cause the script to fail and reboot
# FAQ  
### How do these 'sim' thingies work? 
- These sim levels are designed to give every player as much experience as possible in the shortest amount of time (most exp / time possible), completely idly. This is possible by equipping exp hats (2x exp) and taking advantage of a process called 'obj simming', or 'objective simming'  
### What is 'objective simming'? 
- Objective simming is a variant of simming. Simming involves giving all the exp hats to a player so that they may get the most exp possible. Objective simming not only transfers the hats to every player, but gives every player the max amount of exp. To accomplish this, each player must hit more finish blocks than every other player, then quit the game... So, P1 will hit 1 finish block extra, then quit at ~2 minutes, P2 will hit P1 with a sword to get the hats, hit 2 finish blocks, then quits.. etc.  2 mins: p1 quit(+1finish), p2 slash, p2 quit(+2finish), p3 slash, p3 quit(+3 finish), p4 slash, p4 quit(+4finish)  
### What are the different sim types?  
- Sim type 1 (named Gaming #) is a bit different and will award p4 with the outfit piece/upgrade that may exist on the current sim run. This is different than normal objective simming since p4 will hit every finish block which claims the reward and circumvents the need to quit on p4 at all  
- Sim type 2 (named Gaming # (no outfit rewards))is a regular objective sim  
- Sim type 3 is an objective sim, but much slower, as it doesn't take advantage of autohotkey's ability to control movement in addition to clicks  
### Which sim type should I use?  
- Use type 1 or 2 if you want exp the quickest. Type 1 will gain the outfit reward at the cost of ~1-2 seconds per sim. Type 3 is not recommended
### How is experience calculated?  
- Each player will get 25 exp for 'attempting' the level, as well as (rank+5) exp for every other player in the sim. With all 4 exp hats equipped, this total is multiplied by 5. Additionally, experience is multiplied by 2 if that player has earned less than 5000 exp in the current day. If they've earned more than 5000 but less than 25000, experience is instead multiplied by 1.5. After 25000 total exp in the day, the multiplier bonus expires (set to 1x). Finally, during a happy hour, all experience is multiplied by 2, after all the previous calculations. NOTE: P1 will naturally get a small margin less for reasons described in the next question
### Why is it quitting at 1:57/1:58?  
- This time ends up being the most optimal. at ~1:57, p1 will lose 1 exp in the 'level attempt', and 1 exp for each 'defeat'. This DOES mean p1 earns the least exp (20 less), but the loss is worth the time saved, as the next 3 players will still earn the max experience possible. At 1:58, only the 1 exp  
### Why isn't it working?  
- Try reading the 'NOTES/KNOWN ISSUES' section above to troubleshoot some common issues. If you are still running into problems, please contact me  
  
  
  
  
##
Please let me know if you find any issues or if you have any other features you might like me to add (:  
  
  
Thanks for reading me! Long live Platform Racing  
  
-YaBoiTroi, EpicMidget, Troy  

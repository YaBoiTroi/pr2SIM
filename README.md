# THE EPIC PLATFORM RACING 2 EXPERIENCE SIMULATOR v1.0.0

PLEASE READ THE README BEFORE ASKING ANY QUESTIONS
... but I will also answer any questions you have
MANY MORE FEATURES TO COME

**---------------------------------------------------------------------------------------------------------------------------------**

The EPIC PLATFORM RACING 2 EXPERIENCE SIMULATOR is an all-in-one autohotkey
script which will boot your pr2 instances, position them, hide them (to your
desktop), log you in, find the sim level and run the sim.. all at the press
of a single key (well.. sorta)
  
**Notable features**
-Happy hour locator!! log into happy hours as they appear for BIG exp
-Anti-disconnect!! any issue that the instance encounters while simming will 
force a reboot and fix the sim
-Input isolation!! you can still control your computer
while the sim runs and will soon forget that they're there at all
-Setup dialogue!! Just answer the questions prompted by the script correctly
and you're good to go
  
## **INSTRUCTIONS**
-download AUTOHOTKEY here: https://www.autohotkey.com/
-Download EPICPR2SIM
-Run EPICPR2SIM
-Profit
  
**NOTES/KNOWN ISSUES**
-Minimizing the PR2 windows is not (currently) supported.
If you do, they will unminimize themselves and position at their bootup location
-Moving the instances is ALLOWED, but moving them while they are receiving input
from the script will cause them to fail and reboot  
-currently, the script will copy values pasted in the text box during the
race which will mess with you at times. Anything you copied will be placed back
in your clipboard after the script is finished with the clipboard.  
-Excessive sleep(delay) calls while booting and setting up instances to
account for server instability and pr2 input jank. Will be optimized later
through automatic calibration and/or image processing  
-Pressing control (ctrl) at very specific moments is known to cause issues.
There are many fail-safes for this, but more work will need to be done.
-If the script is breaking often, reach out to me and I will help troubleshoot
the issue. I have found that a computer restart fixes things sometimes, as
certain function keys (ctrl, windows, shift) will get 'stuck'. I added code
to prevent this. Please let me know if you can't solve your issue. PR2
servers aren't inconsistent, and there are gamers worldwide, with varying 
computer processing power as well. Delays may be inaccurate, but are accommodated
somewhat.   
-If your input is pressed at the exact same moment the script presses an input,
the single instance might soft lock, depending on your input. The user input
is always prioritized, as the sim can always fix itself if needed.  
-I AM NOT GONNA STEAL YOUR LOGIN INFO (lol) There is only ONE single 
communication that the script makes which is necessary to collect the happy 
hour data. Info is saved locally to 'EPICsimDetails.ini, for you only.
If you are concerned, just read through the code yourself (:  
-If holding shift while the script is logging in, your shift press will be
undone and you will need to press shift again

  
**Future (large) Plans**
-calibration mode to allow script to adapt to processing power/ internet  
-Image processing for no downtime  
-COMPLETE input isolation, removing those rare  
-Will implement macroExperimental (seen in code) which quits the sim faster and/or gives outfit rewards
  
Please let me know if you find any issues or if you have any other features
you might like me to add There is still much work to be done
long live platform racing
-Much more..


Thanks for reading me! Long live Platform Racing  
  
-YaBoiTroi, EpicMidget, Troy
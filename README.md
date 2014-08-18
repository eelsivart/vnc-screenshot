vnc-screenshot
==============

Nmap NSE script that captures a screenshot from the host(s) over VNC using vncsnapshot.

vnc-screenshot.nse  
Version 0.1

Dependencies:  
vncsnapshot (apt-get install vncsnapshot or http://sourceforge.net/projects/vncsnapshot/)

Installation:  
 # cp vnc-screenshot.nse /usr/share/nmap/scripts/    (or whereever your nmap/scripts folder is located)  
 # nmap --script-updatedb

Usage Examples:  
 # nmap -v -p5900 --script=vnc-screenshot 192.168.1.0/24  
 # nmap -v -p5900 --script=vnc-screenshot --script-args vnc-screenshot.quality=50,vnc-screenshot.indexpage=vnc.html 192.168.1.0/24  
 # nmap -v -p5900 --script=vnc-screenshot --script-args vnc-screenshot.passwd=/root/.vnc/passwd 192.168.1.0/24

Available script-args:  
  vnc-screenshot.quality = 0-100 (default is 75)  
  vnc-screenshot.indexpage = file.html (default is index.html)  
  vnc-screenshot.passwd = /root/.vnc/passwd (passwd file must be created with vncpasswd)

Change Log:  
8/16/2014 - v0.1 - Initial release

-- vnc-screenshot.nse
-- Version 0.1
--
-- Dependencies: 
--    vncsnapshot (apt-get install vncsnapshot or http://sourceforge.net/projects/vncsnapshot/)
--
-- Installation:
--    # cp vnc-screenshot.nse /usr/share/nmap/scripts/    (or whereever your nmap/scripts folder is located)
--    # nmap --script-updatedb
--
-- Usage Examples:
--    # nmap -v -p5900 --script=vnc-screenshot 192.168.1.0/24
--    # nmap -v -p5900 --script=vnc-screenshot --script-args vnc-screenshot.quality=50,vnc-screenshot.indexpage=vnc.html 192.168.1.0/24
--    # nmap -v -p5900 --script=vnc-screenshot --script-args vnc-screenshot.passwd=/root/.vnc/passwd 192.168.1.0/24
--
-- Available script-args:
--    vnc-screenshot.quality = 0-100 (default is 75)
--    vnc-screenshot.indexpage = file.html (default is index.html)
--    vnc-screenshot.passwd = /root/.vnc/passwd (passwd file must be created with vncpasswd)
--
-- Change Log:
-- 8/16/2014 - v0.1 - Initial release

local shortport = require "shortport"
local stdnse = require "stdnse"
local vnc = require "vnc"

description = [[
Captures a screenshot from the host(s) over VNC using vncsnapshot.
]]

author = "Travis Lee < eelsivart at gmail dot com >"
license = "GPLv2"
categories = {"discovery", "safe"}

-- Check to see if port is tcp, was scanned, is open, and is VNC
portrule = shortport.port_or_service( {5900, 5901, 5902} , "vnc", "tcp", "open")

action = function(host, port)
	
	local vnc = vnc.VNC:new( host.ip, port.number )
    
	-- quality defaults to 75
	local quality = stdnse.get_script_args("vnc-screenshot.quality") or "75"

	-- quality defaults to index.html
	local indexpage = stdnse.get_script_args("vnc-screenshot.indexpage") or "index.html"
	
	-- optional password file for vnc authentication. must be created with the vncpasswd util
	local passwd = stdnse.get_script_args("vnc-screenshot.passwd")
    
	-- Screenshots will be called vnc-screenshot-nmap-<IP>_<port>.jpg
	local filename = "vnc-screenshot-nmap-" .. host.ip .. "_" .. port.number .. ".jpg"

	-- Declare vars
	local result
	local cmd
	local ret

	-- Connect to the VNC server and perform handshake to determine available security types
	vnc:connect()
	vnc:handshake()

	-- If there is NO authentication
	if ( vnc:supportsSecType(vnc.sectypes.NONE) ) then
    
		-- Set the shell command: vncsnapshot -allowblank -cursor -quality <quality> <ip> <filename>
		cmd = "vncsnapshot -allowblank -cursor -quality " .. quality .. " " .. host.ip .. " " .. filename .. " 2> /dev/null   >/dev/null"
		stdnse.print_verbose("vnc-screenshot.nse: VNC server has NO authentication")   
    
	-- Else if there IS authentication and the passwd option is used
	else
	
		if passwd then
			-- Set the shell command: vncsnapshot -allowblank -cursor -quality <quality> -passwd <passwd_file> <ip> <filename>
			cmd = "vncsnapshot -allowblank -cursor -quality " .. quality .. " -passwd " .. passwd .. " " .. host.ip .. " " .. filename .. " 2> /dev/null   >/dev/null"
			stdnse.print_verbose("vnc-screenshot.nse: VNC server has authentication methods")
		end
		
	end

	if cmd then
		stdnse.print_verbose("vnc-screenshot.nse: Capturing VNC screenshot for %s",host.ip .. ":" .. port.number)
		ret = os.execute(cmd)
	end

	-- If the command was successful, print the saved message, otherwise print the fail message
	if ret then

		-- Append image to the index html page
		local cmd2 = 'echo "' .. filename .. ' @ `date`:<BR><A HREF=' .. filename .. ' TARGET=_blank><IMG SRC=' .. filename .. ' width=400 border=1></A><BR><BR>" >> ' .. indexpage
		local ret2 = os.execute(cmd2)

		result = "Screenshot saved to " .. filename
	else
		if cmd then
			result = "Error! Something went wrong... verify vncsnapshot is installed and in your path?"
		else
			result = "Error! VNC server requires authentication but no passwd file specified"
		end
	end

	-- Return the output message
	return stdnse.format_output(true,  result)
end

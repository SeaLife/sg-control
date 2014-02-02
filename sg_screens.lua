if SGControl.Version ~= "v1.5" then error("SG-Control Failed!") end
-- Stargate Screens
SGControl.Menu[1] = {name="Home", 		funct=function() StargateScreen.Mode = "home" end}
SGControl.Menu[2] = {name="List", 		funct=function() StargateScreen.Mode = "list" end}
SGControl.Menu[3] = {name="Config", 	funct=function() StargateScreen.Mode = "config" end}
SGControl.Menu[4] = {name="Log", 		funct=function() StargateScreen.Mode = "log" end}

SGControl.List = {}
SGControl.List.Page = 0
SGControl.Error = ""
SGControl.Delete = ""
SGControl.ConfigFile = "/.log"
SGControl.SGListCheck = {}
SGConfig = {}
SGConfig[0] = 0
SGConfig[1] = {Name="Firewall Incoming", 	State=false}
SGConfig[2] = {Name="Firewall Whitelist", 	State=true}
SGConfig[3] = {Name="System Lockdown", 		State=false}
SGConfig[4] = {Name="Stargate-Log", 		State=true}

peripheral.addFunction("stargate", "clearConnection", function(p) local ok, err = pcall( p.disconnect ) end)
peripheral.addFunction("stargate", "dial", function(p, address) SGControl.Error = "" p.connect(address) end)
function SGControl.CheckStargates()
	local SG = peripheral.find("stargate", true, true)
	local sgList = SGControl.listStargates()
	SGControl.SGListCheck = {}
	for k, v in pairs( sgList ) do
		SGControl.SGListCheck[k] = SG.isValidAddress( v )
		--SGControl.SGListCheck[k] = false
	end
end
function StargateScreen.Home()
	local sg = peripheral.find("stargate", true, true)
	local x, y = term.getSize()
	
	local SG_Fuel = sg.getFuelLevel()
	local SG_State = sg.getState()
	local SG_DHD = sg.isDHDConnected()
	local SG_CON = sg.isConnected()
	local SG_Chevr = sg.getLockedChevronCount()

	local function btostring( boolean ) if boolean == true then return "Yes" else return "No" end end

	term.setCursorPos(1, 4)
	term.setTextColor( colors.yellow )
	term.cprint("Stargate Overview")
	term.setTextColor( colors.gray )
	term.xyprint( 2, 6, 	"Stargate Address: ")
	term.xyprint( 2, 8, 	"Stargate Fuel:")
	term.xyprint( 2, 10, 	"Stargate State: ")
	term.xyprint( 2, 12, 	"Stargate DHD: ")
	term.xyprint( 2, 14, 	"Stargate Chevron: ")
	term.xyprint( 22, 6, 	SG_ADDRESS)
	term.xyprint( 22, 8, 	SG_Fuel)
	term.xyprint( 22, 10, 	SG_State)
	term.xyprint( 22, 12, 	btostring(SG_DHD) )
	term.xyprint( 22, 14, 	SG_Chevr )

	if sg.getDialledAddress() ~= "" then
		term.setTextColor( colors.red )
		term.setCursorPos(1, y-1)
		term.cprint("Active Wormhole [" .. sg.getDialledAddress() .. "]")
	else
		term.setTextColor( colors.gray )
		term.setCursorPos(1, y-1)
		term.cprint("Stargate Idle")
	end
end
function StargateScreen.List()
	local SG = peripheral.find("stargate", true, true)
	local x, y = term.getSize()
	local sgList = SGControl.listStargates()
	local maxEntries = 9
	local lowIndex = SGControl.List.Page * 9 + 1
	local maxIndex = lowIndex + maxEntries - 1

	local index = 1
	for i=lowIndex, maxIndex do
		if sgList[i] ~= nil then
			local SGInfo = SGControl.getSGName(sgList[i])
			term.setTextColor( colors.red )
			term.xyprint(2, 3+index, "x")
			SGControl.addTouch( 2, 2, 3+index, function() StargateScreen.Mode = "delStargate" SGControl.Delete = sgList[i] end)
			term.setTextColor( colors.lime )
			term.xyprint(5, 3+index, sgList[i])
			SGControl.addTouch( 5, 5+7, 3+index, function() SG.clearConnection() sleep(2) local _, err = pcall(SG.dial, sgList[i]) if err then SGControl.Error = err end end)
			if( index%2 == 0 ) then term.setTextColor( colors.gray ) else term.setTextColor(colors.lightGray) end
			term.xyprint(5+7+3, 3+index, SGInfo )
			local STATE = ""
			if SGControl.SGListCheck[i] ~= nil then
				if SGControl.SGListCheck[i] == true then
					term.setTextColor( colors.green )
					STATE = "Exists"
				else
					term.setTextColor( colors.red )
					STATE = "Failed"
				end
			else
				term.setTextColor( colors.red )
				STATE = "Not Tested"
			end
			term.xyprint(5+7+3+20, 3+index, "> " .. STATE .. "" )
			index = index + 1
		end
	end
	-- Disconnect
	index = index + 1
	term.setTextColor( colors.pink )
	SGControl.addTouch( 2, 2, 3+index, function() StargateScreen.Mode = "addStargate" end)
	term.xyprint(2, 3+index, "+")
	SGControl.addTouch( 5, 5+10, 3+index, function() SG.clearConnection() end)
	term.setTextColor( colors.lime )
	term.xyprint(5, 3+index, "Disconnect" )
	SGControl.addTouch( 5+10+5, 5+10+5+16, 3+index, function() SGControl.CheckStargates() end)
	term.setTextColor( colors.lime )
	term.xyprint(5 + 10 + 5, 3+index, "[Test Stargates]" )

	if SGControl.Error ~= "" then 
		term.setTextColor( colors.red )
		term.xyprint( 2, y-3, "Error: " .. string.sub(SGControl.Error, 20) )
	end
	term.setTextColor( colors.yellow )
	local maxPage = math.ceil( #sgList / maxEntries )
	term.xyprint( (x/2)-(string.len("Page: " .. (SGControl.List.Page+1) .. "/" .. maxPage)/2), y-1,  "Page: " .. (SGControl.List.Page+1) .. "/" .. maxPage)
	term.setTextColor( colors.lime )
	term.xyprint( 2+4, y-1, "<-")
	term.xyprint( x-2-4, y-1, "->")
	SGControl.addTouch( 2+4, 2+4+2, y-1, function() if SGControl.List.Page > 0 then SGControl.List.Page = SGControl.List.Page - 1 end end)
	SGControl.addTouch( x-2-4, x-2-2, y-1, function() if SGControl.List.Page < 998 then SGControl.List.Page = SGControl.List.Page + 1 end end)
	if SG.getDialledAddress() ~= "" then
		term.setTextColor( colors.red )
		term.setCursorPos(1, y-3)
		term.cprint("Active Wormhole [" .. SG.getDialledAddress() .. "]")
	end
end
function StargateScreen.Config()
	local x, y = term.getSize()
	term.setTextColor( colors.yellow )
	term.setCursorPos(1, 4)
	term.cprint("Stargate Config Manager")
	local maxEntries = 5
	local lowIndex = SGConfig[0] * maxEntries + 1
	local maxIndex = lowIndex + maxEntries - 1
	local index = 1
	for i=lowIndex, maxIndex do
		if SGConfig[i] ~= nil then
			term.setTextColor( colors.gray )
			term.xyprint(2, 5+index+(index-1), SGConfig[i].Name )
			StargateScreen.CheckBox(2+20, 5+index+(index-1), SGConfig[i].State )
			SGControl.addTouch(2+20, 2+20+4, 5+index+(index-1), function() SGConfig[i].State = SGControl.revertBoolean(SGConfig[i].State) end)

			index = index + 1
		end
	end
	term.setTextColor( colors.yellow )
	local maxPage = math.ceil( #SGConfig / maxEntries )
	term.xyprint( (x/2)-(string.len("Page: " .. (SGConfig[0]+1) .. "/" .. maxPage)/2), y-1,  "Page: " .. (SGConfig[0]+1) .. "/" .. maxPage)
	term.setTextColor( colors.lime )
	term.xyprint( 2+4, y-1, "<-")
	term.xyprint( x-2-4, y-1, "->")
	SGControl.addTouch( 2+4, 2+4+2, y-1, function() if SGConfig[0] > 0 then SGConfig[0] = SGConfig[0] - 1 end end)
	SGControl.addTouch( x-2-4, x-2-2, y-1, function() if SGConfig[0] < 998 then SGConfig[0] = SGConfig[0] + 1 end end)
end

function StargateScreen.AddStargate()
	local x, y = term.getSize()
	term.setTextColor( colors.red )
	term.setCursorPos(1, 4)
	term.cprint("Add Stargate")
	term.setTextColor( colors.yellow )
	term.xyprint(3, 6, "Address: " )
	local Addr = read()
	term.xyprint(3, 8, "Name:    " )
	local Name = read()
	if string.len(Addr) == 7 and Addr ~= SG_ADDRESS then
		SGControl.addStargate( string.upper(Addr), Name)
		term.setCursorPos(1, y-1)
		term.setTextColor( colors.green )
		term.cprint("Stargate Added!")
		sleep(2)
		StargateScreen.Mode = "list"
		SGControl.SGListCheck = {}
	else
		if Addr == "abort" then
			StargateScreen.Mode = "list"
		end
		term.setCursorPos(1, y-1)
		term.setTextColor( colors.red )
		term.cprint("Adding Failed! (Unexpected Error)")
		sleep(2)
	end
end

function StargateScreen.DelStargate()
	local x, y = term.getSize()
	term.setTextColor( colors.red )
	term.setCursorPos(1, 4)
	term.cprint("Delete Stargate")
	term.setTextColor( colors.yellow )
	term.xyprint(3, 7, "Address: " .. SGControl.Delete )

	term.setTextColor( colors.red )
	term.xyprint(11, y-4, "Yes")
	term.setTextColor( colors.green )
	term.xyprint(x-11-2, y-4, "No")

	SGControl.addTouch(11, 11+3, y-4, function() SGControl.removeSG(SGControl.Delete) StargateScreen.Mode = "list" end)
	SGControl.addTouch(x-11-2, x-11, y-4, function() StargateScreen.Mode = "list" end)
	SGControl.SGListCheck = {}
end
function StargateScreen.Log()
	-- RANDOM CODE (NOT MY WORK)
	local function readLines(sPath)
		local file = fs.open(sPath, "r")
		if file then
			local tLines = {}
			local sLine = file.readLine()
			while sLine do
				table.insert(tLines, sLine)
				sLine = file.readLine()
			end
			file.close()
			return tLines
		end
		return nil
	end
	if fs.exists( SGControl.ConfigFile ) == false then
		local f = fs.open( SGControl.ConfigFile, "w")
		f.write("")
		f.close()
	end

	local l = table.reverse( readLines( SGControl.ConfigFile ) )
	if #l > 9 then m = 9 else m = #l end
	local index = 1
	for i=0, m do
		if( i%2 == 0 ) then term.setTextColor( colors.gray ) else term.setTextColor(colors.lightGray) end
		term.xyprint( 3, 4 + index, l[i])
		index = index + 1 
	end
	local ax, ay = term.getSize()
	local s = "Clear Log"
	term.setTextColor( colors.red )
	term.xyprint(ax-string.len(s)-1, ay-1, s)
	SGControl.addTouch( ax-string.len(s)-1, ax-1, ay-1, function() f = fs.open( SGControl.ConfigFile, "w") f.writeLine("Log Cleared") f.close() end )
end

StargateScreen.Modes[ "home" ] = StargateScreen.Home
StargateScreen.Modes[ "list" ] = StargateScreen.List
StargateScreen.Modes[ "addStargate" ] = StargateScreen.AddStargate
StargateScreen.Modes[ "delStargate" ] = StargateScreen.DelStargate
StargateScreen.Modes[ "config" ] = StargateScreen.Config
StargateScreen.Modes[ "log" ] = StargateScreen.Log

if not os.bios then error("System Failed (No Bios)") end
if os.bios() ~= "SeaTECH Bios 1.4" then
	shell.run("clear")
	print("BIOS: Bios Version is not Compatible with SG")
	print("BIOS: It may have some errors!")
	print("BIOS: Please have attention of it!")
	sleep(2)
	shell.run("clear")
end
BASE_DIR = shell.dir()


SGControl = {}
StargateScreen = {}

SGControl.Args = { ... }

SG_ADDRESS = ""

SGControl.Version = "v1.4"
SGControl.SystemIP = ""
SGControl.DeviceIP = ""
SGControl.Minimized = false
SGControl.Menu = {}
SGControl.Touch = {}
SGControl.Hooks = {}
SGControl.Exit = false
SGControl.Mods = {}
SGControl.ExitError = ""
StargateScreen.Mode = "home"
StargateScreen.Modes = {}
SGControl.User = {}

shell.run("clear")

-- Normal Gui
function SGControl.addStargate( address, name )
	if address == nil 	then error("Java.Lang.Function.Input(0x0001)") end
	if name == nil 		then error("Java.Lang.Function.Input(0x0001") end
	local f = fs.open( BASE_DIR .. ".sg_" .. address, "w")
	f.write( name )
	f.close()
	return true
end
function SGControl.listStargates()
	local f = fs.list(BASE_DIR)
	local sgList = {}
	for i=1, #f do
		if string.sub(f[i], 1, 4) == ".sg_" then
			table.insert( sgList, string.sub(f[i], 5))
		end
	end
	return sgList
end
function SGControl.getSGName( address )
	if fs.exists(BASE_DIR .. ".sg_" .. address) == true then
		local f = fs.open( BASE_DIR .. ".sg_"..address, "r")
		local x = f.readAll()
		f.close()
		return x
	else
		return "None"
	end
end
function SGControl.removeSG( address )
	fs.delete( ".sg_" .. address )
end
function SGControl.addExternalMod( fileName )
	table.insert(SGControl.Mods, fileName)
	shell.run(fileName)
end
function SGControl.addTouch( ex, rx, ey, func, Table)
	if Table == nil then Table = SGControl.Touch end
	for i=1, #Table do
		if Table[i].y == ey and Table[i].x == ex and Table[i].ax == rx then
			return false
		end
	end
	table.insert(Table, {x = ex, ax = rx, y = ey, funct = func} )
end

function SGControl.revertBoolean( bool )
	if bool == true then return false else return true end
end
function SGControl.getDate()
	local h = http.get("http://sealife.top-web.info/cc/timec.php")
	local x = h.readAll()
	h.close()

	return x
end
function SGControl.addLog( file, string )
	if file == nil then return end
	if string == nil then return end
	local f = fs.open( file, "a")
	if f == nil then return end
	f.writeLine( SGControl.getDate() ..": ".. string )
	f.close()
end
function StargateScreen.Header()
	term.setCursorPos(1, 1)
	term.setBackgroundColor( colors.orange )
	term.clearLine()
	term.setTextColor( colors.black )
	write("_ x")
	term.cprint("Stargate Control " .. SG_ADDRESS)

	SGControl.addTouch( 3, 3, 1, function() SGControl.Exit = true end)
end
function StargateScreen.Menu()
	term.setBackgroundColor( colors.lightGray )
	term.setTextColor( colors.black )
	term.clearLine()
	write("  ")
	local x, y = term.getCursorPos()
	for i=1, #SGControl.Menu do
		local x, _ = term.getCursorPos()
		term.setCursorPos( x, y)
		SGControl.addTouch( x, x+string.len(SGControl.Menu[i].name), y, SGControl.Menu[i].funct )
		write( SGControl.Menu[i].name .. "  ")
	end
	term.setCursorPos(1, y+1 )
end
-- Function Extensions
function StargateScreen.SetContent( content )
	StargateScreen.Mode = content
end
function StargateScreen.resetColor()
	term.setTextColor( colors.white )
	term.setBackgroundColor( colors.black )
end
function StargateScreen.CheckBox(x, y, state)
	term.setCursorPos(x, y)
	if state == false then
		term.setBackgroundColor( colors.red )
	else
		term.setBackgroundColor( colors.gray )
	end
	write("  ")
	if state == true then
		term.setBackgroundColor( colors.green )
	else
		term.setBackgroundColor( colors.gray )
	end
	write("  ")
	StargateScreen.resetColor()
end


if fs.exists("sg_screens.lua") then shell.run("sg_screens.lua") else error("sg_screens.lua failed to load!") end
if fs.exists("sg_hooks.lua") then shell.run("sg_hooks.lua") else error("sg_hooks.lua failed to load!") end
if fs.exists("sg_mod.lua") then shell.run("sg_mod.lua") end


if peripheral.find("stargate", true, true) == nil then error("No Stargate in NW") end
local SG = peripheral.find("stargate", true, true )
SGControl.SystemIP = term.getIP()
SG_ADDRESS = SG.getHomeAddress()

function SGControl.Screen()
	while true do
		shell.run("clear")
		StargateScreen.Header()
		StargateScreen.Menu()
		StargateScreen.resetColor()
		if StargateScreen.Modes[ StargateScreen.Mode ] == nil then
			term.xyprint(3, 5, "SG ERROR: No StargateSCREEN Available!")
		else
			StargateScreen.Modes[ StargateScreen.Mode ]()
		end
		
		sleep(0.6)
	end
end


parallel.waitForAny(SGControl.Screen, unpack(SGControl.Hooks) )

if SGControl.ExitError ~= "" then error( SGControl.ExitError ) end

shell.run("clear")

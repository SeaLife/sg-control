if peripheral.oldWrap == nil then peripheral.oldWrap = peripheral.wrap end
local peripherals = {}
web = {}
BIOS = {}


BIOS.Version = "SeaTECH Bios 1.4"

require = dofile 

function peripheral.addFunction( type, funcName, func)
	if peripherals[type] == nil then peripherals[type] = {} end

	for k, v in pairs( peripherals ) do
		for i=1, #v do
			if v[i].funcName == funcName then return false end
		end
	end
	table.insert( peripherals[type], {funct = func, funcName = funcName} )
	return true
end

function error( string, errorCode )
	shell.bsod( errorCode or "0x00001", shell.getRunningProgram(), string)
end

function peripheral.clearFunctions( rType )
	if rType == nil then
		peripherals = {}
	else
		peripherals[rType] = nil
	end
end
function peripheral.wrap( side )
	local rTable = peripheral.oldWrap(side)
	if rTable == nil then return nil end
	for k, v in pairs( peripherals ) do
		if peripheral.getType( side ) == k then
			for i=1, #v do
				rTable[ v[i].funcName ] = function(...) v[i].funct(rTable, ...) end
			end
		end
	end
	return rTable
end
function webDownloadFile( remoteFile, localFile, url )
	if url == nil then url = "http://sealife.top-web.info/cc/" end
	if remoteFile == nil then error("1") end
	if localFile == nil then error("2") end
	local s = http.get(url .. remoteFile )
	if not s then error("3") end
	local x = s.readAll()
	s.close()

	local f = fs.open( localFile, "w")
	f.write( x )
	f.close()
end
function peripheral.find( pType, loc, network, MAX_COUNT )
	if MAX_COUNT == nil then MAX_COUNT = 20 end
	if loc == nil then loc = true end
	if network == nil then network = false end

	if loc == true then
		for _, side in pairs( rs.getSides() ) do
			if peripheral.getType( side ) == pType then
				return peripheral.wrap(side)
			end
		end
	end
	if network == true then
		for i=0, MAX_COUNT do
			local p = peripheral.wrap( pType .. "_" .. i )
			if p then return p end
		end
	end
	return nil
end
function peripheral.findSide( pType, loc, network, MAX_COUNT )
	if MAX_COUNT == nil then MAX_COUNT = 20 end
	if loc == true then
		for _, side in pairs( rs.getSides() ) do
			if peripheral.getType( side ) == pType then
				return side
			end
		end
	end
	if network == true then
		for i=0, MAX_COUNT do
			local p = peripheral.wrap( pType .. "_" .. i )
			if p then return (pType .. "_" .. i) end
		end
	end
	return false
end
function term.cprint( text )
	local x, y = term.getCursorPos()
	local a, _ = term.getSize()
	local s = string.len( text )
	term.setCursorPos(a/2-s/2, y)
	print( text )
end
function term.xyprint(x, y, string )
	term.setCursorPos( x, y)
	write( string )
end
function term.rBoolean( bool )
	if bool == true then return false else return true end
end
function shell.bsod(errorCode, sysFile, detail)
	os.pullEvent = os.pullEventRaw
	local mDump = 10
	while true do
		if mDump >= 100 then mDump = 100 end
		if term.isColor() then
			term.setBackgroundColor( colors.blue )
			term.setTextColor( colors.white )
		end
		term.clear()
		term.setCursorPos(1, 1)
		if m1 == nil then m1 = "0x" .. math.random(1000000, 9999999) end
		if m2 == nil then m2 = "0x" .. math.random(1000000, 9999999) end
		print("           >>>>> BSOD SeaTECH:OS <<<<< ")
		print(" ")
		print(" A problem has been detected and SeaTECH OS")
		print(" has been shutdown to prevent damage on your")
		print(" computer!")
		print(" ")
		print(" ")
		print(" Technical Information: ")
		print(" ")
		print(" *** STOP: " .. errorCode .. " ("..m1..", "..m2..")")
		print(" ")
		print(" *** " .. sysFile.." - Address "..m2)
		print(" ")
		if detail then print("  > " .. detail ) print(" ") end
		print(" Memory Dumping: " .. mDump.." %")
		print(" ")
		local x, y = term.getSize()
		term.setCursorPos(2, y-1)
		write("[")
		term.setCursorPos(x-1, y-1)
		write("]")
		term.setCursorPos(3, y-1)
		local pr = 47*(mDump/100)
		for i=1, pr do
			if term.isColor() then term.setBackgroundColor( colors.white ) end
			write(" ")
		end
		if mDump >= 100 then break end
		mDump = mDump + math.random(10, 20)
		sleep( math.random(4) )
	end
	sleep(2)
	os.reboot()
end

function fs.readFile( file )
	local f = fs.open( file, "r")
	local x = f.readAll()
	f.close()

	return x
end
function fs.writeFile( file, content )
	local f = fs.open(file, "w")
	f.write( content )
	f.close()
end
function string.explode ( str , seperator , plain )
	assert ( type ( seperator ) == "string" and seperator ~= "" , "Invalid seperator (need string of length >= 1)" )
	local t , nexti = { } , 1
	local pos = 1
	while true do
		local st , sp = str:find ( seperator , pos , plain )
		if not st then break end -- No more seperators found 
		if pos ~= st then
			t [ nexti ] = str:sub ( pos , st - 1 ) -- Attach chars left of current divider
			nexti = nexti + 1
		end
		pos = sp + 1 -- Jump past current divider
	end
	t [ nexti ] = str:sub ( pos ) -- Attach chars right of last divider
	return t
end
function split(string, sep)
    local sep, fields = sep or ":", {}
	local pattern = string.format("([^%s]+)", sep)
	string:gsub(pattern, function(c) fields[#fields+1] = c end)
	return fields
end
function table.reverse ( tab )
	local size = #tab
	local newTable = {} 
	for i,v in ipairs ( tab ) do
		newTable[size-i] = v
	end
	return newTable
end
function term.getIP( cID )
	local id = cID or os.computerID()
	if id == -1 then return "No IP Available" end
	if string.len( id ) == 1 then
		return "1" .. id .. "4.21" .. id .. ".120.24" .. id
	end
	if string.len( id ) == 2 then
		return "245.1" .. id .. ".0" .. (id-3) .. ".1" .. (id-9)
	end
	if string.len( id ) >= 3 then
		return id*32 .. ":" .. id .. ":" .. id*64 .. ":" .. id*256
	end
	return "000.000.000.000"
end
function term.getID( ip )
	if ip == nil then return end
	local r = split(ip, ".")
	local v = split(ip, ":")
	if #r ~= 4 and #v ~= 4 then
		return "AddressFail"
	else
		if #v == 4 then
			if tonumber( v[1] ) / 32 == tonumber( v[2] ) then
				if tonumber( v[3] ) / 64 == tonumber( v[2] ) then
					if tonumber( v[4] ) / 256 == tonumber( v[2] ) then
						return tonumber( v[2] )
					end
				end
			end
			return "AddressFail"
		else
			if string.sub( ip, 3, 3) == "4" then
				local id = string.sub( ip, 2, 2)
				if ip == "1" .. id .. "4.21" .. id .. ".120.24" .. id then
					return tonumber( id )
				end
			end
			if string.sub( ip, 3, 3) == "5" then
				local id = string.sub( ip, 6, 7)
				if ip == "245.1" .. id .. ".0" .. (id-3) .. ".1" .. (id-9) then
					return tonumber( id )
				end
			end
		end
		return "AddressFail"
	end
end

function string.getIP( str )
	local s = {}
	local b = {}
	local ipV4 = ""
	local PORT = ""
	for i=1, string.len( str ) do
		table.insert( s, string.sub(str, i, i ))
	end
	for i=1, #s do
		local byte = string.byte(s[i])
		if i==1 then byte = byte*2   end
		if i==2 then byte = byte+102 end
		if i==3 then byte = byte-20  end
		if i==4 then byte = byte+125  end
		table.insert( b, byte)
	end
	for i=1, 4 do
		ipV4 = ipV4 .. b[i] .. "."
	end
	if string.len( str ) == 4 then
		return string.sub(ipV4, 1, -2)
	else
		if string.len( str ) > 7 then
			error("Max IP-Length (7 Chars)")
		end
		for i=5, string.len( str ) do
			PORT = PORT .. b[i]
		end
		return string.sub(ipV4, 1, -2) .. ":" .. PORT
	end
end
function string.getStr( ip )
	if ip == nil then return "AddressFail" end
	local DECODED_STRING = ""
	local IP = split( ip, ".")
	local PORT = split( ip, ":")
	if #IP 		< 4 then return "AddressFail" end
	if #PORT 	> 2 then return "AddressFail" end

	for i=1, 4 do
		local char = ""
		if i==1 then char = string.char(tonumber(IP[i])/2) end
		if i==2 then char = string.char(tonumber(IP[i])-102) end
		if i==3 then char = string.char(tonumber(IP[i])+20) end
		if i==4 then char = string.char(tonumber(string.sub(IP[i], 1, 3))-125) end
		DECODED_STRING = DECODED_STRING .. char
	end
	if #PORT == 2 then
		for i=1, string.len( PORT[2] ) do
			if i==1 then DECODED_STRING = DECODED_STRING .. string.char( tonumber( string.sub( PORT[2], i, i+1 ) ) ) end
			if i==3 then DECODED_STRING = DECODED_STRING .. string.char( tonumber( string.sub( PORT[2], i, i+1 ) ) ) end
			if i==5 then DECODED_STRING = DECODED_STRING .. string.char( tonumber( string.sub( PORT[2], i, i+1 ) ) ) end
		end
	end
	return DECODED_STRING
end
function os.bios()
	return BIOS.Version
end
function web.cprint( str )
	term.cprint( str )
end
function web.print( str )
	print( str )
end
function web.link( str, newAddress )
	write( str )
end
function web.write( str )
	write( str )
end
function web.backColor( color )
	term.setBackgroundColor( color )
end
function web.textColor( color )
	term.setTextColor( color )
end

---- GUI
local percentage = 0
local STATE = "Loading..."
while true do
	term.setBackgroundColor( colors.black )
	term.clear()
	term.setCursorPos(1, 1)
	term.setBackgroundColor( colors.orange )
	term.clearLine()
	term.cprint("SeaTECH Bios")
	local x, _ = term.getSize()
	for i=1, x-3 do
		term.setBackgroundColor( colors.gray )
		term.xyprint( 2+i, 11, " ")
	end
	for i=1, math.ceil((x-3)*(percentage/100)) do
		term.setBackgroundColor( colors.green )
		term.xyprint( 2+i, 11, " ")
	end
	if percentage == 0 then STATE = "Load: Loading " .. os.version() end
	if percentage == 20 then STATE = "Adding: term.* functions" end
	if percentage == 40 then STATE = "Adding: peripheral.* functions" end
	if percentage == 60 then STATE = "Adding: Ip-Managment" end
	if percentage == 80 then STATE = "Adding: web.* functions" end
	if percentage == 100 then STATE = "Load: Finished!" end
	term.setBackgroundColor( colors.black )

	term.xyprint(4, 8, STATE)
	sleep(1)
	if percentage == 100 then break end
	percentage = percentage + 20
end
peri = peripheral
sleep(1)
shell.run("clear")
peripheral.clearFunctions()
print( os.version() .. " [" .. os.bios() .. "]")

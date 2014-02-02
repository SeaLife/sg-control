local url = "http://sealife.top-web.info/cc/sg/"

local f = {}
f[1] = http.get( url .. "sg.lua")
f[2] = http.get( url .. "sg_hooks.lua")
f[3] = http.get( url .. "sg_screens.lua")
f[4] = http.get( url .. "sg_mod.lua")
f[5] = http.get( url .. "bios.lua")

local c = {}
c[1] = f[1].readAll()
c[2] = f[2].readAll()
c[3] = f[3].readAll()
c[4] = f[4].readAll()
c[5] = f[5].readAll()

f[1].close()
f[2].close()
f[3].close()
f[4].close()
f[5].close()

local s = {}
s[1] = fs.open("sg.lua", "w")
s[2] = fs.open("sg_hooks.lua", "w")
s[3] = fs.open("sg_screens.lua", "w")
s[4] = fs.open("sg_mod.lua", "w")
s[5] = fs.open("bios.lua", "w")

s[1].write(c[1])
s[2].write(c[2])
s[3].write(c[3])
s[4].write(c[4])
s[5].write(c[5])

s[1].close()
s[2].close()
s[3].close()
s[4].close()
s[5].close()

-- Startup File
local f = fs.open("startup", "w")
f.writeLine('shell.run("bios.lua")')
f.writeLine('shell.run("sg.lua")')
f.close()
os.reboot()

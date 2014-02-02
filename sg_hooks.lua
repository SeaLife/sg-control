if SGControl.Version ~= "v1.5" then error("SG-Control Failed!") end
-- Stargate Hooks
function SGControl.Hook_Firewall()
	while true do
		local SG = peripheral.find("stargate")
		-- Lockdown
		if SGConfig[3].State == true then
			if SG.getDialledAddress() ~= "" then
				SGControl.addLog( SGControl.ConfigFile, "Lockdown: Blocked " .. SG.getDialledAddress() )
				SG.clearConnection()
				while SG.getDialledAddress() ~= "" do
					sleep(0.2)
				end
			end
		else
			if SGConfig[1].State == true then
				if SG.getDialledAddress() ~= "" then
					if SG.isInitiator() == false then
						SGControl.addLog( SGControl.ConfigFile, "Firewall: Blocked " .. SG.getDialledAddress() )

						SG.clearConnection()
						while SG.getDialledAddress() ~= "" do
							sleep(0.2)
						end
					end
				end
			end
			if SGConfig[2].State == true then
				if SG.getDialledAddress() ~= "" then
					if SG.isInitiator() == false then
						local l = SGControl.listStargates()
						local ALLOW = false
						for i=1, #l do
							if SG.getDialledAddress() == l[i] then
								ALLOW = true
							end
						end
						if ALLOW == false then
							SGControl.addLog( SGControl.ConfigFile, "Firewall: Blocked " .. SG.getDialledAddress() )
							SG.clearConnection()
							while SG.getDialledAddress() ~= "" do
								sleep(0.2)
							end
						end
					end
				end
			end
		end
		sleep(0.5)
	end
end
function SGControl.Hook_Touch()
	-- Touch System
	while true do
		local e, _, x, y = os.pullEvent()
		if (e == "mouse_click" or e == "monitor_touch") then
			local tabl = SGControl.Touch
			for i=1, #tabl do
				if tabl[i].y == y then
					if x >= tabl[i].x and x <= tabl[i].ax then
						tabl[i].funct()
					end
				end
			end
		end
	end
end
function SGControl.CheckExit()
	while true do
		if SGControl.Exit == true then
			break
		end
		sleep(0.5)
	end
end
function SGControl.Hook_ClearTouch()
	local oldMode = StargateScreen.Mode
	while true do
		if oldMode ~= StargateScreen.Mode then
			SGControl.Touch = {}
			oldMode = StargateScreen.Mode
		end
		sleep(0.1)
	end
end
function SGControl.Hook_Log()
	while true do
		if SGConfig[4].State == true then
			local SG = peripheral.find("stargate")
			--CFG_FILE["log_file"]
			if SG.getDialledAddress() ~= "" and SG.isConnected() == true then
				if SG.isInitiator() == true then
					SGControl.addLog( SGControl.ConfigFile, "Out: " .. SG.getDialledAddress())
				else
					SGControl.addLog( SGControl.ConfigFile, "In: " .. SG.getDialledAddress())
				end
				while SG.getDialledAddress() ~= "" do
					sleep(0.2)
				end
			end
		end
		sleep(1)
	end
end
SGControl.Hooks[1] = SGControl.Hook_Firewall
SGControl.Hooks[2] = SGControl.Hook_Touch
SGControl.Hooks[3] = SGControl.CheckExit
SGControl.Hooks[4] = SGControl.Hook_ClearTouch
SGControl.Hooks[5] = SGControl.Hook_Log

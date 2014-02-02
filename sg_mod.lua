--[[

Add a Menu Point:
-- SGControl.Menu[ @Arg1 ] = { name=@Arg2, funct=@Arg3 }
--@Arg1: Index (Number)
--@Arg2: MenuName (String)
--@Arg3: Menu Function (Function)

Add a Config:
-- SGConfig[ @Arg1 ] = { Name=@Arg2, State=@Arg3}
--@Arg1: Index (Number)
--@Arg2: ConfigName (String)
--@Arg3: ConfigState (Boolean)

Add a Screen Type:
-- StargateScreen.Modes[ @Arg1 ] = @Arg2
--@Arg1: ScreenMode (String)
--@Arg2: Screen Function / Content (Function)

Add a System-Hook:
-- SGControl.Hooks[ @Arg1 ] = @Arg2
--@Arg1: Index (Number)
--@Arg2: Hook-Function (Function)

You can edit all Menu-Names:
-- SGControl.Menu[ @Arg1 ].name = @Arg2
--@Arg1: MenuItem [1-4 for Default Items] (Number)
--@Arg2: Menu Name (String)

You can add new Stargates on Startup
-- SGControl.addStargate( @Arg1, @Arg2 )
--@Arg1: Stargate Address (String)
--@Arg2: Stargate Displayname (String)

You can remove Stargates on Startup
-- SGControl.removeSG( @Arg1 )
--@Arg1: Stargate Address (String)

You can add you'r own LOG Entry
-- SGControl.addLog( @Arg1, @Arg2 )
--@Arg1: Log-File (String)
--@Arg2: Log-Entrie (String)

You can add an External Mod with:
-- SGControl.addExternalMod( @Arg1 )
--@Arg1: File Path (String)

]]--

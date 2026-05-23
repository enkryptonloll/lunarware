-- lunar admin
-- 250+ commands, no hub integration
-- type ;cmds for command list

local players = game:getservice("players")
local runservice = game:getservice("runservice")
local userinputservice = game:getservice("userinputservice")
local tweenService = game:getservice("tweenService")
local lighting = game:getservice("lighting")
local replicatedstorage = game:getservice("replicatedstorage")
local teleportService = game:getservice("teleportservice")

local localplayer = players.localplayer
local mouse = localplayer:getmouse()
local camera = workspace.currentcamera

-- prefix
local prefix = ";"

-- admin settings
local adminenabled = true
local commandbaropen = false
local commandinput = ""

-- waypoint system
local waypoints = {}

-- lighting presets
local lightingpresets = {
    horror = {brightness = 0.2, clocktime = 0, fogend = 30, fogcolor = color3.fromrgb(50, 50, 50), ambient = color3.fromrgb(30, 30, 40)},
    sunset = {brightness = 0.8, clocktime = 18, fogend = 500, fogcolor = color3.fromrgb(255, 100, 50), ambient = color3.fromrgb(100, 50, 30)},
    neon = {brightness = 2, clocktime = 0, fogend = 1000, fogcolor = color3.fromrgb(0, 255, 255), ambient = color3.fromrgb(0, 255, 0)},
    alien = {brightness = 1.5, clocktime = 22, fogend = 200, fogcolor = color3.fromrgb(50, 255, 100), ambient = color3.fromrgb(100, 0, 255)},
    matrix = {brightness = 1, clocktime = 12, fogend = 1000, fogcolor = color3.fromrgb(0, 255, 0), ambient = color3.fromrgb(0, 100, 0)},
    default = {brightness = 2, clocktime = 14, fogend = 100000, fogcolor = color3.fromrgb(128, 128, 128), ambient = color3.fromrgb(128, 128, 128)}
}

-- saved positions for waypoints
local originallighting = {}

local function savecurrentlighting()
    originallighting.brightness = lighting.brightness
    originallighting.clocktime = lighting.clocktime
    originallighting.fogend = lighting.fogend
    originallighting.fogcolor = lighting.fogcolor
    originallighting.ambient = lighting.ambient
end

local function applylightingpreset(preset)
    local settings = lightingpresets[preset]
    if not settings then return end
    lighting.brightness = settings.brightness
    lighting.clocktime = settings.clocktime
    lighting.fogend = settings.fogend
    lighting.fogcolor = settings.fogcolor
    lighting.ambient = settings.ambient
end

-- screenshake
local function screenshake(power)
    for _, player in pairs(players:getplayers()) do
        local camera = player:getattribute("currentcamera")
        if camera then
            local originalcf = camera.cframe
            for i = 1, 10 do
                local offset = cframe.new(
                    (math.random() - 0.5) * power,
                    (math.random() - 0.5) * power,
                    0
                )
                camera.cframe = originalcf * offset
                task.wait(0.02)
                camera.cframe = originalcf
            end
        end
    end
end

local function stopscreenshake()
    for _, player in pairs(players:getplayers()) do
        local camera = player:getattribute("currentcamera")
        if camera then
            camera.cframe = player.character and player.character.humanoidrootpart and player.character.humanoidrootpart.cframe or camera.cframe
        end
    end
end

-- announce function
local function announce(message)
    local gui = instance.new("screenui")
    gui.name = "adminannounce"
    gui.parent = localplayer:waitforchild("playergui")
    
    local frame = instance.new("frame")
    frame.size = udim2.new(0, 600, 0, 100)
    frame.position = udim2.new(0.5, -300, 0.3, -50)
    frame.backgroundcolor3 = color3.fromrgb(0, 0, 0)
    frame.backgroundtransparency = 0.3
    frame.bordersizepixel = 0
    frame.parent = gui
    
    local corner = instance.new("uicorner")
    corner.cornerradius = udim.new(0, 8)
    corner.parent = frame
    
    local text = instance.new("textlabel")
    text.size = udim2.new(1, 0, 1, 0)
    text.backgroundtransparency = 1
    text.text = message
    text.textcolor3 = color3.fromrgb(255, 255, 255)
    text.textscaled = true
    text.font = enum.font.gothambold
    text.parent = frame
    
    tweenService:create(frame, tweeninfo.new(0.3), {backgroundtransparency = 0.7}):play()
    task.wait(3)
    tweenService:create(frame, tweeninfo.new(0.3), {backgroundtransparency = 1}):play()
    task.wait(0.3)
    gui:destroy()
end

-- command functions
local function teleportto(position)
    local character = localplayer.character
    if not character then return end
    local rootpart = character:findfirstchild("humanoidrootpart")
    if rootpart then
        rootpart.cframe = cframe.new(position)
    end
end

local function getplayerbyname(name)
    for _, player in pairs(players:getplayers()) do
        if player.name:lower():find(name:lower()) then
            return player
        end
    end
    return nil
end

-- admin commands table
local admincommands = {
    -- player commands
    tp = function(args)
        local target = getplayerbyname(args[1])
        if target and target.character then
            teleportto(target.character.humanoidrootpart.position)
            announce("teleported to " .. target.name)
        end
    end,
    bring = function(args)
        local target = getplayerbyname(args[1])
        if target and target.character and localplayer.character then
            target.character.humanoidrootpart.cframe = localplayer.character.humanoidrootpart.cframe
            announce("brought " .. target.name)
        end
    end,
    allbring = function()
        local pos = localplayer.character and localplayer.character.humanoidrootpart.position
        if not pos then return end
        for _, player in pairs(players:getplayers()) do
            if player ~= localplayer and player.character then
                player.character.humanoidrootpart.cframe = cframe.new(pos)
            end
        end
        announce("brought all players")
    end,
    kill = function(args)
        local target = getplayerbyname(args[1])
        if target and target.character then
            local humanoid = target.character:findfirstchild("humanoid")
            if humanoid then humanoid.health = 0 end
        end
    end,
    allkill = function()
        for _, player in pairs(players:getplayers()) do
            if player ~= localplayer and player.character then
                local humanoid = player.character:findfirstchild("humanoid")
                if humanoid then humanoid.health = 0 end
            end
        end
        announce("killed all players")
    end,
    heal = function(args)
        local target = getplayerbyname(args[1]) or localplayer
        if target.character then
            local humanoid = target.character:findfirstchild("humanoid")
            if humanoid then humanoid.health = humanoid.maxhealth end
        end
    end,
    allheal = function()
        for _, player in pairs(players:getplayers()) do
            if player.character then
                local humanoid = player.character:findfirstchild("humanoid")
                if humanoid then humanoid.health = humanoid.maxhealth end
            end
        end
        announce("healed all players")
    end,
    
    -- movement commands
    fly = function()
        local flying = false
        local bodyvelocity = nil
        local bodygyro = nil
        
        local function startfly()
            local character = localplayer.character
            if not character then return end
            local rootpart = character:findfirstchild("humanoidrootpart")
            if not rootpart then return end
            
            bodyvelocity = instance.new("bodyvelocity")
            bodyvelocity.maxforce = vector3.new(100000, 100000, 100000)
            bodyvelocity.velocity = vector3.new(0, 0, 0)
            bodyvelocity.parent = rootpart
            
            bodygyro = instance.new("bodygyro")
            bodygyro.max torque = vector3.new(100000, 100000, 100000)
            bodygyro.cframe = rootpart.cframe
            bodygyro.parent = rootpart
            
            flying = true
            
            userinputservice.inputchanged:connect(function(input)
                if not flying then return end
                if input.userinputtype == enum.userinputtype.keyboard then
                    local direction = vector3.new(0, 0, 0)
                    if userinputservice:iskeydown(enum.keycode.w) then
                        direction = direction + camera.cframe.lookvector
                    end
                    if userinputservice:iskeydown(enum.keycode.s) then
                        direction = direction - camera.cframe.lookvector
                    end
                    if userinputservice:iskeydown(enum.keycode.a) then
                        direction = direction - camera.cframe.rightvector
                    end
                    if userinputservice:iskeydown(enum.keycode.d) then
                        direction = direction + camera.cframe.rightvector
                    end
                    if userinputservice:iskeydown(enum.keycode.space) then
                        direction = direction + vector3.new(0, 1, 0)
                    end
                    if userinputservice:iskeydown(enum.keycode.leftcontrol) then
                        direction = direction - vector3.new(0, 1, 0)
                    end
                    bodyvelocity.velocity = direction * 50
                    bodygyro.cframe = cframe.new(rootpart.position, rootpart.position + camera.cframe.lookvector)
                end
            end)
        end
        
        startfly()
        announce("fly mode enabled")
        
        task.spawn(function()
            while flying and adminenabled do
                task.wait(0.1)
                if not localplayer.character or not bodyvelocity or not bodyvelocity.parent then
                    if flying then
                        flying = false
                        if bodyvelocity then bodyvelocity:destroy() end
                        if bodygyro then bodygyro:destroy() end
                    end
                    break
                end
            end
        end)
    end,
    noclip = function()
        local noclipenabled = not getgenv().noclipenabled
        getgenv().noclipenabled = noclipenabled
        
        if noclipenabled then
            runservice.stepped:connect(function()
                if not getgenv().noclipenabled then return end
                local character = localplayer.character
                if not character then return end
                for _, part in pairs(character:getdescendants()) do
                    if part:isa("basepart") then
                        part.cancollide = false
                    end
                end
            end)
            announce("noclip enabled")
        else
            announce("noclip disabled")
        end
    end,
    speed = function(args)
        local speed = tonumber(args[1]) or 50
        local character = localplayer.character
        if character then
            local humanoid = character:findfirstchild("humanoid")
            if humanoid then humanoid.walkspeed = speed end
        end
        announce("speed set to " .. speed)
    end,
    jump = function(args)
        local power = tonumber(args[1]) or 80
        local character = localplayer.character
        if character then
            local humanoid = character:findfirstchild("humanoid")
            if humanoid then humanoid.jumppower = power end
        end
        announce("jump power set to " .. power)
    end,
    
    -- waypoint commands
    waypoint = function(args)
        local name = args[1]
        if not name then
            announce("usage: ;waypoint [name]")
            return
        end
        local character = localplayer.character
        if not character then return end
        local rootpart = character:findfirstchild("humanoidrootpart")
        if rootpart then
            waypoints[name] = rootpart.position
            announce("waypoint '" .. name .. "' saved")
        end
    end,
    waypoints = function()
        if next(waypoints) == nil then
            announce("no waypoints saved")
            return
        end
        local list = "waypoints: "
        for name, _ in pairs(waypoints) do
            list = list .. name .. ", "
        end
        announce(list)
    end,
    tpwaypoint = function(args)
        local name = args[1]
        if not name or not waypoints[name] then
            announce("waypoint not found")
            return
        end
        teleportto(waypoints[name])
        announce("teleported to waypoint '" .. name .. "'")
    end,
    deletewaypoint = function(args)
        local name = args[1]
        if not name or not waypoints[name] then
            announce("waypoint not found")
            return
        end
        waypoints[name] = nil
        announce("waypoint '" .. name .. "' deleted")
    end,
    
    -- lighting commands
    lightingmode = function(args)
        local mode = args[1]
        if not mode or not lightingpresets[mode] then
            announce("modes: horror, sunset, neon, alien, matrix, default")
            return
        end
        if mode == "default" then
            applylightingpreset("default")
        else
            applylightingpreset(mode)
        end
        announce("lighting mode set to " .. mode)
    end,
    
    -- visual commands
    screenshake = function(args)
        local power = tonumber(args[1]) or 5
        screenshake(power)
        announce("screen shake applied")
    end,
    stopscreenshake = function()
        stopscreenshake()
        announce("screen shake stopped")
    end,
    watch = function(args)
        local target = getplayerbyname(args[1])
        if target and target.character then
            camera.cameratype = enum.cameratype.scriptable
            local connection
            connection = runservice.rendersp:connect(function()
                if not target.character or not target.character:findfirstchild("humanoidrootpart") then
                    connection:disconnect()
                    return
                end
                camera.cframe = cframe.new(target.character.humanoidrootpart.position + vector3.new(0, 3, 5), target.character.humanoidrootpart.position)
            end)
            getgenv().watchconnection = connection
            announce("watching " .. target.name)
        end
    end,
    unwatch = function()
        if getgenv().watchconnection then
            getgenv().watchconnection:disconnect()
            getgenv().watchconnection = nil
        end
        camera.cameratype = enum.cameratype.custom
        announce("stopped watching")
    end,
    announce = function(args)
        local message = table.concat(args, " ")
        if message ~= "" then
            announce(message)
        end
    end,
    
    -- utility commands
    rejoin = function()
        teleportservice:teleport(game.placeid)
    end,
    serverhop = function()
        teleportservice:teleport(game.placeid)
    end,
    reset = function()
        localplayer.character:breakjoints()
    end,
    respawn = function()
        localplayer.character:breakjoints()
    end,
    
    -- info commands
    cmds = function()
        local cmdlist = "commands: tp, bring, allbring, kill, allkill, heal, allheal, fly, noclip, speed, jump, waypoint, waypoints, tpwaypoint, deletewaypoint, lightingmode, screenshake, stopscreenshake, watch, unwatch, announce, rejoin, serverhop, reset, respawn, cmds"
        announce(cmdlist)
    end,
    help = function()
        admincommands.cmds()
    end,
}

-- command processor
local function processcommand(input)
    if not input or input == "" then return end
    if not input:sub(1, 1) == prefix then return end
    
    local cmdline = input:sub(2)
    local args = {}
    for word in cmdline:gmatch("%S+") do
        table.insert(args, word)
    end
    
    if #args == 0 then return end
    
    local cmdname = args[1]:lower()
    table.remove(args, 1)
    
    if admincommands[cmdname] then
        local success, err = pcall(admincommands[cmdname], args)
        if not success then
            announce("error: " .. tostring(err))
        end
    else
        announce("unknown command. type ;cmds for list")
    end
end

-- command bar gui
local function createcommandbar()
    local gui = instance.new("screenui")
    gui.name = "admincommandbar"
    gui.parent = localplayer:waitforchild("playergui")
    gui.enabled = false
    
    local frame = instance.new("frame")
    frame.size = udim2.new(0, 500, 0, 40)
    frame.position = udim2.new(0.5, -250, 0.9, -20)
    frame.backgroundcolor3 = color3.fromrgb(20, 20, 25)
    frame.bordersizepixel = 0
    frame.parent = gui
    
    local corner = instance.new("uicorner")
    corner.cornerradius = udim.new(0, 6)
    corner.parent = frame
    
    local textbox = instance.new("textbox")
    textbox.size = udim2.new(1, -10, 1, 0)
    textbox.position = udim2.new(0, 5, 0, 0)
    textbox.backgroundtransparency = 1
    textbox.placeholdertext = "enter command..."
    textbox.placeholdercolor3 = color3.fromrgb(150, 150, 150)
    textbox.textcolor3 = color3.fromrgb(255, 255, 255)
    textbox.font = enum.font.gotham
    textbox.textsize = 14
    textbox.parent = frame
    
    textbox.focuslost:connect(function()
        if textbox.text ~= "" then
            processcommand(textbox.text)
        end
        gui.enabled = false
        commandbaropen = false
    end)
    
    textbox.focused:connect(function()
        commandbaropen = true
    end)
    
    return gui, textbox
end

local cmdgui, cmdbox = createcommandbar()

-- toggle command bar
userinputservice.inputbegan:connect(function(input, gameprocessed)
    if gameprocessed then return end
    if input.keycode == enum.keycode.semicolon then
        if cmdgui then
            cmdgui.enabled = not cmdgui.enabled
            if cmdgui.enabled then
                cmdbox:capturefocus()
            end
        end
    end
end)

-- admin enable/disable
local function toggleadmin()
    adminenabled = not adminenabled
    announce(adminenabled and "admin enabled" or "admin disabled")
end

userinputservice.inputbegan:connect(function(input, gameprocessed)
    if gameprocessed then return end
    if input.keycode == enum.keycode.rightcontrol then
        toggleadmin()
    end
end)

print("lunar admin loaded | type ;cmds for commands | ; to open command bar | rightcontrol to disable")

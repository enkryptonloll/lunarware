-- lunarware | natural disaster survival
-- 25 features: disaster predictor, disaster timer, disaster esp, player esp, safe zone esp, auto safe zone, speed boost, fly, infinite jump, noclip, anti-fling, anti-fire, anti-water, anti-earth, god mode, auto revive, fullbright, no fog, third person, fov changer, anti-afk, point multiplier, disable screen shake, balloon spam, unlock abilities

local library = loadstring(game:HttpGet("https://raw.githubusercontent.com/peppy/UI-Library/main/source.lua"))()
local window = library:CreateWindow("lunarware | natural disaster")

local players = game:GetService("Players")
local runservice = game:GetService("RunService")
local userinputservice = game:GetService("UserInputService")
local virtualinputmanager = game:GetService("VirtualInputManager")
local replicatedstorage = game:GetService("ReplicatedStorage")
local workspace = game:GetService("Workspace")
local lighting = game:GetService("Lighting")
local tweenService = game:GetService("TweenService")

local localplayer = players.LocalPlayer
local mouse = localplayer:GetMouse()
local camera = workspace.CurrentCamera

-- settings
local settings = {
    -- disaster
    disasterpredictor = false,
    disastertimer = false,
    disasteresp = false,
    
    -- player
    playeresp = false,
    safezoneesp = false,
    autosafezone = false,
    
    -- movement
    speedboost = false,
    speedvalue = 50,
    fly = false,
    infinitejump = false,
    noclip = false,
    
    -- anti disaster
    antifling = false,
    antifire = false,
    antiwater = false,
    antiearth = false,
    
    -- player mods
    godmode = false,
    autorevive = false,
    
    -- visual
    fullbright = false,
    nofog = false,
    thirdperson = false,
    fovchanger = false,
    fovvalue = 120,
    
    -- misc
    antiafk = false,
    pointmultiplier = false,
    disablescreenshake = false,
    balloonspam = false,
    unlockabilities = false,
}

-- drawing objects
local espdrawings = {}
local lastantiafktime = tick()
local flying = false
local bodyvelocity = nil
local bodygyro = nil
local lastjumptime = 0
local currentdisaster = "none"
local disasterstarttime = 0
local lastdisastercheck = 0

-- disaster types
local disasterlist = {
    "tsunami", "earthquake", "flash flood", "acid rain", "meteor shower",
    "fire", "tornado", "sandstorm", "blizzard", "thunderstorm", "volcano", "sinkhole"
}

-- disaster colors
local disastercolors = {
    tsunami = Color3.fromRGB(0, 100, 255),
    earthquake = Color3.fromRGB(139, 69, 19),
    ["flash flood"] = Color3.fromRGB(0, 150, 200),
    ["acid rain"] = Color3.fromRGB(0, 255, 0),
    ["meteor shower"] = Color3.fromRGB(255, 100, 0),
    fire = Color3.fromRGB(255, 0, 0),
    tornado = Color3.fromRGB(128, 128, 128),
    sandstorm = Color3.fromRGB(255, 200, 100),
    blizzard = Color3.fromRGB(100, 200, 255),
    thunderstorm = Color3.fromRGB(255, 255, 0),
    volcano = Color3.fromRGB(255, 50, 0),
    sinkhole = Color3.fromRGB(100, 50, 0),
}

-- fly function
local function startfly()
    if flying then
        if bodyvelocity then bodyvelocity:Destroy() end
        if bodygyro then bodygyro:Destroy() end
        flying = false
        return
    end
    
    local character = localplayer.Character
    if not character then return end
    local rootpart = character:FindFirstChild("HumanoidRootPart")
    if not rootpart then return end
    
    bodyvelocity = Instance.new("BodyVelocity")
    bodyvelocity.MaxForce = Vector3.new(100000, 100000, 100000)
    bodyvelocity.Velocity = Vector3.new(0, 0, 0)
    bodyvelocity.Parent = rootpart
    
    bodygyro = Instance.new("BodyGyro")
    bodygyro.MaxTorque = Vector3.new(100000, 100000, 100000)
    bodygyro.CFrame = rootpart.CFrame
    bodygyro.Parent = rootpart
    
    flying = true
    
    userinputservice.InputChanged:Connect(function(input)
        if not flying then return end
        if input.UserInputType == Enum.UserInputType.Keyboard then
            local direction = Vector3.new(0, 0, 0)
            if userinputservice:IsKeyDown(Enum.KeyCode.W) then
                direction = direction + camera.CFrame.LookVector
            end
            if userinputservice:IsKeyDown(Enum.KeyCode.S) then
                direction = direction - camera.CFrame.LookVector
            end
            if userinputservice:IsKeyDown(Enum.KeyCode.A) then
                direction = direction - camera.CFrame.RightVector
            end
            if userinputservice:IsKeyDown(Enum.KeyCode.D) then
                direction = direction + camera.CFrame.RightVector
            end
            if userinputservice:IsKeyDown(Enum.KeyCode.Space) then
                direction = direction + Vector3.new(0, 1, 0)
            end
            if userinputservice:IsKeyDown(Enum.KeyCode.LeftControl) then
                direction = direction - Vector3.new(0, 1, 0)
            end
            bodyvelocity.Velocity = direction * 50
            bodygyro.CFrame = CFrame.new(rootpart.Position, rootpart.Position + camera.CFrame.LookVector)
        end
    end)
end

-- noclip
local noclipconnection = nil
local function setnoclip()
    if settings.noclip then
        if not noclipconnection then
            noclipconnection = runservice.Stepped:Connect(function()
                local character = localplayer.Character
                if character then
                    for _, part in pairs(character:GetDescendants()) do
                        if part:IsA("BasePart") then
                            part.CanCollide = false
                        end
                    end
                end
            end)
        end
    else
        if noclipconnection then
            noclipconnection:Disconnect()
            noclipconnection = nil
            local character = localplayer.Character
            if character then
                for _, part in pairs(character:GetDescendants()) do
                    if part:IsA("BasePart") then
                        part.CanCollide = true
                    end
                end
            end
        end
    end
end

-- infinite jump
local function infinitejump()
    if not settings.infinitejump then return end
    local character = localplayer.Character
    if not character then return end
    local humanoid = character:FindFirstChild("Humanoid")
    if not humanoid then return end
    
    if userinputservice:IsKeyDown(Enum.KeyCode.Space) then
        local now = tick()
        if now - lastjumptime > 0.1 then
            humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
            lastjumptime = now
        end
    end
end

-- movement
local function applymovement()
    local character = localplayer.Character
    if not character then return end
    local humanoid = character:FindFirstChild("Humanoid")
    if not humanoid then return end
    
    if settings.speedboost then
        humanoid.WalkSpeed = settings.speedvalue
    else
        humanoid.WalkSpeed = 16
    end
end

-- god mode
local function godmode()
    if not settings.godmode then return end
    local character = localplayer.Character
    if not character then return end
    local humanoid = character:FindFirstChild("Humanoid")
    if humanoid then
        humanoid.MaxHealth = math.huge
        humanoid.Health = math.huge
        humanoid.BreakJointsOnDeath = false
    end
end

-- auto revive
local function autorevive()
    if not settings.autorevive then return end
    local character = localplayer.Character
    if not character then return end
    local humanoid = character:FindFirstChild("Humanoid")
    if humanoid and humanoid.Health <= 0 then
        localplayer.Character = nil
        task.wait(1)
        localplayer.CharacterAdded:Wait()
    end
end

-- anti disaster functions
local function antifling()
    if not settings.antifling then return end
    local character = localplayer.Character
    if not character then return end
    local rootpart = character:FindFirstChild("HumanoidRootPart")
    if rootpart and rootpart.AssemblyLinearVelocity.Y > 100 then
        rootpart.AssemblyLinearVelocity = Vector3.new(rootpart.AssemblyLinearVelocity.X, 0, rootpart.AssemblyLinearVelocity.Z)
    end
end

local function antifire()
    if not settings.antifire then return end
    local character = localplayer.Character
    if character then
        local fire = character:FindFirstChild("Fire")
        if fire then fire:Destroy() end
    end
    
    for _, v in pairs(workspace:GetDescendants()) do
        if v:IsA("Fire") and v.Parent and v.Parent:IsDescendantOf(localplayer.Character) then
            v:Destroy()
        end
    end
end

local function antiwater()
    if not settings.antiwater then return end
    local character = localplayer.Character
    if not character then return end
    local rootpart = character:FindFirstChild("HumanoidRootPart")
    if rootpart and rootpart.Position.Y < 0 then
        rootpart.CFrame = CFrame.new(rootpart.Position.X, 10, rootpart.Position.Z)
    end
end

local function antiearth()
    if not settings.antiearth then return end
    local character = localplayer.Character
    if not character then return end
    local humanoid = character:FindFirstChild("Humanoid")
    if humanoid then
        local animator = humanoid:FindFirstChild("Animator")
        if animator then
            for _, track in pairs(animator:GetPlayingAnimationTracks()) do
                if track.Animation and track.Animation.Name:lower():find("shake") then
                    track:Stop()
                end
            end
        end
    end
end

-- disaster predictor
local function getcurrentdisaster()
    for _, v in pairs(workspace:GetDescendants()) do
        if v:IsA("Model") then
            local name = v.Name:lower()
            for _, disaster in pairs(disasterlist) do
                if name:find(disaster) then
                    return disaster
                end
            end
        end
    end
    
    local gui = localplayer.PlayerGui:FindFirstChild("GameGui")
    if gui then
        local text = gui:FindFirstChild("DisasterText")
        if text and text:IsA("TextLabel") then
            for _, disaster in pairs(disasterlist) do
                if text.Text:lower():find(disaster) then
                    return disaster
                end
            end
        end
    end
    return "none"
end

-- find safe zone
local function findsafezone()
    for _, v in pairs(workspace:GetDescendants()) do
        if v:IsA("BasePart") and v.Name:lower():find("safe") or v.Name:lower():find("platform") then
            if v.Position.Y > 0 then
                return v.Position
            end
        end
    end
    return nil
end

-- auto safe zone
local function autosafezone()
    if not settings.autosafezone then return end
    
    local safepos = findsafezone()
    if safepos then
        local char = localplayer.Character
        if char and char:FindFirstChild("HumanoidRootPart") then
            char.HumanoidRootPart.CFrame = CFrame.new(safepos)
        end
    end
end

-- balloon spam
local function balloonspam()
    if not settings.balloonspam then return end
    
    local character = localplayer.Character
    if character then
        local balloon = character:FindFirstChild("Balloon")
        if balloon and balloon:IsA("Tool") then
            virtualinputmanager:SendKeyEvent(true, Enum.KeyCode.F, false, game)
            task.wait(0.1)
            virtualinputmanager:SendKeyEvent(false, Enum.KeyCode.F, false, game)
        end
    end
end

-- point multiplier
local function pointmultiplier()
    if not settings.pointmultiplier then return end
    
    local stats = localplayer:FindFirstChild("leaderstats")
    if stats then
        local points = stats:FindFirstChild("Points")
        if points then
            points.Value = points.Value + 5
        end
    end
end

-- disable screen shake
local function disablescreenshake()
    if not settings.disablescreenshake then return end
    
    local camera = workspace.CurrentCamera
    if camera then
        local shake = camera:FindFirstChild("Shake")
        if shake then shake:Destroy() end
    end
    
    for _, v in pairs(workspace:GetDescendants()) do
        if v:IsA("NumberValue") and v.Name:lower():find("shake") then
            v.Value = 0
        end
    end
end

-- unlock abilities
local function unlockabilities()
    if not settings.unlockabilities then return end
    
    local abilities = replicatedstorage:FindFirstChild("Abilities")
    if abilities then
        for _, ability in pairs(abilities:GetChildren()) do
            for _, child in pairs(ability:GetChildren()) do
                if child.Name == "Owned" and child:IsA("BoolValue") then
                    child.Value = true
                end
            end
        end
    end
    
    local perks = localplayer:FindFirstChild("Perks")
    if perks then
        for _, perk in pairs(perks:GetChildren()) do
            if perk:IsA("BoolValue") then
                perk.Value = true
            end
        end
    end
end

-- anti afk
local function antiafk()
    if not settings.antiafk then return end
    if tick() - lastantiafktime > 60 then
        virtualinputmanager:SendKeyEvent(true, Enum.KeyCode.W, false, game)
        task.wait(0.05)
        virtualinputmanager:SendKeyEvent(false, Enum.KeyCode.W, false, game)
        lastantiafktime = tick()
    end
end

-- visual functions
local function setthirdperson()
    if settings.thirdperson then
        camera.CameraType = Enum.CameraType.Scriptable
        local character = localplayer.Character
        if character and character:FindFirstChild("HumanoidRootPart") then
            camera.CFrame = CFrame.new(character.HumanoidRootPart.Position + Vector3.new(0, 3, 10), character.HumanoidRootPart.Position)
        end
    else
        camera.CameraType = Enum.CameraType.Custom
    end
end

local function setfov()
    if settings.fovchanger then
        camera.FieldOfView = settings.fovvalue
    else
        camera.FieldOfView = 70
    end
end

local function setfullbright()
    if settings.fullbright then
        lighting.Brightness = 2
        lighting.ClockTime = 14
        lighting.OutdoorAmbient = Color3.fromRGB(128, 128, 128)
        lighting.GlobalShadows = false
    end
end

local function setnofog()
    if settings.nofog then
        lighting.FogEnd = 100000
    else
        lighting.FogEnd = 1000
    end
end

-- disaster timer
local function updatedisasterinfo()
    local newdisaster = getcurrentdisaster()
    if newdisaster ~= currentdisaster then
        currentdisaster = newdisaster
        disasterstarttime = tick()
    end
end

-- esp drawing
local function getscreenposition(position)
    local vector, onscreen = camera:WorldToViewportPoint(position)
    if not onscreen then return nil end
    return Vector2.new(vector.X, vector.Y)
end

local function clearesp(obj)
    if espdrawings[obj] then
        for _, drawing in pairs(espedrawings[obj]) do
            pcall(function() drawing:Remove() end)
        end
        espdrawings[obj] = nil
    end
end

local function drawesp()
    -- player esp
    if settings.playeresp then
        for _, player in pairs(players:GetPlayers()) do
            if player ~= localplayer then
                local character = player.Character
                local humanoid = character and character:FindFirstChild("Humanoid")
                
                if not character or not humanoid or humanoid.Health <= 0 then
                    clearesp(player)
                    continue
                end
                
                local root = character:FindFirstChild("HumanoidRootPart")
                if not root then
                    clearesp(player)
                    continue
                end
                
                local pos = getscreenposition(root.Position)
                if not pos then
                    clearesp(player)
                    continue
                end
                
                if not espdrawings[player] then
                    espdrawings[player] = {}
                end
                
                if not espdrawings[player].box then
                    espdrawings[player].box = Drawing.new("Square")
                    espdrawings[player].box.Thickness = 2
                    espdrawings[player].box.Filled = false
                end
                local box = espdrawings[player].box
                box.Visible = true
                box.Position = Vector2.new(pos.X - 25, pos.Y - 50)
                box.Size = Vector2.new(50, 100)
                box.Color = Color3.fromRGB(255, 0, 0)
                
                if not espdrawings[player].name then
                    espdrawings[player].name = Drawing.new("Text")
                    espdrawings[player].name.Size = 14
                    espdrawings[player].name.Center = true
                    espdrawings[player].name.Outline = true
                end
                local name = espdrawings[player].name
                name.Visible = true
                name.Position = Vector2.new(pos.X, pos.Y - 55)
                name.Text = player.Name
                name.Color = Color3.fromRGB(255, 255, 255)
            end
        end
    end
    
    -- disaster esp
    if settings.disasteresp and currentdisaster ~= "none" then
        for _, v in pairs(workspace:GetDescendants()) do
            if v:IsA("BasePart") then
                local name = v.Name:lower()
                if name:find(currentdisaster) or (currentdisaster == "tsunami" and name:find("water")) then
                    local pos = getscreenposition(v.Position)
                    if pos then
                        if not espdrawings[v] then
                            espdrawings[v] = {}
                        end
                        if not espdrawings[v].text then
                            espdrawings[v].text = Drawing.new("Text")
                            espdrawings[v].text.Size = 16
                            espdrawings[v].text.Center = true
                            espdrawings[v].text.Outline = true
                        end
                        local text = espdrawings[v].text
                        text.Visible = true
                        text.Position = pos
                        text.Text = currentdisaster:upper()
                        text.Color = disastercolors[currentdisaster] or Color3.fromRGB(255, 0, 0)
                    end
                end
            end
        end
    end
    
    -- safe zone esp
    if settings.safezoneesp then
        local safepos = findsafezone()
        if safepos then
            local pos = getscreenposition(safepos)
            if pos then
                if not espdrawings.safezone then
                    espdrawings.safezone = {}
                end
                if not espdrawings.safezone.text then
                    espdrawings.safezone.text = Drawing.new("Text")
                    espdrawings.safezone.text.Size = 14
                    espdrawings.safezone.text.Center = true
                    espdrawings.safezone.text.Outline = true
                end
                local text = espdrawings.safezone.text
                text.Visible = true
                text.Position = pos
                text.Text = "safe zone"
                text.Color = Color3.fromRGB(0, 255, 0)
            end
        end
    end
end

-- tabs
local disastertab = window:CreateTab("disaster")
local movementtab = window:CreateTab("movement")
local visualtab = window:CreateTab("visual")
local misctab = window:CreateTab("misc")

-- disaster tab
disastertab:CreateToggle("disaster predictor", false, function(v) settings.disasterpredictor = v end)
disastertab:CreateToggle("disaster timer", false, function(v) settings.disastertimer = v end)
disastertab:CreateToggle("disaster esp", false, function(v) settings.disasteresp = v end)
disastertab:CreateToggle("safe zone esp", false, function(v) settings.safezoneesp = v end)
disastertab:CreateToggle("auto safe zone", false, function(v) settings.autosafezone = v end)
disastertab:CreateToggle("player esp", false, function(v) settings.playeresp = v end)

-- movement tab
movementtab:CreateToggle("speed boost", false, function(v) settings.speedboost = v end)
movementtab:CreateSlider("speed value", 16, 250, 50, function(v) settings.speedvalue = v end)
movementtab:CreateToggle("fly", false, function(v)
    settings.fly = v
    startfly()
end)
movementtab:CreateToggle("infinite jump", false, function(v) settings.infinitejump = v end)
movementtab:CreateToggle("noclip", false, function(v)
    settings.noclip = v
    setnoclip()
end)

-- visual tab
visualtab:CreateToggle("third person", false, function(v) settings.thirdperson = v end)
visualtab:CreateToggle("fov changer", false, function(v) settings.fovchanger = v end)
visualtab:CreateSlider("fov value", 70, 120, 120, function(v) settings.fovvalue = v end)
visualtab:CreateToggle("fullbright", false, function(v) settings.fullbright = v end)
visualtab:CreateToggle("no fog", false, function(v) settings.nofog = v end)

-- misc tab
misctab:CreateToggle("god mode", false, function(v) settings.godmode = v end)
misctab:CreateToggle("auto revive", false, function(v) settings.autorevive = v end)
misctab:CreateToggle("anti-fling", false, function(v) settings.antifling = v end)
misctab:CreateToggle("anti-fire", false, function(v) settings.antifire = v end)
misctab:CreateToggle("anti-water", false, function(v) settings.antiwater = v end)
misctab:CreateToggle("anti-earthquake", false, function(v) settings.antiearth = v end)
misctab:CreateToggle("point multiplier", false, function(v) settings.pointmultiplier = v end)
misctab:CreateToggle("disable screen shake", false, function(v) settings.disablescreenshake = v end)
misctab:CreateToggle("balloon spam", false, function(v) settings.balloonspam = v end)
misctab:CreateToggle("anti-afk", false, function(v) settings.antiafk = v end)
misctab:CreateButton("unlock all abilities (local)", function() unlockabilities() end)

-- update loop for disaster info
task.spawn(function()
    while true do
        updatedisasterinfo()
        
        if settings.disasterpredictor and currentdisaster ~= "none" then
            library:Notification("disaster warning", currentdisaster:upper() + " incoming!", "ok")
        end
        
        if settings.disastertimer and currentdisaster ~= "none" then
            local elapsed = tick() - disasterstarttime
            if elapsed > 10 and elapsed < 60 then
                -- would show timer but needs UI element
            end
        end
        
        task.wait(5)
    end
end)

-- main loop
runservice.RenderStepped:Connect(function()
    applymovement()
    infinitejump()
    godmode()
    autorevive()
    antifling()
    antifire()
    antiwater()
    antiearth()
    autosafezone()
    balloonspam()
    pointmultiplier()
    disablescreenshake()
    antiafk()
    setthirdperson()
    setfov()
    setfullbright()
    setnofog()
    drawesp()
end)

localplayer.CharacterAdded:Connect(function()
    task.wait(0.5)
    applymovement()
    godmode()
end)

print("lunarware natural disaster loaded")

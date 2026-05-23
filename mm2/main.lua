-- lunarware | murder mystery 2
-- 25 features: role esp, player esp, murderer notifier, sheriff notifier, gun esp, coin esp, gem esp, teleport to gun, teleport to coins, teleport to gems, auto collect coins, auto collect gems, auto pickup gun, speed boost, fly, infinite jump, fullbright, no fog, third person, fov changer, anti-afk, player distance esp, kill aura, auto shoot, unlock knives/guns

local library = loadstring(game:HttpGet("https://raw.githubusercontent.com/peppy/UI-Library/main/source.lua"))()
local window = library:CreateWindow("lunarware | mm2")

local players = game:GetService("Players")
local runservice = game:GetService("RunService")
local userinputservice = game:GetService("UserInputService")
local virtualinputmanager = game:GetService("VirtualInputManager")
local replicatedstorage = game:GetService("ReplicatedStorage")
local workspace = game:GetService("Workspace")
local lighting = game:GetService("Lighting")

local localplayer = players.LocalPlayer
local mouse = localplayer:GetMouse()
local camera = workspace.CurrentCamera

-- settings
local settings = {
    -- esp
    roleesp = false,
    playeresp = false,
    gunesp = false,
    coinesp = false,
    gemesp = false,
    espcolor = Color3.fromRGB(255, 0, 0),
    
    -- notifiers
    murderernotifier = false,
    sheriffnotifier = false,
    
    -- teleports
    teleporttogun = false,
    teleporttocoins = false,
    teleporttogems = false,
    
    -- auto collect
    autocollectcoins = false,
    autocollectgems = false,
    autopickupgun = false,
    
    -- combat
    killaura = false,
    autoshoot = false,
    
    -- movement
    speedboost = false,
    speedvalue = 50,
    fly = false,
    infinitejump = false,
    
    -- visual
    fullbright = false,
    nofog = false,
    thirdperson = false,
    fovchanger = false,
    fovvalue = 120,
    
    -- misc
    antiafk = false,
    playerdistanceesp = false,
    unlockitems = false,
}

-- drawing objects
local espdrawings = {}
local lastantiafktime = tick()
local flying = false
local bodyvelocity = nil
local bodygyro = nil
local lastjump = 0

-- role colors
local rolecolors = {
    murderer = Color3.fromRGB(255, 0, 0),
    sheriff = Color3.fromRGB(0, 0, 255),
    innocent = Color3.fromRGB(0, 255, 0),
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

-- infinite jump
local function infinitejump()
    if not settings.infinitejump then return end
    local character = localplayer.Character
    if not character then return end
    local humanoid = character:FindFirstChild("Humanoid")
    if not humanoid then return end
    
    if userinputservice:IsKeyDown(Enum.KeyCode.Space) then
        humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
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

-- get player role
local function getplayerrole(player)
    local role = player:FindFirstChild("Role")
    if role then
        return role.Value
    end
    return "innocent"
end

-- kill aura for murderer
local function killaura()
    if not settings.killaura then return end
    
    local myrole = getplayerrole(localplayer)
    if myrole ~= "murderer" then return end
    
    for _, player in pairs(players:GetPlayers()) do
        if player ~= localplayer then
            local role = getplayerrole(player)
            if role == "innocent" or role == "sheriff" then
                local character = player.Character
                if character then
                    local dist = (character.HumanoidRootPart.Position - localplayer.Character.HumanoidRootPart.Position).Magnitude
                    if dist < 10 then
                        virtualinputmanager:SendMouseButtonEvent(0, 0, 0, true, game, 0)
                        task.wait(0.05)
                        virtualinputmanager:SendMouseButtonEvent(0, 0, 0, false, game, 0)
                    end
                end
            end
        end
    end
end

-- auto shoot for sheriff
local function autoshoot()
    if not settings.autoshoot then return end
    
    local myrole = getplayerrole(localplayer)
    if myrole ~= "sheriff" then return end
    
    for _, player in pairs(players:GetPlayers()) do
        if player ~= localplayer then
            local role = getplayerrole(player)
            if role == "murderer" then
                local character = player.Character
                if character then
                    local head = character:FindFirstChild("Head")
                    if head then
                        local screenpos, onscreen = camera:WorldToViewportPoint(head.Position)
                        if onscreen then
                            virtualinputmanager:SendMouseButtonEvent(0, 0, 0, true, game, 0)
                            task.wait(0.1)
                            virtualinputmanager:SendMouseButtonEvent(0, 0, 0, false, game, 0)
                        end
                    end
                end
            end
        end
    end
end

-- auto collect coins
local function autocollectcoinsloop()
    while settings.autocollectcoins do
        for _, v in pairs(workspace:GetDescendants()) do
            if v:IsA("Model") and v.Name:lower():find("coin") then
                local char = localplayer.Character
                if char and char:FindFirstChild("HumanoidRootPart") then
                    char.HumanoidRootPart.CFrame = v:GetPivot()
                end
                virtualinputmanager:SendMouseButtonEvent(0, 0, 0, true, game, 0)
                task.wait(0.05)
                virtualinputmanager:SendMouseButtonEvent(0, 0, 0, false, game, 0)
            end
        end
        task.wait(0.5)
    end
end

-- auto collect gems
local function autocollectgemsloop()
    while settings.autocollectgems do
        for _, v in pairs(workspace:GetDescendants()) do
            if v:IsA("Model") and v.Name:lower():find("gem") then
                local char = localplayer.Character
                if char and char:FindFirstChild("HumanoidRootPart") then
                    char.HumanoidRootPart.CFrame = v:GetPivot()
                end
                virtualinputmanager:SendMouseButtonEvent(0, 0, 0, true, game, 0)
                task.wait(0.05)
                virtualinputmanager:SendMouseButtonEvent(0, 0, 0, false, game, 0)
            end
        end
        task.wait(0.5)
    end
end

-- auto pickup gun
local function autopickupgunloop()
    while settings.autopickupgun do
        for _, v in pairs(workspace:GetDescendants()) do
            if v:IsA("Model") and v.Name:lower():find("gun") then
                local char = localplayer.Character
                if char and char:FindFirstChild("HumanoidRootPart") then
                    char.HumanoidRootPart.CFrame = v:GetPivot()
                end
                virtualinputmanager:SendMouseButtonEvent(0, 0, 0, true, game, 0)
                task.wait(0.05)
                virtualinputmanager:SendMouseButtonEvent(0, 0, 0, false, game, 0)
            end
        end
        task.wait(0.5)
    end
end

-- notifiers
local lastnotifytime = 0
local function checknotifiers()
    for _, player in pairs(players:GetPlayers()) do
        if player ~= localplayer then
            local role = getplayerrole(player)
            local dist = 0
            if localplayer.Character and player.Character then
                dist = (player.Character.HumanoidRootPart.Position - localplayer.Character.HumanoidRootPart.Position).Magnitude
            end
            
            if settings.murderernotifier and role == "murderer" and dist < 50 then
                if tick() - lastnotifytime > 10 then
                    library:Notification("warning", "murderer is near you!", "ok")
                    lastnotifytime = tick()
                end
            end
            
            if settings.sheriffnotifier and role == "sheriff" and dist < 50 then
                if tick() - lastnotifytime > 10 then
                    library:Notification("info", "sheriff is near you!", "ok")
                    lastnotifytime = tick()
                end
            end
        end
    end
end

-- unlock all knives and guns
local function unlockitems()
    if not settings.unlockitems then return end
    
    local weaponsfolder = replicatedstorage:FindFirstChild("Weapons")
    if weaponsfolder then
        for _, weapon in pairs(weaponsfolder:GetChildren()) do
            for _, child in pairs(weapon:GetChildren()) do
                if child.Name == "Owned" and child:IsA("BoolValue") then
                    child.Value = true
                end
            end
        end
    end
    
    local knivesfolder = replicatedstorage:FindFirstChild("Knives")
    if knivesfolder then
        for _, knife in pairs(knivesfolder:GetChildren()) do
            for _, child in pairs(knife:GetChildren()) do
                if child.Name == "Owned" and child:IsA("BoolValue") then
                    child.Value = true
                end
            end
        end
    end
    
    local gunsfolder = replicatedstorage:FindFirstChild("Guns")
    if gunsfolder then
        for _, gun in pairs(gunsfolder:GetChildren()) do
            for _, child in pairs(gun:GetChildren()) do
                if child.Name == "Owned" and child:IsA("BoolValue") then
                    child.Value = true
                end
            end
        end
    end
end

-- teleport functions
local function teleporttoposition(position)
    local char = localplayer.Character
    if char and char:FindFirstChild("HumanoidRootPart") then
        char.HumanoidRootPart.CFrame = CFrame.new(position)
    end
end

local function teleporttogunfunc()
    for _, v in pairs(workspace:GetDescendants()) do
        if v:IsA("Model") and v.Name:lower():find("gun") then
            teleporttoposition(v:GetPivot().Position)
            return
        end
    end
end

local function teleporttocoinsfunc()
    for _, v in pairs(workspace:GetDescendants()) do
        if v:IsA("Model") and v.Name:lower():find("coin") then
            teleporttoposition(v:GetPivot().Position)
            return
        end
    end
end

local function teleporttogemsfunc()
    for _, v in pairs(workspace:GetDescendants()) do
        if v:IsA("Model") and v.Name:lower():find("gem") then
            teleporttoposition(v:GetPivot().Position)
            return
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
            camera.CFrame = CFrame.new(character.HumanoidRootPart.Position + Vector3.new(0, 2, 6), character.HumanoidRootPart.Position)
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
    if settings.playeresp or settings.roleesp then
        for _, player in pairs(players:GetPlayers()) do
            if player ~= localplayer then
                local character = player.Character
                local humanoid = character and character:FindFirstChild("Humanoid")
                
                if not character or not humanoid or humanoid.Health <= 0 then
                    clearesp(player)
                    continue
                end
                
                local root = character:FindFirstChild("HumanoidRootPart") or character.PrimaryPart
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
                
                local role = getplayerrole(player)
                local rolecolor = rolecolors[role:lower()] or Color3.fromRGB(255, 255, 255)
                local displaycolor = settings.roleesp and rolecolor or settings.espcolor
                
                -- box esp
                if settings.playeresp then
                    if not espdrawings[player].box then
                        espdrawings[player].box = Drawing.new("Square")
                        espdrawings[player].box.Thickness = 2
                        espdrawings[player].box.Filled = false
                    end
                    local box = espdrawings[player].box
                    box.Visible = true
                    box.Position = Vector2.new(pos.X - 25, pos.Y - 50)
                    box.Size = Vector2.new(50, 100)
                    box.Color = displaycolor
                elseif espdrawings[player].box then
                    espdrawings[player].box.Visible = false
                end
                
                -- name esp
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
                
                -- role esp
                if settings.roleesp then
                    if not espdrawings[player].role then
                        espdrawings[player].role = Drawing.new("Text")
                        espdrawings[player].role.Size = 12
                        espdrawings[player].role.Center = true
                        espdrawings[player].role.Outline = true
                    end
                    local roletext = espdrawings[player].role
                    roletext.Visible = true
                    roletext.Position = Vector2.new(pos.X, pos.Y - 40)
                    roletext.Text = role:upper()
                    roletext.Color = rolecolor
                elseif espdrawings[player].role then
                    espdrawings[player].role.Visible = false
                end
                
                -- distance esp
                if settings.playerdistanceesp then
                    if not espdrawings[player].distance then
                        espdrawings[player].distance = Drawing.new("Text")
                        espdrawings[player].distance.Size = 11
                        espdrawings[player].distance.Center = true
                        espdrawings[player].distance.Outline = true
                    end
                    local dist = (root.Position - camera.CFrame.Position).Magnitude / 3.28084
                    local distance = espdrawings[player].distance
                    distance.Visible = true
                    distance.Position = Vector2.new(pos.X, pos.Y + 55)
                    distance.Text = string.format("%.0fm", dist)
                    distance.Color = Color3.fromRGB(200, 200, 200)
                elseif espdrawings[player].distance then
                    espdrawings[player].distance.Visible = false
                end
            end
        end
    end
    
    -- gun esp
    if settings.gunesp then
        for _, v in pairs(workspace:GetDescendants()) do
            if v:IsA("Model") and v.Name:lower():find("gun") then
                local pos = getscreenposition(v:GetPivot().Position)
                if pos then
                    if not espdrawings[v] then
                        espdrawings[v] = {}
                    end
                    if not espdrawings[v].text then
                        espdrawings[v].text = Drawing.new("Text")
                        espdrawings[v].text.Size = 14
                        espdrawings[v].text.Center = true
                        espdrawings[v].text.Outline = true
                    end
                    local text = espdrawings[v].text
                    text.Visible = true
                    text.Position = pos
                    text.Text = "gun"
                    text.Color = Color3.fromRGB(255, 215, 0)
                end
            end
        end
    end
    
    -- coin esp
    if settings.coinesp then
        for _, v in pairs(workspace:GetDescendants()) do
            if v:IsA("Model") and v.Name:lower():find("coin") then
                local pos = getscreenposition(v:GetPivot().Position)
                if pos then
                    if not espdrawings[v] then
                        espdrawings[v] = {}
                    end
                    if not espdrawings[v].text then
                        espdrawings[v].text = Drawing.new("Text")
                        espdrawings[v].text.Size = 12
                        espdrawings[v].text.Center = true
                        espdrawings[v].text.Outline = true
                    end
                    local text = espdrawings[v].text
                    text.Visible = true
                    text.Position = pos
                    text.Text = "coin"
                    text.Color = Color3.fromRGB(255, 215, 0)
                end
            end
        end
    end
    
    -- gem esp
    if settings.gemesp then
        for _, v in pairs(workspace:GetDescendants()) do
            if v:IsA("Model") and v.Name:lower():find("gem") then
                local pos = getscreenposition(v:GetPivot().Position)
                if pos then
                    if not espdrawings[v] then
                        espdrawings[v] = {}
                    end
                    if not espdrawings[v].text then
                        espdrawings[v].text = Drawing.new("Text")
                        espdrawings[v].text.Size = 12
                        espdrawings[v].text.Center = true
                        espdrawings[v].text.Outline = true
                    end
                    local text = espdrawings[v].text
                    text.Visible = true
                    text.Position = pos
                    text.Text = "gem"
                    text.Color = Color3.fromRGB(100, 255, 255)
                end
            end
        end
    end
end

-- tabs
local esptab = window:CreateTab("esp")
local combattab = window:CreateTab("combat")
local autotab = window:CreateTab("auto")
local movementtab = window:CreateTab("movement")
local visualtab = window:CreateTab("visual")
local misctab = window:CreateTab("misc")

-- esp tab
esptab:CreateToggle("player esp", false, function(v) settings.playeresp = v end)
esptab:CreateToggle("role esp", false, function(v) settings.roleesp = v end)
esptab:CreateToggle("player distance esp", false, function(v) settings.playerdistanceesp = v end)
esptab:CreateToggle("gun esp", false, function(v) settings.gunesp = v end)
esptab:CreateToggle("coin esp", false, function(v) settings.coinesp = v end)
esptab:CreateToggle("gem esp", false, function(v) settings.gemesp = v end)
esptab:CreateColorpicker("esp color", Color3.fromRGB(255,0,0), function(v) settings.espcolor = v end)

-- combat tab
combattab:CreateToggle("kill aura (murderer only)", false, function(v) settings.killaura = v end)
combattab:CreateToggle("auto shoot (sheriff only)", false, function(v) settings.autoshoot = v end)
combattab:CreateToggle("murderer notifier", false, function(v) settings.murderernotifier = v end)
combattab:CreateToggle("sheriff notifier", false, function(v) settings.sheriffnotifier = v end)

-- auto tab
autotab:CreateToggle("auto collect coins", false, function(v)
    settings.autocollectcoins = v
    if v then task.spawn(autocollectcoinsloop) end
end)
autotab:CreateToggle("auto collect gems", false, function(v)
    settings.autocollectgems = v
    if v then task.spawn(autocollectgemsloop) end
end)
autotab:CreateToggle("auto pickup gun", false, function(v)
    settings.autopickupgun = v
    if v then task.spawn(autopickupgunloop) end
end)

-- movement tab
movementtab:CreateToggle("speed boost", false, function(v) settings.speedboost = v end)
movementtab:CreateSlider("speed value", 16, 250, 50, function(v) settings.speedvalue = v end)
movementtab:CreateToggle("fly", false, function(v)
    settings.fly = v
    startfly()
end)
movementtab:CreateToggle("infinite jump", false, function(v) settings.infinitejump = v end)

-- visual tab
visualtab:CreateToggle("third person", false, function(v) settings.thirdperson = v end)
visualtab:CreateToggle("fov changer", false, function(v) settings.fovchanger = v end)
visualtab:CreateSlider("fov value", 70, 120, 120, function(v) settings.fovvalue = v end)
visualtab:CreateToggle("fullbright", false, function(v) settings.fullbright = v end)
visualtab:CreateToggle("no fog", false, function(v) settings.nofog = v end)

-- misc tab
misctab:CreateToggle("anti-afk", false, function(v) settings.antiafk = v end)
misctab:CreateButton("teleport to gun", function() teleporttogunfunc() end)
misctab:CreateButton("teleport to coins", function() teleporttocoinsfunc() end)
misctab:CreateButton("teleport to gems", function() teleporttogemsfunc() end)
misctab:CreateButton("unlock all knives/guns (local)", function() unlockitems() end)

-- main loop
runservice.RenderStepped:Connect(function()
    applymovement()
    infinitejump()
    killaura()
    autoshoot()
    checknotifiers()
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
end)

print("lunarware mm2 loaded")

-- lunarware | lumber tycoon 2
-- 25 features: auto farm trees, auto collect wood, auto sell wood, auto transport to sawmill, tree esp, player esp, item esp, teleport to tree, teleport to sawmill, teleport to shop, teleport to land, instant chop, axe durability bypass, auto load truck, auto unload truck, auto buy blueprint, auto gift collector, fly, speed boost, noclip, fullbright, no fog, anti-afk, item magnet, dupe axe

local library = loadstring(game:HttpGet("https://raw.githubusercontent.com/peppy/UI-Library/main/source.lua"))()
local window = library:CreateWindow("lunarware | lumber tycoon 2")

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
    -- auto farm
    autofarm = false,
    autofarmradius = 200,
    autocollectwood = false,
    autosellwood = false,
    autotransport = false,
    
    -- esp
    treeesp = false,
    playeresp = false,
    itemesp = false,
    espcolor = Color3.fromRGB(0, 255, 0),
    
    -- teleports
    teleporttotree = false,
    teleporttosawmill = false,
    teleporttoshop = false,
    teleporttoland = false,
    
    -- axe mods
    instantchop = false,
    axedurability = false,
    dupeaxe = false,
    
    -- auto actions
    autoloadtruck = false,
    autounloadtruck = false,
    autobuyblueprint = false,
    autogiftcollector = false,
    
    -- movement
    speedboost = false,
    speedvalue = 50,
    fly = false,
    noclip = false,
    
    -- visual
    fullbright = false,
    nofog = false,
    
    -- misc
    antiafk = false,
    itemmagnet = false,
}

-- drawing objects
local espdrawings = {}
local lastantiafktime = tick()
local flying = false
local bodyvelocity = nil
local bodygyro = nil
local noclipconnection = nil

-- axe data storage
local ownedaxes = {}
local originalaxedurability = {}

-- teleport locations
local sawmillposition = Vector3.new(0, 0, 0)
local shopposition = Vector3.new(0, 0, 0)
local landposition = Vector3.new(0, 0, 0)

-- find teleport locations
local function findlocations()
    for _, v in pairs(workspace:GetDescendants()) do
        if v:IsA("BasePart") then
            if v.Name:lower():find("sawmill") or v.Name:lower():find("saw") then
                sawmillposition = v.Position
            end
            if v.Name:lower():find("shop") or v.Name:lower():find("store") then
                shopposition = v.Position
            end
            if v.Name:lower():find("land") or v.Name:lower():find("plot") then
                landposition = v.Position
            end
        end
    end
end

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

-- dupe axe
local function dupeaxe()
    if not settings.dupeaxe then return end
    
    local character = localplayer.Character
    if not character then return end
    
    local tool = character:FindFirstChildWhichIsA("Tool")
    if tool and tool.Name:lower():find("axe") then
        local clone = tool:Clone()
        clone.Parent = localplayer.Backpack
        task.wait(0.1)
        clone.Parent = character
    end
end

-- axe durability bypass
local function bypassaxedurability()
    if not settings.axedurability then return end
    
    local character = localplayer.Character
    if not character then return end
    
    local tool = character:FindFirstChildWhichIsA("Tool")
    if tool then
        for _, child in pairs(tool:GetDescendants()) do
            if child:IsA("NumberValue") and (child.Name:lower():find("durability") or child.Name:lower():find("health")) then
                if originalaxedurability[tool.Name] == nil then
                    originalaxedurability[tool.Name] = child.Value
                end
                child.Value = 9999
            end
        end
    end
end

-- instant chop
local function instantchop()
    if not settings.instanchop then return end
    
    for _, v in pairs(workspace:GetDescendants()) do
        if v:IsA("Model") and v:FindFirstChild("ClickDetector") then
            local name = v.Name:lower()
            if name:find("tree") or name:find("stump") then
                virtualinputmanager:SendMouseButtonEvent(0, 0, 0, true, game, 0)
                task.wait(0.01)
                virtualinputmanager:SendMouseButtonEvent(0, 0, 0, false, game, 0)
            end
        end
    end
end

-- auto farm
local function autofarmloop()
    while settings.autofarm do
        local nearest = nil
        local nearestdist = settings.autofarmradius
        
        for _, v in pairs(workspace:GetDescendants()) do
            if v:IsA("Model") and v:FindFirstChild("ClickDetector") then
                local name = v.Name:lower()
                if name:find("tree") then
                    local dist = (v:GetPivot().Position - localplayer.Character.HumanoidRootPart.Position).Magnitude
                    if dist < nearestdist then
                        nearest = v
                        nearestdist = dist
                    end
                end
            end
        end
        
        if nearest then
            local char = localplayer.Character
            if char and char:FindFirstChild("HumanoidRootPart") then
                char.HumanoidRootPart.CFrame = nearest:GetPivot()
            end
            for i = 1, 10 do
                virtualinputmanager:SendMouseButtonEvent(0, 0, 0, true, game, 0)
                task.wait(0.05)
                virtualinputmanager:SendMouseButtonEvent(0, 0, 0, false, game, 0)
            end
        end
        task.wait(0.5)
    end
end

-- auto collect wood
local function autocollectwoodloop()
    while settings.autocollectwood do
        for _, v in pairs(workspace:GetDescendants()) do
            if v:IsA("Model") and v:FindFirstChild("ClickDetector") then
                local name = v.Name:lower()
                if name:find("log") or name:find("wood") or name:find("plank") then
                    local dist = (v:GetPivot().Position - localplayer.Character.HumanoidRootPart.Position).Magnitude
                    if dist < 50 then
                        local char = localplayer.Character
                        if char and char:FindFirstChild("HumanoidRootPart") then
                            char.HumanoidRootPart.CFrame = v:GetPivot()
                        end
                        virtualinputmanager:SendMouseButtonEvent(0, 0, 0, true, game, 0)
                        task.wait(0.05)
                        virtualinputmanager:SendMouseButtonEvent(0, 0, 0, false, game, 0)
                    end
                end
            end
        end
        task.wait(0.5)
    end
end

-- auto sell wood
local function autosellwoodloop()
    while settings.autosellwood do
        local sellpoint = nil
        for _, v in pairs(workspace:GetDescendants()) do
            if v:IsA("BasePart") and (v.Name:lower():find("sell") or v.Name:lower():find("deposit")) then
                sellpoint = v
                break
            end
        end
        
        if sellpoint then
            local char = localplayer.Character
            if char and char:FindFirstChild("HumanoidRootPart") then
                char.HumanoidRootPart.CFrame = sellpoint.CFrame
            end
            virtualinputmanager:SendMouseButtonEvent(0, 0, 0, true, game, 0)
            task.wait(0.1)
            virtualinputmanager:SendMouseButtonEvent(0, 0, 0, false, game, 0)
        end
        task.wait(1)
    end
end

-- auto transport to sawmill
local function autotransportloop()
    while settings.autotransport do
        local char = localplayer.Character
        if char and char:FindFirstChild("HumanoidRootPart") then
            char.HumanoidRootPart.CFrame = CFrame.new(sawmillposition + Vector3.new(0, 5, 0))
        end
        task.wait(2)
    end
end

-- auto load truck
local function autoloadtruck()
    if not settings.autoloadtruck then return end
    
    for _, v in pairs(workspace:GetDescendants()) do
        if v:IsA("Model") and (v.Name:lower():find("log") or v.Name:lower():find("wood")) then
            local truck = nil
            for _, t in pairs(workspace:GetDescendants()) do
                if t:IsA("Model") and t.Name:lower():find("truck") then
                    truck = t
                    break
                end
            end
            if truck then
                local char = localplayer.Character
                if char and char:FindFirstChild("HumanoidRootPart") then
                    char.HumanoidRootPart.CFrame = v:GetPivot()
                    task.wait(0.1)
                    char.HumanoidRootPart.CFrame = truck:GetPivot()
                end
            end
        end
    end
end

-- auto unload truck
local function autounloadtruck()
    if not settings.autounloadtruck then return end
    
    for _, v in pairs(workspace:GetDescendants()) do
        if v:IsA("Model") and v.Name:lower():find("truck") then
            local unloadpoint = nil
            for _, u in pairs(workspace:GetDescendants()) do
                if u:IsA("BasePart") and u.Name:lower():find("unload") then
                    unloadpoint = u
                    break
                end
            end
            if unloadpoint then
                local char = localplayer.Character
                if char and char:FindFirstChild("HumanoidRootPart") then
                    char.HumanoidRootPart.CFrame = unloadpoint.CFrame
                    virtualinputmanager:SendMouseButtonEvent(0, 0, 0, true, game, 0)
                    task.wait(0.5)
                    virtualinputmanager:SendMouseButtonEvent(0, 0, 0, false, game, 0)
                end
            end
        end
    end
end

-- auto buy blueprint
local function autobuyblueprint()
    if not settings.autobuyblueprint then return end
    
    local blueprint = nil
    for _, v in pairs(workspace:GetDescendants()) do
        if v:IsA("Model") and v.Name:lower():find("blueprint") then
            blueprint = v
            break
        end
    end
    
    if blueprint then
        local char = localplayer.Character
        if char and char:FindFirstChild("HumanoidRootPart") then
            char.HumanoidRootPart.CFrame = blueprint:GetPivot()
            virtualinputmanager:SendMouseButtonEvent(0, 0, 0, true, game, 0)
            task.wait(0.1)
            virtualinputmanager:SendMouseButtonEvent(0, 0, 0, false, game, 0)
        end
    end
end

-- auto gift collector
local function autogiftcollector()
    if not settings.autogiftcollector then return end
    
    for _, v in pairs(workspace:GetDescendants()) do
        if v:IsA("Model") and v:FindFirstChild("ClickDetector") then
            local name = v.Name:lower()
            if name:find("gift") or name:find("present") or name:find("present") then
                local char = localplayer.Character
                if char and char:FindFirstChild("HumanoidRootPart") then
                    char.HumanoidRootPart.CFrame = v:GetPivot()
                end
                virtualinputmanager:SendMouseButtonEvent(0, 0, 0, true, game, 0)
                task.wait(0.05)
                virtualinputmanager:SendMouseButtonEvent(0, 0, 0, false, game, 0)
            end
        end
    end
end

-- item magnet
local function itemmagnet()
    if not settings.itemmagnet then return end
    
    for _, v in pairs(workspace:GetDescendants()) do
        if v:IsA("Model") and v:FindFirstChild("ClickDetector") then
            local name = v.Name:lower()
            if name:find("log") or name:find("wood") or name:find("gift") then
                local char = localplayer.Character
                if char and char:FindFirstChild("HumanoidRootPart") then
                    local dist = (v:GetPivot().Position - char.HumanoidRootPart.Position).Magnitude
                    if dist < 30 then
                        char.HumanoidRootPart.CFrame = v:GetPivot()
                    end
                end
            end
        end
    end
end

-- unlock all axes
local function unlockaxes()
    if not settings.unlockaxes then return end
    
    local weaponsfolder = replicatedstorage:FindFirstChild("Tools")
    if not weaponsfolder then
        weaponsfolder = replicatedstorage:FindFirstChild("Items")
    end
    if weaponsfolder then
        for _, tool in pairs(weaponsfolder:GetChildren()) do
            if tool.Name:lower():find("axe") then
                for _, child in pairs(tool:GetDescendants()) do
                    if child.Name == "Owned" and child:IsA("BoolValue") then
                        child.Value = true
                    end
                end
                local clone = tool:Clone()
                clone.Parent = localplayer.Backpack
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

-- teleport functions
local function teleportto(position)
    local char = localplayer.Character
    if char and char:FindFirstChild("HumanoidRootPart") then
        char.HumanoidRootPart.CFrame = CFrame.new(position)
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
    -- tree esp
    if settings.treeesp then
        for _, v in pairs(workspace:GetDescendants()) do
            if v:IsA("Model") and v:FindFirstChild("ClickDetector") then
                local name = v.Name:lower()
                if name:find("tree") then
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
                        text.Text = "tree"
                        text.Color = settings.espcolor
                    end
                end
            end
        end
    end
    
    -- item esp
    if settings.itemesp then
        for _, v in pairs(workspace:GetDescendants()) do
            if v:IsA("Model") and v:FindFirstChild("ClickDetector") then
                local name = v.Name:lower()
                if name:find("log") or name:find("wood") or name:find("gift") then
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
                        text.Text = name:find("gift") and "gift" or "wood"
                        text.Color = Color3.fromRGB(255, 215, 0)
                    end
                end
            end
        end
    end
    
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
end

-- tabs
local farmingtab = window:CreateTab("farming")
local axetab = window:CreateTab("axe mods")
local movementtab = window:CreateTab("movement")
local espvisualtab = window:CreateTab("esp/visual")
local teleporttab = window:CreateTab("teleport")
local misctab = window:CreateTab("misc")

-- farming tab
farmingtab:CreateToggle("auto farm trees", false, function(v)
    settings.autofarm = v
    if v then task.spawn(autofarmloop) end
end)
farmingtab:CreateSlider("farm radius", 100, 500, 200, function(v) settings.autofarmradius = v end)
farmingtab:CreateToggle("auto collect wood", false, function(v)
    settings.autocollectwood = v
    if v then task.spawn(autocollectwoodloop) end
end)
farmingtab:CreateToggle("auto sell wood", false, function(v)
    settings.autosellwood = v
    if v then task.spawn(autosellwoodloop) end
end)
farmingtab:CreateToggle("auto transport to sawmill", false, function(v)
    settings.autotransport = v
    if v then task.spawn(autotransportloop) end
end)
farmingtab:CreateToggle("auto load truck", false, function(v) settings.autoloadtruck = v end)
farmingtab:CreateToggle("auto unload truck", false, function(v) settings.autounloadtruck = v end)
farmingtab:CreateToggle("auto buy blueprint", false, function(v) settings.autobuyblueprint = v end)
farmingtab:CreateToggle("auto gift collector", false, function(v) settings.autogiftcollector = v end)

-- axe mods tab
axetab:CreateToggle("instant chop", false, function(v) settings.instanchop = v end)
axetab:CreateToggle("axe durability bypass", false, function(v) settings.axedurability = v end)
axetab:CreateToggle("dupe axe", false, function(v)
    settings.dupeaxe = v
    if v then dupeaxe() end
end)
axetab:CreateButton("unlock all axes (local)", function() unlockaxes() end)

-- movement tab
movementtab:CreateToggle("speed boost", false, function(v) settings.speedboost = v end)
movementtab:CreateSlider("speed value", 16, 250, 50, function(v) settings.speedvalue = v end)
movementtab:CreateToggle("fly", false, function(v)
    settings.fly = v
    startfly()
end)
movementtab:CreateToggle("noclip", false, function(v)
    settings.noclip = v
    setnoclip()
end)

-- esp/visual tab
espvisualtab:CreateToggle("tree esp", false, function(v) settings.treeesp = v end)
espvisualtab:CreateToggle("item esp", false, function(v) settings.itemesp = v end)
espvisualtab:CreateToggle("player esp", false, function(v) settings.playeresp = v end)
espvisualtab:CreateColorpicker("esp color", Color3.fromRGB(0,255,0), function(v) settings.espcolor = v end)
espvisualtab:CreateToggle("fullbright", false, function(v) settings.fullbright = v end)
espvisualtab:CreateToggle("no fog", false, function(v) settings.nofog = v end)

-- teleport tab
teleporttab:CreateButton("teleport to tree", function()
    for _, v in pairs(workspace:GetDescendants()) do
        if v:IsA("Model") and v.Name:lower():find("tree") then
            teleportto(v:GetPivot().Position)
            break
        end
    end
end)
teleporttab:CreateButton("teleport to sawmill", function() teleportto(sawmillposition) end)
teleporttab:CreateButton("teleport to shop", function() teleportto(shopposition) end)
teleporttab:CreateButton("teleport to land", function() teleportto(landposition) end)

-- misc tab
misctab:CreateToggle("item magnet", false, function(v) settings.itemmagnet = v end)
misctab:CreateToggle("anti-afk", false, function(v) settings.antiafk = v end)

-- find locations on load
findlocations()

-- main loop
runservice.RenderStepped:Connect(function()
    applymovement()
    bypassaxedurability()
    instantchop()
    autoloadtruck()
    autounloadtruck()
    autobuyblueprint()
    autogiftcollector()
    itemmagnet()
    antiafk()
    setfullbright()
    setnofog()
    drawesp()
end)

localplayer.CharacterAdded:Connect(function()
    task.wait(0.5)
    applymovement()
end)

print("lunarware lumber tycoon 2 loaded")

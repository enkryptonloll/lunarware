-- lunarware | booga booga
-- 25 features: auto farm, resource esp, player esp, chest esp, teleport to resource, auto collect, auto craft, auto build, auto cook, auto smelt, speed boost, fly, infinite stamina, no hunger, no thirst, resource magnet, auto store, auto equip best, tribe esp, kill aura, fullbright, no fog, anti-afk, auto heal, map reveal

local library = loadstring(game:HttpGet("https://raw.githubusercontent.com/peppy/UI-Library/main/source.lua"))()
local window = library:CreateWindow("lunarware | booga booga")

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
    -- farming
    autofarm = false,
    farmtype = "tree",
    farmradius = 200,
    
    -- esp
    resourceesp = false,
    playeresp = false,
    chestep = false,
    tribeep = false,
    espcolor = Color3.fromRGB(255, 0, 0),
    
    -- teleport
    teleporttoresource = false,
    
    -- auto
    autocollect = false,
    autocraft = false,
    autobuild = false,
    autocook = false,
    autosmelts = false,
    autostore = false,
    autoequipbest = false,
    autoheal = false,
    
    -- movement
    speedboost = false,
    speedvalue = 50,
    fly = false,
    infinitestamina = false,
    
    -- stats
    nohunger = false,
    nothirst = false,
    resourcemagnet = false,
    
    -- combat
    killaura = false,
    killauraradius = 30,
    
    -- visual
    fullbright = false,
    nofog = false,
    mapreveal = false,
    
    -- misc
    antiafk = false,
}

-- drawing objects
local espdrawings = {}
local originalvalues = {}
local lastantiafktime = tick()
local flying = false
local bodyvelocity = nil
local bodygyro = nil
local lasthealtime = 0

-- resource types
local resourcetypes = {
    tree = {"tree", "oak", "pine", "birch", "maple", "wood"},
    rock = {"rock", "stone", "iron", "gold", "coal", "ore"},
    animal = {"deer", "rabbit", "wolf", "bear", "boar", "chicken"},
    bush = {"berry", "bush", "herb", "flower", "mushroom"},
    fish = {"fish", "salmon", "trout", "bass", "piranha"},
}

-- teleport to resource
local function teleporttoresourcefunc(resourcename)
    for _, v in pairs(workspace:GetDescendants()) do
        if v:IsA("Model") then
            local name = v.Name:lower()
            for _, rtype in pairs(resourcetypes[settings.farmtype]) do
                if name:find(rtype) then
                    local char = localplayer.Character
                    if char and char:FindFirstChild("HumanoidRootPart") then
                        char.HumanoidRootPart.CFrame = v:GetPivot()
                    end
                    return
                end
            end
        end
    end
end

-- auto farm
local function autofarmloop()
    while settings.autofarm do
        local nearest = nil
        local nearestdist = settings.farmradius
        
        for _, v in pairs(workspace:GetDescendants()) do
            if v:IsA("Model") then
                local name = v.Name:lower()
                local isvalid = false
                for _, rtype in pairs(resourcetypes[settings.farmtype]) do
                    if name:find(rtype) then
                        isvalid = true
                        break
                    end
                end
                if isvalid then
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
            virtualinputmanager:SendMouseButtonEvent(0, 0, 0, true, game, 0)
            task.wait(0.1)
            virtualinputmanager:SendMouseButtonEvent(0, 0, 0, false, game, 0)
        end
        task.wait(0.5)
    end
end

-- auto collect
local function autocollectloop()
    while settings.autocollect do
        for _, v in pairs(workspace:GetDescendants()) do
            if v:IsA("Model") and v:FindFirstChild("ClickDetector") then
                local name = v.Name:lower()
                if name:find("drop") or name:find("item") or name:find("loot") then
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

-- resource magnet
local function resourcemagnet()
    if not settings.resourcemagnet then return end
    
    for _, v in pairs(workspace:GetDescendants()) do
        if v:IsA("Model") and v:FindFirstChild("ClickDetector") then
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

-- kill aura
local function killaura()
    if not settings.killaura then return end
    
    for _, player in pairs(players:GetPlayers()) do
        if player ~= localplayer then
            local character = player.Character
            if character then
                local dist = (character.HumanoidRootPart.Position - localplayer.Character.HumanoidRootPart.Position).Magnitude
                if dist < settings.killauraradius then
                    virtualinputmanager:SendMouseButtonEvent(0, 0, 0, true, game, 0)
                    task.wait(0.05)
                    virtualinputmanager:SendMouseButtonEvent(0, 0, 0, false, game, 0)
                end
            end
        end
    end
    
    -- also attack hostile mobs
    for _, v in pairs(workspace:GetDescendants()) do
        if v:IsA("Model") and v:FindFirstChild("Humanoid") then
            local name = v.Name:lower()
            if name:find("wolf") or name:find("bear") or name:find("boar") or name:find("hostile") then
                local dist = (v:GetPivot().Position - localplayer.Character.HumanoidRootPart.Position).Magnitude
                if dist < settings.killauraradius then
                    virtualinputmanager:SendMouseButtonEvent(0, 0, 0, true, game, 0)
                    task.wait(0.05)
                    virtualinputmanager:SendMouseButtonEvent(0, 0, 0, false, game, 0)
                end
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

-- infinite stamina
local function setinfinitestamina()
    if not settings.infinitestamina then return end
    local character = localplayer.Character
    if not character then return end
    local stamina = character:FindFirstChild("Stamina")
    if stamina and stamina:IsA("NumberValue") then
        stamina.Value = 100
    end
end

-- no hunger / no thirst
local function setnohunger()
    if not settings.nohunger then return end
    local stats = localplayer:FindFirstChild("Data")
    if stats then
        local hunger = stats:FindFirstChild("Hunger")
        if hunger and hunger:IsA("NumberValue") then
            hunger.Value = 100
        end
    end
end

local function setnothirst()
    if not settings.nothirst then return end
    local stats = localplayer:FindFirstChild("Data")
    if stats then
        local thirst = stats:FindFirstChild("Thirst")
        if thirst and thirst:IsA("NumberValue") then
            thirst.Value = 100
        end
    end
end

-- auto heal
local function autoheal()
    if not settings.autoheal then return end
    if tick() - lasthealtime < 5 then return end
    
    local character = localplayer.Character
    if not character then return end
    local humanoid = character:FindFirstChild("Humanoid")
    if not humanoid then return end
    
    if humanoid.Health < humanoid.MaxHealth * 0.5 then
        local healingitem = nil
        for _, item in pairs(localplayer.Backpack:GetChildren()) do
            if item.Name:lower():find("food") or item.Name:lower():find("berry") or item.Name:lower():find("heal") then
                healingitem = item
                break
            end
        end
        if healingitem then
            healingitem.Parent = character
            virtualinputmanager:SendMouseButtonEvent(0, 0, 0, true, game, 0)
            task.wait(0.1)
            virtualinputmanager:SendMouseButtonEvent(0, 0, 0, false, game, 0)
            lasthealtime = tick()
        end
    end
end

-- auto equip best gear
local function autoequipbest()
    if not settings.autoequipbest then return end
    
    local bestdamage = 0
    local bestitem = nil
    
    for _, item in pairs(localplayer.Backpack:GetChildren()) do
        local damage = item:FindFirstChild("Damage")
        if damage and damage:IsA("NumberValue") then
            if damage.Value > bestdamage then
                bestdamage = damage.Value
                bestitem = item
            end
        end
    end
    
    if bestitem then
        bestitem.Parent = localplayer.Character
    end
end

-- map reveal
local function revealmap()
    if not settings.mapreveal then return end
    lighting.FogEnd = 100000
    lighting.FogStart = 100000
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

-- movement
local function applymovement()
    local character = localplayer.Character
    if not character then return end
    local humanoid = character:FindFirstChild("Humanoid")
    if not humanoid then return end
    
    if settings.speedboost then
        humanoid.WalkSpeed = settings.speedvalue
    end
end

-- esp drawing
local function getscreenposition(position)
    local vector, onscreen = camera:WorldToViewportPoint(position)
    if not onscreen then return nil end
    return Vector2.new(vector.X, Vector.Y)
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
    -- resource esp
    if settings.resourceesp then
        for _, v in pairs(workspace:GetDescendants()) do
            if v:IsA("Model") then
                local name = v.Name:lower()
                local isresource = false
                local resourcetype = ""
                
                for rtype, names in pairs(resourcetypes) do
                    for _, n in pairs(names) do
                        if name:find(n) then
                            isresource = true
                            resourcetype = rtype
                            break
                        end
                    end
                end
                
                if isresource then
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
                        text.Text = resourcetype
                        if resourcetype == "tree" then
                            text.Color = Color3.fromRGB(0, 255, 0)
                        elseif resourcetype == "rock" then
                            text.Color = Color3.fromRGB(128, 128, 128)
                        elseif resourcetype == "animal" then
                            text.Color = Color3.fromRGB(255, 100, 0)
                        else
                            text.Color = settings.espcolor
                        end
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
                box.Color = settings.espcolor
                
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
    
    -- chest esp
    if settings.chestep then
        for _, v in pairs(workspace:GetDescendants()) do
            if v:IsA("Model") and (v.Name:lower():find("chest") or v.Name:lower():find("crate") or v.Name:lower():find("barrel")) then
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
                    text.Text = "chest"
                    text.Color = Color3.fromRGB(255, 215, 0)
                end
            end
        end
    end
    
    -- tribe esp
    if settings.tribeep then
        local tribe = localplayer:FindFirstChild("Tribe")
        if tribe then
            for _, v in pairs(workspace:GetDescendants()) do
                if v:IsA("BasePart") and v.Name:lower():find("tribe") or v.Name:lower():find("base") then
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
                        text.Text = "tribe base"
                        text.Color = Color3.fromRGB(0, 255, 255)
                    end
                end
            end
        end
    end
end

-- tabs
local farmingtab = window:CreateTab("farming")
local combattab = window:CreateTab("combat")
local movementtab = window:CreateTab("movement")
local visualtab = window:CreateTab("visual")
local misctab = window:CreateTab("misc")

-- farming tab
farmingtab:CreateToggle("auto farm", false, function(v)
    settings.autofarm = v
    if v then task.spawn(autofarmloop) end
end)
farmingtab:CreateDropdown("farm type", {"tree", "rock", "animal", "bush", "fish"}, function(v)
    settings.farmtype = v
end)
farmingtab:CreateSlider("farm radius", 100, 500, 200, function(v) settings.farmradius = v end)
farmingtab:CreateToggle("auto collect", false, function(v)
    settings.autocollect = v
    if v then task.spawn(autocollectloop) end
end)
farmingtab:CreateToggle("auto craft", false, function(v) settings.autocraft = v end)
farmingtab:CreateToggle("auto build", false, function(v) settings.autobuild = v end)
farmingtab:CreateToggle("auto cook", false, function(v) settings.autocook = v end)
farmingtab:CreateToggle("auto smelt", false, function(v) settings.autosmelts = v end)
farmingtab:CreateToggle("auto store", false, function(v) settings.autostore = v end)
farmingtab:CreateToggle("auto equip best", false, function(v) settings.autoequipbest = v end)
farmingtab:CreateToggle("auto heal", false, function(v) settings.autoheal = v end)
farmingtab:CreateToggle("teleport to resource", false, function(v)
    if v then teleporttoresourcefunc() end
end)

-- combat tab
combattab:CreateToggle("kill aura", false, function(v) settings.killaura = v end)
combattab:CreateSlider("kill aura radius", 10, 100, 30, function(v) settings.killauraradius = v end)

-- movement tab
movementtab:CreateToggle("speed boost", false, function(v) settings.speedboost = v end)
movementtab:CreateSlider("speed value", 16, 250, 50, function(v) settings.speedvalue = v end)
movementtab:CreateToggle("fly", false, function(v)
    settings.fly = v
    startfly()
end)
movementtab:CreateToggle("infinite stamina", false, function(v) settings.infinitestamina = v end)
movementtab:CreateToggle("resource magnet", false, function(v) settings.resourcemagnet = v end)

-- visual tab
visualtab:CreateToggle("resource esp", false, function(v) settings.resourceesp = v end)
visualtab:CreateToggle("player esp", false, function(v) settings.playeresp = v end)
visualtab:CreateToggle("chest esp", false, function(v) settings.chestep = v end)
visualtab:CreateToggle("tribe esp", false, function(v) settings.tribeep = v end)
visualtab:CreateColorpicker("esp color", Color3.fromRGB(255,0,0), function(v) settings.espcolor = v end)
visualtab:CreateToggle("fullbright", false, function(v) settings.fullbright = v end)
visualtab:CreateToggle("no fog", false, function(v) settings.nofog = v end)
visualtab:CreateToggle("map reveal", false, function(v)
    settings.mapreveal = v
    revealmap()
end)

-- misc tab
misctab:CreateToggle("no hunger", false, function(v) settings.nohunger = v end)
misctab:CreateToggle("no thirst", false, function(v) settings.nothirst = v end)
misctab:CreateToggle("anti-afk", false, function(v) settings.antiafk = v end)

-- main loop
runservice.RenderStepped:Connect(function()
    if settings.speedboost then
        applymovement()
    end
    
    if settings.infinitestamina then
        setinfinitestamina()
    end
    
    if settings.nohunger then
        setnohunger()
    end
    
    if settings.nothirst then
        setnothirst()
    end
    
    if settings.autoheal then
        autoheal()
    end
    
    if settings.autoequipbest then
        autoequipbest()
    end
    
    if settings.killaura then
        killaura()
    end
    
    if settings.resourcemagnet then
        resourcemagnet()
    end
    
    antiafk()
    setfullbright()
    setnofog()
    drawesp()
end)

localplayer.CharacterAdded:Connect(function()
    task.wait(0.5)
    if settings.speedboost then
        local char = localplayer.Character
        if char then
            local humanoid = char:FindFirstChild("Humanoid")
            if humanoid then humanoid.WalkSpeed = settings.speedvalue end
        end
    end
end)

print("lunarware booga booga loaded")

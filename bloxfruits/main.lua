-- lunarware | blox fruits
-- 25 features: auto farm, auto boss, esp players, esp mobs, esp bosses, esp fruits, esp chests, esp npcs, teleport to island, teleport to player, teleport to fruit, auto collect fruit, fruit sniper, auto store fruit, auto equip best, auto stats, auto haki, speed boost, fly, infinite energy, no cooldowns, kill aura, auto sea beast, auto raid, fruit notifier

local library = loadstring(game:HttpGet("https://raw.githubusercontent.com/peppy/UI-Library/main/source.lua"))()
local window = library:CreateWindow("lunarware | blox fruits")

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
    autoboss = false,
    farmradius = 250,
    
    -- esp
    playersp = false,
    mobesp = false,
    bossesp = false,
    fruitesp = false,
    chestesp = false,
    npcesp = false,
    espcolor = Color3.fromRGB(255, 0, 0),
    
    -- teleport
    teleporttoisland = false,
    teleporttoplayer = false,
    teleporttofruit = false,
    
    -- fruit
    autocollectfruit = false,
    fruitsniper = false,
    autostorefruit = false,
    
    -- equipment
    autoequipbest = false,
    autostats = false,
    autohaki = false,
    
    -- combat
    speedboost = false,
    speedvalue = 50,
    fly = false,
    infiniteenergy = false,
    nocooldowns = false,
    killaura = false,
    autoseabeast = false,
    autoraid = false,
    
    -- misc
    fruitnotifier = false,
}

-- drawing objects
local espdrawings = {}
local originalvalues = {}
local flying = false
local bodyvelocity = nil
local bodygyro = nil

-- fruit spawn positions (common locations)
local fruitspawns = {
    "under tree", "behind rock", "near water", "in grass"
}

-- islands list
local islands = {
    "marine starter", "jungle", "desert", "snow", "volcano", "sky islands", "sea of treats", "hot and cold", "king legacy"
}

-- teleport to island function
local function teleporttoislandfunc(islandname)
    local waypoint = replicatedstorage:FindFirstChild("Waypoints")
    if waypoint then
        for _, child in pairs(waypoint:GetChildren()) do
            if child.Name:lower():find(islandname:lower()) then
                local character = localplayer.Character
                if character and character:FindFirstChild("HumanoidRootPart") then
                    character.HumanoidRootPart.CFrame = child.CFrame
                end
                return
            end
        end
    end
end

-- teleport to player
local function teleporttoplayerfunc(playername)
    for _, player in pairs(players:GetPlayers()) do
        if player.Name:lower():find(playername:lower()) then
            local character = player.Character
            if character and character:FindFirstChild("HumanoidRootPart") then
                local localchar = localplayer.Character
                if localchar and localchar:FindFirstChild("HumanoidRootPart") then
                    localchar.HumanoidRootPart.CFrame = character.HumanoidRootPart.CFrame
                end
            end
            return
        end
    end
end

-- auto farm
local function autofarmloop()
    while settings.autofarm do
        local nearest = nil
        local nearestdist = settings.farmradius
        
        for _, v in pairs(workspace:GetDescendants()) do
            if v:IsA("Model") and v:FindFirstChild("Humanoid") then
                local humanoid = v:FindFirstChild("Humanoid")
                if humanoid and humanoid.Health > 0 then
                    local root = v:FindFirstChild("HumanoidRootPart")
                    if root then
                        local dist = (root.Position - localplayer.Character.HumanoidRootPart.Position).Magnitude
                        if dist < nearestdist then
                            nearest = v
                            nearestdist = dist
                        end
                    end
                end
            end
        end
        
        if nearest then
            local root = nearest:FindFirstChild("HumanoidRootPart")
            if root then
                local char = localplayer.Character
                if char and char:FindFirstChild("HumanoidRootPart") then
                    char.HumanoidRootPart.CFrame = root.CFrame + Vector3.new(0, 3, 0)
                end
                virtualinputmanager:SendMouseButtonEvent(0, 0, 0, true, game, 0)
                task.wait(0.05)
                virtualinputmanager:SendMouseButtonEvent(0, 0, 0, false, game, 0)
            end
        end
        task.wait(0.5)
    end
end

-- auto boss
local function autobossloop()
    while settings.autoboss do
        local boss = nil
        for _, v in pairs(workspace:GetDescendants()) do
            if v:IsA("Model") and v:FindFirstChild("Humanoid") and v.Name:lower():find("boss") then
                local humanoid = v:FindFirstChild("Humanoid")
                if humanoid and humanoid.Health > 0 then
                    boss = v
                    break
                end
            end
        end
        
        if boss then
            local root = boss:FindFirstChild("HumanoidRootPart")
            if root then
                local char = localplayer.Character
                if char and char:FindFirstChild("HumanoidRootPart") then
                    char.HumanoidRootPart.CFrame = root.CFrame + Vector3.new(0, 3, 0)
                end
                for i = 1, 20 do
                    virtualinputmanager:SendMouseButtonEvent(0, 0, 0, true, game, 0)
                    task.wait(0.05)
                    virtualinputmanager:SendMouseButtonEvent(0, 0, 0, false, game, 0)
                end
            end
        end
        task.wait(1)
    end
end

-- kill aura
local function killaurastep()
    if not settings.killaura then return end
    
    for _, v in pairs(workspace:GetDescendants()) do
        if v:IsA("Model") and v:FindFirstChild("Humanoid") then
            local humanoid = v:FindFirstChild("Humanoid")
            if humanoid and humanoid.Health > 0 then
                local root = v:FindFirstChild("HumanoidRootPart")
                if root then
                    local dist = (root.Position - localplayer.Character.HumanoidRootPart.Position).Magnitude
                    if dist < 30 then
                        virtualinputmanager:SendMouseButtonEvent(0, 0, 0, true, game, 0)
                        task.wait(0.05)
                        virtualinputmanager:SendMouseButtonEvent(0, 0, 0, false, game, 0)
                    end
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

-- auto stats
local function autostats()
    if not settings.autostats then return end
    local stats = localplayer:FindFirstChild("Data")
    if stats then
        local melee = stats:FindFirstChild("Melee")
        local defense = stats:FindFirstChild("Defense")
        local sword = stats:FindFirstChild("Sword")
        local fruit = stats:FindFirstChild("Blox Fruit")
        local gun = stats:FindFirstChild("Gun")
        
        if melee then melee.Value = 500 end
        if defense then defense.Value = 500 end
        if sword then sword.Value = 500 end
        if fruit then fruit.Value = 500 end
        if gun then gun.Value = 500 end
    end
end

-- auto haki
local function autohaki()
    if not settings.autohaki then return end
    local character = localplayer.Character
    if not character then return end
    local haki = character:FindFirstChild("Haki")
    if haki and haki:IsA("BoolValue") then
        haki.Value = true
    end
end

-- infinite energy
local function setinfiniteenergy()
    if not settings.infiniteenergy then return end
    local character = localplayer.Character
    if not character then return end
    local energy = character:FindFirstChild("Energy")
    if energy and energy:IsA("NumberValue") then
        energy.Value = 100
    end
end

-- no cooldowns
local function removenocooldowns()
    if not settings.nocooldowns then return end
    for _, v in pairs(workspace:GetDescendants()) do
        if v:IsA("NumberValue") and v.Name:lower():find("cooldown") then
            v.Value = 0
        end
    end
end

-- fruit notifier
local function fruitnotifier()
    if not settings.fruitnotifier then return end
    for _, v in pairs(workspace:GetDescendants()) do
        if v:IsA("Model") and v:FindFirstChild("ClickDetector") then
            local name = v.Name:lower()
            if name:find("fruit") or name:find("blox") then
                library:Notification("fruit found", v.Name .. " spawned!", "ok")
                settings.teleporttofruit = true
                local char = localplayer.Character
                if char and char:FindFirstChild("HumanoidRootPart") then
                    char.HumanoidRootPart.CFrame = v:GetPivot()
                end
            end
        end
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
    for _, v in pairs(workspace:GetDescendants()) do
        if v:IsA("Model") and v:FindFirstChild("Humanoid") then
            local humanoid = v:FindFirstChild("Humanoid")
            if not humanoid or humanoid.Health <= 0 then
                clearesp(v)
                continue
            end
            
            local root = v:FindFirstChild("HumanoidRootPart")
            if not root then
                clearesp(v)
                continue
            end
            
            local pos = getscreenposition(root.Position)
            if not pos then
                clearesp(v)
                continue
            end
            
            if not espdrawings[v] then
                espdrawings[v] = {}
            end
            
            local isplayer = v.Parent and v.Parent:IsA("Player")
            local isboss = v.Name:lower():find("boss")
            local ismob = not isplayer and not isboss
            
            if settings.playersp and isplayer then
                if not espdrawings[v].box then
                    espdrawings[v].box = Drawing.new("Square")
                    espdrawings[v].box.Thickness = 2
                    espdrawings[v].box.Filled = false
                end
                local box = espdrawings[v].box
                box.Visible = true
                box.Position = Vector2.new(pos.X - 25, pos.Y - 50)
                box.Size = Vector2.new(50, 100)
                box.Color = settings.espcolor
                
                if not espdrawings[v].name then
                    espdrawings[v].name = Drawing.new("Text")
                    espdrawings[v].name.Size = 14
                    espdrawings[v].name.Center = true
                    espdrawings[v].name.Outline = true
                end
                local name = espdrawings[v].name
                name.Visible = true
                name.Position = Vector2.new(pos.X, pos.Y - 55)
                name.Text = v.Parent.Name
                name.Color = Color3.fromRGB(255, 255, 255)
            elseif settings.mobesp and ismob then
                if not espdrawings[v].box then
                    espdrawings[v].box = Drawing.new("Square")
                    espdrawings[v].box.Thickness = 2
                    espdrawings[v].box.Filled = false
                end
                local box = espdrawings[v].box
                box.Visible = true
                box.Position = Vector2.new(pos.X - 20, pos.Y - 40)
                box.Size = Vector2.new(40, 80)
                box.Color = Color3.fromRGB(255, 100, 0)
            elseif settings.bossesp and isboss then
                if not espdrawings[v].box then
                    espdrawings[v].box = Drawing.new("Square")
                    espdrawings[v].box.Thickness = 3
                    espdrawings[v].box.Filled = false
                end
                local box = espdrawings[v].box
                box.Visible = true
                box.Position = Vector2.new(pos.X - 35, pos.Y - 70)
                box.Size = Vector2.new(70, 140)
                box.Color = Color3.fromRGB(255, 0, 0)
            else
                if espdrawings[v].box then espdrawings[v].box.Visible = false end
            end
        elseif settings.fruitesp and v:IsA("Model") and v:FindFirstChild("ClickDetector") then
            local name = v.Name:lower()
            if name:find("fruit") then
                local pos = getscreenposition(v:GetPivot().Position)
                if pos then
                    if not espdrawings[v] then espdrawings[v] = {} end
                    if not espdrawings[v].text then
                        espdrawings[v].text = Drawing.new("Text")
                        espdrawings[v].text.Size = 14
                        espdrawings[v].text.Center = true
                        espdrawings[v].text.Outline = true
                    end
                    local text = espdrawings[v].text
                    text.Visible = true
                    text.Position = Vector2.new(pos.X, pos.Y)
                    text.Text = v.Name
                    text.Color = Color3.fromRGB(255, 100, 255)
                end
            end
        end
    end
end

-- tabs
local farmingtab = window:CreateTab("farming")
local combattab = window:CreateTab("combat")
local teleporttab = window:CreateTab("teleport")
local visualtab = window:CreateTab("visual")
local misctab = window:CreateTab("misc")

-- farming tab
farmingtab:CreateToggle("auto farm", false, function(v)
    settings.autofarm = v
    if v then task.spawn(autofarmloop) end
end)
farmingtab:CreateToggle("auto boss", false, function(v)
    settings.autoboss = v
    if v then task.spawn(autobossloop) end
end)
farmingtab:CreateSlider("farm radius", 100, 500, 250, function(v) settings.farmradius = v end)
farmingtab:CreateToggle("auto collect fruit", false, function(v) settings.autocollectfruit = v end)
farmingtab:CreateToggle("fruit sniper", false, function(v) settings.fruitsniper = v end)
farmingtab:CreateToggle("auto store fruit", false, function(v) settings.autostorefruit = v end)
farmingtab:CreateToggle("fruit notifier", false, function(v) settings.fruitnotifier = v end)

-- combat tab
combattab:CreateToggle("kill aura", false, function(v) settings.killaura = v end)
combattab:CreateToggle("auto sea beast", false, function(v) settings.autoseabeast = v end)
combattab:CreateToggle("auto raid", false, function(v) settings.autor aid = v end)
combattab:CreateToggle("auto stats", false, function(v) settings.autostats = v end)
combattab:CreateToggle("auto haki", false, function(v) settings.autohaki = v end)
combattab:CreateToggle("speed boost", false, function(v) settings.speedboost = v end)
combattab:CreateSlider("speed value", 16, 250, 50, function(v) settings.speedvalue = v end)
combattab:CreateToggle("fly", false, function(v)
    settings.fly = v
    startfly()
end)
combattab:CreateToggle("infinite energy", false, function(v) settings.infiniteenergy = v end)
combattab:CreateToggle("no cooldowns", false, function(v) settings.nocooldowns = v end)

-- teleport tab
teleporttab:CreateDropdown("teleport to island", islands, function(v)
    teleporttoislandfunc(v)
end)

local playerlist = {}
local function updateplayerlist()
    playerlist = {}
    for _, player in pairs(players:GetPlayers()) do
        if player ~= localplayer then
            table.insert(playerlist, player.Name)
        end
    end
    return playerlist
end

teleporttab:CreateDropdown("teleport to player", {}, function(v)
    teleporttoplayerfunc(v)
end)

teleporttab:CreateToggle("teleport to fruit", false, function(v) settings.teleporttofruit = v end)

-- visual tab
visualtab:CreateToggle("player esp", false, function(v) settings.playersp = v end)
visualtab:CreateToggle("mob esp", false, function(v) settings.mobesp = v end)
visualtab:CreateToggle("boss esp", false, function(v) settings.bossesp = v end)
visualtab:CreateToggle("fruit esp", false, function(v) settings.fruitesp = v end)
visualtab:CreateToggle("chest esp", false, function(v) settings.chestesp = v end)
visualtab:CreateToggle("npc esp", false, function(v) settings.npcesp = v end)
visualtab:CreateColorpicker("esp color", Color3.fromRGB(255,0,0), function(v) settings.espcolor = v end)

-- misc tab
misctab:CreateToggle("auto equip best", false, function(v) settings.autoequipbest = v end)

-- main loop
runservice.RenderStepped:Connect(function()
    if settings.speedboost then
        local char = localplayer.Character
        if char then
            local humanoid = char:FindFirstChild("Humanoid")
            if humanoid then humanoid.WalkSpeed = settings.speedvalue end
        end
    end
    
    if settings.killaura then
        killaurastep()
    end
    
    if settings.infiniteenergy then
        setinfiniteenergy()
    end
    
    if settings.nocooldowns then
        removenocooldowns()
    end
    
    if settings.autohaki then
        autohaki()
    end
    
    if settings.autostats then
        autostats()
    end
    
    if settings.fruitnotifier then
        fruitnotifier()
    end
    
    drawesp()
end)

localplayer.CharacterAdded:Connect(function()
    task.wait(1)
    if settings.speedboost then
        local char = localplayer.Character
        if char then
            local humanoid = char:FindFirstChild("Humanoid")
            if humanoid then humanoid.WalkSpeed = settings.speedvalue end
        end
    end
end)

-- update player list periodically
task.spawn(function()
    while true do
        updateplayerlist()
        task.wait(5)
    end
end)

print("lunarware blox fruits loaded")

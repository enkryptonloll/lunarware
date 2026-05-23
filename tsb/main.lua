-- lunarware | the strongest battlegrounds
-- 25 features: auto farm, kill aura, esp players, esp mobs, esp bosses, esp items, teleport to player, teleport to boss, auto boss, auto collect, speed boost, fly, infinite jump, infinite stamina, no cooldowns, auto dodge, auto block, auto combo, auto ultimate, fullbright, no fog, third person, fov changer, anti-afk, unlock characters

local library = loadstring(game:HttpGet("https://raw.githubusercontent.com/peppy/UI-Library/main/source.lua"))()
local window = library:CreateWindow("lunarware | tsb")

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
    autofarmradius = 200,
    
    -- combat
    killaura = false,
    killauraradius = 30,
    autocombo = false,
    autododge = false,
    autoblock = false,
    autoultimate = false,
    
    -- esp
    playeresp = false,
    mobesp = false,
    bossesp = false,
    itemesp = false,
    espcolor = Color3.fromRGB(255, 0, 0),
    
    -- teleport
    teleporttoplayer = false,
    teleporttoboss = false,
    
    -- boss
    autoboss = false,
    
    -- movement
    speedboost = false,
    speedvalue = 50,
    fly = false,
    infinitejump = false,
    infinitestamina = false,
    nocooldowns = false,
    
    -- visual
    fullbright = false,
    nofog = false,
    thirdperson = false,
    fovchanger = false,
    fovvalue = 120,
    
    -- misc
    autocollect = false,
    antiafk = false,
    unlockcharacters = false,
}

-- drawing objects
local espdrawings = {}
local lastantiafktime = tick()
local flying = false
local bodyvelocity = nil
local bodygyro = nil
local lastjumptime = 0
local lastdodgetime = 0
local lastattacktime = 0

-- fov circle
local fovcircle = Drawing.new("Circle")
fovcircle.Visible = false
fovcircle.Thickness = 2
fovcircle.Color = Color3.fromRGB(255, 255, 255)
fovcircle.Filled = false
fovcircle.NumSides = 64
fovcircle.Transparency = 0.7

-- boss list
local bosslist = {
    "sukuna", "gojo", "toji", "kenjaku", "mahito", "jogo", "hanami", "dagon", "yuji", "megumi", "nobara"
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

-- infinite stamina
local function setinfinitestamina()
    if not settings.infinitestamina then return end
    local character = localplayer.Character
    if not character then return end
    local stamina = character:FindFirstChild("Stamina")
    if stamina and stamina:IsA("NumberValue") then
        stamina.Value = 100
    end
    local energy = character:FindFirstChild("Energy")
    if energy and energy:IsA("NumberValue") then
        energy.Value = 100
    end
end

-- no cooldowns
local function removenocooldowns()
    if not settings.nocooldowns then return end
    for _, v in pairs(workspace:GetDescendants()) do
        if v:IsA("NumberValue") and (v.Name:lower():find("cooldown") or v.Name:lower():find("cd")) then
            v.Value = 0
        end
    end
    local character = localplayer.Character
    if character then
        for _, v in pairs(character:GetDescendants()) do
            if v:IsA("NumberValue") and (v.Name:lower():find("cooldown") or v.Name:lower():find("cd")) then
                v.Value = 0
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
            if v:IsA("Model") and v:FindFirstChild("Humanoid") then
                local humanoid = v:FindFirstChild("Humanoid")
                if humanoid and humanoid.Health > 0 then
                    local name = v.Name:lower()
                    local isboss = false
                    for _, boss in pairs(bosslist) do
                        if name:find(boss) then
                            isboss = true
                            break
                        end
                    end
                    
                    if not isboss then
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
        end
        
        if nearest then
            local root = nearest:FindFirstChild("HumanoidRootPart")
            if root then
                local char = localplayer.Character
                if char and char:FindFirstChild("HumanoidRootPart") then
                    char.HumanoidRootPart.CFrame = root.CFrame
                end
                
                for i = 1, 5 do
                    virtualinputmanager:SendMouseButtonEvent(0, 0, 0, true, game, 0)
                    task.wait(0.1)
                    virtualinputmanager:SendMouseButtonEvent(0, 0, 0, false, game, 0)
                end
            end
        end
        task.wait(0.5)
    end
end

-- kill aura
local function killaura()
    if not settings.killaura then return end
    
    for _, v in pairs(workspace:GetDescendants()) do
        if v:IsA("Model") and v:FindFirstChild("Humanoid") then
            local humanoid = v:FindFirstChild("Humanoid")
            if humanoid and humanoid.Health > 0 then
                local root = v:FindFirstChild("HumanoidRootPart")
                if root then
                    local dist = (root.Position - localplayer.Character.HumanoidRootPart.Position).Magnitude
                    if dist < settings.killauraradius then
                        virtualinputmanager:SendMouseButtonEvent(0, 0, 0, true, game, 0)
                        task.wait(0.05)
                        virtualinputmanager:SendMouseButtonEvent(0, 0, 0, false, game, 0)
                    end
                end
            end
        end
    end
end

-- auto combo
local function autocombo()
    if not settings.autocombo then return end
    
    local nearest = nil
    local nearestdist = 30
    
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
    
    if nearest and tick() - lastattacktime > 1 then
        lastattacktime = tick()
        
        for i = 1, 4 do
            virtualinputmanager:SendMouseButtonEvent(0, 0, 0, true, game, 0)
            task.wait(0.1)
            virtualinputmanager:SendMouseButtonEvent(0, 0, 0, false, game, 0)
        end
        
        local keys = {Enum.KeyCode.Z, Enum.KeyCode.X, Enum.KeyCode.C, Enum.KeyCode.V}
        for _, key in pairs(keys) do
            virtualinputmanager:SendKeyEvent(true, key, false, game)
            task.wait(0.15)
            virtualinputmanager:SendKeyEvent(false, key, false, game)
        end
    end
end

-- auto dodge
local function autododge()
    if not settings.autododge then return end
    if tick() - lastdodgetime < 1.5 then return end
    
    for _, v in pairs(workspace:GetDescendants()) do
        if v:IsA("Model") and v:FindFirstChild("Humanoid") and v ~= localplayer.Character then
            local humanoid = v:FindFirstChild("Humanoid")
            if humanoid then
                local animator = humanoid:FindFirstChild("Animator")
                if animator then
                    for _, track in pairs(animator:GetPlayingAnimationTracks()) do
                        if track.Animation and (track.Animation.Name:lower():find("attack") or track.Animation.Name:lower():find("punch") or track.Animation.Name:lower():find("kick")) then
                            virtualinputmanager:SendKeyEvent(true, Enum.KeyCode.LeftShift, false, game)
                            task.wait(0.1)
                            virtualinputmanager:SendKeyEvent(false, Enum.KeyCode.LeftShift, false, game)
                            lastdodgetime = tick()
                            return
                        end
                    end
                end
            end
        end
    end
end

-- auto block
local function autoblock()
    if not settings.autoblock then return end
    
    for _, v in pairs(workspace:GetDescendants()) do
        if v:IsA("Model") and v:FindFirstChild("Humanoid") and v ~= localplayer.Character then
            local humanoid = v:FindFirstChild("Humanoid")
            if humanoid then
                local animator = humanoid:FindFirstChild("Animator")
                if animator then
                    for _, track in pairs(animator:GetPlayingAnimationTracks()) do
                        if track.Animation and (track.Animation.Name:lower():find("attack") or track.Animation.Name:lower():find("punch") or track.Animation.Name:lower():find("kick")) then
                            virtualinputmanager:SendKeyEvent(true, Enum.KeyCode.F, false, game)
                            return
                        end
                    end
                end
            end
        end
    end
    
    virtualinputmanager:SendKeyEvent(false, Enum.KeyCode.F, false, game)
end

-- auto ultimate
local function autoultimate()
    if not settings.autoultimate then return end
    
    local character = localplayer.Character
    if not character then return end
    
    local ultgauge = character:FindFirstChild("UltimateGauge")
    if ultgauge and ultgauge:IsA("NumberValue") and ultgauge.Value >= 100 then
        local nearest = nil
        local nearestdist = 50
        
        for _, v in pairs(workspace:GetDescendants()) do
            if v:IsA("Model") and v:FindFirstChild("Humanoid") then
                local root = v:FindFirstChild("HumanoidRootPart")
                if root then
                    local dist = (root.Position - character.HumanoidRootPart.Position).Magnitude
                    if dist < nearestdist then
                        nearest = v
                        nearestdist = dist
                    end
                end
            end
        end
        
        if nearest then
            virtualinputmanager:SendKeyEvent(true, Enum.KeyCode.Q, false, game)
            task.wait(0.1)
            virtualinputmanager:SendKeyEvent(false, Enum.KeyCode.Q, false, game)
        end
    end
end

-- auto boss
local function autobossloop()
    while settings.autoboss do
        local boss = nil
        for _, v in pairs(workspace:GetDescendants()) do
            if v:IsA("Model") then
                local name = v.Name:lower()
                for _, b in pairs(bosslist) do
                    if name:find(b) then
                        local humanoid = v:FindFirstChild("Humanoid")
                        if humanoid and humanoid.Health > 0 then
                            boss = v
                            break
                        end
                    end
                end
            end
        end
        
        if boss then
            local root = boss:FindFirstChild("HumanoidRootPart")
            if root then
                local char = localplayer.Character
                if char and char:FindFirstChild("HumanoidRootPart") then
                    char.HumanoidRootPart.CFrame = root.CFrame
                end
                
                for i = 1, 20 do
                    virtualinputmanager:SendMouseButtonEvent(0, 0, 0, true, game, 0)
                    task.wait(0.1)
                    virtualinputmanager:SendMouseButtonEvent(0, 0, 0, false, game, 0)
                end
            end
        end
        task.wait(2)
    end
end

-- auto collect items
local function autocollectitems()
    if not settings.autocollect then return end
    
    for _, v in pairs(workspace:GetDescendants()) do
        if v:IsA("Model") and v:FindFirstChild("ClickDetector") then
            local name = v.Name:lower()
            if name:find("scroll") or name:find("item") or name:find("drop") or name:find("essence") or name:find("soul") then
                local char = localplayer.Character
                if char and char:FindFirstChild("HumanoidRootPart") then
                    char.HumanoidRootPart.CFrame = v:GetPivot()
                end
                virtualinputmanager:SendMouseButtonEvent(0, 0, 0, true, game, 0)
                task.wait(0.1)
                virtualinputmanager:SendMouseButtonEvent(0, 0, 0, false, game, 0)
            end
        end
    end
end

-- unlock characters
local function unlockcharacters()
    if not settings.unlockcharacters then return end
    
    local charactersfolder = replicatedstorage:FindFirstChild("Characters")
    if charactersfolder then
        for _, char in pairs(charactersfolder:GetChildren()) do
            for _, child in pairs(char:GetChildren()) do
                if child.Name == "Owned" and child:IsA("BoolValue") then
                    child.Value = true
                end
            end
        end
    end
    
    local skillsfolder = localplayer:FindFirstChild("Skills")
    if skillsfolder then
        for _, skill in pairs(skillsfolder:GetChildren()) do
            if skill:IsA("BoolValue") then
                skill.Value = true
            end
        end
    end
    
    local abilities = localplayer:FindFirstChild("Abilities")
    if abilities then
        for _, ability in pairs(abilities:GetChildren()) do
            if ability:IsA("BoolValue") then
                ability.Value = true
            end
        end
    end
end

-- teleport functions
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

local function teleporttobossfunc()
    for _, v in pairs(workspace:GetDescendants()) do
        if v:IsA("Model") then
            local name = v.Name:lower()
            for _, b in pairs(bosslist) do
                if name:find(b) then
                    local root = v:FindFirstChild("HumanoidRootPart")
                    if root then
                        local char = localplayer.Character
                        if char and char:FindFirstChild("HumanoidRootPart") then
                            char.HumanoidRootPart.CFrame = root.CFrame
                        end
                    end
                    return
                end
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
            camera.CFrame = CFrame.new(character.HumanoidRootPart.Position + Vector3.new(0, 4, 12), character.HumanoidRootPart.Position)
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
            
            local name = v.Name:lower()
            local isboss = false
            for _, b in pairs(bosslist) do
                if name:find(b) then
                    isboss = true
                    break
                end
            end
            local isplayer = v.Parent and v.Parent:IsA("Player")
            local ismob = not isplayer and not isboss
            
            if settings.playeresp and isplayer then
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
                local nametext = espdrawings[v].name
                nametext.Visible = true
                nametext.Position = Vector2.new(pos.X, pos.Y - 55)
                nametext.Text = v.Parent.Name
                nametext.Color = Color3.fromRGB(255, 255, 255)
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
                
                if not espdrawings[v].name then
                    espdrawings[v].name = Drawing.new("Text")
                    espdrawings[v].name.Size = 16
                    espdrawings[v].name.Center = true
                    espdrawings[v].name.Outline = true
                end
                local bosstext = espdrawings[v].name
                bosstext.Visible = true
                bosstext.Position = Vector2.new(pos.X, pos.Y - 75)
                bosstext.Text = v.Name
                bosstext.Color = Color3.fromRGB(255, 50, 50)
            else
                if espdrawings[v].box then espdrawings[v].box.Visible = false end
            end
        elseif settings.itemesp and v:IsA("Model") and v:FindFirstChild("ClickDetector") then
            local name = v.Name:lower()
            if name:find("scroll") or name:find("item") or name:find("drop") or name:find("essence") or name:find("soul") then
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
                    text.Text = "item"
                    text.Color = Color3.fromRGB(255, 255, 0)
                end
            end
        end
    end
end

-- player list for teleport
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

-- tabs
local farmingtab = window:CreateTab("farming")
local combattab = window:CreateTab("combat")
local espvisualtab = window:CreateTab("esp/visual")
local movementtab = window:CreateTab("movement")
local misctab = window:CreateTab("misc")

-- farming tab
farmingtab:CreateToggle("auto farm", false, function(v)
    settings.autofarm = v
    if v then task.spawn(autofarmloop) end
end)
farmingtab:CreateSlider("farm radius", 100, 500, 200, function(v) settings.autofarmradius = v end)
farmingtab:CreateToggle("auto boss", false, function(v)
    settings.autoboss = v
    if v then task.spawn(autobossloop) end
end)
farmingtab:CreateToggle("auto collect items", false, function(v) settings.autocollect = v end)

-- combat tab
combattab:CreateToggle("kill aura", false, function(v) settings.killaura = v end)
combattab:CreateSlider("kill aura radius", 10, 100, 30, function(v) settings.killauraradius = v end)
combattab:CreateToggle("auto combo", false, function(v) settings.autocombo = v end)
combattab:CreateToggle("auto dodge", false, function(v) settings.autododge = v end)
combattab:CreateToggle("auto block", false, function(v) settings.autoblock = v end)
combattab:CreateToggle("auto ultimate", false, function(v) settings.autoultimate = v end)

-- esp/visual tab
espvisualtab:CreateToggle("player esp", false, function(v) settings.playeresp = v end)
espvisualtab:CreateToggle("mob esp", false, function(v) settings.mobesp = v end)
espvisualtab:CreateToggle("boss esp", false, function(v) settings.bossesp = v end)
espvisualtab:CreateToggle("item esp", false, function(v) settings.itemesp = v end)
espvisualtab:CreateColorpicker("esp color", Color3.fromRGB(255,0,0), function(v) settings.espcolor = v end)
espvisualtab:CreateToggle("third person", false, function(v) settings.thirdperson = v end)
espvisualtab:CreateToggle("fov changer", false, function(v) settings.fovchanger = v end)
espvisualtab:CreateSlider("fov value", 70, 120, 120, function(v) settings.fovvalue = v end)
espvisualtab:CreateToggle("fullbright", false, function(v) settings.fullbright = v end)
espvisualtab:CreateToggle("no fog", false, function(v) settings.nofog = v end)

-- movement tab
movementtab:CreateToggle("speed boost", false, function(v) settings.speedboost = v end)
movementtab:CreateSlider("speed value", 16, 250, 50, function(v) settings.speedvalue = v end)
movementtab:CreateToggle("fly", false, function(v)
    settings.fly = v
    startfly()
end)
movementtab:CreateToggle("infinite jump", false, function(v) settings.infinitejump = v end)
movementtab:CreateToggle("infinite stamina", false, function(v) settings.infinitestamina = v end)
movementtab:CreateToggle("no cooldowns", false, function(v) settings.nocooldowns = v end)

-- misc tab
misctab:CreateToggle("anti-afk", false, function(v) settings.antiafk = v end)
misctab:CreateButton("unlock all characters (local)", function() unlockcharacters() end)
misctab:CreateButton("teleport to boss", function() teleporttobossfunc() end)
misctab:CreateDropdown("teleport to player", {}, function(v)
    teleporttoplayerfunc(v)
end)

-- update player list
task.spawn(function()
    while true do
        updateplayerlist()
        task.wait(5)
    end
end)

-- main loop
runservice.RenderStepped:Connect(function()
    applymovement()
    infinitejump()
    setinfinitestamina()
    removenocooldowns()
    autocollectitems()
    killaura()
    autocombo()
    autododge()
    autoblock()
    autoultimate()
    antiafk()
    setthirdperson()
    setfov()
    setfullbright()
    setnofog()
    drawesp()
    
    if settings.fovchanger then
        fovcircle.Visible = false
    end
end)

localplayer.CharacterAdded:Connect(function()
    task.wait(0.5)
    applymovement()
end)

print("lunarware tsb loaded")

-- lunarware | operation siege
-- advanced siege script with anti-cheat bypass
-- 25 features: silent aim, aimbot, triggerbot, esp boxes, esp names, esp health, esp operator, esp distance, esp snaplines, no recoil, no spread, rapid fire, infinite ammo, auto reload, hitbox extender, speed boost, fly, infinite jump, third person, fov changer, fullbright, no fog, anti-afk, auto knife, skin changer, anti-cheat bypass

local library = loadstring(game:HttpGet("https://raw.githubusercontent.com/peppy/UI-Library/main/source.lua"))()
local window = library:CreateWindow("lunarware | operation siege")

local players = game:GetService("Players")
local runservice = game:GetService("RunService")
local userinputservice = game:GetService("UserInputService")
local virtualinputmanager = game:GetService("VirtualInputManager")
local replicatedstorage = game:GetService("ReplicatedStorage")
local workspace = game:GetService("Workspace")
local lighting = game:GetService("Lighting")
local httprequest = (syn and syn.request) or (http and http.request) or request

local localplayer = players.LocalPlayer
local mouse = localplayer:GetMouse()
local camera = workspace.CurrentCamera

-- settings
local settings = {
    -- aimbot
    silentaim = false,
    aimbot = false,
    triggerbot = false,
    aimbotfov = 120,
    aimbotsmoothness = 5,
    aimpart = "head",
    
    -- esp
    boxesp = false,
    nameesp = false,
    healthesp = false,
    operatoresp = false,
    distanceesp = false,
    snaplines = false,
    espcolor = Color3.fromRGB(255, 0, 0),
    
    -- weapon
    norecoil = false,
    nospread = false,
    rapidfire = false,
    infiniteammo = false,
    autoreload = false,
    hitboxsize = 1,
    
    -- movement
    speedboost = false,
    speedvalue = 50,
    fly = false,
    infinitejump = false,
    
    -- visual
    thirdperson = false,
    fovchanger = false,
    fovvalue = 120,
    fullbright = false,
    nofog = false,
    
    -- misc
    antiafk = false,
    autoknife = false,
    skinchanger = false,
    selectedskin = "default",
    anticheatbypass = false,
}

-- anti-cheat bypass variables
local anticheatdetected = false
local bypassmethods = {}

-- drawing objects
local espdrawings = {}
local originalhitboxes = {}
local lastantiafktime = tick()
local flying = false
local bodyvelocity = nil
local bodygyro = nil
local lastjumptime = 0
local lastshot = 0

-- fov circle
local fovcircle = Drawing.new("Circle")
fovcircle.Visible = false
fovcircle.Thickness = 2
fovcircle.Color = Color3.fromRGB(255, 255, 255)
fovcircle.Filled = false
fovcircle.NumSides = 64
fovcircle.Transparency = 0.7

-- operator colors
local operatorcolors = {
    ["recruit"] = Color3.fromRGB(100, 100, 100),
    ["sledge"] = Color3.fromRGB(200, 100, 50),
    ["thermite"] = Color3.fromRGB(255, 100, 0),
    ["ash"] = Color3.fromRGB(255, 50, 50),
    ["twitch"] = Color3.fromRGB(100, 100, 255),
    ["doc"] = Color3.fromRGB(0, 200, 0),
    ["rook"] = Color3.fromRGB(100, 100, 200),
    ["jager"] = Color3.fromRGB(255, 200, 0),
    ["bandit"] = Color3.fromRGB(255, 255, 0),
    ["caveira"] = Color3.fromRGB(100, 0, 100),
    ["vigil"] = Color3.fromRGB(0, 0, 0),
    ["maverick"] = Color3.fromRGB(200, 100, 0),
    ["nomad"] = Color3.fromRGB(150, 100, 50),
    ["kali"] = Color3.fromRGB(50, 50, 150),
    ["iana"] = Color3.fromRGB(100, 200, 200),
    ["ace"] = Color3.fromRGB(0, 100, 200),
    ["zero"] = Color3.fromRGB(0, 200, 100),
}

-- anti-cheat bypass functions
local function findanticheat()
    local acnames = {"AntiCheat", "AC", "ExploitDetector", "Admin", "Logger", "BanSystem", "Security", "Protection"}
    local detected = {}
    
    for _, v in pairs(workspace:GetDescendants()) do
        for _, name in pairs(acnames) do
            if v.Name:find(name) and (v:IsA("Script") or v:IsA("LocalScript")) then
                table.insert(detected, v)
            end
        end
    end
    
    for _, v in pairs(game:GetDescendants()) do
        for _, name in pairs(acnames) do
            if v.Name:find(name) and (v:IsA("Script") or v:IsA("LocalScript")) then
                table.insert(detected, v)
            end
        end
    end
    
    return detected
end

local function disableanticheat()
    if not settings.anticheatbypass then return end
    
    local acscripts = findanticheat()
    for _, script in pairs(acscripts) do
        pcall(function()
            script.Disabled = true
            script:Destroy()
        end)
    end
    
    -- hook remote events to prevent detection
    local mt = getrawmetatable(game)
    if mt then
        setreadonly(mt, false)
        local oldnamecall = mt.__namecall
        mt.__namecall = newcclosure(function(self, ...)
            local args = {...}
            local method = getnamecallmethod()
            
            -- block reporting
            if method == "FireServer" and tostring(self):find("Report") then
                return
            end
            
            -- block logging
            if method == "FireServer" and tostring(self):find("Log") then
                return
            end
            
            -- block anticheat pings
            if method == "FireServer" and tostring(self):find("Heartbeat") then
                return
            end
            
            return oldnamecall(self, ...)
        end)
    end
    
    -- hook http requests
    if httprequest then
        local oldrequest = httprequest
        httprequest = function(options)
            if options.Url and (options.Url:find("discord") or options.Url:find("webhook")) then
                return {Success = true, StatusCode = 200}
            end
            return oldrequest(options)
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

-- hitbox extender
local function expandhitboxes()
    if settings.hitboxsize <= 1 then
        for part, size in pairs(originalhitboxes) do
            pcall(function() part.Size = size end)
        end
        originalhitboxes = {}
        return
    end
    
    for _, player in pairs(players:GetPlayers()) do
        if player ~= localplayer then
            local character = player.Character
            if character then
                local head = character:FindFirstChild("Head")
                local torso = character:FindFirstChild("UpperTorso")
                
                if head and not originalhitboxes[head] then
                    originalhitboxes[head] = head.Size
                    head.Size = head.Size * settings.hitboxsize
                end
                if torso and not originalhitboxes[torso] then
                    originalhitboxes[torso] = torso.Size
                    torso.Size = torso.Size * settings.hitboxsize
                end
            end
        end
    end
end

-- weapon functions
local function getcurrentweapon()
    local character = localplayer.Character
    if not character then return nil end
    
    local tool = character:FindFirstChildWhichIsA("Tool")
    if tool then return tool end
    
    for _, child in pairs(localplayer.Backpack:GetChildren()) do
        if child:IsA("Tool") then
            return child
        end
    end
    return nil
end

local function applyweaponmods()
    local weapon = getcurrentweapon()
    if not weapon then return end
    
    for _, child in pairs(weapon:GetDescendants()) do
        if child:IsA("NumberValue") then
            local name = child.Name:lower()
            
            if settings.norecoil and (name:find("recoil") or name:find("kick") or name:find("camera")) then
                child.Value = 0
            end
            if settings.nospread and (name:find("spread") or name:find("bloom") or name:find("inaccuracy")) then
                child.Value = 0
            end
            if settings.rapidfire and (name:find("firerate") or name:find("cooldown") or name:find("delay")) then
                child.Value = 0.01
            end
            if settings.infiniteammo and (name:find("ammo") or name:find("clip") or name:find("magazine")) then
                child.Value = 999
            end
        end
    end
end

-- auto reload
local function autoreload()
    if not settings.autoreload then return end
    local weapon = getcurrentweapon()
    if not weapon then return end
    
    local ammo = nil
    for _, child in pairs(weapon:GetDescendants()) do
        if child.Name == "Ammo" and child:IsA("NumberValue") then
            ammo = child
            break
        end
    end
    
    if ammo and ammo.Value == 0 then
        virtualinputmanager:SendKeyEvent(true, Enum.KeyCode.R, false, game)
        task.wait(0.05)
        virtualinputmanager:SendKeyEvent(false, Enum.KeyCode.R, false, game)
    end
end

-- auto knife
local function autoknife()
    if not settings.autoknife then return end
    
    for _, player in pairs(players:GetPlayers()) do
        if player ~= localplayer then
            local character = player.Character
            if character and localplayer.Character then
                local distance = (character.HumanoidRootPart.Position - localplayer.Character.HumanoidRootPart.Position).Magnitude
                if distance < 8 then
                    virtualinputmanager:SendKeyEvent(true, Enum.KeyCode.F, false, game)
                    task.wait(0.05)
                    virtualinputmanager:SendKeyEvent(false, Enum.KeyCode.F, false, game)
                end
            end
        end
    end
end

-- skin changer
local function applyskin()
    if not settings.skinchanger then return end
    
    local weapon = getcurrentweapon()
    if weapon then
        for _, child in pairs(weapon:GetDescendants()) do
            if child:IsA("StringValue") and child.Name:lower():find("skin") then
                child.Value = settings.selectedskin
            end
        end
    end
    
    local character = localplayer.Character
    if character then
        for _, child in pairs(character:GetDescendants()) do
            if child:IsA("StringValue") and child.Name:lower():find("operator") then
                child.Value = settings.selectedskin
            end
        end
    end
end

-- get operator name
local function getoperator(player)
    local character = player.Character
    if character then
        for _, child in pairs(character:GetDescendants()) do
            if child:IsA("StringValue") and (child.Name:lower():find("operator") or child.Name:lower():find("character")) then
                return child.Value
            end
        end
    end
    return "recruit"
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
            camera.CFrame = CFrame.new(character.HumanoidRootPart.Position + Vector3.new(0, 3, 8), character.HumanoidRootPart.Position)
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

local function clearesp(player)
    if espdrawings[player] then
        for _, drawing in pairs(espedrawings[player]) do
            pcall(function() drawing:Remove() end)
        end
        espdrawings[player] = nil
    end
end

local function drawesp()
    for _, player in pairs(players:GetPlayers()) do
        if player == localplayer then continue end
        
        local character = player.Character
        local humanoid = character and character:FindFirstChild("Humanoid")
        
        if not character or not humanoid or humanoid.Health <= 0 then
            clearesp(player)
            continue
        end
        
        local root = character:FindFirstChild("HumanoidRootPart") or character.PrimaryPart
        local head = character:FindFirstChild("Head")
        if not root or not head then
            clearesp(player)
            continue
        end
        
        local headpos = getscreenposition(head.Position)
        local rootpos = getscreenposition(root.Position)
        if not headpos or not rootpos then
            clearesp(player)
            continue
        end
        
        if not espdrawings[player] then
            espdrawings[player] = {}
        end
        
        local height = rootpos.Y - headpos.Y
        local width = height * 0.5
        local left = headpos.X - width / 2
        local top = headpos.Y
        
        local operator = getoperator(player)
        local opcolor = operatorcolors[operator:lower()] or settings.espcolor
        
        -- box esp
        if settings.boxesp then
            if not espdrawings[player].box then
                espdrawings[player].box = Drawing.new("Square")
                espdrawings[player].box.Thickness = 2
                espdrawings[player].box.Filled = false
            end
            local box = espdrawings[player].box
            box.Visible = true
            box.Position = Vector2.new(left, top)
            box.Size = Vector2.new(width, height)
            box.Color = opcolor
        elseif espdrawings[player].box then
            espdrawings[player].box.Visible = false
        end
        
        -- name esp
        if settings.nameesp then
            if not espdrawings[player].name then
                espdrawings[player].name = Drawing.new("Text")
                espdrawings[player].name.Size = 14
                espdrawings[player].name.Center = false
                espdrawings[player].name.Outline = true
            end
            local name = espdrawings[player].name
            name.Visible = true
            name.Position = Vector2.new(left, top - 18)
            name.Text = player.Name
            name.Color = Color3.fromRGB(255, 255, 255)
        elseif espdrawings[player].name then
            espdrawings[player].name.Visible = false
        end
        
        -- operator esp
        if settings.operatoresp then
            if not espdrawings[player].operator then
                espdrawings[player].operator = Drawing.new("Text")
                espdrawings[player].operator.Size = 11
                espdrawings[player].operator.Center = false
                espdrawings[player].operator.Outline = true
            end
            local optext = espdrawings[player].operator
            optext.Visible = true
            optext.Position = Vector2.new(left, top - 30)
            optext.Text = operator:upper()
            optext.Color = opcolor
        elseif espdrawings[player].operator then
            espdrawings[player].operator.Visible = false
        end
        
        -- health esp
        if settings.healthesp then
            if not espdrawings[player].health then
                espdrawings[player].health = Drawing.new("Line")
                espdrawings[player].health.Thickness = 3
            end
            local healthpercent = humanoid.Health / humanoid.MaxHealth
            local health = espdrawings[player].health
            health.Visible = true
            health.From = Vector2.new(left - 6, top + height)
            health.To = Vector2.new(left - 6, top + height - (height * healthpercent))
            health.Color = Color3.fromRGB(255 - (255 * healthpercent), 255 * healthpercent, 0)
        elseif espdrawings[player].health then
            espdrawings[player].health.Visible = false
        end
        
        -- distance esp
        if settings.distanceesp then
            if not espdrawings[player].distance then
                espdrawings[player].distance = Drawing.new("Text")
                espdrawings[player].distance.Size = 11
                espdrawings[player].distance.Center = false
                espdrawings[player].distance.Outline = true
            end
            local dist = (root.Position - camera.CFrame.Position).Magnitude / 3.28084
            local distance = espdrawings[player].distance
            distance.Visible = true
            distance.Position = Vector2.new(left, top + height + 2)
            distance.Text = string.format("%.0fm", dist)
            distance.Color = Color3.fromRGB(200, 200, 200)
        elseif espdrawings[player].distance then
            espdrawings[player].distance.Visible = false
        end
        
        -- snaplines
        if settings.snaplines then
            if not espdrawings[player].snap then
                espdrawings[player].snap = Drawing.new("Line")
                espdrawings[player].snap.Thickness = 1
            end
            local center = Vector2.new(camera.ViewportSize.X / 2, camera.ViewportSize.Y)
            local snap = espdrawings[player].snap
            snap.Visible = true
            snap.From = center
            snap.To = rootpos
            snap.Color = opcolor
        elseif espdrawings[player].snap then
            espdrawings[player].snap.Visible = false
        end
    end
end

-- aimbot functions
local function getclosestplayer()
    local closest = nil
    local shortest = settings.aimbotfov
    local center = Vector2.new(mouse.X, mouse.Y)
    
    for _, player in pairs(players:GetPlayers()) do
        if player ~= localplayer then
            local character = player.Character
            if not character then continue end
            
            local humanoid = character:FindFirstChild("Humanoid")
            if not humanoid or humanoid.Health <= 0 then continue end
            
            local part = nil
            if settings.aimpart == "head" then
                part = character:FindFirstChild("Head")
            elseif settings.aimpart == "chest" then
                part = character:FindFirstChild("UpperTorso")
            else
                part = character:FindFirstChild("HumanoidRootPart")
            end
            if not part then continue end
            
            local screenpos, onscreen = camera:WorldToViewportPoint(part.Position)
            if not onscreen then continue end
            
            local distance = (center - Vector2.new(screenpos.X, screenpos.Y)).Magnitude
            
            if distance < shortest then
                shortest = distance
                closest = player
            end
        end
    end
    return closest
end

local function performaimbot()
    if not settings.aimbot then return end
    if not userinputservice:IsMouseButtonPressed(Enum.UserInputType.MouseButton2) then return end
    
    local target = getclosestplayer()
    if not target then return end
    
    local character = target.Character
    if not character then return end
    
    local part = nil
    if settings.aimpart == "head" then
        part = character:FindFirstChild("Head")
    elseif settings.aimpart == "chest" then
        part = character:FindFirstChild("UpperTorso")
    else
        part = character:FindFirstChild("HumanoidRootPart")
    end
    if not part then return end
    
    if settings.silentaim then
        local direction = (part.Position - camera.CFrame.Position).Unit
        camera.CFrame = CFrame.lookAt(camera.CFrame.Position, camera.CFrame.Position + direction)
    else
        local screenpos = camera:WorldToViewportPoint(part.Position)
        local targetpos = Vector2.new(screenpos.X, screenpos.Y)
        local currentpos = Vector2.new(mouse.X, mouse.Y)
        local delta = targetpos - currentpos
        local smoothdelta = delta / settings.aimbotsmoothness
        mousemoverel(smoothdelta.X, smoothdelta.Y)
    end
end

-- triggerbot
local function isonenemy()
    local center = Vector2.new(mouse.X, mouse.Y)
    
    for _, player in pairs(players:GetPlayers()) do
        if player ~= localplayer then
            local character = player.Character
            if not character then continue end
            
            local humanoid = character:FindFirstChild("Humanoid")
            if not humanoid or humanoid.Health <= 0 then continue end
            
            local head = character:FindFirstChild("Head")
            if not head then continue end
            
            local screenpos, onscreen = camera:WorldToViewportPoint(head.Position)
            if not onscreen then continue end
            
            local distance = (center - Vector2.new(screenpos.X, screenpos.Y)).Magnitude
            
            if distance < 30 then
                return true
            end
        end
    end
    return false
end

local function triggerbotloop()
    while true do
        if settings.triggerbot then
            if isonenemy() then
                virtualinputmanager:SendMouseButtonEvent(0, 0, 0, true, game, 0)
                task.wait(0.01)
                virtualinputmanager:SendMouseButtonEvent(0, 0, 0, false, game, 0)
            end
        end
        task.wait(0.01)
    end
end

task.spawn(triggerbotloop)

-- skin list for dropdown
local skinlist = {"default", "black ice", "glacier", "fire", "gold", "platinum", "diamond", "carbon fiber", "woodland", "desert", "arctic", "tiger", "zebra", "neon", "rainbow"}

-- tabs
local aimbottab = window:CreateTab("aimbot")
local espvisualtab = window:CreateTab("esp/visual")
local weapontab = window:CreateTab("weapon")
local movementtab = window:CreateTab("movement")
local misctab = window:CreateTab("misc")

-- aimbot tab
aimbottab:CreateToggle("silent aim", false, function(v) settings.silentaim = v end)
aimbottab:CreateToggle("aimbot", false, function(v) settings.aimbot = v end)
aimbottab:CreateToggle("triggerbot", false, function(v) settings.triggerbot = v end)
aimbottab:CreateSlider("aimbot fov", 30, 360, 120, function(v) settings.aimbotfov = v end)
aimbottab:CreateSlider("smoothness", 1, 20, 5, function(v) settings.aimbotsmoothness = v end)
aimbottab:CreateDropdown("aim part", {"head", "chest", "humanoidrootpart"}, function(v) settings.aimpart = v end)

-- esp/visual tab
espvisualtab:CreateToggle("box esp", false, function(v) settings.boxesp = v end)
espvisualtab:CreateToggle("name esp", false, function(v) settings.nameesp = v end)
espvisualtab:CreateToggle("operator esp", false, function(v) settings.operatoresp = v end)
espvisualtab:CreateToggle("health esp", false, function(v) settings.healthesp = v end)
espvisualtab:CreateToggle("distance esp", false, function(v) settings.distanceesp = v end)
espvisualtab:CreateToggle("snaplines", false, function(v) settings.snaplines = v end)
espvisualtab:CreateColorpicker("esp color", Color3.fromRGB(255,0,0), function(v) settings.espcolor = v end)
espvisualtab:CreateToggle("third person", false, function(v) settings.thirdperson = v end)
espvisualtab:CreateToggle("fov changer", false, function(v) settings.fovchanger = v end)
espvisualtab:CreateSlider("fov value", 70, 120, 120, function(v) settings.fovvalue = v end)
espvisualtab:CreateToggle("fullbright", false, function(v) settings.fullbright = v end)
espvisualtab:CreateToggle("no fog", false, function(v) settings.nofog = v end)

-- weapon tab
weapontab:CreateToggle("no recoil", false, function(v) settings.norecoil = v end)
weapontab:CreateToggle("no spread", false, function(v) settings.nospread = v end)
weapontab:CreateToggle("rapid fire", false, function(v) settings.rapidfire = v end)
weapontab:CreateToggle("infinite ammo", false, function(v) settings.infiniteammo = v end)
weapontab:CreateToggle("auto reload", false, function(v) settings.autoreload = v end)
weapontab:CreateSlider("hitbox size", 1, 3, 1, function(v) settings.hitboxsize = v end)
weapontab:CreateToggle("auto knife", false, function(v) settings.autoknife = v end)
weapontab:CreateToggle("skin changer", false, function(v) settings.skinchanger = v end)
weapontab:CreateDropdown("select skin", skinlist, function(v) settings.selectedskin = v end)

-- movement tab
movementtab:CreateToggle("speed boost", false, function(v) settings.speedboost = v end)
movementtab:CreateSlider("speed value", 16, 250, 50, function(v) settings.speedvalue = v end)
movementtab:CreateToggle("fly", false, function(v)
    settings.fly = v
    startfly()
end)
movementtab:CreateToggle("infinite jump", false, function(v) settings.infinitejump = v end)

-- misc tab
misctab:CreateToggle("anti-afk", false, function(v) settings.antiafk = v end)
misctab:CreateToggle("anti-cheat bypass", false, function(v)
    settings.anticheatbypass = v
    if v then disableanticheat() end
end)
misctab:CreateButton("scan for anti-cheat", function()
    local ac = findanticheat()
    if #ac > 0 then
        library:Notification("anti-cheat found", #ac .. " scripts detected", "ok")
    else
        library:Notification("clean", "no anti-cheat detected", "ok")
    end
end)

-- main loop
runservice.RenderStepped:Connect(function()
    applyweaponmods()
    autoreload()
    expandhitboxes()
    applymovement()
    infinitejump()
    autoknife()
    applyskin()
    antiafk()
    setthirdperson()
    setfov()
    setfullbright()
    setnofog()
    drawesp()
    
    if settings.aimbot then
        performaimbot()
    end
    
    if settings.fovchanger then
        fovcircle.Visible = settings.aimbot
        fovcircle.Radius = settings.aimbotfov
        fovcircle.Position = Vector2.new(mouse.X, mouse.Y)
    else
        fovcircle.Visible = false
    end
end)

localplayer.CharacterAdded:Connect(function()
    task.wait(0.5)
    applymovement()
    if settings.anticheatbypass then disableanticheat() end
end)

-- initial anti-cheat bypass
if settings.anticheatbypass then
    disableanticheat()
end

print("lunarware operation siege loaded")

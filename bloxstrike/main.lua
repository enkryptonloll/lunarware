-- lunarware | blox strike
-- cs2 style cheat with anti-cheat bypass
-- 25 features: silent aim, aimbot, triggerbot, esp boxes, esp names, esp health, esp weapons, esp grenades, esp c4, radar hack, glow esp, chams, thirdperson, fov changer, no recoil, no spread, rapid fire, infinite ammo, auto reload, hitbox extender, bunny hop, speed boost, auto strafe, killstreak esp, bomb timer

local library = loadstring(game:HttpGet("https://raw.githubusercontent.com/peppy/UI-Library/main/source.lua"))()
local window = library:CreateWindow("lunarware | blox strike")

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
    weaponesp = false,
    grenadeesp = false,
    c4esp = false,
    radarhack = false,
    glowesp = false,
    chamsp = false,
    chamsmaterial = "neon",
    killstreakesp = false,
    bombtimer = false,
    
    -- visual
    thirdperson = false,
    fovchanger = false,
    fovvalue = 120,
    noscope = false,
    
    -- weapon
    norecoil = false,
    nospread = false,
    rapidfire = false,
    infiniteammo = false,
    autoreload = false,
    hitboxsize = 1,
    
    -- movement
    bunnyhop = false,
    speedboost = false,
    speedvalue = 50,
    autostrafe = false,
    
    -- anti cheat bypass
    bypassanticheat = false,
}

-- drawing objects
local espdrawings = {}
local originalhitboxes = {}
local lastjump = 0
local lastshot = 0
local rainbowhue = 0

-- fov circle
local fovcircle = Drawing.new("Circle")
fovcircle.Visible = false
fovcircle.Thickness = 2
fovcircle.Color = Color3.fromRGB(255, 255, 255)
fovcircle.Filled = false
fovcircle.NumSides = 64
fovcircle.Transparency = 0.7

-- radar hack gui
local radargui = nil
local function createradar()
    if radargui then radargui:Destroy() end
    if not settings.radarhack then return end
    
    radargui = Instance.new("ScreenGui")
    radargui.Name = "RadarHack"
    radargui.Parent = localplayer:WaitForChild("PlayerGui")
    
    local radarframe = Instance.new("Frame")
    radarframe.Size = UDim2.new(0, 200, 0, 200)
    radarframe.Position = UDim2.new(0, 10, 0.5, -100)
    radarframe.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    radarframe.BackgroundTransparency = 0.5
    radarframe.BorderSizePixel = 0
    radarframe.Parent = radargui
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(1, 0)
    corner.Parent = radarframe
    
    local function updateradar()
        for _, child in pairs(radarframe:GetChildren()) do
            if child ~= radarframe then child:Destroy() end
        end
        
        local localroot = localplayer.Character and localplayer.Character:FindFirstChild("HumanoidRootPart")
        if not localroot then return end
        
        for _, player in pairs(players:GetPlayers()) do
            if player ~= localplayer then
                local character = player.Character
                local root = character and character:FindFirstChild("HumanoidRootPart")
                if root then
                    local relative = root.Position - localroot.Position
                    local angle = math.atan2(relative.X, relative.Z)
                    local distance = math.min(relative.Magnitude / 100, 80)
                    local x = math.sin(angle) * distance
                    local z = math.cos(angle) * distance
                    
                    local dot = Instance.new("Frame")
                    dot.Size = UDim2.new(0, 5, 0, 5)
                    dot.Position = UDim2.new(0.5, x - 2.5, 0.5, z - 2.5)
                    dot.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
                    dot.Parent = radarframe
                end
            end
        end
    end
    
    runservice.RenderStepped:Connect(updateradar)
end

-- anti cheat bypass
local function bypassanticheat()
    if not settings.bypassanticheat then return end
    
    -- remove common anti-cheat scripts
    local toremove = {"AntiCheat", "AC", "ExploitDetector", "Admin", "Logging"}
    for _, v in pairs(workspace:GetDescendants()) do
        for _, name in pairs(toremove) do
            if v.Name:find(name) and (v:IsA("Script") or v:IsA("LocalScript")) then
                v.Disabled = true
                pcall(function() v:Destroy() end)
            end
        end
    end
    
    -- hook remote events to prevent detection
    local mt = getrawmetatable(game)
    if mt then
        setreadonly(mt, false)
        local oldnamecall = mt.__namecall
        mt.__namecall = newcclosure(function(self, ...)
            local args = {...}
            local method = getnamecallmethod()
            if method == "FireServer" and tostring(self):find("Report") then
                return
            end
            return oldnamecall(self, ...)
        end)
    end
end

-- glow esp
local function createglowesp(character)
    if not settings.glowesp then return end
    local highlight = Instance.new("Highlight")
    highlight.FillColor = Color3.fromRGB(255, 0, 0)
    highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
    highlight.FillTransparency = 0.5
    highlight.OutlineTransparency = 0
    highlight.Parent = character
    return highlight
end

-- chams
local function applychams(character)
    if not settings.chamsp then return end
    local material = settings.chamsmaterial == "neon" and Enum.Material.Neon or Enum.Material.ForceField
    for _, part in pairs(character:GetDescendants()) do
        if part:IsA("BasePart") then
            part.Material = material
            part.Color = Color3.fromRGB(255, 0, 0)
            part.Transparency = 0.3
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
            
            if settings.norecoil and (name:find("recoil") or name:find("kick")) then
                child.Value = 0
            end
            if settings.nospread and (name:find("spread") or name:find("bloom")) then
                child.Value = 0
            end
            if settings.rapidfire and (name:find("firerate") or name:find("cooldown")) then
                child.Value = 0.01
            end
            if settings.infiniteammo and (name:find("ammo") or name:find("clip")) then
                child.Value = 999
            end
        end
    end
end

-- hitbox expander
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

-- movement
local function bunnyhop()
    if not settings.bunnyhop then return end
    local character = localplayer.Character
    if not character then return end
    local humanoid = character:FindFirstChild("Humanoid")
    if not humanoid then return end
    
    if humanoid.FloorMaterial ~= Enum.Material.Air and userinputservice:IsKeyDown(Enum.KeyCode.Space) then
        local now = tick()
        if now - lastjump > 0.15 then
            humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
            lastjump = now
        end
    end
end

local function autostrafe()
    if not settings.autostrafe then return end
    local character = localplayer.Character
    if not character then return end
    local humanoid = character:FindFirstChild("Humanoid")
    if not humanoid then return end
    local root = character:FindFirstChild("HumanoidRootPart")
    if not root then return end
    
    local velocity = root.AssemblyLinearVelocity
    local speed = velocity.Magnitude
    
    if speed > 10 and humanoid.FloorMaterial == Enum.Material.Air then
        local movedirection = mouse.Hit.Position - root.Position
        movedirection = movedirection.Unit
        root.AssemblyLinearVelocity = Vector3.new(movedirection.X * speed, velocity.Y, movedirection.Z * speed)
    end
end

local function applymovement()
    local character = localplayer.Character
    if not character then return end
    local humanoid = character:FindFirstChild("Humanoid")
    if not humanoid then return end
    
    if settings.speedboost then
        humanoid.WalkSpeed = settings.speedvalue
    end
end

-- visual
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

local function removescope()
    if settings.noscope then
        local scope = localplayer.PlayerGui:FindFirstChild("ScopeGui")
        if scope then scope.Enabled = false end
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
            
            if settings.glowesp then
                createglowesp(character)
            end
            if settings.chamsp then
                applychams(character)
            end
        end
        
        local height = rootpos.Y - headpos.Y
        local width = height * 0.5
        local left = headpos.X - width / 2
        local top = headpos.Y
        
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
            box.Color = Color3.fromRGB(255, 0, 0)
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
        
        -- weapon esp
        if settings.weaponesp then
            if not espdrawings[player].weapon then
                espdrawings[player].weapon = Drawing.new("Text")
                espdrawings[player].weapon.Size = 12
                espdrawings[player].weapon.Center = false
                espdrawings[player].weapon.Outline = true
            end
            local tool = character:FindFirstChildWhichIsA("Tool")
            local weapon = espdrawings[player].weapon
            weapon.Visible = true
            weapon.Position = Vector2.new(left + width + 5, top + height - 15)
            weapon.Text = tool and tool.Name or "fists"
            weapon.Color = Color3.fromRGB(255, 255, 0)
        elseif espdrawings[player].weapon then
            espdrawings[player].weapon.Visible = false
        end
        
        -- killstreak esp
        if settings.killstreakesp then
            local killstreak = player:FindFirstChild("leaderstats") and player.leaderstats:FindFirstChild("Kills")
            if killstreak and killstreak.Value >= 5 then
                if not espdrawings[player].killstreak then
                    espdrawings[player].killstreak = Drawing.new("Text")
                    espdrawings[player].killstreak.Size = 11
                    espdrawings[player].killstreak.Center = true
                    espdrawings[player].killstreak.Outline = true
                end
                local ks = espdrawings[player].killstreak
                ks.Visible = true
                ks.Position = Vector2.new(headpos.X, headpos.Y - 30)
                ks.Text = killstreak.Value .. " kills"
                ks.Color = Color3.fromRGB(255, 165, 0)
            elseif espdrawings[player].killstreak then
                espdrawings[player].killstreak.Visible = false
            end
        end
    end
    
    -- grenade and c4 esp
    if settings.grenadeesp or settings.c4esp then
        for _, v in pairs(workspace:GetDescendants()) do
            if v:IsA("Model") then
                local name = v.Name:lower()
                if settings.grenadeesp and (name:find("grenade") or name:find("flashbang")) then
                    local pos = getscreenposition(v:GetPivot().Position)
                    if pos then
                        if not espdrawings[v] then espdrawings[v] = {} end
                        if not espdrawings[v].name then
                            espdrawings[v].name = Drawing.new("Text")
                            espdrawings[v].name.Size = 14
                            espdrawings[v].name.Center = true
                            espdrawings[v].name.Outline = true
                        end
                        local text = espdrawings[v].name
                        text.Visible = true
                        text.Position = pos
                        text.Text = "grenade"
                        text.Color = Color3.fromRGB(255, 100, 0)
                    end
                elseif settings.c4esp and name:find("c4") then
                    local pos = getscreenposition(v:GetPivot().Position)
                    if pos then
                        if not espdrawings[v] then espdrawings[v] = {} end
                        if not espdrawings[v].name then
                            espdrawings[v].name = Drawing.new("Text")
                            espdrawings[v].name.Size = 14
                            espdrawings[v].name.Center = true
                            espdrawings[v].name.Outline = true
                        end
                        local text = espdrawings[v].name
                        text.Visible = true
                        text.Position = pos
                        text.Text = "c4"
                        text.Color = Color3.fromRGB(255, 0, 0)
                    end
                end
            end
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

-- bomb timer
local function checkbombtimer()
    if not settings.bombtimer then return end
    for _, v in pairs(workspace:GetDescendants()) do
        if v:IsA("Model") and v.Name:lower():find("bomb") or v.Name:lower():find("c4") then
            local timer = v:FindFirstChild("Timer")
            if timer and timer:IsA("NumberValue") then
                library:Notification("bomb warning", "explodes in " .. math.floor(timer.Value) .. " seconds", "ok")
            end
        end
    end
end

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
espvisualtab:CreateToggle("health esp", false, function(v) settings.healthesp = v end)
espvisualtab:CreateToggle("weapon esp", false, function(v) settings.weaponesp = v end)
espvisualtab:CreateToggle("grenade esp", false, function(v) settings.grenadeesp = v end)
espvisualtab:CreateToggle("c4 esp", false, function(v) settings.c4esp = v end)
espvisualtab:CreateToggle("radar hack", false, function(v)
    settings.radarhack = v
    createradar()
end)
espvisualtab:CreateToggle("glow esp", false, function(v) settings.glowesp = v end)
espvisualtab:CreateToggle("chams", false, function(v) settings.chamsp = v end)
espvisualtab:CreateDropdown("chams material", {"neon", "forcefield"}, function(v) settings.chamsmaterial = v end)
espvisualtab:CreateToggle("killstreak esp", false, function(v) settings.killstreakesp = v end)
espvisualtab:CreateToggle("bomb timer", false, function(v) settings.bombtimer = v end)
espvisualtab:CreateToggle("third person", false, function(v) settings.thirdperson = v end)
espvisualtab:CreateToggle("fov changer", false, function(v) settings.fovchanger = v end)
espvisualtab:CreateSlider("fov value", 70, 120, 120, function(v) settings.fovvalue = v end)
espvisualtab:CreateToggle("no scope overlay", false, function(v) settings.noscope = v end)

-- weapon tab
weapontab:CreateToggle("no recoil", false, function(v) settings.norecoil = v end)
weapontab:CreateToggle("no spread", false, function(v) settings.nospread = v end)
weapontab:CreateToggle("rapid fire", false, function(v) settings.rapidfire = v end)
weapontab:CreateToggle("infinite ammo", false, function(v) settings.infiniteammo = v end)
weapontab:CreateToggle("auto reload", false, function(v) settings.autoreload = v end)
weapontab:CreateSlider("hitbox size", 1, 3, 1, function(v) settings.hitboxsize = v end)

-- movement tab
movementtab:CreateToggle("bunny hop", false, function(v) settings.bunnyhop = v end)
movementtab:CreateToggle("speed boost", false, function(v) settings.speedboost = v end)
movementtab:CreateSlider("speed value", 16, 250, 50, function(v) settings.speedvalue = v end)
movementtab:CreateToggle("auto strafe", false, function(v) settings.autostrafe = v end)

-- misc tab
misctab:CreateToggle("bypass anti-cheat", false, function(v)
    settings.bypassanticheat = v
    bypassanticheat()
end)

-- main loop
runservice.RenderStepped:Connect(function()
    applyweaponmods()
    autoreload()
    expandhitboxes()
    bunnyhop()
    autostrafe()
    applymovement()
    setthirdperson()
    setfov()
    removescope()
    drawesp()
    checkbombtimer()
    
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
end)

print("lunarware blox strike loaded")

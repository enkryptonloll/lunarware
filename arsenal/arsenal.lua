-- lunarware | arsenal script
-- toggle key: k
-- panic key: p (configurable)
-- aimbot key: right mouse button (configurable)

local library = loadstring(game:GetObjects("rbxassetid://7657867786")[1].Source)()
local Wait = library.subs.Wait

-- feature table
local Features = {
    -- legit section
    LegitAimbot = false,
    LegitAimbotSmoothness = 5,
    LegitFOVCircle = false,
    LegitFOVCircleSize = 120,
    LegitFOVCircleColor = Color3.fromRGB(150, 200, 255),
    LegitVisibleCheck = false,
    LegitTeamCheck = false,
    LegitAimPart = "Head",
    LegitAimKey = "RightMouse",
    
    -- rage section
    RageAimbot = false,
    RageSilentAim = false,
    RageFOVCircle = false,
    RageFOVCircleSize = 360,
    RageFOVCircleColor = Color3.fromRGB(255, 100, 100),
    RageWallbang = false,
    RageTeamCheck = false,
    RageAimPart = "Head",
    RageAimKey = "RightMouse",
    Triggerbot = false,
    TriggerDelay = 0,
    TriggerKey = "F",
    AutoKnife = false,
    
    -- gun mods
    FastFire = false,
    NoRecoil = false,
    NoSpread = false,
    InfiniteAmmo = false,
    InstantReload = false,
    DamageMultiplier = false,
    DamageMultiplierValue = 5,
    RainbowGun = false,
    
    -- hitbox
    HitboxExpander = false,
    HitboxSize = 2.5,
    
    -- movement
    BunnyHop = false,
    SpeedBoost = false,
    SpeedBoostValue = 50,
    NoClip = false,
    NoJumpCooldown = false,
    
    -- visuals
    BoxESP = false,
    NameESP = false,
    DistanceESP = false,
    HealthBar = false,
    TracerESP = false,
    RainbowESP = false,
    BoxColor = Color3.fromRGB(200, 200, 255),
    TracerColor = Color3.fromRGB(200, 200, 255),
    NoFog = false,
    FullBright = false,
    ZoomHack = false,
    ZoomHackValue = 120,
    
    -- misc
    GodMode = false,
    KillEffect = false,
    PanicKey = "P",
}

local LunarWare = library:CreateWindow({
    Name = "lunarware | arsenal",
    Themeable = {
        Info = "press k to toggle menu | panic key: p"
    }
})

-- ========== LEGIT TAB ==========
local LegitTab = LunarWare:CreateTab({
    Name = "legit"
})

local LegitAimbotSection = LegitTab:CreateSection({
    Name = "legit aimbot"
})

LegitAimbotSection:AddToggle({
    Name = "legit aimbot",
    Flag = "legitaimbot",
    Callback = function(v) Features.LegitAimbot = v end
})

LegitAimbotSection:AddSlider({
    Name = "smoothness",
    Flag = "legitsmoothness",
    Value = 5,
    Min = 1,
    Max = 20,
    Callback = function(v) Features.LegitAimbotSmoothness = v end
})

LegitAimbotSection:AddDropdown({
    Name = "aim part",
    Flag = "legitaimpart",
    Options = {"Head", "UpperTorso", "HumanoidRootPart"},
    Callback = function(v) Features.LegitAimPart = v end
})

LegitAimbotSection:AddDropdown({
    Name = "aim key",
    Flag = "legitaimkey",
    Options = {"RightMouse", "LeftMouse", "MiddleMouse", "Q", "E", "R", "F", "LeftControl", "LeftShift"},
    Callback = function(v) Features.LegitAimKey = v end
})

LegitAimbotSection:AddToggle({
    Name = "fov circle",
    Flag = "legitfovcircle",
    Callback = function(v) Features.LegitFOVCircle = v end
})

LegitAimbotSection:AddSlider({
    Name = "fov size",
    Flag = "legitfovsize",
    Value = 120,
    Min = 30,
    Max = 200,
    Callback = function(v) Features.LegitFOVCircleSize = v end
})

LegitAimbotSection:AddColorpicker({
    Name = "fov circle color",
    Flag = "legitfovcolor",
    Value = Features.LegitFOVCircleColor,
    Callback = function(v) Features.LegitFOVCircleColor = v end
})

LegitAimbotSection:AddToggle({
    Name = "visible check",
    Flag = "legitvisible",
    Callback = function(v) Features.LegitVisibleCheck = v end
})

LegitAimbotSection:AddToggle({
    Name = "team check",
    Flag = "legitteam",
    Callback = function(v) Features.LegitTeamCheck = v end
})

-- ========== RAGE TAB ==========
local RageTab = LunarWare:CreateTab({
    Name = "rage"
})

local RageAimbotSection = RageTab:CreateSection({
    Name = "rage aimbot"
})

RageAimbotSection:AddToggle({
    Name = "rage aimbot",
    Flag = "rageaimbot",
    Callback = function(v) Features.RageAimbot = v end
})

RageAimbotSection:AddToggle({
    Name = "silent aim",
    Flag = "ragesilent",
    Callback = function(v) Features.RageSilentAim = v end
})

RageAimbotSection:AddDropdown({
    Name = "aim part",
    Flag = "rageaimpart",
    Options = {"Head", "UpperTorso", "HumanoidRootPart"},
    Callback = function(v) Features.RageAimPart = v end
})

RageAimbotSection:AddDropdown({
    Name = "aim key",
    Flag = "rageaimkey",
    Options = {"RightMouse", "LeftMouse", "MiddleMouse", "Q", "E", "R", "F", "LeftControl", "LeftShift"},
    Callback = function(v) Features.RageAimKey = v end
})

RageAimbotSection:AddToggle({
    Name = "fov circle",
    Flag = "ragefovcircle",
    Callback = function(v) Features.RageFOVCircle = v end
})

RageAimbotSection:AddSlider({
    Name = "fov size",
    Flag = "ragefovsize",
    Value = 360,
    Min = 100,
    Max = 500,
    Callback = function(v) Features.RageFOVCircleSize = v end
})

RageAimbotSection:AddColorpicker({
    Name = "fov circle color",
    Flag = "ragefovcolor",
    Value = Features.RageFOVCircleColor,
    Callback = function(v) Features.RageFOVCircleColor = v end
})

RageAimbotSection:AddToggle({
    Name = "wallbang",
    Flag = "ragewallbang",
    Callback = function(v) Features.RageWallbang = v end
})

RageAimbotSection:AddToggle({
    Name = "team check",
    Flag = "rageteam",
    Callback = function(v) Features.RageTeamCheck = v end
})

local RageTriggerSection = RageTab:CreateSection({
    Name = "triggerbot"
})

RageTriggerSection:AddToggle({
    Name = "triggerbot",
    Flag = "triggerbot",
    Callback = function(v) Features.Triggerbot = v end
})

RageTriggerSection:AddSlider({
    Name = "trigger delay (ms)",
    Flag = "triggerdelay",
    Value = 0,
    Min = 0,
    Max = 500,
    Callback = function(v) Features.TriggerDelay = v end
})

RageTriggerSection:AddDropdown({
    Name = "trigger key",
    Flag = "triggerkey",
    Options = {"F", "Q", "E", "R", "LeftControl", "LeftShift", "RightMouse", "LeftMouse"},
    Callback = function(v) Features.TriggerKey = v end
})

RageTriggerSection:AddToggle({
    Name = "auto knife",
    Flag = "autoknife",
    Callback = function(v) Features.AutoKnife = v end
})

-- ========== WEAPON TAB ==========
local WeaponTab = LunarWare:CreateTab({
    Name = "weapon"
})

local GunModsSection = WeaponTab:CreateSection({
    Name = "gun mods"
})

GunModsSection:AddToggle({
    Name = "fast fire",
    Flag = "fastfire",
    Callback = function(v) 
        Features.FastFire = v
        ApplyGunMods()
    end
})

GunModsSection:AddToggle({
    Name = "no recoil",
    Flag = "norecoil",
    Callback = function(v) 
        Features.NoRecoil = v
        ApplyGunMods()
    end
})

GunModsSection:AddToggle({
    Name = "no spread",
    Flag = "nospread",
    Callback = function(v) 
        Features.NoSpread = v
        ApplyGunMods()
    end
})

GunModsSection:AddToggle({
    Name = "infinite ammo",
    Flag = "infiniteammo",
    Callback = function(v) 
        Features.InfiniteAmmo = v
        ApplyGunMods()
    end
})

GunModsSection:AddToggle({
    Name = "instant reload",
    Flag = "instantreload",
    Callback = function(v) 
        Features.InstantReload = v
        ApplyGunMods()
    end
})

GunModsSection:AddToggle({
    Name = "damage multiplier",
    Flag = "damagemultiplier",
    Callback = function(v) 
        Features.DamageMultiplier = v
        ApplyGunMods()
    end
})

GunModsSection:AddSlider({
    Name = "damage value",
    Flag = "damagevalue",
    Value = 5,
    Min = 2,
    Max = 20,
    Callback = function(v) 
        Features.DamageMultiplierValue = v
        if Features.DamageMultiplier then ApplyGunMods() end
    end
})

GunModsSection:AddToggle({
    Name = "rainbow gun",
    Flag = "rainbowgun",
    Callback = function(v) Features.RainbowGun = v end
})

local HitboxSection = WeaponTab:CreateSection({
    Name = "hitbox expander"
})

HitboxSection:AddToggle({
    Name = "hitbox expander",
    Flag = "hitboxexpander",
    Callback = function(v) Features.HitboxExpander = v end
})

HitboxSection:AddSlider({
    Name = "hitbox size",
    Flag = "hitboxsize",
    Value = 2.5,
    Min = 1,
    Max = 5,
    Callback = function(v) Features.HitboxSize = v end
})

-- ========== MOVEMENT TAB ==========
local MovementTab = LunarWare:CreateTab({
    Name = "movement"
})

local MovementSection = MovementTab:CreateSection({
    Name = "movement"
})

MovementSection:AddToggle({
    Name = "bunny hop",
    Flag = "bunnyhop",
    Callback = function(v) Features.BunnyHop = v end
})

MovementSection:AddToggle({
    Name = "speed boost",
    Flag = "speedboost",
    Callback = function(v) Features.SpeedBoost = v end
})

MovementSection:AddSlider({
    Name = "speed value",
    Flag = "speedvalue",
    Value = 50,
    Min = 16,
    Max = 250,
    Callback = function(v) Features.SpeedBoostValue = v end
})

MovementSection:AddToggle({
    Name = "no clip",
    Flag = "noclip",
    Callback = function(v) Features.NoClip = v end
})

MovementSection:AddToggle({
    Name = "no jump cooldown",
    Flag = "nojumpcooldown",
    Callback = function(v) Features.NoJumpCooldown = v end
})

-- ========== VISUAL TAB ==========
local VisualTab = LunarWare:CreateTab({
    Name = "visual"
})

local ESPSection = VisualTab:CreateSection({
    Name = "esp"
})

ESPSection:AddToggle({
    Name = "box esp",
    Flag = "boxesp",
    Callback = function(v) Features.BoxESP = v end
})

ESPSection:AddColorpicker({
    Name = "box color",
    Flag = "boxcolor",
    Value = Features.BoxColor,
    Callback = function(v) Features.BoxColor = v end
})

ESPSection:AddToggle({
    Name = "name esp",
    Flag = "nameesp",
    Callback = function(v) Features.NameESP = v end
})

ESPSection:AddToggle({
    Name = "distance esp",
    Flag = "distanceesp",
    Callback = function(v) Features.DistanceESP = v end
})

ESPSection:AddToggle({
    Name = "health bar",
    Flag = "healthbar",
    Callback = function(v) Features.HealthBar = v end
})

ESPSection:AddToggle({
    Name = "tracer esp",
    Flag = "traceresp",
    Callback = function(v) Features.TracerESP = v end
})

ESPSection:AddColorpicker({
    Name = "tracer color",
    Flag = "tracercolor",
    Value = Features.TracerColor,
    Callback = function(v) Features.TracerColor = v end
})

ESPSection:AddToggle({
    Name = "rainbow esp",
    Flag = "rainbowesp",
    Callback = function(v) Features.RainbowESP = v end
})

local WorldSection = VisualTab:CreateSection({
    Name = "world"
})

WorldSection:AddToggle({
    Name = "no fog",
    Flag = "nofog",
    Callback = function(v) Features.NoFog = v end
})

WorldSection:AddToggle({
    Name = "full bright",
    Flag = "fullbright",
    Callback = function(v) Features.FullBright = v end
})

WorldSection:AddToggle({
    Name = "zoom hack",
    Flag = "zoomhack",
    Callback = function(v) Features.ZoomHack = v end
})

WorldSection:AddSlider({
    Name = "zoom value",
    Flag = "zoomvalue",
    Value = 120,
    Min = 70,
    Max = 120,
    Callback = function(v) Features.ZoomHackValue = v end
})

-- ========== MISC TAB ==========
local MiscTab = LunarWare:CreateTab({
    Name = "misc"
})

local MiscSection = MiscTab:CreateSection({
    Name = "misc"
})

MiscSection:AddToggle({
    Name = "god mode",
    Flag = "godmode",
    Callback = function(v) Features.GodMode = v end
})

MiscSection:AddToggle({
    Name = "kill effect",
    Flag = "killeffect",
    Callback = function(v) Features.KillEffect = v end
})

MiscSection:AddDropdown({
    Name = "panic key",
    Flag = "panickey",
    Options = {"P", "O", "I", "U", "Y", "T", "R", "E", "W", "Q", "LeftControl", "RightControl", "LeftShift", "RightShift"},
    Callback = function(v) Features.PanicKey = v end
})

-- Services
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local VirtualInputManager = game:GetService("VirtualInputManager")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local Lighting = game:GetService("Lighting")

local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()
local Camera = Workspace.CurrentCamera

-- drawing objects
local ESPDrawings = {}
local OriginalHitboxes = {}
local LastJump = 0
local RainbowHue = 0
local GunRainbowHue = 0
local LastTriggerTime = 0
local TriggerbotRunning = true

-- fov circles
local LegitFOVCircle = Drawing.new("Circle")
LegitFOVCircle.Visible = false
LegitFOVCircle.Thickness = 2
LegitFOVCircle.Filled = false
LegitFOVCircle.NumSides = 64
LegitFOVCircle.Transparency = 0.7

local RageFOVCircle = Drawing.new("Circle")
RageFOVCircle.Visible = false
RageFOVCircle.Thickness = 2
RageFOVCircle.Filled = false
RageFOVCircle.NumSides = 64
RageFOVCircle.Transparency = 0.7

-- ========== PANIC KEY FUNCTION ==========
local function PanicMode()
    -- Disable ALL features
    Features.LegitAimbot = false
    Features.RageAimbot = false
    Features.Triggerbot = false
    Features.AutoKnife = false
    Features.FastFire = false
    Features.NoRecoil = false
    Features.NoSpread = false
    Features.InfiniteAmmo = false
    Features.InstantReload = false
    Features.DamageMultiplier = false
    Features.RainbowGun = false
    Features.HitboxExpander = false
    Features.BunnyHop = false
    Features.SpeedBoost = false
    Features.NoClip = false
    Features.NoJumpCooldown = false
    Features.BoxESP = false
    Features.NameESP = false
    Features.DistanceESP = false
    Features.HealthBar = false
    Features.TracerESP = false
    Features.RainbowESP = false
    Features.NoFog = false
    Features.FullBright = false
    Features.ZoomHack = false
    Features.GodMode = false
    
    -- Reset weapon values to original
    RestoreHitboxes()
    
    library:Notification({
        Title = "lunarware",
        Content = "panic mode activated - all features disabled",
        Time = 3
    })
end

-- ========== PANIC KEY CHECK ==========
local function IsPanicKeyPressed(key)
    if key == "P" then return UserInputService:IsKeyDown(Enum.KeyCode.P)
    elseif key == "O" then return UserInputService:IsKeyDown(Enum.KeyCode.O)
    elseif key == "I" then return UserInputService:IsKeyDown(Enum.KeyCode.I)
    elseif key == "U" then return UserInputService:IsKeyDown(Enum.KeyCode.U)
    elseif key == "Y" then return UserInputService:IsKeyDown(Enum.KeyCode.Y)
    elseif key == "T" then return UserInputService:IsKeyDown(Enum.KeyCode.T)
    elseif key == "R" then return UserInputService:IsKeyDown(Enum.KeyCode.R)
    elseif key == "E" then return UserInputService:IsKeyDown(Enum.KeyCode.E)
    elseif key == "W" then return UserInputService:IsKeyDown(Enum.KeyCode.W)
    elseif key == "Q" then return UserInputService:IsKeyDown(Enum.KeyCode.Q)
    elseif key == "LeftControl" then return UserInputService:IsKeyDown(Enum.KeyCode.LeftControl)
    elseif key == "RightControl" then return UserInputService:IsKeyDown(Enum.KeyCode.RightControl)
    elseif key == "LeftShift" then return UserInputService:IsKeyDown(Enum.KeyCode.LeftShift)
    elseif key == "RightShift" then return UserInputService:IsKeyDown(Enum.KeyCode.RightShift)
    end
    return false
end

-- ========== GUN MOD FUNCTIONS ==========
local function ApplyGunMods()
    local WeaponsFolder = ReplicatedStorage:FindFirstChild("Weapons")
    if not WeaponsFolder then
        WeaponsFolder = ReplicatedStorage:FindFirstChild("weapon")
    end
    if not WeaponsFolder then return end
    
    for _, Weapon in pairs(WeaponsFolder:GetChildren()) do
        for _, Child in pairs(Weapon:GetChildren()) do
            local Name = Child.Name
            
            if Features.FastFire and (Name == "FireRate" or Name == "BFireRate") then
                Child.Value = 0.02
            end
            
            if Features.NoRecoil and (Name == "Recoil" or Name == "Kickback") then
                Child.Value = 0
            end
            
            if Features.NoSpread and (Name == "Spread" or Name == "Bloom") then
                Child.Value = 0
            end
            
            if Features.InfiniteAmmo and (Name == "Ammo" or Name == "StoredAmmo") then
                Child.Value = 999
            end
            
            if Features.InstantReload and (Name == "ReloadTime") then
                Child.Value = 0
            end
            
            if Features.DamageMultiplier and Name == "Damage" then
                Child.Value = Child.Value * Features.DamageMultiplierValue
            end
        end
    end
end

-- ========== RAINBOW GUN ==========
local function ApplyRainbowGun()
    if not Features.RainbowGun then return end
    
    GunRainbowHue = (GunRainbowHue + 0.03) % 1
    local color = Color3.fromHSV(GunRainbowHue, 1, 1)
    
    local character = LocalPlayer.Character
    if not character then return end
    
    local tool = character:FindFirstChildWhichIsA("Tool")
    if tool then
        for _, part in pairs(tool:GetDescendants()) do
            if part:IsA("BasePart") then
                part.Color = color
            end
        end
    end
    
    for _, tool in pairs(LocalPlayer.Backpack:GetChildren()) do
        if tool:IsA("Tool") then
            for _, part in pairs(tool:GetDescendants()) do
                if part:IsA("BasePart") then
                    part.Color = color
                end
            end
        end
    end
end

-- ========== HITBOX EXPANDER ==========
local function ExpandHitboxes()
    if not Features.HitboxExpander then return end
    
    for _, Player in pairs(Players:GetPlayers()) do
        if Player ~= LocalPlayer then
            local Character = Player.Character
            if Character then
                local Head = Character:FindFirstChild("Head")
                local Torso = Character:FindFirstChild("UpperTorso")
                local Root = Character:FindFirstChild("HumanoidRootPart")
                
                if Head and not OriginalHitboxes[Head] then
                    OriginalHitboxes[Head] = Head.Size
                    Head.Size = Head.Size * Features.HitboxSize
                end
                if Torso and not OriginalHitboxes[Torso] then
                    OriginalHitboxes[Torso] = Torso.Size
                    Torso.Size = Torso.Size * Features.HitboxSize
                end
                if Root and not OriginalHitboxes[Root] then
                    OriginalHitboxes[Root] = Root.Size
                    Root.Size = Root.Size * Features.HitboxSize
                end
            end
        end
    end
end

local function RestoreHitboxes()
    for Part, OriginalSize in pairs(OriginalHitboxes) do
        pcall(function() Part.Size = OriginalSize end)
    end
    OriginalHitboxes = {}
end

local function GodMode()
    if not Features.GodMode then return end
    local Character = LocalPlayer.Character
    if not Character then return end
    local Humanoid = Character:FindFirstChild("Humanoid")
    if Humanoid then
        Humanoid.MaxHealth = 9e9
        Humanoid.Health = 9e9
    end
end

-- ========== MOVEMENT FUNCTIONS ==========
local function BunnyHop()
    if not Features.BunnyHop then return end
    local Character = LocalPlayer.Character
    if not Character then return end
    local Humanoid = Character:FindFirstChild("Humanoid")
    if not Humanoid then return end
    
    if Humanoid.FloorMaterial ~= Enum.Material.Air and UserInputService:IsKeyDown(Enum.KeyCode.Space) then
        local Now = tick()
        if Now - LastJump > 0.15 then
            Humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
            LastJump = Now
        end
    end
end

local function NoJumpCooldown()
    if not Features.NoJumpCooldown then return end
    local Character = LocalPlayer.Character
    if not Character then return end
    local Humanoid = Character:FindFirstChild("Humanoid")
    if Humanoid and UserInputService:IsKeyDown(Enum.KeyCode.Space) then
        Humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
    end
end

local function ApplyMovement()
    local Character = LocalPlayer.Character
    if not Character then return end
    local Humanoid = Character:FindFirstChild("Humanoid")
    if not Humanoid then return end
    
    if Features.SpeedBoost then
        Humanoid.WalkSpeed = Features.SpeedBoostValue
    else
        Humanoid.WalkSpeed = 16
    end
end

local function NoClip()
    if not Features.NoClip then return end
    local Character = LocalPlayer.Character
    if not Character then return end
    
    for _, Part in pairs(Character:GetDescendants()) do
        if Part:IsA("BasePart") then
            Part.CanCollide = false
        end
    end
end

-- ========== WORLD MODS ==========
local function ApplyWorldMods()
    if Features.NoFog then
        Lighting.FogEnd = 100000
        Lighting.FogStart = 100000
    end
    
    if Features.FullBright then
        Lighting.Brightness = 2
        Lighting.ClockTime = 14
        Lighting.OutdoorAmbient = Color3.fromRGB(128,128,128)
    end
    
    if Features.ZoomHack then
        Camera.FieldOfView = Features.ZoomHackValue
    else
        Camera.FieldOfView = 70
    end
end

local function ApplyRainbowESP()
    if not Features.RainbowESP then return end
    RainbowHue = (RainbowHue + 0.01) % 1
    local RainbowColor = Color3.fromHSV(RainbowHue, 1, 1)
    Features.BoxColor = RainbowColor
    Features.TracerColor = RainbowColor
end

-- ========== ESP DRAWING FUNCTIONS ==========
local function GetScreenPosition(Position)
    local Vector, OnScreen = Camera:WorldToViewportPoint(Position)
    if not OnScreen then return nil end
    return Vector2.new(Vector.X, Vector.Y)
end

local function ClearESP(Player)
    if ESPDrawings[Player] then
        if ESPDrawings[Player].Box then ESPDrawings[Player].Box:Remove() end
        if ESPDrawings[Player].Name then ESPDrawings[Player].Name:Remove() end
        if ESPDrawings[Player].Distance then ESPDrawings[Player].Distance:Remove() end
        if ESPDrawings[Player].HealthBar then ESPDrawings[Player].HealthBar:Remove() end
        if ESPDrawings[Player].Tracer then ESPDrawings[Player].Tracer:Remove() end
        ESPDrawings[Player] = nil
    end
end

local function DrawESP()
    for _, Player in pairs(Players:GetPlayers()) do
        if Player == LocalPlayer then continue end
        
        local Character = Player.Character
        local Humanoid = Character and Character:FindFirstChild("Humanoid")
        
        if not Character or not Humanoid or Humanoid.Health <= 0 then
            ClearESP(Player)
            continue
        end
        
        local RootPart = Character:FindFirstChild("HumanoidRootPart") or Character.PrimaryPart
        local Head = Character:FindFirstChild("Head")
        if not RootPart or not Head then
            ClearESP(Player)
            continue
        end
        
        local HeadPos = GetScreenPosition(Head.Position)
        local RootPos = GetScreenPosition(RootPart.Position)
        if not HeadPos or not RootPos then
            ClearESP(Player)
            continue
        end
        
        if not ESPDrawings[Player] then
            ESPDrawings[Player] = {}
        end
        
        local Height = RootPos.Y - HeadPos.Y
        local Width = Height * 0.5
        local Left = HeadPos.X - Width / 2
        local Top = HeadPos.Y
        
        if Features.BoxESP then
            if not ESPDrawings[Player].Box then
                ESPDrawings[Player].Box = Drawing.new("Square")
                ESPDrawings[Player].Box.Thickness = 2
                ESPDrawings[Player].Box.Filled = false
            end
            local Box = ESPDrawings[Player].Box
            Box.Visible = true
            Box.Position = Vector2.new(Left, Top)
            Box.Size = Vector2.new(Width, Height)
            Box.Color = Features.BoxColor
        elseif ESPDrawings[Player].Box then
            ESPDrawings[Player].Box.Visible = false
        end
        
        if Features.NameESP then
            if not ESPDrawings[Player].Name then
                ESPDrawings[Player].Name = Drawing.new("Text")
                ESPDrawings[Player].Name.Size = 14
                ESPDrawings[Player].Name.Center = false
                ESPDrawings[Player].Name.Outline = true
            end
            local Name = ESPDrawings[Player].Name
            Name.Visible = true
            Name.Position = Vector2.new(Left, Top - 18)
            Name.Text = Player.Name
            Name.Color = Color3.fromRGB(255,255,255)
        elseif ESPDrawings[Player].Name then
            ESPDrawings[Player].Name.Visible = false
        end
        
        if Features.DistanceESP then
            if not ESPDrawings[Player].Distance then
                ESPDrawings[Player].Distance = Drawing.new("Text")
                ESPDrawings[Player].Distance.Size = 12
                ESPDrawings[Player].Distance.Center = false
                ESPDrawings[Player].Distance.Outline = true
            end
            local Dist = (RootPart.Position - Camera.CFrame.Position).Magnitude / 3.28084
            local Distance = ESPDrawings[Player].Distance
            Distance.Visible = true
            Distance.Position = Vector2.new(Left, Top + Height + 2)
            Distance.Text = string.format("%.0fm", Dist)
            Distance.Color = Color3.fromRGB(200,200,200)
        elseif ESPDrawings[Player].Distance then
            ESPDrawings[Player].Distance.Visible = false
        end
        
        if Features.HealthBar then
            if not ESPDrawings[Player].HealthBar then
                ESPDrawings[Player].HealthBar = Drawing.new("Line")
                ESPDrawings[Player].HealthBar.Thickness = 3
            end
            local HealthPercent = Humanoid.Health / Humanoid.MaxHealth
            local Health = ESPDrawings[Player].HealthBar
            Health.Visible = true
            Health.From = Vector2.new(Left - 6, Top + Height)
            Health.To = Vector2.new(Left - 6, Top + Height - (Height * HealthPercent))
            Health.Color = Color3.fromRGB(255 - (255 * HealthPercent), 255 * HealthPercent, 0)
        elseif ESPDrawings[Player].HealthBar then
            ESPDrawings[Player].HealthBar.Visible = false
        end
        
        if Features.TracerESP then
            if not ESPDrawings[Player].Tracer then
                ESPDrawings[Player].Tracer = Drawing.new("Line")
                ESPDrawings[Player].Tracer.Thickness = 1.5
            end
            local Center = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y)
            local Tracer = ESPDrawings[Player].Tracer
            Tracer.Visible = true
            Tracer.From = Center
            Tracer.To = RootPos
            Tracer.Color = Features.TracerColor
        elseif ESPDrawings[Player].Tracer then
            ESPDrawings[Player].Tracer.Visible = false
        end
    end
end

-- ========== KEY PRESS CHECKS ==========
local function IsKeyPressed(key)
    if key == "RightMouse" then
        return UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton2)
    elseif key == "LeftMouse" then
        return UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton1)
    elseif key == "MiddleMouse" then
        return UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton3)
    elseif key == "Q" then
        return UserInputService:IsKeyDown(Enum.KeyCode.Q)
    elseif key == "E" then
        return UserInputService:IsKeyDown(Enum.KeyCode.E)
    elseif key == "R" then
        return UserInputService:IsKeyDown(Enum.KeyCode.R)
    elseif key == "F" then
        return UserInputService:IsKeyDown(Enum.KeyCode.F)
    elseif key == "LeftControl" then
        return UserInputService:IsKeyDown(Enum.KeyCode.LeftControl)
    elseif key == "LeftShift" then
        return UserInputService:IsKeyDown(Enum.KeyCode.LeftShift)
    end
    return false
end

local function IsTriggerKeyPressed(key)
    if key == "RightMouse" then
        return UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton2)
    elseif key == "LeftMouse" then
        return UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton1)
    elseif key == "F" then
        return UserInputService:IsKeyDown(Enum.KeyCode.F)
    elseif key == "Q" then
        return UserInputService:IsKeyDown(Enum.KeyCode.Q)
    elseif key == "E" then
        return UserInputService:IsKeyDown(Enum.KeyCode.E)
    elseif key == "R" then
        return UserInputService:IsKeyDown(Enum.KeyCode.R)
    elseif key == "LeftControl" then
        return UserInputService:IsKeyDown(Enum.KeyCode.LeftControl)
    elseif key == "LeftShift" then
        return UserInputService:IsKeyDown(Enum.KeyCode.LeftShift)
    end
    return false
end

-- ========== AIMBOT FUNCTIONS ==========
local function GetTarget(aimPart, teamCheck, wallbang, fovSize, isRage)
    local BestTarget = nil
    local BestDistance = fovSize
    local Center = Vector2.new(Mouse.X, Mouse.Y)
    
    for _, Player in pairs(Players:GetPlayers()) do
        if Player ~= LocalPlayer then
            if teamCheck and Player.Team == LocalPlayer.Team then
                continue
            end
            
            local Character = Player.Character
            if not Character then continue end
            
            local Humanoid = Character:FindFirstChild("Humanoid")
            if not Humanoid or Humanoid.Health <= 0 then continue end
            
            local TargetPart = nil
            if aimPart == "Head" then
                TargetPart = Character:FindFirstChild("Head")
            elseif aimPart == "UpperTorso" then
                TargetPart = Character:FindFirstChild("UpperTorso")
            else
                TargetPart = Character:FindFirstChild("HumanoidRootPart")
            end
            if not TargetPart then continue end
            
            local ScreenPos, OnScreen = Camera:WorldToViewportPoint(TargetPart.Position)
            if not OnScreen and not wallbang then continue end
            
            local Distance = (Center - Vector2.new(ScreenPos.X, ScreenPos.Y)).Magnitude
            
            if Distance < BestDistance then
                if not isRage then
                    local Params = RaycastParams.new()
                    Params.FilterDescendantsInstances = {LocalPlayer.Character}
                    local Ray = Workspace:Raycast(Camera.CFrame.Position, (TargetPart.Position - Camera.CFrame.Position).Unit * 1000, Params)
                    if Ray and Ray.Instance:IsDescendantOf(Character) then
                        BestDistance = Distance
                        BestTarget = Player
                    end
                else
                    BestDistance = Distance
                    BestTarget = Player
                end
            end
        end
    end
    return BestTarget
end

local function PerformLegitAimbot()
    local Target = GetTarget(Features.LegitAimPart, Features.LegitTeamCheck, false, Features.LegitFOVCircleSize, false)
    if not Target then return end
    
    local Character = Target.Character
    if not Character then return end
    
    local TargetPart = Character:FindFirstChild(Features.LegitAimPart)
    if not TargetPart then
        if Features.LegitAimPart == "Head" then TargetPart = Character:FindFirstChild("Head")
        elseif Features.LegitAimPart == "UpperTorso" then TargetPart = Character:FindFirstChild("UpperTorso")
        else TargetPart = Character:FindFirstChild("HumanoidRootPart") end
    end
    if not TargetPart then return end
    
    local ScreenPos = Camera:WorldToViewportPoint(TargetPart.Position)
    local TargetPos = Vector2.new(ScreenPos.X, ScreenPos.Y)
    local CurrentPos = Vector2.new(Mouse.X, Mouse.Y)
    local Delta = TargetPos - CurrentPos
    local SmoothDelta = Delta / Features.LegitAimbotSmoothness
    mousemoverel(SmoothDelta.X, SmoothDelta.Y)
end

local function PerformRageAimbot()
    local Target = GetTarget(Features.RageAimPart, Features.RageTeamCheck, Features.RageWallbang, Features.RageFOVCircleSize, true)
    if not Target then return end
    
    local Character = Target.Character
    if not Character then return end
    
    local TargetPart = Character:FindFirstChild(Features.RageAimPart)
    if not TargetPart then
        if Features.RageAimPart == "Head" then TargetPart = Character:FindFirstChild("Head")
        elseif Features.RageAimPart == "UpperTorso" then TargetPart = Character:FindFirstChild("UpperTorso")
        else TargetPart = Character:FindFirstChild("HumanoidRootPart") end
    end
    if not TargetPart then return end
    
    if Features.RageSilentAim then
        local Direction = (TargetPart.Position - Camera.CFrame.Position).Unit
        Camera.CFrame = CFrame.lookAt(Camera.CFrame.Position, Camera.CFrame.Position + Direction)
    else
        local ScreenPos = Camera:WorldToViewportPoint(TargetPart.Position)
        local TargetPos = Vector2.new(ScreenPos.X, ScreenPos.Y)
        local CurrentPos = Vector2.new(Mouse.X, Mouse.Y)
        local Delta = TargetPos - CurrentPos
        mousemoverel(Delta.X, Delta.Y)
    end
end

-- ========== TRIGGERBOT ==========
local function IsOnEnemy()
    local Center = Vector2.new(Mouse.X, Mouse.Y)
    local FOVRadius = 50
    
    for _, Player in pairs(Players:GetPlayers()) do
        if Player ~= LocalPlayer then
            if Features.RageTeamCheck and Player.Team == LocalPlayer.Team then
                continue
            end
            
            local Character = Player.Character
            if not Character then continue end
            
            local Humanoid = Character:FindFirstChild("Humanoid")
            if not Humanoid or Humanoid.Health <= 0 then continue end
            
            local TargetPart = Character:FindFirstChild("Head") or Character:FindFirstChild("HumanoidRootPart")
            if not TargetPart then continue end
            
            local ScreenPos, OnScreen = Camera:WorldToViewportPoint(TargetPart.Position)
            if not OnScreen then continue end
            
            local Distance = (Center - Vector2.new(ScreenPos.X, ScreenPos.Y)).Magnitude
            
            if Distance < FOVRadius then
                return true
            end
        end
    end
    return false
end

local function TriggerbotLoop()
    while TriggerbotRunning do
        if Features.Triggerbot then
            if Features.TriggerKey == "RightMouse" or Features.TriggerKey == "LeftMouse" then
                if IsTriggerKeyPressed(Features.TriggerKey) and IsOnEnemy() then
                    local Now = tick()
                    if Now - LastTriggerTime >= (Features.TriggerDelay / 1000) then
                        LastTriggerTime = Now
                        VirtualInputManager:SendMouseButtonEvent(0, 0, 0, true, game, 0)
                        task.wait(0.01)
                        VirtualInputManager:SendMouseButtonEvent(0, 0, 0, false, game, 0)
                    end
                end
            else
                if IsTriggerKeyPressed(Features.TriggerKey) and IsOnEnemy() then
                    local Now = tick()
                    if Now - LastTriggerTime >= (Features.TriggerDelay / 1000) then
                        LastTriggerTime = Now
                        VirtualInputManager:SendMouseButtonEvent(0, 0, 0, true, game, 0)
                        task.wait(0.01)
                        VirtualInputManager:SendMouseButtonEvent(0, 0, 0, false, game, 0)
                    end
                end
            end
        end
        task.wait(0.01)
    end
end

task.spawn(TriggerbotLoop)

-- ========== AUTO KNIFE ==========
local function AutoKnife()
    if not Features.AutoKnife then return end
    for _, Player in pairs(Players:GetPlayers()) do
        if Player ~= LocalPlayer then
            local Character = Player.Character
            if Character and LocalPlayer.Character then
                local Distance = (Character.HumanoidRootPart.Position - LocalPlayer.Character.HumanoidRootPart.Position).Magnitude
                if Distance < 5 then
                    VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.F, false, game)
                    task.wait(0.05)
                    VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.F, false, game)
                end
            end
        end
    end
end

-- ========== KILL EFFECT ==========
local function KillEffect()
    if not Features.KillEffect then return end
    local ColorCorrection = Instance.new("ColorCorrectionEffect")
    ColorCorrection.TintColor = Color3.fromRGB(255,0,0)
    ColorCorrection.Parent = Camera
    task.wait(0.1)
    ColorCorrection:Destroy()
end

-- hook kill detection
local OldIndex = nil
if getrawmetatable then
    local mt = getrawmetatable(game)
    setreadonly(mt, false)
    OldIndex = mt.__index
    mt.__index = function(self, key)
        if key == "Health" and tostring(self) == "Humanoid" and self.Parent and self.Parent.Parent and self.Parent.Parent:IsA("Player") then
            if self.Health <= 0 and self.Parent.Parent ~= LocalPlayer then
                if Features.KillEffect then KillEffect() end
            end
        end
        return OldIndex(self, key)
    end
end

-- ========== APPLY GUN MODS ==========
ApplyGunMods()

-- ========== PANIC KEY LOOP ==========
task.spawn(function()
    while true do
        if IsPanicKeyPressed(Features.PanicKey) then
            PanicMode()
            task.wait(1)
        end
        task.wait(0.1)
    end
end)

-- ========== MAIN LOOP ==========
RunService.RenderStepped:Connect(function()
    ApplyGunMods()
    ApplyRainbowGun()
    ApplyWorldMods()
    ApplyRainbowESP()
    GodMode()
    BunnyHop()
    NoJumpCooldown()
    ApplyMovement()
    NoClip()
    
    if Features.HitboxExpander then
        ExpandHitboxes()
    else
        RestoreHitboxes()
    end
    
    DrawESP()
    
    if Features.AutoKnife then AutoKnife() end
    
    -- Update FOV Circles
    if Features.LegitFOVCircle and Features.LegitAimbot then
        LegitFOVCircle.Visible = true
        LegitFOVCircle.Radius = Features.LegitFOVCircleSize
        LegitFOVCircle.Position = Vector2.new(Mouse.X, Mouse.Y)
        LegitFOVCircle.Color = Features.LegitFOVCircleColor
    else
        LegitFOVCircle.Visible = false
    end
    
    if Features.RageFOVCircle and Features.RageAimbot then
        RageFOVCircle.Visible = true
        RageFOVCircle.Radius = Features.RageFOVCircleSize
        RageFOVCircle.Position = Vector2.new(Mouse.X, Mouse.Y)
        RageFOVCircle.Color = Features.RageFOVCircleColor
    else
        RageFOVCircle.Visible = false
    end
    
    -- Aimbot
    if Features.LegitAimbot and IsKeyPressed(Features.LegitAimKey) then
        PerformLegitAimbot()
    end
    
    if Features.RageAimbot and IsKeyPressed(Features.RageAimKey) then
        PerformRageAimbot()
    end
end)

LocalPlayer.CharacterAdded:Connect(function()
    task.wait(1)
end)

print("lunarware loaded | press k / right shift to toggle menu")
-- lunarware hub | vape ui
-- junkie key system
-- press k to open menu

local lib = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/UI-Libs/main/Vape.txt"))()

-- ========== JUNKIE KEY SYSTEM ==========
local Junkie = loadstring(game:HttpGet("https://api.junkie-development.de/api/v1/luascripts/public/8e08cda5c530a6529a71a14b94a33734eccc870e9f28220410eb21d719f66da9/download"))()
Junkie.service = "lunarware"
Junkie.identifier = "491725ee-ff0c-4b65-90ce-10bf06971951"
Junkie.provider = "lunarware_provider"

local IsAuthenticated = false
local CurrentKey = ""

local function VerifyKey(key)
    local result = Junkie.check_key(key)
    if result and result.valid then
        if result.message == "KEYLESS" or result.message == "KEY_VALID" then
            IsAuthenticated = true
            return true, "Key accepted - welcome to lunarware"
        end
    end
    return false, "Invalid key"
end

-- ========== GAME SCRIPTS RAW URLs ==========
-- Replace with your actual raw.githubusercontent.com URLs
local Scripts = {
    arsenal = "https://raw.githubusercontent.com/enkryptonloll/lunarware/main/arsenal/main.lua",
    bloxfruits = "https://raw.githubusercontent.com/enkryptonloll/lunarware/main/bloxfruits/main.lua",
    bloxstrike = "https://raw.githubusercontent.com/enkryptonloll/lunarware/main/bloxstrike/main.lua",
    boogabooga = "https://raw.githubusercontent.com/enkryptonloll/lunarware/main/boogabooga/main.lua",
    dahood = "https://raw.githubusercontent.com/enkryptonloll/lunarware/main/dahood/main.lua",
    jjs = "https://raw.githubusercontent.com/enkryptonloll/lunarware/main/jjs/main.lua",
    lumbertycoon = "https://raw.githubusercontent.com/enkryptonloll/lunarware/main/lumbertycoon/main.lua",
    mm2 = "https://raw.githubusercontent.com/enkryptonloll/lunarware/main/mm2/main.lua",
    naturaldisaster = "https://raw.githubusercontent.com/enkryptonloll/lunarware/main/naturaldisaster/main.lua",
    operationsiege = "https://raw.githubusercontent.com/enkryptonloll/lunarware/main/operationsiege/main.lua",
    rivals = "https://raw.githubusercontent.com/enkryptonloll/lunarware/main/rivals/main.lua",
    sab = "https://raw.githubusercontent.com/enkryptonloll/lunarware/main/sab/main.lua",
    troll = "https://raw.githubusercontent.com/enkryptonloll/lunarware/main/troll/main.lua",
    tsb = "https://raw.githubusercontent.com/enkryptonloll/lunarware/main/tsb/main.lua",
    universal = "https://raw.githubusercontent.com/enkryptonloll/lunarware/main/universal/main.lua",
}

-- ========== VAPE UI ==========
local Win = lib:Window("lunarware hub", Color3.fromRGB(100, 50, 200), Enum.KeyCode.K)

-- Key Tab
local KeyTab = Win:Tab("key")
KeyTab:Label("enter your junkie key")
local KeyBox = KeyTab:Textbox("key", true, function(v) CurrentKey = v end)
KeyTab:Button("authenticate", function()
    if CurrentKey and CurrentKey ~= "" then
        local success, msg = VerifyKey(CurrentKey)
        if success then
            lib:Notification("success", msg, "ok")
        else
            lib:Notification("error", msg, "ok")
        end
    else
        lib:Notification("error", "enter a key", "ok")
    end
end)

-- Games Tab
local GamesTab = Win:Tab("games")
GamesTab:Label("select a game (requires authentication)")

local function LoadGame(url, name)
    if not IsAuthenticated then
        lib:Notification("error", "authenticate first in key tab", "ok")
        return
    end
    local success, result = pcall(function()
        return game:HttpGet(url)
    end)
    if success and result and result ~= "" then
        loadstring(result)()
        lib:Notification("loaded", name .. " injected", "ok")
    else
        lib:Notification("error", "failed to load " .. name, "ok")
    end
end

-- Create all game buttons
local gameList = {
    {"arsenal", "arsenal"},
    {"blox fruits", "bloxfruits"},
    {"blox strike", "bloxstrike"},
    {"booga booga", "boogabooga"},
    {"da hood", "dahood"},
    {"jj's", "jjs"},
    {"lumber tycoon", "lumbertycoon"},
    {"murder mystery 2", "mm2"},
    {"natural disaster", "naturaldisaster"},
    {"operation siege", "operationsiege"},
    {"rivals", "rivals"},
    {"sab", "sab"},
    {"troll", "troll"},
    {"tsb", "tsb"},
    {"universal", "universal"},
}

for _, game in ipairs(gameList) do
    GamesTab:Button(game[1], function()
        LoadGame(Scripts[game[2]], game[1])
    end)
end

-- Info Tab
local InfoTab = Win:Tab("info")
InfoTab:Label("lunarware hub v2.0")
InfoTab:Label("junkie key system")
InfoTab:Label("")
InfoTab:Label("press k to toggle menu")
InfoTab:Label("get your key from discord")

print("lunarware hub loaded | press k to open menu")

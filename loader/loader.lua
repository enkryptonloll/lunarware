-- lunarware hub
-- game hub with script management
-- press k to open menu

local lib = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/UI-Libs/main/Vape.txt"))()

-- script database
local scripts = {
    -- combat scripts
    {name = "arsenal", category = "combat", url = "https://raw.githubusercontent.com/enkryptonloll/lunarware/main/arsenal/main.lua"},
    {name = "blox strike", category = "combat", url = "https://raw.githubusercontent.com/enkryptonloll/lunarware/main/bloxstrike/main.lua"},
    {name = "da hood", category = "combat", url = "https://raw.githubusercontent.com/enkryptonloll/lunarware/main/dahood/main.lua"},
    {name = "mm2", category = "combat", url = "https://raw.githubusercontent.com/enkryptonloll/lunarware/main/mm2/main.lua"},
    {name = "rivals", category = "combat", url = "https://raw.githubusercontent.com/enkryptonloll/lunarware/main/rivals/main.lua"},
    {name = "tsb", category = "combat", url = "https://raw.githubusercontent.com/enkryptonloll/lunarware/main/tsb/main.lua"},
    {name = "jjs", category = "combat", url = "https://raw.githubusercontent.com/enkryptonloll/lunarware/main/jjs/main.lua"},
    {name = "operation siege", category = "combat", url = "https://raw.githubusercontent.com/enkryptonloll/lunarware/main/operationsiege/main.lua"},
    
    -- farming scripts
    {name = "blox fruits", category = "farming", url = "https://raw.githubusercontent.com/enkryptonloll/lunarware/main/bloxfruits/main.lua"},
    {name = "lumber tycoon", category = "farming", url = "https://raw.githubusercontent.com/enkryptonloll/lunarware/main/lumbertycoon/main.lua"},
    {name = "booga booga", category = "farming", url = "https://raw.githubusercontent.com/enkryptonloll/lunarware/main/boogabooga/main.lua"},
    {name = "blade ball", category = "farming", url = "https://raw.githubusercontent.com/enkryptonloll/lunarware/main/bladeball/main.lua"},
    
    -- survival scripts
    {name = "natural disaster", category = "survival", url = "https://raw.githubusercontent.com/enkryptonloll/lunarware/main/naturaldisaster/main.lua"},
    
    -- admin script
    {name = "lunar admin", category = "admin", url = "https://raw.githubusercontent.com/enkryptonloll/lunarware/main/admin/main.lua"},
}

-- stored data
local favorites = {}
local recent = {}
local scriptstatus = {}
local queuedscripts = {}
local loadingqueue = false

local function loaddata()
    local success, data = pcall(function() return readfile("lunarware_favorites.json") end)
    if success and data then
        favorites = game:GetService("HttpService"):JSONDecode(data)
    end
    local success2, data2 = pcall(function() return readfile("lunarware_recent.json") end)
    if success2 and data2 then
        recent = game:GetService("HttpService"):JSONDecode(data2)
    end
end

local function savefavorites()
    pcall(function()
        writefile("lunarware_favorites.json", game:GetService("HttpService"):JSONEncode(favorites))
    end)
end

local function saverecent()
    pcall(function()
        writefile("lunarware_recent.json", game:GetService("HttpService"):JSONEncode(recent))
    end)
end

local function addrecent(name)
    for i, v in ipairs(recent) do
        if v == name then
            table.remove(recent, i)
            break
        end
    end
    table.insert(recent, 1, name)
    if #recent > 10 then
        table.remove(recent)
    end
    saverecent()
end

loaddata()

-- main window
local win = lib:Window("lunarware hub", Color3.fromRGB(30, 30, 40), Enum.KeyCode.K)

-- tabs
local home_tab = win:Tab("home")
local scripts_tab = win:Tab("scripts")
local favorites_tab = win:Tab("favorites")
local recent_tab = win:Tab("recent")
local queue_tab = win:Tab("queue")
local settings_tab = win:Tab("settings")

-- home tab
home_tab:Label("lunarware hub v3.0")
home_tab:Label("")
home_tab:Label("total scripts: " .. #scripts)
home_tab:Label("favorites: " .. #favorites)
home_tab:Label("")
home_tab:Button("refresh scripts", function()
    lib:Notification("lunarware", "refreshing scripts...", "ok")
    for i, script in ipairs(scripts) do
        scriptstatus[script.name] = nil
    end
end)

-- function to load script
local function loadscript(url, name)
    addrecent(name)
    local success, result = pcall(function()
        return game:HttpGet(url)
    end)
    if success and result and result ~= "" then
        loadstring(result)()
        lib:Notification("lunarware", name .. " loaded", "ok")
        scriptstatus[name] = "loaded"
    else
        lib:Notification("error", "failed to load " .. name, "ok")
        scriptstatus[name] = "error"
    end
end

-- scripts tab
local search_box = scripts_tab:Textbox("search", true, function(v)
    local searchterm = v:lower()
    for _, child in pairs(scripts_tab.Container:GetChildren()) do
        if child:IsA("TextButton") then
            local shouldshow = searchterm == "" or string.find(string.lower(child.Name), searchterm)
            child.Visible = shouldshow
        end
    end
end)

-- category filter
local currentcategory = "all"
local function filterbycategory(category)
    currentcategory = category
    for _, child in pairs(scripts_tab.Container:GetChildren()) do
        if child:IsA("TextButton") then
            local scriptdata = nil
            for _, s in ipairs(scripts) do
                if s.name == child.Name then
                    scriptdata = s
                    break
                end
            end
            if scriptdata then
                local showcategory = category == "all" or scriptdata.category == category
                child.Visible = showcategory
            end
        end
    end
end

scripts_tab:Button("all", function() filterbycategory("all") end)
scripts_tab:Button("combat", function() filterbycategory("combat") end)
scripts_tab:Button("farming", function() filterbycategory("farming") end)
scripts_tab:Button("survival", function() filterbycategory("survival") end)
scripts_tab:Button("admin", function() filterbycategory("admin") end)

scripts_tab:Label("")

for _, script in ipairs(scripts) do
    local btn = scripts_tab:Button(script.name, function()
        loadscript(script.url, script.name)
    end)
    btn.Name = script.name
end

-- favorites tab
local function updatefavoritestab()
    for _, child in pairs(favorites_tab.Container:GetChildren()) do
        if child:IsA("TextButton") then
            child:Destroy()
        end
    end
    
    if #favorites == 0 then
        favorites_tab:Label("no favorites yet")
        return
    end
    
    for _, favname in ipairs(favorites) do
        local scriptdata = nil
        for _, s in ipairs(scripts) do
            if s.name == favname then
                scriptdata = s
                break
            end
        end
        if scriptdata then
            local btn = favorites_tab:Button(scriptdata.name, function()
                loadscript(scriptdata.url, scriptdata.name)
            end)
            btn.Name = scriptdata.name
        end
    end
end

-- recent tab
local function updaterecenttab()
    for _, child in pairs(recent_tab.Container:GetChildren()) do
        if child:IsA("TextButton") then
            child:Destroy()
        end
    end
    
    if #recent == 0 then
        recent_tab:Label("no recent scripts")
        return
    end
    
    for _, recentname in ipairs(recent) do
        local scriptdata = nil
        for _, s in ipairs(scripts) do
            if s.name == recentname then
                scriptdata = s
                break
            end
        end
        if scriptdata then
            local btn = recent_tab:Button(scriptdata.name, function()
                loadscript(scriptdata.url, scriptdata.name)
            end)
            btn.Name = scriptdata.name
        end
    end
end

-- queue tab
local function processqueue()
    if loadingqueue or #queuedscripts == 0 then return end
    loadingqueue = true
    local nextscript = queuedscripts[1]
    table.remove(queuedscripts, 1)
    
    local success, result = pcall(function()
        return game:HttpGet(nextscript.url)
    end)
    if success and result and result ~= "" then
        loadstring(result)()
        lib:Notification("lunarware", nextscript.name .. " loaded from queue", "ok")
    else
        lib:Notification("error", "failed to load " .. nextscript.name, "ok")
    end
    
    loadingqueue = false
    if #queuedscripts > 0 then
        task.spawn(processqueue)
    end
    updatequeuetab()
end

local function addtoqueue(name, url)
    table.insert(queuedscripts, {name = name, url = url})
    updatequeuetab()
    if not loadingqueue then
        task.spawn(processqueue)
    end
end

local function updatequeuetab()
    for _, child in pairs(queue_tab.Container:GetChildren()) do
        if child:IsA("TextButton") or child:IsA("TextLabel") then
            child:Destroy()
        end
    end
    
    if #queuedscripts == 0 then
        queue_tab:Label("queue empty")
        return
    end
    
    for i, qscript in ipairs(queuedscripts) do
        queue_tab:Label(i .. ". " .. qscript.name)
    end
    
    queue_tab:Button("clear queue", function()
        queuedscripts = {}
        updatequeuetab()
    end)
end

-- clear scripts tab and recreate with queue option
for _, child in pairs(scripts_tab.Container:GetChildren()) do
    if child:IsA("TextButton") then
        child:Destroy()
    end
end

scripts_tab:Label("search")
local searchbox = scripts_tab:Textbox("search", true, function(v)
    local searchterm = v:lower()
    for _, child in pairs(scripts_tab.Container:GetChildren()) do
        if child:IsA("TextButton") then
            local shouldshow = searchterm == "" or string.find(string.lower(child.Name), searchterm)
            child.Visible = shouldshow
        end
    end
end)

scripts_tab:Button("all", function() filterbycategory("all") end)
scripts_tab:Button("combat", function() filterbycategory("combat") end)
scripts_tab:Button("farming", function() filterbycategory("farming") end)
scripts_tab:Button("survival", function() filterbycategory("survival") end)
scripts_tab:Button("admin", function() filterbycategory("admin") end)

scripts_tab:Label("")

for _, script in ipairs(scripts) do
    local container = scripts_tab:NewContainer({Name = script.name .. "_container", Size = 80})
    local btn = container:Button(script.name, function()
        loadscript(script.url, script.name)
    end)
    btn.Name = script.name
    
    local queuebtn = container:Button("queue", function()
        addtoqueue(script.name, script.url)
    end)
    queuebtn.Name = script.name .. "_queue"
    
    local favbtn = container:Button("star", function()
        local found = false
        for i, f in ipairs(favorites) do
            if f == script.name then
                table.remove(favorites, i)
                found = true
                break
            end
        end
        if not found then
            table.insert(favorites, script.name)
        end
        savefavorites()
        updatefavoritestab()
        lib:Notification("lunarware", script.name .. (found and " removed from favorites" or " added to favorites"), "ok")
    end)
    favbtn.Name = script.name .. "_fav"
end

-- settings tab
settings_tab:Label("theme")
settings_tab:Dropdown("accent color", {"default", "red", "blue", "green", "purple"}, function(v)
    if v == "red" then
        lib:ChangePresetColor(Color3.fromRGB(255, 50, 50))
    elseif v == "blue" then
        lib:ChangePresetColor(Color3.fromRGB(50, 100, 255))
    elseif v == "green" then
        lib:ChangePresetColor(Color3.fromRGB(50, 255, 50))
    elseif v == "purple" then
        lib:ChangePresetColor(Color3.fromRGB(150, 50, 255))
    else
        lib:ChangePresetColor(Color3.fromRGB(44, 120, 224))
    end
end)

settings_tab:Label("")
settings_tab:Toggle("notifications", true, function(v)
    getgenv().notificationsenabled = v
end)

settings_tab:Label("")
settings_tab:Button("clear all data", function()
    favorites = {}
    recent = {}
    queuedscripts = {}
    savefavorites()
    saverecent()
    updatefavoritestab()
    updaterecenttab()
    updatequeuetab()
    lib:Notification("lunarware", "all data cleared", "ok")
end)

settings_tab:Label("")
settings_tab:Button("unload hub", function()
    local ui = game:GetService("CoreGui"):FindFirstChild("ui")
    if ui then ui:Destroy() end
end)

-- initial updates
updatefavoritestab()
updaterecenttab()
updatequeuetab()

print("lunarware hub loaded | press k to open menu")

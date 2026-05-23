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
    {name = "sab", category = "farming", url = "https://raw.githubusercontent.com/enkryptonloll/lunarware/main/sab/main.lua"},
    {name = "blade ball", category = "farming", url = "https://raw.githubusercontent.com/enkryptonloll/lunarware/main/bladeball/main.lua"},
    
    -- survival scripts
    {name = "natural disaster", category = "survival", url = "https://raw.githubusercontent.com/enkryptonloll/lunarware/main/naturaldisaster/main.lua"},
    
    -- misc scripts
    {name = "troll", category = "misc", url = "https://raw.githubusercontent.com/enkryptonloll/lunarware/main/troll/main.lua"},
    {name = "universal", category = "misc", url = "https://raw.githubusercontent.com/enkryptonloll/lunarware/main/universal/main.lua"},
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
        favorites = game:getservice("httpservice"):jsondecode(data)
    end
    local success2, data2 = pcall(function() return readfile("lunarware_recent.json") end)
    if success2 and data2 then
        recent = game:getservice("httpservice"):jsondecode(data2)
    end
end

local function savefavorites()
    pcall(function()
        writefile("lunarware_favorites.json", game:getservice("httpservice"):jsonencode(favorites))
    end)
end

local function saverecent()
    pcall(function()
        writefile("lunarware_recent.json", game:getservice("httpservice"):jsonencode(recent))
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
local win = lib:window("lunarware hub", color3.fromrgb(30, 30, 40), enum.keycode.k)

-- tabs
local home_tab = win:tab("home")
local scripts_tab = win:tab("scripts")
local favorites_tab = win:tab("favorites")
local recent_tab = win:tab("recent")
local queue_tab = win:tab("queue")
local settings_tab = win:tab("settings")

-- home tab
home_tab:label("lunarware hub v3.0")
home_tab:label("")
home_tab:label("total scripts: " .. #scripts)
home_tab:label("favorites: " .. #favorites)
home_tab:label("")
home_tab:button("refresh scripts", function()
    lib:notification("lunarware", "refreshing scripts...", "ok")
    for i, script in ipairs(scripts) do
        scriptstatus[script.name] = nil
    end
end)

-- function to load script
local function loadscript(url, name)
    addrecent(name)
    local success, result = pcall(function()
        return game:getservice("http"):getasync(url)
    end)
    if success and result and result ~= "" then
        loadstring(result)()
        lib:notification("lunarware", name .. " loaded", "ok")
        scriptstatus[name] = "loaded"
    else
        lib:notification("error", "failed to load " .. name, "ok")
        scriptstatus[name] = "error"
    end
end

-- scripts tab
local search_box = scripts_tab:textbox("search", true, function(v)
    local searchterm = v:lower()
    for _, child in pairs(scripts_tab.container:getchildren()) do
        if child:isa("textbutton") then
            local shouldshow = searchterm == "" or child.name:lower():find(searchterm)
            child.visible = shouldshow
        end
    end
end)

-- category filter
local currentcategory = "all"
local function filterbycategory(category)
    currentcategory = category
    for _, child in pairs(scripts_tab.container:getchildren()) do
        if child:isa("textbutton") then
            local scriptdata = nil
            for _, s in ipairs(scripts) do
                if s.name == child.name then
                    scriptdata = s
                    break
                end
            end
            if scriptdata then
                local showcategory = category == "all" or scriptdata.category == category
                child.visible = showcategory
            end
        end
    end
end

scripts_tab:button("all", function() filterbycategory("all") end)
scripts_tab:button("combat", function() filterbycategory("combat") end)
scripts_tab:button("farming", function() filterbycategory("farming") end)
scripts_tab:button("survival", function() filterbycategory("survival") end)
scripts_tab:button("misc", function() filterbycategory("misc") end)

scripts_tab:label("")

for _, script in ipairs(scripts) do
    local btn = scripts_tab:button(script.name, function()
        loadscript(script.url, script.name)
    end)
    btn.name = script.name
end

-- favorites tab
local function updatefavoritestab()
    for _, child in pairs(favorites_tab.container:getchildren()) do
        if child:isa("textbutton") then
            child:destroy()
        end
    end
    
    if #favorites == 0 then
        favorites_tab:label("no favorites yet")
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
            local btn = favorites_tab:button(scriptdata.name, function()
                loadscript(scriptdata.url, scriptdata.name)
            end)
            btn.name = scriptdata.name
        end
    end
end

-- add to favorites from scripts tab
-- modified to add favorite when clicking star (will need ui modification)

-- recent tab
local function updaterecenttab()
    for _, child in pairs(recent_tab.container:getchildren()) do
        if child:isa("textbutton") then
            child:destroy()
        end
    end
    
    if #recent == 0 then
        recent_tab:label("no recent scripts")
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
            local btn = recent_tab:button(scriptdata.name, function()
                loadscript(scriptdata.url, scriptdata.name)
            end)
            btn.name = scriptdata.name
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
        return game:getservice("http"):getasync(nextscript.url)
    end)
    if success and result and result ~= "" then
        loadstring(result)()
        lib:notification("lunarware", nextscript.name .. " loaded from queue", "ok")
    else
        lib:notification("error", "failed to load " .. nextscript.name, "ok")
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
    for _, child in pairs(queue_tab.container:getchildren()) do
        if child:isa("textbutton") or child:isa("textlabel") then
            child:destroy()
        end
    end
    
    if #queuedscripts == 0 then
        queue_tab:label("queue empty")
        return
    end
    
    for i, qscript in ipairs(queuedscripts) do
        queue_tab:label(i .. ". " .. qscript.name)
    end
    
    queue_tab:button("clear queue", function()
        queuedscripts = {}
        updatequeuetab()
    end)
end

-- add queue buttons to scripts tab (modified buttons)
-- clear scripts tab and recreate with queue option
for _, child in pairs(scripts_tab.container:getchildren()) do
    if child:isa("textbutton") then
        child:destroy()
    end
end

scripts_tab:label("search")
local searchbox = scripts_tab:textbox("search", true, function(v)
    local searchterm = v:lower()
    for _, child in pairs(scripts_tab.container:getchildren()) do
        if child:isa("textbutton") then
            local shouldshow = searchterm == "" or child.name:lower():find(searchterm)
            child.visible = shouldshow
        end
    end
end)

scripts_tab:button("all", function() filterbycategory("all") end)
scripts_tab:button("combat", function() filterbycategory("combat") end)
scripts_tab:button("farming", function() filterbycategory("farming") end)
scripts_tab:button("survival", function() filterbycategory("survival") end)
scripts_tab:button("misc", function() filterbycategory("misc") end)

scripts_tab:label("")

for _, script in ipairs(scripts) do
    local container = scripts_tab:newcontainer({name = script.name .. "_container", size = 80})
    local btn = container:button(script.name, function()
        loadscript(script.url, script.name)
    end)
    btn.name = script.name
    
    local queuebtn = container:button("queue", function()
        addtoqueue(script.name, script.url)
    end)
    queuebtn.name = script.name .. "_queue"
    
    local favbtn = container:button("star", function()
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
        lib:notification("lunarware", script.name .. (found and " removed from favorites" or " added to favorites"), "ok")
    end)
    favbtn.name = script.name .. "_fav"
end

-- settings tab
settings_tab:label("theme")
settings_tab:dropdown("accent color", {"default", "red", "blue", "green", "purple"}, function(v)
    if v == "red" then
        lib:changepresetcolor(color3.fromrgb(255, 50, 50))
    elseif v == "blue" then
        lib:changepresetcolor(color3.fromrgb(50, 100, 255))
    elseif v == "green" then
        lib:changepresetcolor(color3.fromrgb(50, 255, 50))
    elseif v == "purple" then
        lib:changepresetcolor(color3.fromrgb(150, 50, 255))
    else
        lib:changepresetcolor(color3.fromrgb(44, 120, 224))
    end
end)

settings_tab:label("")
settings_tab:toggle("notifications", true, function(v)
    getgenv().notificationsenabled = v
end)

settings_tab:label("")
settings_tab:button("clear all data", function()
    favorites = {}
    recent = {}
    queuedscripts = {}
    savefavorites()
    saverecent()
    updatefavoritestab()
    updaterecenttab()
    updatequeuetab()
    lib:notification("lunarware", "all data cleared", "ok")
end)

settings_tab:label("")
settings_tab:button("unload hub", function()
    local ui = game:getservice("coregui"):findfirstchild("ui")
    if ui then ui:destroy() end
end)

-- initial updates
updatefavoritestab()
updaterecenttab()
updatequeuetab()

print("lunarware hub loaded | press k to open menu")

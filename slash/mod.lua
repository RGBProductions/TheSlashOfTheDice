Slash.Mod = {
    APIVersion = 1
}

---@alias ModInfo {modid: string, name: string, version: string, author: string, description: string, gameVersion?: integer|{[1]: integer, [2]: integer}, apiVersion?: integer, dependencies?: {[integer]: string}, hidden?: boolean, clientSide?: boolean}

local modObject = {}
modObject.__index = modObject

local mods = {}
local targetId = "main"
local targetPath = ""
local targetInfo = nil

---Creates a new mod object
---@param data table?
---@return table
function Slash.Mod.New(data)
    if type(data) ~= "table" then data = {} end
    if targetInfo then
        data.info = targetInfo
    end
    return setmetatable(data, modObject)
end

local function modLog(...)
    local t = {...}
    local s = "[" .. targetId:upper() .. "] "
    for i = 1, select("#",t) do
        s = s .. tostring(t[i]) .. "\t"
    end
    s = s:sub(1,-2)
    print(s)
end

local modAdditions = {}
local modGlobal = {
    love = {
        getVersion = love.getVersion,
        isVersionCompatible = love.isVersionCompatible,
        audio = love.audio,
        data = love.data,
        font = love.font,
        graphics = love.graphics,
        image = love.image,
        joystick = love.joystick,
        keyboard = love.keyboard,
        math = love.math,
        mouse = love.mouse,
        sound = love.sound,
        system = {
            getClipboardText = love.system.getClipboardText,
            getOS = love.system.getOS,
            getPowerInfo = love.system.getPowerInfo,
            getProcessorCount = love.system.getProcessorCount,
            hasBackgroundMusic = love.system.hasBackgroundMusic,
            setClipboardText = love.system.setClipboardText,
            vibrate = love.system.vibrate
        },
        timer = love.timer,
        touch = love.touch,
        video = love.video
    },
    math = math,
    print = modLog,
    coroutine = coroutine,
    string = string,
    table = table,
    tonumber = tonumber,
    tostring = tostring,
    type = type,
    unpack = unpack,
    setmetatable = setmetatable,
    getmetatable = getmetatable,
    pairs = pairs,
    ipairs = ipairs,
    next = next,
    select = select,
    error = error,
    module = module,
    newproxy = newproxy,
    pcall = pcall,
    Slash = Slash,
    json = json
}

local modIndexer = setmetatable({}, {
    __index = function (t, k)
        return modAdditions[k] or modGlobal[k]
    end,
    __newindex = function (t, k, v)
        if getmetatable(modAdditions[k]) == modObject then
            error("cannot reassign mod '" .. tostring(k) .. "'", 2)
        end
        modAdditions[k] = v
    end
})

modGlobal.require = function(path,...)
    local paths = {
        targetPath.."/?.lua",
        targetPath.."/?/init.lua"
    }
    path = path:gsub("%.", "/")
    local notfound = {}
    for _,p in ipairs(paths) do
        local newPath = p:gsub("%?",path)
        if love.filesystem.getInfo(newPath) then
            local c,e = love.filesystem.load(newPath)
            setfenv(c,modIndexer)
            return c(...)
        else
            table.insert(notfound, "\tno file '" .. newPath .. "'")
        end
    end
    error("module '" .. path .. "' not found:\n" .. table.concat(notfound,"\n"), 2)
end

local function preloadImages(path,base)
    base = base or path
    for _,itm in ipairs(love.filesystem.getDirectoryItems(path)) do
        local itmPath = path.."/"..itm
        if love.filesystem.getInfo(itmPath).type == "file" then
            local splitPath = itm:split("%.")
            local ext = splitPath[#splitPath]
            if ext == "png" or ext == "jpg" or ext == "jpeg" then
                local name = itmPath:sub(#base+2,-(#ext+2))
                Slash.Assets.PreloadImage(name, itmPath)
            end
        else
            preloadImages(itmPath,base)
        end
    end
end

local function preloadAudio(path,base)
    base = base or path
    for _,itm in ipairs(love.filesystem.getDirectoryItems(path)) do
        local itmPath = path.."/"..itm
        if love.filesystem.getInfo(itmPath).type == "file" then
            local splitPath = itm:split("%.")
            local ext = splitPath[#splitPath]
            if ext == "wav" or ext == "ogg" or ext == "mp3" then
                local name = itmPath:sub(#base+2,-(#ext+2))
                Slash.Assets.PreloadAudio(name, itmPath)
            end
        else
            preloadAudio(itmPath,base)
        end
    end
end

local mounted = {}

local function checkMod(info)
    if not info then return false, "No mod info" end
    local validAPI = type(info.apiVersion) ~= "number" or info.apiVersion == Slash.Mod.APIVersion
    if not validAPI then
        return false, "API version mismatch (mod uses version " .. info.apiVersion .. ", game uses version " .. Slash.Mod.APIVersion .. ")"
    end
    
    local versions = (type(info.gameVersion) == "number" and {info.gameVersion,info.gameVersion}) or (type(info.gameVersion) == "table" and info.gameVersion) or {Version[2],Version[2]}
    local validVersion = Version[2] >= versions[1] and Version[2] <= versions[2]
    if not validVersion then
        return false, "Game version mismatch (mod uses version" .. (versions[1] ~= versions[2] and "s" or "") .. " " .. versions[1] .. (versions[1] ~= versions[2] and (" to " .. versions[2]) or "") .. ", game uses version " .. Version[2] .. ")"
    end

    return true
end

---Retrieves the info for the current mod
---@return ModInfo
function Slash.Mod.GetInfo()
    return targetInfo
end

---Retrieves the ID of the current mod
---@return string
function Slash.Mod.GetID()
    return targetId
end

---Loads a mod
---@param path string
---@param info ModInfo?
---@return boolean
---@return string|nil
function Slash.Mod.Load(path,info)
    if info then
        local s,r = checkMod(info)
        if not s then
            return s,r
        end
    end
    local saveId = targetId
    local savePath = targetPath
    local saveInfo = targetInfo
    if info then
        targetId = info.modid
    end
    targetPath = path
    targetInfo = info
    preloadImages(path.."/assets/images")
    preloadAudio(path.."/assets/music", path.."/assets")
    preloadAudio(path.."/assets/sounds", path.."/assets")
    for _,file in ipairs(love.filesystem.getDirectoryItems(path.."/assets/lang")) do
        local name = file:sub(1,-6)
        local s,r = pcall(json.decode, love.filesystem.read(path.."/assets/lang/"..file))
        if s then Slash.Localization.AddLanguage(name,r) end
    end
    for _,file in ipairs(love.filesystem.getDirectoryItems(path.."/scenes")) do
        if file:sub(-3,-1) == "lua" then
            Slash.Scenes.Add(file:sub(1,-5))
        end
    end
    if love.filesystem.getInfo(path.."/init.lua") then
        local c,e = love.filesystem.load(path.."/init.lua")
        if c then
            setfenv(c, modIndexer)
            local s,r = pcall(c)
            if not s then
                targetPath = savePath
                targetId = saveId
                targetInfo = saveInfo
                return s,r
            end
        end
    end
    table.insert(mods, {id = (info or {}).modid, info = info, path = path})
    targetPath = savePath
    targetId = saveId
    targetInfo = saveInfo
    return true,nil
end

---@alias loadermod {id: string, path: string, info: ModInfo}

---Loads all mods from the mods folder
---@return integer
function Slash.Mod.LoadAllMods()
    local files = love.filesystem.getDirectoryItems("mods")
    local valid = {}
    for _,file in ipairs(files) do
        local path = "mods/"..file
        local basePath = path
        if file:sub(-3,-1) == "zip" then
            path = path:sub(1,-5)
            local s = love.filesystem.mount(basePath, path)
            table.insert(mounted, basePath)
        end
        if love.filesystem.getInfo(path.."/mod.json") then
            local s,info = pcall(json.decode, love.filesystem.read(path.."/mod.json"))
            if s and type(info.modid) == "string" then
                local modCheck,modError = checkMod(info)
                if not modCheck then
                    print("Can't load " .. info.modid .. ": " .. modError)
                else
                    valid[info.modid] = {id = info.modid, path = path, info = info}
                end
            end
        end
    end
    
    local loadOrder = {}
    local added = {}

    ---@param mod loadermod
    local function addMod(mod)
        if added[mod.id] then
            return true
        end

        if mod.info.dependencies then
            for _,dependency in ipairs(mod.info.dependencies) do
                if not valid[dependency] then
                    return false, "missing dependency " .. dependency
                end
                if not addMod(valid[dependency]) then
                    return false, "failed to load dependency " .. dependency
                end
            end
        end
        table.insert(loadOrder, {dependencies = mod.info.dependencies, loaded = mod})
        added[mod.id] = true
        return true
    end

    for id,data in pairs(valid) do
        local s,r = addMod(data)
        if not s then
            print("Could not load " .. id .. ": " .. r)
        end
    end

    local succeeded = {}

    for _,mod in ipairs(loadOrder) do
        local failedDependency = false
        for _,dep in ipairs(mod.dependencies or {}) do
            if not succeeded[dep] then
                print("failed to load " .. mod.loaded.id .. ": dependency " .. dep .. " was not loaded")
                failedDependency = true
                break
            end
        end
        if not failedDependency then
            local success,message = Slash.Mod.Load(mod.loaded.path, mod.loaded.info)
            if not success then
                print("Failed to load " .. mod.loaded.id .. ": " .. message)
            else
                succeeded[mod.loaded.id] = true
            end
        end
    end

    return Slash.Mod.GetModCount()
end

---Unmounts all archives
function Slash.Mod.UnmountArchives()
    while #mounted > 0 do
        love.filesystem.unmount(table.remove(mounted, 1))
    end
end

---Gets the number of loaded mods
---@return integer
function Slash.Mod.GetModCount()
    return #mods
end

---Gets the number of loaded visible mods
---@return integer
function Slash.Mod.GetVisibleModCount()
    local count = 0
    for _,mod in pairs(mods) do
        if not (mod.info or {}).hidden then
            count = count + 1
        end
    end
    return count
end

---Gets a mod by its ID, or nil if it doesn't exist
---@param id string
---@return loadermod?
function Slash.Mod.GetMod(id)
    for _,mod in ipairs(mods) do
        if mod.id == id then
            return mod
        end
    end
end

---Gets a list of all mods in the order they were loaded
---@return {[integer]: ModInfo}
function Slash.Mod.GetMods()
    local retrieved = {}
    for _,mod in ipairs(mods) do
        table.insert(retrieved, mod.info)
    end
    return retrieved
end

function Slash.Mod.GetPath(path)
    if path then
        return targetPath .. "/" .. path
    end
    return targetPath
end

function Slash.Mod.ReadFile(path)
    path = path:gsub("%.%.","")
    path = targetPath.."/"..path
    return love.filesystem.read(path)
end

function Slash.Mod.FlushGlobal()
    for k,v in pairs(modGlobal) do
        modAdditions[k] = nil
    end
    for k,v in pairs(modAdditions) do
        _G[k] = v
    end
end

function Slash.Mod.Additions()
    return modAdditions
end
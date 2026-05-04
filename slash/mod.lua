Slash.Mod = {
    APIVersion = 1
}

---@alias ModInfo {modid: string, name: string, version: string, author: string, description: string, gameVersion?: integer|{[1]: integer, [2]: integer}, apiVersion?: integer, dependencies?: {[integer]: string}, hidden?: boolean, clientSide?: boolean, icon?: love.Image}

---@class ModObject
---@field path string
---@field info ModInfo
local modObject = {}
modObject.__index = modObject

local mods = {}
local disabled = {}
local targetId = "main"
local targetPath = ""
local targetInfo = nil
local isMod = false

local dirty = false

local objects = {}

---Creates a new mod object
---@param path string
---@param info ModInfo
---@return ModObject
function Slash.Mod.New(path,info)
    if type(info) ~= "table" then info = {} end
    if objects[info.modid] then error("cannot create duplicate mod", 2) end
    objects[info.modid] = setmetatable({info = info, path = path}, modObject)
    return objects[info.modid]
end

local function preloadImages(path,base,namespace)
    base = base or path
    for _,itm in ipairs(love.filesystem.getDirectoryItems(path)) do
        local itmPath = path.."/"..itm
        if love.filesystem.getInfo(itmPath).type == "file" then
            local splitPath = itm:split_plain(".")
            local ext = splitPath[#splitPath]
            if ext == "png" or ext == "jpg" or ext == "jpeg" then
                local name = namespace .. ":" .. itmPath:sub(#base+2,-(#ext+2)):gsub("/",".")
                Slash.Assets.PreloadImage(name, itmPath)
            end
        else
            preloadImages(itmPath,base,namespace)
        end
    end
end

local function preloadAudio(path,base,namespace)
    base = base or path
    for _,itm in ipairs(love.filesystem.getDirectoryItems(path)) do
        local itmPath = path.."/"..itm
        if love.filesystem.getInfo(itmPath).type == "file" then
            local splitPath = itm:split_plain(".")
            local ext = splitPath[#splitPath]
            if ext == "wav" or ext == "ogg" or ext == "mp3" then
                local name = namespace .. ":" .. itmPath:sub(#base+2,-(#ext+2)):gsub("/",".")
                -- print("AUD " .. name)
                Slash.Assets.PreloadAudio(name, itmPath)
            end
        else
            preloadAudio(itmPath,base,namespace)
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
---@return ModInfo?
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
    if not info then return false, "missing mod info" end

    if info then
        local s,r = checkMod(info)
        if not s then
            return s,r
        end
    end
    
    local assetPaths = love.filesystem.getDirectoryItems(path.."/assets")
    for _,namespace in ipairs(assetPaths) do
        preloadImages(path.."/assets/"..namespace.."/images", nil, namespace)
        preloadAudio(path.."/assets/"..namespace.."/music", path.."/assets/"..namespace, namespace)
        preloadAudio(path.."/assets/"..namespace.."/sounds", path.."/assets/"..namespace, namespace)
        for _,file in ipairs(love.filesystem.getDirectoryItems(path.."/assets/"..namespace.."/lang")) do
            local name = file:sub(1,-6)
            local s,r = pcall(json.decode, love.filesystem.read(path.."/assets/"..namespace.."/lang/"..file))
            if s then Slash.Localization.AddLanguage(name,r) end
        end
    end
    for _,file in ipairs(love.filesystem.getDirectoryItems(path.."/scenes")) do
        if file:sub(-3,-1) == "lua" then
            local s,r = Slash.Scenes.Add(info.modid .. ":" .. file:sub(1,-5), path.."/scenes/"..file)
            if not s then
                Slash.Log.Error("Couldn't add scene " .. path.."/scenes/"..file .. ": " .. r)
            end
        end
    end
    if love.filesystem.getInfo(path.."/init.lua") then
        local c,e = love.filesystem.load(path.."/init.lua")
        if c then
            local s,r = pcall(c, path, info)
            if not s then
                print(debug.traceback(r))
                return s,r
            end
        end
    end
    if love.filesystem.getInfo(path.."/icon.png") then
        info.icon = love.graphics.newImage(path.."/icon.png")
    else
        info.icon = Slash.Assets.Missing
    end
    local id = (info or {}).modid
    mods[id] = {id = id, info = info, path = path}
    table.insert(mods, mods[id])
    return true,nil
end

---@alias loadermod {id: string, path: string, info: ModInfo}

---Loads all mods from the mods folder
---@return integer
function Slash.Mod.LoadAllMods()
    local S,disabledMods = pcall(json.decode, love.filesystem.read("mods/disabled.json"))
    if not S then
        disabledMods = {}
    end
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
                if love.filesystem.getInfo(path.."/icon.png") then
                    info.icon = love.graphics.newImage(path.."/icon.png")
                else
                    info.icon = Slash.Assets.Missing
                end
                if table.index(disabledMods, info.modid) then
                    local id = info.modid
                    disabled[id] = {id = info.modid, path = path, info = info}
                    table.insert(disabled, disabled[id])
                else
                    local modCheck,modError = checkMod(info)
                    if not modCheck then
                        print("Can't load " .. info.modid .. ": " .. modError)
                    else
                        valid[info.modid] = {id = info.modid, path = path, info = info}
                    end
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

function Slash.Mod.RetrieveDisabledMods()
    return disabled
    -- local S,files = pcall(json.decode, love.filesystem.read("mods/disabled.json"))
    -- if not S then return {} end
    -- disabled = {}
    -- for _,file in ipairs(files) do
    --     local path = "mods/"..file
    --     local basePath = path
    --     if file:sub(-3,-1) == "zip" then
    --         path = path:sub(1,-5)
    --         local s = love.filesystem.mount(basePath, path)
    --         table.insert(mounted, basePath)
    --     end
    --     if love.filesystem.getInfo(path.."/mod.json") then
    --         local s,info = pcall(json.decode, love.filesystem.read(path.."/mod.json"))
    --         if s and type(info.modid) == "string" then
    --             local modCheck,modError = checkMod(info)
    --             if modCheck then
    --                 if love.filesystem.getInfo(path.."/icon.png") then
    --                     info.icon = love.graphics.newImage(path.."/icon.png")
    --                 else
    --                     info.icon = Slash.Assets.Missing
    --                 end
    --                 table.insert(disabled, {id = info.modid, path = path, info = info})
    --             end
    --         end
    --     end
    -- end
    -- return disabled
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
    for _,mod in ipairs(mods) do
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
    return mods[id]
end

---Gets a list of all mods in the order they were loaded
---@return {id: string, path: string, info: ModInfo}[]
function Slash.Mod.GetMods()
    local retrieved = {}
    for _,mod in ipairs(mods) do
        table.insert(retrieved, mod)
    end
    return retrieved
end

function modObject:getPath(path)
    if path then
        return self.path .. "/" .. path
    end
    return targetPath
end

function modObject:readFile(path)
    path = path:gsub("%.%.","")
    path = self.path.."/"..path
    return love.filesystem.read(path)
end

---@deprecated This is a stub. This should be removed.
function Slash.Mod.FlushGlobal()
end

---@deprecated This is a stub. This should be removed.
function Slash.Mod.Additions()
    return nil
end

function Slash.Mod.Disable(id)
    if mods[id] then
        table.insert(disabled, mods[id])
        disabled[id] = mods[id]
        for i = 1, #mods do
            if mods[i] == mods[id] then
                table.remove(mods, i)
                break
            end
        end
        mods[id] = nil
        dirty = true
    end
end

function Slash.Mod.Enable(id)
    if disabled[id] then
        table.insert(mods, disabled[id])
        mods[id] = disabled[id]
        for i = 1, #disabled do
            if disabled[i] == disabled[id] then
                table.remove(disabled, i)
                break
            end
        end
        disabled[id] = nil
        dirty = true
    end
end

function Slash.Mod.RequiresRestart()
    return dirty
end

function Slash.Mod.WriteDisabled()
    if not love.filesystem.getInfo("mods") then
        love.filesystem.createDirectory("mods")
    end
    local result = {}
    for _,mod in ipairs(disabled) do
        table.insert(result, mod.id)
    end
    love.filesystem.write("mods/disabled.json", json.encode(result))
end
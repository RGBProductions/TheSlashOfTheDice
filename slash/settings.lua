-- Interfaces with game settings
Slash.Settings = {}

local settingsData = {}
local settingsRules = {}
local settingsBehaviors = {}
local settingsTypes = {}
local settingsQueue = {}

local function getLocation(path)
    local components = path:split("%.")
    local field = table.remove(components, #components)
    local location = settingsData
    for _,component in ipairs(components) do
        if not location[component] then
            location[component] = {}
        end
        location = location[component]
    end
    return location,field
end

local function enforce(path,value)
    if settingsTypes[path] and type(value) ~= settingsTypes[path] then return false end
    for _,rule in ipairs(settingsRules[path] or {}) do
        if not rule(value) then
            return false
        end
    end
    return true
end



---Registers a setting path
---@param path string
---@param default any
---@param enforceType? boolean
---@param ... fun(value: any): boolean
function Slash.Settings.Add(path, default, enforceType, ...)
    local location,field = getLocation(path)
    location[field] = default
    if enforceType then
        Slash.Settings.EnforceType(path, type(default))
    end
    for _,rule in pairs({...}) do
        Slash.Settings.AddRule(path, rule)
    end
end

---Enforces a type on a setting
---@param path string
---@param fieldType? string
function Slash.Settings.EnforceType(path, fieldType)
    settingsTypes[path] = fieldType
end

---Adds a value enforcement rule to a setting
---@param path string
---@param rule fun(value: any): boolean
function Slash.Settings.AddRule(path, rule)
    if type(rule) ~= "function" then return end
    settingsRules[path] = settingsRules[path] or {}
    table.insert(settingsRules[path], rule)
end

---Adds a set behavior for a setting
---@param path string
---@param behavior fun(value: any)
function Slash.Settings.AddBehavior(path, behavior)
    if type(behavior) ~= "function" then return end
    settingsBehaviors[path] = settingsBehaviors[path] or {}
    table.insert(settingsBehaviors[path], behavior)
end

---Retrieves a setting
---@param path string
---@return any
function Slash.Settings.Get(path)
    local location,field = getLocation(path)
    return location[field]
end

---Sets a setting
---@param path string
---@param value any
---@return boolean didSucceed
function Slash.Settings.Set(path, value)
    if not enforce(path, value) then return false end
    local location,field = getLocation(path)
    location[field] = value
    for _,behavior in ipairs(settingsBehaviors[path] or {}) do
        behavior(value)
    end
    return true
end

---Clears the settings queue
function Slash.Settings.ClearQueue()
    settingsQueue = {}
end

---Queues a setting change
---@param path string
---@param value any
---@return boolean didSucceed
function Slash.Settings.Queue(path, value)
    if not enforce(path, value) then return false end
    table.insert(settingsQueue, {path = path, value = value})
    return true
end

---Pushes queued changes to the settings and clears the queue
function Slash.Settings.PushQueue()
    for _,change in ipairs(settingsQueue) do
        Slash.Settings.Set(change.path, change.value)
    end
    Slash.Settings.ClearQueue()
end

function Slash.Settings.GetJSON()
    return json.encode(settingsData)
end

function Slash.Settings.Save()
    local s,r = pcall(Slash.Settings.GetJSON)
    if not s then return s,r end
    love.filesystem.write("settings.json", r)
    return true,nil
end

function Slash.Settings.Load()
    if not love.filesystem.getInfo("settings.json") then return end
    local s,data = pcall(json.decode, love.filesystem.read("settings.json"))
    if not s then return end
    
    local function getPaths(cur)
        local paths = {}
        for k,v in pairs(cur) do
            if type(v) == "table" then
                for k2,v2 in pairs(getPaths(v)) do
                    paths[k.."."..k2] = v2
                end
            else
                paths[k] = v
            end
        end
        return paths
    end

    for k,v in pairs(getPaths(data)) do
        Slash.Settings.Set(k,v)
    end
end



-- A set of pre-defined rule builders
Slash.SettingsRules = {}

---Ensures a number is between two numbers or is less/greater than a specific number
---@param min? number
---@param max? number
---@return fun(value: any): boolean
function Slash.SettingsRules.NumberRange(min,max)
    return function(value)
        return value >= (min or -math.huge) and value <= (max or math.huge)
    end
end

---Ensures a value is within a set of choices
---@param choices table
---@return fun(value: any): boolean
function Slash.SettingsRules.Choices(choices)
    return function(value)
        return table.index(choices, value) ~= nil
    end
end

---Ensures a string is within a range of lengths
---@param min? integer
---@param max? integer
---@return fun(value: string): boolean
function Slash.SettingsRules.Length(min,max)
    return function(value)
        return #value >= (min or 0) and #value <= (max or math.huge)
    end
end

---Ensures a string is a valid langugae
---@return fun(value: string): boolean
function Slash.SettingsRules.Language()
    return function(value)
        return Slash.Localization.HasLanguage(value)
    end
end

function Slash.Settings.Clear()
    settingsData = {}
    settingsRules = {}
    settingsBehaviors = {}
    settingsTypes = {}
    settingsQueue = {}
end
-- Stores the game state
Slash.Game = {}

---Initializes the game state
---@param init? table
function Slash.InitGame(init)
    if type(init) ~= "table" then init = {} end
    Slash.Game = {}

    Slash.Game.Gamemode = nil

    Slash.Game.Entities = {}

    Slash.Game.RunTimer = true
    Slash.Game.ShowTimer = true
    Slash.Game.TimerMax = 15
    Slash.Game.Timer = Slash.Game.TimerMax
    Slash.Game.TimerDecrement = 0.5

    Slash.Game.GameEndData = {Ended = false, EndReason = "generic", Text = {}, Counters = {}, Options = {}}
    Slash.Game.Spectating = false

    Slash.Game = table.merge(Slash.Game, init)
end

function Slash.UID()
    return math.floor(love.timer.getTime()*10000)
end

---@type fun(reason?: string, text?: {[integer]: string}, counters?: {[integer]: {label: string, value: number}}, options?: table)
Slash.EndGame = Slash.Network.SyncedMethod("Slash.EndGame", function(reason, text, counters, options)
    Slash.Game.GameEndData.Ended = true
    Slash.Game.GameEndData.EndReason = reason or "generic"
    Slash.Game.GameEndData.Text = text or {}
    Slash.Game.GameEndData.Counters = counters or {}
    Slash.Game.GameEndData.Options = options or {"replay", "exit"}
end)

---@type fun(timer?: number, max?: number)
Slash.SetTimer = Slash.Network.SyncedMethod("Slash.SetTimer", function(timer, max)
    Slash.Game.Timer = timer or Slash.Game.Timer
    Slash.Game.TimerMax = max or Slash.Game.TimerMax
end)

---@type fun(uid: integer, entityType: string, x: number, y: number, ...: any)
Slash.SpawnEntity = Slash.Network.SyncedMethod("Slash.SpawnEntity", function(uid,entityType,x,y,...)
    if type(entityType) ~= "string" then return end
    if type(Slash.EntityTypes[entityType]) ~= "table" then return end
    local entity = {
        uid = uid,
        type = Slash.EntityTypes[entityType],
        x = x,
        y = y
    }
    if type(entity.type.init) == "function" then
        entity.type.init(entity, ...)
    end
    table.insert(Slash.Game.Entities, entity)
end)

function Slash.GetEntityByUID(uid)
    for _,entity in ipairs(Slash.Game.Entities) do
        if entity.uid == uid then
            return entity
        end
    end
end

function Slash.GetEntitiesByType(entityType)
    if type(entityType) == "string" then
        entityType = Slash.EntityTypes[entityType]
    end
    local entities = {}
    for _,entity in ipairs(Slash.Game.Entities) do
        if entity.type == entityType then
            table.insert(entities, entity)
        end
    end
    return entities
end

local function compareFilter(value, filter)
    if type(filter) ~= "table" then return true end
    for _,filterValue in ipairs(filter) do
        if filterValue == value then
            return true
        end
    end
    return false
end

function Slash.GetNearestEntity(origin, maxDistance, filterTypes)
    if type(maxDistance) ~= "number" then maxDistance = math.huge end
    if type(filterTypes) == "string" then filterTypes = {Slash.EntityTypes[filterTypes]} end
    local entities = {}
    for _,entity in ipairs(Slash.Game.Entities) do
        local distance = math.sqrt((entity.x-origin.x)^2 + (entity.y-origin.y)^2)
        if compareFilter(entity, filterTypes) and distance <= maxDistance then
            table.insert(entities, entity)
        end
    end
    table.sort(entities, function (a, b)
        return math.sqrt((a.x-origin.x)^2 + (a.y-origin.y)^2) < math.sqrt((b.x-origin.x)^2 + (b.y-origin.y)^2)
    end)
    return entities[1]
end
-- Gamemode management
Slash.Gamemode = {}

---@alias Gamemode {name: string, description: string, behaviors: {[integer]: fun(dt: number)}, renderer: {[integer]: function}}

---@type {[string]: Gamemode}
local gamemodes = {}

---Creates a new gamemode
---@param name string
---@param behaviors {[integer]: function}
---@param renderer {[integer]: function}
---@return Gamemode
function Slash.Gamemode.Create(name, behaviors, renderer)
    gamemodes[name] = {
        name = "gamemode." .. name .. ".name",
        description = "gamemode." .. name .. ".description",
        behaviors = behaviors,
        renderer = renderer
    }
    return gamemodes[name]
end

---Retrieves a gamemode
---@param name string
---@return Gamemode?
function Slash.Gamemode.Get(name)
    return gamemodes[name]
end
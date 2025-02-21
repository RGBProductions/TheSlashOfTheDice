Slash.Scenes = {}

local scenes = {}
local ids = {}

function Slash.Scenes.Add(id)
    local path = Slash.Mod.GetPath("scenes/" .. id)
    id = Slash.Mod.GetID() .. ":" .. id
    local c,e = love.filesystem.load(path .. ".lua")
    if c then
        local s,r = pcall(c)
        if s then
            scenes[id] = r
            table.insert(ids, id)
        end
        return s,r
    end
    return c ~= nil,e
end

function Slash.Scenes.GetScene(id)
    return scenes[id]
end

function Slash.Scenes.Load(id, args)
    local s,r = SceneManager.LoadSceneDirect(Slash.Scenes.GetScene(id), args)
    if not s then
        Slash.Log.Error("Can't load scene '" .. id .. "': " .. r)
    end
    return s
end

function Slash.Scenes.Clear()
    scenes = {}
    ids = {}
end

function Slash.Scenes.GetAllIds()
    return ids
end
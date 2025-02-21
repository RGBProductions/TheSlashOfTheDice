Slash.Entities = {}
Slash.EntityTypes = {}

function Slash.Entities.NewType(id, data)
    id = Slash.Mod.GetID() .. ":" .. id
    data.id = id
    Slash.EntityTypes[id] = data
    return Slash.EntityTypes[id]
end

function Slash.Entities.Clear()
    Slash.EntityTypes = {}
end
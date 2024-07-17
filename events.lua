Events = {}

local Listeners = {}
local OnceListeners = {}

function Events.on(name, listener)
    Listeners[name] = Listeners[name] or {}
    table.insert(Listeners[name], listener)
end

function Events.once(name, listener)
    OnceListeners[name] = OnceListeners[name] or {}
    table.insert(OnceListeners[name], listener)
end

function Events.removeListener(name, listener)
    local l1 = table.index(Listeners[name] or {}, listener)
    local l2 = table.index(OnceListeners[name] or {}, listener)
    if l1 then
        table.remove(Listeners[name], l1)
    end
    if l2 then
        table.remove(OnceListeners[name], l2)
    end
end

function Events.fire(name, ...)
    for _,listener in ipairs(OnceListeners[name] or {}) do
        listener(...)
        table.remove(OnceListeners[name], table.index(OnceListeners[name], listener))
    end
    for _,listener in ipairs(Listeners[name] or {}) do
        listener(...)
    end
end
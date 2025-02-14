local websocket = require "websocket"

Slash.Network = {
    Socket = nil,
    UserID = nil,
    Room = {
        Players = {},
        ID = nil
    }
}

function Slash.Network.IsConnected()
    return Slash.Network.Socket ~= nil and Slash.Network.Socket.status == websocket.STATUS.OPEN
end

function Slash.Network.IsHosting()
    return Slash.Network.GetGameHost() == Slash.Network.UserID
end

---@alias packet {type: string, packetId: integer, target?: string, data: {[string]: any}}

local sync = {}
local clientReceivers = {}
local hostReceivers = {}

local function onmessage(socket, message)
    print(message)

    local success,packet = pcall(json.decode, message)
    if not success then return end

    if Slash.Network.IsHosting() and socket.target == Slash.Network.GetGameHost() then
        if type(hostReceivers[packet.type]) == "function" then
            hostReceivers[packet.type](packet)
        end
    end
    if type(clientReceivers[packet.type]) == "function" then
        clientReceivers[packet.type](packet)
    end
end

hostReceivers.synced = function(packet)
    if type(sync[packet.data.id]) ~= "function" then return end
    Slash.Network.Broadcast(packet)
end

clientReceivers.synced = function(packet)
    if type(sync[packet.data.id]) == "function" then
        sync[packet.data.id](unpack(packet.data.args))
    end
end

clientReceivers.logged_in = function(packet)
    Slash.Network.UserID = packet.data.userId
end

---Adds a client-side packet handler
---@param type string
---@param func fun(packet: packet)
function Slash.Network.AddClientReceiver(type, func)
    clientReceivers[type] = func
end

---Adds a host-side packet handler
---@param type string
---@param func fun(packet: packet)
function Slash.Network.AddHostReceiver(type, func)
    clientReceivers[type] = func
end

---Connects to the server
---
---If the client is already connected, this function will do nothing
---
---If you need to connect to a different server, use `Slash.Network.Disconnect` first
---@param ip string
---@param port integer
function Slash.Network.Connect(ip,port)
    if Slash.Network.IsConnected() then return end
    
    local socket = websocket.new(ip,port)
    socket.onmessage = onmessage
    
    Slash.Network.Socket = socket
end

function Slash.Network.Disconnect()
    if Slash.Network.Socket then
        Slash.Network.Socket:close(1000, "disconnected")
    end
    Slash.Network.Update()

    Slash.Network.UserID = nil
    Slash.Network.Socket = nil
    Slash.Network.Room.Players = {}
    Slash.Network.Room.ID = nil
end

---Updates the network state
function Slash.Network.Update()
    if not Slash.Network.Socket then return end

    Slash.Network.Socket:update()
end

---Creates a network synchronized function
---
---These functions cannot return a value, so if you need data from them you must save it in a global variable.
---@param id string
---@param func function
---@return function
function Slash.Network.SyncedMethod(id, func)
    sync[id] = func
    return function(...)
        if Slash.Network.IsConnected() then
            Slash.Network.SendHost({type = "synced", data = {id = id, args = {...}}})
        else
            func(...)
        end
    end
end

function Slash.Network.Request(packet)
    local _onmessage = Slash.Network.Socket.onmessage
    local received = nil
    local time = love.timer.getTime()
    ---@diagnostic disable-next-line: duplicate-set-field
    Slash.Network.Socket.onmessage = function (self,message)
        local success,result = pcall(json.decode, message)
        if not success then return end
        if result.packetId == packet.packetId then
            received = result
        end
        _onmessage(self,message)
    end
    Slash.Network.Send(packet)
    while (not received) and love.timer.getTime()-time < 5 do
        Slash.Network.Update()
    end
    Slash.Network.Socket.onmessage = _onmessage
    return received
end

---Sends a packet over the network
---@param packet packet
function Slash.Network.Send(packet)
    -- if not Slash.Network.IsConnected() then return end
    packet.packetId = math.floor(love.timer.getTime()*10000)
    Slash.Network.Socket:send(json.encode(packet))
end

---Sends a packet to the game host.
---@param packet packet
function Slash.Network.SendHost(packet)
    packet.target = Slash.Network.GetGameHost()
    Slash.Network.Send(packet)
end

---Broadcasts a packet to all connected clients, only works host-side
---@param packet packet
function Slash.Network.Broadcast(packet)
    if Slash.IsHost() then
        for _,player in ipairs(Slash.Network.Room.Players) do
            packet.target = player
            Slash.Network.Send(packet)
        end
    end
end

---Retrieves the ID of the game host
---@return string
function Slash.Network.GetGameHost()
    return Slash.Network.Room.Players[1]
end
---@diagnostic disable: duplicate-set-field

Net = {
    Hosting = false,
    Connected = false,
    UserInfo = {},
    ClientID = "",
    RoomList = {},
    Room = {
        id = "",
        players = {}
    },
    ---@type wsclient
    Socket = nil
}

function Net.Send(packet)
    if Net.Socket then
        Net.Socket:send(json.encode(packet))
    end
end

function Net.Broadcast(packet,blacklist)
    blacklist = blacklist or {}
    local _uuid = packet._uuid
    if Net.Socket then
        for _,player in ipairs(Net.Room.players) do
            if player ~= Net.ClientID and not table.index(blacklist, player) then
                packet._uuid = player
                Net.Socket:send(json.encode(packet))
            end
        end
    end
    packet._uuid = _uuid
end

function Net.RetrieveUserInfo(id)
    if Net.UserInfo[id] then return end
    Net.Send({type = "get_user_info", id = id})
end

function Net.Connect(ip,port)
    Net.Disconnect()
    if not websocket then return end
    Net.Socket = websocket.new(ip, port)

    function Net.Socket:onopen()
        Net.Connected = true
        print("Net Connected")
        local name = "SlashPlayer" .. love.math.random(11111,99999)
        print(name)
        Net.Send({type = "temp", name = name})
    end

    function Net.Socket:onclose()
        print("Net Disconnected")
        Net.Socket = nil
    end

    function Net.Socket:onmessage(msg)
        local packet = json.decode(msg)
        -- if packet.type ~= "modify_player" and packet.type ~= "modify_entity" and packet.type ~= "player_update" then
        --     print(msg)
        -- end
        if packet.type == "logged_in" then
            Net.ClientID = packet.id
            Net.RetrieveUserInfo(packet.id)
        end
        if packet.type == "room_list" then
            Net.RoomList = packet.rooms
        end
        if packet.type == "user_info" then
            Net.UserInfo[packet.id] = packet.info
        end
        if packet.type == "hosting" then
            Net.Room.id = packet.id
            Net.Room.players = {}
            Net.Hosting = true
            table.insert(Net.Room.players, Net.ClientID)
            SceneManager.LoadScene("scenes/mplobby")
        end
        if packet.type == "negotiating" then
            MPMenuMessage = "Negotiating..."
        end
        if packet.type == "joined_game" then
            Net.Room.id = packet.id
            Net.Room.players = packet.players
            for _,player in ipairs(packet.players) do
                Net.RetrieveUserInfo(player)
            end
            SceneManager.LoadScene("scenes/mplobby")
        end
        if packet.type == "join" then
            table.insert(Net.Room.players, packet.id)
            Net.RetrieveUserInfo(packet.id)
        end
        if packet.type == "start_game" then
            love.math.setRandomSeed(packet.rlow, packet.rhigh)
            love.math.setRandomState(packet.rstate)
            SceneManager.LoadScene("scenes/game", {mode = packet.setup.mode, multiplayer = {friendlyFire = packet.setup.friendlyFire}})
        end
        if packet.type == "spawn_player" then
            if packet.id ~= Net.ClientID then
                local player = AddNetPlayer({id = packet.id, name = (Net.UserInfo[packet.id] or {}).displayName}, packet.stats)
            end
            for _,ent in ipairs(Entities) do
                if ent.id == "player" and (ent.data.netinfo or {}).id == packet.id then
                    ent.uid = packet.uid
                    break
                end
            end
        end
        if packet.type == "spawn_entity" then
            local ent = Game.Entity:new(packet.entity.type, packet.entity.x, packet.entity.y, packet.entity.vx, packet.entity.vy, packet.entity.maxhp, EntityTypes[packet.entity.type or "enemy"], packet.entity.data)
            ent.uid = packet.entity.uid
            table.insert(Entities, ent)
        end
        if packet.type == "sync_timer" then
            SpawnTimer = packet.timer or SpawnTimer
            SpawnDelay = packet.delay or SpawnDelay
        end
        if packet.type == "modify_entity" then
            ModifyEntity(packet.uid, packet.netid ~= Net.ClientID and packet.x, packet.netid ~= Net.ClientID and packet.y, packet.netid ~= Net.ClientID and packet.vx, packet.netid ~= Net.ClientID and packet.vy, packet.hp, packet.data)
        end
        if packet.type == "leave" then
            table.remove(Net.Room.players, table.index(Net.Room.players, packet.id))
        end
        if packet.type == "left_game" then
            Net.Hosting = false
        end
        if packet.type == "player_joining" then
            if #Net.Room.players < 10 then
                Net.Send({type = "accept_join", id = packet.id})
            else
                Net.Send({type = "decline_join", id = packet.id, message = "room_full"})
            end
        end
        if packet.type == "player_update" then
            local playerEnt
            for _,ent in ipairs(Entities) do
                if ent.id == "player" then
                    if (ent.data.netinfo or {}).id == packet._uuid then
                        playerEnt = ent
                        break
                    end
                end
            end
            if playerEnt then
                Net.Broadcast({type = "modify_entity", uid = playerEnt.uid, netid = packet._uuid, x = packet.x, y = packet.y, vx = packet.vx, vy = packet.vy, hp = playerEnt.hp, data = {stats = packet.stats}}, {packet._uuid})
                ModifyEntity(playerEnt.uid, packet._uuid ~= Net.ClientID and packet.x, packet._uuid ~= Net.ClientID and packet.y, packet._uuid ~= Net.ClientID and packet.vx, packet._uuid ~= Net.ClientID and packet.vy, playerEnt.hp, {stats = packet._uuid ~= Net.ClientID and packet.stats or nil})
            end
        end
        if packet.type == "slash" then
            local playerEnt
            for _,ent in ipairs(Entities) do
                if ent.id == "player" then
                    if (ent.data.netinfo or {}).id == packet._uuid then
                        playerEnt = ent
                        break
                    end
                end
            end
            if playerEnt then
                Net.Broadcast({type = "modify_entity", uid = playerEnt.uid, netid = packet._uuid, vx = packet.vx, vy = packet.vy, data = {slashTime = 0.25}}, {packet._uuid})
                ModifyEntity(playerEnt.uid, playerEnt.x, playerEnt.y, packet.vx, packet.vy, playerEnt.hp, {slashTime = 0.25})
            end
        end
        if packet.type == "modify_player" then
            ModifyNetPlayer(packet.id, packet.x, packet.y, packet.vx, packet.vy, packet.hp, packet.data)
        end
        if packet.type == "sync_random" then
            love.math.setRandomSeed(packet.rlow, packet.rhigh)
            love.math.setRandomState(packet.rstate)
        end
    end
end

function Net.Disconnect()
    if Net.Socket then
        Net.Socket:close()
        Net.Socket:update()
    end
    Net.Hosting = false
    Net.Connected = false
end

function Net.Update()
    if Net.Socket then
        Net.Socket:update()
    end
end
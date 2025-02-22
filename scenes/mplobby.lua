local scene = {}

love.keyboard.setKeyRepeat(true)

local states = {
    home = 0,
    findgames = 1,
    hostgame = 2
}

function scene.load()
    LogoPos = 16
    local sec = love.data.encode("string", "base64", Net.Room.id.."/"..love.math.random(1111,9999))
    DiscordPresence.partyId = Net.Room.id
    DiscordPresence.partySize = #Net.Room.players
    DiscordPresence.partyMax = 10
    DiscordPresence.joinSecret = sec
    DiscordPresence.details = "In Multiplayer Game"
    DiscordPresence.state = "Lobby"
    DiscordPresence.startTimestamp = DiscordPresence.currentScene == "mplobby" and DiscordPresence.startTimestamp or os.time()
    DiscordPresence.currentScene = "mplobby"
end

function scene.update(dt)
end

function scene.draw()
    local cursor = "arrow"
    love.graphics.setColor(1,1,1)
    love.graphics.draw(MenuBGMesh, -((GlobalTime*48)%MenuBG:getWidth()), -((GlobalTime*48)%MenuBG:getHeight()))
    love.graphics.setFont(xlfont)
    love.graphics.printf("Multiplayer Game", 0, 16, love.graphics.getWidth(), "center")
    love.graphics.setFont(lgfont)

    local w,h = love.graphics.getWidth()-256, love.graphics.getHeight()-192
    local x,y = (love.graphics.getWidth()-w)/2, (love.graphics.getHeight()-h)/2
    love.graphics.setColor(0,0,0,0.75)
    love.graphics.rectangle("fill", x, y, w, h)
    love.graphics.setColor(1,1,1)
    love.graphics.setLineWidth(4)
    love.graphics.rectangle("line", x, y, w, h)

    love.graphics.setFont(lgfont)
    love.graphics.printf("Players (" .. #Net.Room.players .. "/" .. 10 .. ")", x, y+(40-lgfont:getHeight())/2, w/2, "center")
    for i,player in ipairs(Net.Room.players) do
        local uinfo = Net.UserInfo[player] or {displayName = player}
        local py = y+(40*i)
        love.graphics.setColor(1,1,1)
        love.graphics.printf(uinfo.displayName, x, py+(40-lgfont:getHeight())/2, w/2, "center")
    end
    
    local mx,my = love.mouse.getPosition()
    local by = love.graphics.getHeight()-96-16-64
    love.graphics.line(x, by-16, x+w, by-16)
    love.graphics.line(love.graphics.getWidth()/2, y, love.graphics.getWidth()/2, by-16)
    love.graphics.line(x, y+40, x+w, y+40)

    love.graphics.setColor(1,1,1)
    love.graphics.rectangle("fill", (love.graphics.getWidth()-256)/2-256-32, by, 256, 64)
    love.graphics.setColor(0,0,0)
    love.graphics.printf("Leave", (love.graphics.getWidth()-256)/2-256-32, by+(64-lgfont:getHeight())/2, 256, "center")

    love.graphics.setColor(1,1,1)
    love.graphics.rectangle("fill", (love.graphics.getWidth()-256)/2, by, 256, 64)
    love.graphics.setColor(0,0,0)
    love.graphics.printf("Start Game", (love.graphics.getWidth()-256)/2, by+(64-lgfont:getHeight())/2, 256, "center")

    love.graphics.setColor(1,1,1)
    love.graphics.rectangle("fill", (love.graphics.getWidth()-256)/2+256+32, by, 256, 64)
    love.graphics.setColor(0,0,0)
    love.graphics.printf("Game Settings", (love.graphics.getWidth()-256)/2+256+32, by+(64-lgfont:getHeight())/2, 256, "center")

    if my >= by and my < by+64 then
        if mx >= (love.graphics.getWidth()-256)/2-256-32 and mx < (love.graphics.getWidth()-256)/2-256-32+256 then
            cursor = "hand"
        end
        if mx >= (love.graphics.getWidth()-256)/2 and mx < (love.graphics.getWidth()-256)/2+256 then
            cursor = "hand"
        end
        if mx >= (love.graphics.getWidth()-256)/2+256+32 and mx < (love.graphics.getWidth()-256)/2+256+32+256 then
            cursor = "hand"
        end
    end

    love.graphics.setFont(lgfont)
    love.graphics.setColor(1,1,1)
    -- local userInfo = Net.UserInfo[Net.ClientID] or {displayName = "..."}
    -- love.graphics.print("Logged in as " .. userInfo.displayName, 16, love.graphics.getHeight()-lgfont:getHeight()-16)

    if not Net.Connected then
        love.graphics.setFont(xlfont)
        love.graphics.setColor(0,0,0,0.5)
        love.graphics.rectangle("fill", 0, 0, love.graphics.getWidth(), love.graphics.getHeight())
        love.graphics.setColor(1,1,1)
        love.graphics.printf("Connecting to network...", 0, (love.graphics.getHeight()-xlfont:getHeight())/2, love.graphics.getWidth(), "center")
    end

    local s,r = pcall(love.mouse.getSystemCursor,cursor)
    if s then
        love.mouse.setCursor(r)
    end
end

function scene.keypressed(k)
    if k == "escape" then
        if MPMenuState ~= states.home then
            MPMenuState = states.home
        else
            Net.Disconnect()
            SceneManager.LoadScene("scenes/menu")
        end
    end
end

function scene.mousemoved(x, y, dx, dy)
end

function scene.mousepressed(x, y)
    local by = love.graphics.getHeight()-96-16-64
    if y >= by and y < by+64 then
        if x >= (love.graphics.getWidth()-256)/2-256-32 and x < (love.graphics.getWidth()-256)/2-256-32+256 then
            Net.Send({type = "leave"})
            SceneManager.LoadScene("scenes/mpmenu")
        end
        if x >= (love.graphics.getWidth()-256)/2 and x < (love.graphics.getWidth()-256)/2+256 then
            local setup = {mode = "default", friendlyFire = false}
            local rlow,rhigh = love.math.getRandomSeed()
            local rstate = love.math.getRandomState()
            Net.Broadcast({type = "start_game", setup = setup, rlow = rlow, rhigh = rhigh, rstate = rstate})
            SceneManager.LoadScene("scenes/game", {mode = setup.mode, multiplayer = {friendlyFire = setup.friendlyFire}})
        end
        if x >= (love.graphics.getWidth()-256)/2+256+32 and x < (love.graphics.getWidth()-256)/2+256+32+256 then
            print("setup game")
        end
    end
end

function scene.wheelmoved(x, y)
end

return scene
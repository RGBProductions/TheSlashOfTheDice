local scene = {}

love.keyboard.setKeyRepeat(true)

local states = {
    home = 0,
    findgames = 1,
    hostgame = 2
}

function scene.load(args)
    MPMenuState = states.home
    ---@type string|nil
    MPMenuMessage = nil
    LogoPos = 16
    if not Net.Connected then
        Net.Connect("192.168.1.28", 3000)
    end
    DiscordPresence.partyId = nil
    DiscordPresence.partySize = nil
    DiscordPresence.partyMax = nil
    DiscordPresence.joinSecret = nil
    DiscordPresence.details = "In the Menu"
    DiscordPresence.state = "Multiplayer Menu"
    DiscordPresence.startTimestamp = os.time()
    DiscordPresence.currentScene = "mpmenu"
end

function scene.update(dt)
end

function scene.draw()
    local cursor = "arrow"
    love.graphics.setColor(1,1,1)
    if not IsMobile then
        love.graphics.setShader(BGShader)
        BGShader:send("time", GlobalTime*48)
        love.graphics.rectangle("fill", 0, 0, love.graphics.getWidth(), love.graphics.getHeight())
        love.graphics.setShader()
    else
        love.graphics.draw(MenuBGMobile, -((GlobalTime*48)%192), -((GlobalTime*48)%192))
    end
    love.graphics.draw(Logo, love.graphics.getWidth()/2, LogoPos, 0, Settings.video.ui_scale, Settings.video.ui_scale, Logo:getWidth()/2, 0)
    love.graphics.setFont(xlfont)
    love.graphics.printf("Multiplayer", 0, LogoPos + Logo:getHeight()*Settings.video.ui_scale, love.graphics.getWidth(), "center")
    love.graphics.setFont(lgfont)
    
    local mx,my = love.mouse.getPosition()

    if MPMenuState == states.home then
        love.graphics.setColor(1,1,1)
        love.graphics.rectangle("fill", (love.graphics.getWidth()-256)/2, love.graphics.getHeight()/2, 256, 48)
        love.graphics.setColor(0,0,0)
        love.graphics.printf("Find Games", (love.graphics.getWidth()-256)/2, love.graphics.getHeight()/2+(48-lgfont:getHeight())/2, 256, "center")

        love.graphics.setColor(1,1,1)
        love.graphics.rectangle("fill", (love.graphics.getWidth()-256)/2, 64+love.graphics.getHeight()/2, 256, 48)
        love.graphics.setColor(0,0,0)
        love.graphics.printf("Host Game", (love.graphics.getWidth()-256)/2, 64+love.graphics.getHeight()/2+(48-lgfont:getHeight())/2, 256, "center")

        love.graphics.setColor(1,1,1)
        love.graphics.rectangle("fill", (love.graphics.getWidth()-256)/2, 128+love.graphics.getHeight()/2, 256, 48)
        love.graphics.setColor(0,0,0)
        love.graphics.printf("Back", (love.graphics.getWidth()-256)/2, 128+love.graphics.getHeight()/2+(48-lgfont:getHeight())/2, 256, "center")

        if mx >= (love.graphics.getWidth()-256)/2 and mx < (love.graphics.getWidth()+256)/2 then
            if my >= love.graphics.getHeight()/2 and my < love.graphics.getHeight()/2+48 then
                cursor = "hand"
            end
            if my >= 64+love.graphics.getHeight()/2 and my < 64+love.graphics.getHeight()/2+48 then
                cursor = "hand"
            end
            if my >= 128+love.graphics.getHeight()/2 and my < 128+love.graphics.getHeight()/2+48 then
                cursor = "hand"
            end
        end
    end
    if MPMenuState == states.findgames then
        for i,room in ipairs(Net.RoomList or {}) do
            local y = LogoPos+Logo:getHeight()*Settings.video.ui_scale+xlfont:getHeight()+32 + (64*(i-1))
            love.graphics.setColor(1,1,1)
            love.graphics.rectangle("fill", (love.graphics.getWidth()-256)/2, y, 256, 48)
            love.graphics.setColor(0,0,0)
            love.graphics.printf(room.id, (love.graphics.getWidth()-256)/2, y+(48-lgfont:getHeight())/2, 256, "center")
            
            if mx >= (love.graphics.getWidth()-256)/2 and mx < (love.graphics.getWidth()+256)/2 and my >= y and my < y+48 then
                cursor = "hand"
            end
        end
        love.graphics.setColor(1,1,1)
        love.graphics.rectangle("fill", (love.graphics.getWidth()-256)/2, love.graphics.getHeight()-64, 256, 48)
        love.graphics.setColor(0,0,0)
        love.graphics.printf("Back", (love.graphics.getWidth()-256)/2, love.graphics.getHeight()-64+(48-lgfont:getHeight())/2, 256, "center")

        if mx >= (love.graphics.getWidth()-256)/2 and mx < (love.graphics.getWidth()+256)/2 then
            if my >= love.graphics.getHeight()-64 and my < love.graphics.getHeight()-64+48 then
                cursor = "hand"
            end
        end
    end

    love.graphics.setFont(lgfont)
    love.graphics.setColor(1,1,1)
    local userInfo = Net.UserInfo[Net.ClientID] or {displayName = "..."}
    love.graphics.print("Logged in as " .. userInfo.displayName, 16, love.graphics.getHeight()-lgfont:getHeight()-16)

    if not Net.Connected then
        love.graphics.setFont(xlfont)
        love.graphics.setColor(0,0,0,0.5)
        love.graphics.rectangle("fill", 0, 0, love.graphics.getWidth(), love.graphics.getHeight())
        love.graphics.setColor(1,1,1)
        love.graphics.printf("Connecting to network...", 0, (love.graphics.getHeight()-xlfont:getHeight())/2, love.graphics.getWidth(), "center")
    end

    if MPMenuMessage then
        love.graphics.setFont(xlfont)
        love.graphics.setColor(0,0,0,0.5)
        love.graphics.rectangle("fill", 0, 0, love.graphics.getWidth(), love.graphics.getHeight())
        love.graphics.setColor(1,1,1)
        love.graphics.printf(MPMenuMessage, 0, (love.graphics.getHeight()-xlfont:getHeight())/2, love.graphics.getWidth(), "center")
    end

    love.mouse.setCursor(love.mouse.getSystemCursor(cursor))
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
    if MPMenuState == states.home then
        if x >= (love.graphics.getWidth()-256)/2 and x < (love.graphics.getWidth()+256)/2 then
            if y >= love.graphics.getHeight()/2 and y < love.graphics.getHeight()/2+48 then
                -- Find Games
                Net.Send({type = "find_rooms", game = "sotd"})
                MPMenuState = states.findgames
            end
            if y >= 64+love.graphics.getHeight()/2 and y < 64+love.graphics.getHeight()/2+48 then
                -- Host Game
                Net.Send({type = "host", game = "sotd"})
            end
            if y >= 128+love.graphics.getHeight()/2 and y < 128+love.graphics.getHeight()/2+48 then
                Net.Disconnect()
                SceneManager.LoadScene("scenes/menu")
            end
        end
    end
    if MPMenuState == states.findgames then
        for i,room in ipairs(Net.RoomList or {}) do
            local by = LogoPos+Logo:getHeight()*Settings.video.ui_scale+xlfont:getHeight()+32 + (64*(i-1))
            if x >= (love.graphics.getWidth()-256)/2 and x < (love.graphics.getWidth()+256)/2 and y >= by and y < by+48 then
                Net.Send({type = "join", id = room.id})
                MPMenuMessage = "Joining game"
            end
        end
        if x >= (love.graphics.getWidth()-256)/2 and x < (love.graphics.getWidth()+256)/2 then
            if y >= love.graphics.getHeight()-64 and y < love.graphics.getHeight()-64+48 then
                MPMenuState = states.home
            end
        end
    end
end

function scene.wheelmoved(x, y)
end

return scene
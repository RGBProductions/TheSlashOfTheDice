local scene = {}

love.keyboard.setKeyRepeat(true)

function SetMenu(m)
    CurrentMenu = m
    MenuSelection = 1
end

function scene.load()
    StopMusic()
    InGame = false
    SusCombo = 0
    Sus = "sus"
    EnterTheSus = love.audio.newSource("assets/music/SUS.ogg", "stream")
    ExitTheSus = love.audio.newSource("assets/music/UNSUS.ogg", "stream")
    SusKill = love.audio.newSource("assets/music/AKill.ogg", "stream")
    MenuTime = 0

    Conversion = {
        ["w"] = "up",
        ["s"] = "down",
        ["a"] = "left",
        ["d"] = "right",
        ["space"] = "return"
    }
    
    Logo = love.graphics.newImage("assets/images/ui/logo-updated.png")
    LogoPos = love.graphics.getHeight()

    CurrentMenu = "main"
    MenuSelection = 1

    WeighingModes = {
        "Legacy",
        "Even",
        "Situational",
        "Unfair (NOT RECOMMENDED)",
        "[Secret] Blessed"
    }

    PlayModes = {
        {"Tutorial", "tutorial"},
        {"Default", "default"},
        {"Enemy Rush", "enemy_rush"}
    }
    if Achievements.IsUnlocked("default_30_waves") then
        table.insert(PlayModes, {"Calm Mode", "calm"})
    end
    if DebugMode then
        table.insert(PlayModes, {"[DBG] MP - Co-op", "coop"})
        table.insert(PlayModes, {"[DBG] MP - FFA", "ffa"})
        table.insert(PlayModes, {"[DBG] MP - TDM", "tdm"})
    end
    Events.fire("gamemodeInit")

    -- for _,mode in ipairs(PlayModes) do
    --     table.insert(Menus.Singleplayer.buttons, #Menus.Singleplayer.buttons-1, {
    --         label = mode[1],
    --         callbacks = {
    --             ["return"] = function()
    --                 SceneManager.LoadScene("scenes/game", {mode=mode[2]})
    --             end
    --         }
    --     })
    -- end
    
    local major,minor,rev,name = love.getVersion()
    MenuVersions = {
        {name = "The Slash of the Dice", version = tostring(version)}
    }

    Events.fire("menuloaded")
    DiscordPresence.details = "In the Menu"
    DiscordPresence.state = nil
    DiscordPresence.startTimestamp = DiscordPresence.currentScene == "menu" and DiscordPresence.startTimestamp or os.time()
    DiscordPresence.currentScene = "menu"

    if DebugMode then
    end

    table.insert(MenuVersions, {name = "LÖVE", version = major .. "." .. minor .. " (" .. name .. ")"})
end

function scene.update(dt)
    MenuTime = MenuTime + dt
    local blend = math.pow(1/(16^3), dt)
    LogoPos = blend*(LogoPos-16)+16
    -- LogoPos = LogoPos - ((LogoPos-16)/8)
end

function scene.draw()
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
    love.graphics.setFont(lrfont)
    local c = "arrow"
    local screenWidth = 1280
    local screenHeight = 720
    local leftMargin = 160
    local rightMargin = 160
    local topMargin = (LogoPos+Logo:getHeight()*Settings.video.ui_scale+32)
    local bottomMargin = 64-(LogoPos-16)
    local centerpoint = {
        (leftMargin+(love.graphics.getWidth()-rightMargin))/2,
        (topMargin+(love.graphics.getHeight()-bottomMargin))/2
    }
    local scale = math.min((love.graphics.getWidth()-leftMargin-rightMargin)/(screenWidth-leftMargin-rightMargin), (love.graphics.getHeight()-topMargin-bottomMargin)/(screenHeight-topMargin-bottomMargin))
    local w,h = screenWidth-leftMargin-rightMargin, screenHeight-topMargin-bottomMargin
    love.graphics.push()
    love.graphics.translate(centerpoint[1], centerpoint[2])
    love.graphics.scale(scale,scale)
    -- love.graphics.circle("fill", 0, 0, 4)
    -- love.graphics.rectangle("line", -w/2, -h/2, w, h)
    if (Menus[CurrentMenu] or {}).draw then
        Menus[CurrentMenu]:draw()
    end
    love.graphics.pop()
    if (Menus[CurrentMenu] or {}).getCursor then
        c = Menus[CurrentMenu]:getCursor((love.mouse.getX()-centerpoint[1])/scale, (love.mouse.getY()-centerpoint[2])/scale) or c
    end
    -- c = Menus[CurrentMenu]:getCursor(love.mouse.getPosition()) or c
    love.mouse.setCursor(love.mouse.getSystemCursor(c))

    love.graphics.setColor(1,1,1)
    if Achievements.IsUnlocked("default_50_waves") then
        love.graphics.draw(Trophy, 32, love.graphics.getHeight()-32-128-32, 0, 128/Trophy:getWidth(), 128/Trophy:getHeight())
    end
    
    love.graphics.setFont(smfont)
    for i,v in ipairs(MenuVersions) do
        love.graphics.print(v.name .. " v" .. v.version .. (v.extra and (" - " .. table.concat(v.extra, ", "))or ""), 0, love.graphics.getHeight() - smfont:getHeight()*(#MenuVersions-i+1))
    end
    -- love.graphics.print("The Slash of the Dice v" .. tostring(version), 0, love.graphics.getHeight() - smfont:getHeight()*2)
    -- local major,minor,rev,name = love.getVersion()
    -- love.graphics.print("LÖVE v" .. major .. "." .. minor .. " (" .. name .. ")", 0, love.graphics.getHeight() - smfont:getHeight())

    if UpdateCheckFailed ~= 0 then
        love.graphics.setColor(1,0,0)
        love.graphics.print("UPDATE CHECKING FAILED WITH CODE " .. UpdateCheckFailed[1], 0, 0)
        local pos = 1
        for k,v in pairs(UpdateCheckFailed[2]) do
            love.graphics.print(tostring(k) .. ":" .. tostring(v), 0, pos*smfont:getHeight())
            pos = pos + 1
        end
    end

    love.graphics.setFont(lgfont)

    local f8 = "This menu is incomplete\nPress F8 to use the old menu"
    local height = lgfont:getHeight()*(#(({lgfont:getWrap(f8,lgfont:getWidth(f8))})[2]))
    love.graphics.printf(f8, love.graphics.getWidth()-lgfont:getWidth(f8), love.graphics.getHeight() - height, lgfont:getWidth(f8), "right")

    if beta then
        love.graphics.setFont(lgfont)
        love.graphics.setColor(0,1,0)
        love.graphics.printf("BETA VERSION", 0, love.graphics.getHeight() - lgfont:getHeight(), love.graphics.getWidth(), "center")
    end
    if update[1] then
        love.graphics.setFont(lgfont)
        love.graphics.printf("An update is available!", 0, love.graphics.getHeight()-lgfont:getHeight()*2, love.graphics.getWidth(), "center")
        love.graphics.printf("New version: " .. update[2], 0, love.graphics.getHeight()-lgfont:getHeight(), love.graphics.getWidth(), "center")
    end
end

function ParseLabel(v)
    if type(v) == "string" then return v end
    local res = ""
    local color = {1,1,1}
    for _,i in pairs(v) do
        if i.type == "color" then
            color = i.color
            if type(color) == "function" then
                color = color()
            end
        end
        if i.type == "text" then
            res = res .. i.value
        end
        if i.type == "fromcode" then
            res = res .. tostring(i.value())
        end
    end
    return res,color
end

function scene.keypressed(k)
    if k == "f8" then
        SceneManager.LoadScene("scenes/oldmenu")
    end
    if k == Sus:sub(SusCombo+1,SusCombo+1) then
        SusCombo = SusCombo + 1
        if SusCombo == #Sus then
            SusCombo = 0
            SusMode = not SusMode
            if SusMode then
                EnterTheSus:setVolume(Settings.audio.sound_volume/100)
                EnterTheSus:stop()
                EnterTheSus:play()
                Achievements.Advance("sus")
            else
                ExitTheSus:setVolume(Settings.audio.sound_volume/100)
                ExitTheSus:stop()
                ExitTheSus:play()
            end
        end
    end
    if Conversion[k] then
        k = Conversion[k]
    end
    
end

function scene.mousemoved(x, y, dx, dy)
    local screenWidth = 1280
    local screenHeight = 720
    local leftMargin = 160
    local rightMargin = 160
    local topMargin = (LogoPos+Logo:getHeight()*Settings.video.ui_scale+32)
    local bottomMargin = 64-(LogoPos-16)
    local centerpoint = {
        (leftMargin+(love.graphics.getWidth()-rightMargin))/2,
        (topMargin+(love.graphics.getHeight()-bottomMargin))/2
    }
    local scale = math.min((love.graphics.getWidth()-leftMargin-rightMargin)/(screenWidth-leftMargin-rightMargin), (love.graphics.getHeight()-topMargin-bottomMargin)/(screenHeight-topMargin-bottomMargin))
    x = (x-centerpoint[1])/scale
    y = (y-centerpoint[2])/scale
    if (Menus[CurrentMenu] or {}).mousemove then
        (Menus[CurrentMenu] or {}):mousemove(x, y, dx, dy)
    end
end

function scene.mousepressed(x, y, b)
    local screenWidth = 1280
    local screenHeight = 720
    local leftMargin = 160
    local rightMargin = 160
    local topMargin = (LogoPos+Logo:getHeight()*Settings.video.ui_scale+32)
    local bottomMargin = 64-(LogoPos-16)
    local centerpoint = {
        (leftMargin+(love.graphics.getWidth()-rightMargin))/2,
        (topMargin+(love.graphics.getHeight()-bottomMargin))/2
    }
    local scale = math.min((love.graphics.getWidth()-leftMargin-rightMargin)/(screenWidth-leftMargin-rightMargin), (love.graphics.getHeight()-topMargin-bottomMargin)/(screenHeight-topMargin-bottomMargin))
    x = (x-centerpoint[1])/scale
    y = (y-centerpoint[2])/scale
    if (Menus[CurrentMenu] or {}).click then
        (Menus[CurrentMenu] or {}):click(x, y, b)
    end
end

function scene.mousereleased(x, y, b)
    local screenWidth = 1280
    local screenHeight = 720
    local leftMargin = 160
    local rightMargin = 160
    local topMargin = (LogoPos+Logo:getHeight()*Settings.video.ui_scale+32)
    local bottomMargin = 64-(LogoPos-16)
    local centerpoint = {
        (leftMargin+(love.graphics.getWidth()-rightMargin))/2,
        (topMargin+(love.graphics.getHeight()-bottomMargin))/2
    }
    local scale = math.min((love.graphics.getWidth()-leftMargin-rightMargin)/(screenWidth-leftMargin-rightMargin), (love.graphics.getHeight()-topMargin-bottomMargin)/(screenHeight-topMargin-bottomMargin))
    x = (x-centerpoint[1])/scale
    y = (y-centerpoint[2])/scale
    if (Menus[CurrentMenu] or {}).release then
        (Menus[CurrentMenu] or {}):release(x, y, b)
    end
end

function scene.wheelmoved(x, y)
    local screenWidth = 1280
    local screenHeight = 720
    local leftMargin = 160
    local rightMargin = 160
    local topMargin = (LogoPos+Logo:getHeight()*Settings.video.ui_scale+32)
    local bottomMargin = 64-(LogoPos-16)
    local centerpoint = {
        (leftMargin+(love.graphics.getWidth()-rightMargin))/2,
        (topMargin+(love.graphics.getHeight()-bottomMargin))/2
    }
    local scale = math.min((love.graphics.getWidth()-leftMargin-rightMargin)/(screenWidth-leftMargin-rightMargin), (love.graphics.getHeight()-topMargin-bottomMargin)/(screenHeight-topMargin-bottomMargin))
    local mx,my = love.mouse.getPosition()
    mx = (mx-centerpoint[1])/scale
    my = (my-centerpoint[2])/scale
    if (Menus[CurrentMenu] or {}).scroll then
        (Menus[CurrentMenu] or {}):scroll(mx, my, x, y)
    end
end

return scene
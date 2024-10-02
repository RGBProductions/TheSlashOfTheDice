local scene = {}

love.keyboard.setKeyRepeat(true)

function SetMenu(m)
    CurrentMenu = m
    if (Menus[CurrentMenu] or {}).unpackChildren then
        for _,child in ipairs((Menus[CurrentMenu] or {}):unpackChildren(nil,nil,nil,1)) do
            if child.element.defaultSelected then
                MenuSelection = child
                break
            end
        end
    end
end

function OpenDialog(element)
    local selection = nil
    if (element or {}).unpackChildren then
        for _,child in ipairs((element or {}):unpackChildren(nil,nil,nil,1)) do
            if child.element.defaultSelected then
                selection = child
                break
            end
        end
    end
    table.insert(Dialogs, {element = element, selection = selection})
end

local scrollVelocity = 0
local scrollTarget = {0,0}
local allowScroll = false
local isPress = false
local isTouchHeld = false

function scene.load(args)
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
    
    local logoName = (Languages[Settings.language] or {}).logo
    if logoName then
        logoName = "logo-" .. logoName
    else
        logoName = "logo-en"
    end
    Logo = GetLogo(logoName)
    LogoPos = love.graphics.getHeight()

    SetMenu(args.menu or "main")

    Dialogs = {}

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

    ControlRemap = {
        control = nil,
        entry = 1
    }

    table.insert(MenuVersions, {name = "LÖVE", version = major .. "." .. minor .. " (" .. name .. ")"})
end

local function scroll(mx,my,x,y)
    local screenWidth = 1280
    local screenHeight = 720
    local leftMargin = 160
    local rightMargin = 160
    local topMargin = (LogoPos+Logo:getHeight()*Settings.video.ui_scale+32)
    local baseScale = 1.5
    local topMarginUnscaled = (LogoPos+Logo:getHeight()*baseScale+32)
    local bottomMargin = 64-(LogoPos-16)
    local centerpoint = {
        (leftMargin+(love.graphics.getWidth()-rightMargin))/2,
        (topMargin+(love.graphics.getHeight()-bottomMargin))/2
    }
    local scale = math.min((love.graphics.getWidth()-leftMargin-rightMargin)/(screenWidth-leftMargin-rightMargin), (love.graphics.getHeight()-topMargin-bottomMargin)/(screenHeight-topMarginUnscaled-bottomMargin))
    local m_x = (mx-centerpoint[1])/scale
    local m_y = (my-centerpoint[2])/scale
    local hasDialog = #Dialogs > 0
    for d = #Dialogs, 1, -1 do
        local dialog = Dialogs[d]
        if (dialog.element or {}).scroll then
            local hit,elem = (dialog.element or {}):scroll((mx-love.graphics.getWidth()/2)/scale,(my-love.graphics.getHeight()/2)/scale, x, y)
            if hit then
                break
            end
        end
    end
    if (Menus[CurrentMenu] or {}).scroll and not hasDialog then
        (Menus[CurrentMenu] or {}):scroll(m_x, m_y, x, y)
    end
end

---@param dir {[1]: number, [2]: number}
function GetSelectionTarget(dir, menu, selection)
    menu = menu or Menus[CurrentMenu]
    selection = selection or MenuSelection
    if Dialogs[1] then
        menu = Dialogs[1].element
        selection = Dialogs[1].selection
    end

    if not selection then return end -- nothing to select?

    if (menu or {}).unpackChildren then
        local elements = (menu or {}):unpackChildren() or {}
        local sort = {}
        for _,elem in ipairs(elements) do
            if type(elem.element.getSelectionTarget) == "function" then
                local target = elem.element:getSelectionTarget(dir,selection)
                if target then
                    return target
                end
            end
            if elem.element ~= selection.element and elem.element.canSelect then
                local ox,oy = elem.x-selection.x, elem.y-selection.y
                local distance = math.sqrt(ox*ox+oy*oy)
                local m = (distance == 0 and 1 or distance)
                local nx,ny = ox/m,oy/m
                local parallel = math.dot(dir, {nx,ny})
                local weight = (parallel^8*math.sign(parallel)) * 1/(distance/16)
                table.insert(sort, {element = elem, weight = weight})
            end
        end
        table.sort(sort, function (a, b)
            if b.weight == a.weight then
                if b.element.y == a.element.y then
                    return b.element.x > a.element.x
                end
                return b.element.y > a.element.y
            end
            return b.weight < a.weight
        end)
        return sort[1].element
    end

    return nil
end

function scene.update(dt)
    MenuTime = MenuTime + dt
    local blend = math.pow(1/(16^3), dt)
    LogoPos = blend*(LogoPos-16)+16

    scrollVelocity = math.max(0,math.abs(scrollVelocity)-dt)*math.sign(scrollVelocity)
    if not isTouchHeld then
        scroll(scrollTarget[1],scrollTarget[2],0,scrollVelocity)
    end
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
    local baseScale = 1.5
    local topMarginUnscaled = (LogoPos+Logo:getHeight()*baseScale+32)
    local bottomMargin = 64-(LogoPos-16)
    local centerpoint = {
        (leftMargin+(love.graphics.getWidth()-rightMargin))/2,
        (topMargin+(love.graphics.getHeight()-bottomMargin))/2
    }
    local scale = math.min((love.graphics.getWidth()-leftMargin-rightMargin)/(screenWidth-leftMargin-rightMargin), (love.graphics.getHeight()-topMargin-bottomMargin)/(screenHeight-topMarginUnscaled-bottomMargin))
    love.graphics.push()
    love.graphics.translate(centerpoint[1], centerpoint[2])
    love.graphics.scale(scale,scale)
    -- love.graphics.circle("fill", 0, 0, 4)
    -- love.graphics.rectangle("line", -w/2, -h/2, w, h)
    if (Menus[CurrentMenu] or {}).draw then
        Menus[CurrentMenu]:draw()
    end
    if Gamepads[1] and (Menus[CurrentMenu] or {}).drawSelected then
        Menus[CurrentMenu]:drawSelected()
    end
    love.graphics.pop()
    love.graphics.push()
    love.graphics.translate(love.graphics.getWidth()/2, love.graphics.getHeight()/2)
    love.graphics.scale(scale,scale)
    for _,dialog in ipairs(Dialogs) do
        love.graphics.setColor(0,0,0,0.5)
        love.graphics.rectangle("fill", -love.graphics.getWidth()/2/scale, -love.graphics.getHeight()/2/scale, love.graphics.getWidth()/scale, love.graphics.getHeight()/scale)
        if (dialog.element or {}).draw then
            (dialog.element or {}):draw()
        end
        if Gamepads[1] and (dialog.element or {}).drawSelected then
            (dialog.element or {}):drawSelected()
        end
    end
    love.graphics.pop()
    if (Menus[CurrentMenu] or {}).getCursor and not Dialogs[1] then
        c = Menus[CurrentMenu]:getCursor((love.mouse.getX()-centerpoint[1])/scale, (love.mouse.getY()-centerpoint[2])/scale) or c
    end
    for _,dialog in ipairs(Dialogs) do
        if (dialog.element or {}).getCursor then
            c = (dialog.element or {}):getCursor((love.mouse.getX()-love.graphics.getWidth()/2)/scale, (love.mouse.getY()-love.graphics.getHeight()/2)/scale) or c
        end
    end
    -- c = Menus[CurrentMenu]:getCursor(love.mouse.getPosition()) or c
    local s,r = pcall(love.mouse.getSystemCursor, c)
    if s then
        love.mouse.setCursor(r)
    end

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

    love.graphics.setFont(lgfont)

    if checkingUpdate then
        love.graphics.setColor(1,1,1,0.75)
        love.graphics.printf(Localize("update.checking"), 0, love.graphics.getHeight() - lgfont:getHeight(), love.graphics.getWidth(), "center")
    end
    if beta then
        love.graphics.setFont(lgfont)
        love.graphics.setColor(0,1,0)
        love.graphics.printf(Localize("update.new"), 0, love.graphics.getHeight() - lgfont:getHeight(), love.graphics.getWidth(), "center")
    end
    if update[1] then
        love.graphics.setFont(lgfont)
        love.graphics.printf(Localize("update.old"), 0, love.graphics.getHeight()-lgfont:getHeight()*2, love.graphics.getWidth(), "center")
        love.graphics.printf(Localize("update.new_version"):format(update[2]), 0, love.graphics.getHeight()-lgfont:getHeight(), love.graphics.getWidth(), "center")
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
    if ControlRemap.control then
        -- Override
        Settings.controls[ControlRemap.control][ControlRemap.entry].type = "key"
        Settings.controls[ControlRemap.control][ControlRemap.entry].button = k
        print("New control for " .. ControlRemap.control .. ":" .. ControlRemap.entry .. " is " .. GetControlEntryName(ControlRemap.control, ControlRemap.entry))
        ControlRemap.control = nil
        return
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
    local hasDialog = #Dialogs > 0
    for d = #Dialogs, 1, -1 do
        local dialog = Dialogs[d]
        if (dialog.element or {}).keypress then
            local hit,elem = (dialog.element or {}):keypress(k)
            if hit then
                break
            end
        end
    end
    if (Menus[CurrentMenu] or {}).keypress and not hasDialog then
        (Menus[CurrentMenu] or {}):keypress(k)
    end
end

function scene.textinput(t)
    local hasDialog = #Dialogs > 0
    for d = #Dialogs, 1, -1 do
        local dialog = Dialogs[d]
        if (dialog.element or {}).textinput then
            local hit,elem = (dialog.element or {}):textinput(t)
            if hit then
                break
            end
        end
    end
    if (Menus[CurrentMenu] or {}).textinput and not hasDialog then
        (Menus[CurrentMenu] or {}):textinput(t)
    end
end

function scene.mousemoved(x, y, dx, dy)
    local screenWidth = 1280
    local screenHeight = 720
    local leftMargin = 160
    local rightMargin = 160
    local topMargin = (LogoPos+Logo:getHeight()*Settings.video.ui_scale+32)
    local baseScale = 1.5
    local topMarginUnscaled = (LogoPos+Logo:getHeight()*baseScale+32)
    local bottomMargin = 64-(LogoPos-16)
    local centerpoint = {
        (leftMargin+(love.graphics.getWidth()-rightMargin))/2,
        (topMargin+(love.graphics.getHeight()-bottomMargin))/2
    }
    local scale = math.min((love.graphics.getWidth()-leftMargin-rightMargin)/(screenWidth-leftMargin-rightMargin), (love.graphics.getHeight()-topMargin-bottomMargin)/(screenHeight-topMarginUnscaled-bottomMargin))
    local m_x = (x-centerpoint[1])/scale
    local m_y = (y-centerpoint[2])/scale
    local hasDialog = #Dialogs > 0
    for d = #Dialogs, 1, -1 do
        local dialog = Dialogs[d]
        if (dialog.element or {}).mousemove then
            local hit,elem = (dialog.element or {}):mousemove((x-love.graphics.getWidth()/2)/scale,(y-love.graphics.getHeight()/2)/scale,dx,dy)
            if hit then
                break
            end
        end
    end
    if (Menus[CurrentMenu] or {}).mousemove and not hasDialog then
        (Menus[CurrentMenu] or {}):mousemove(m_x, m_y, dx, dy)
    end
end

function scene.mousepressed(x, y, b, t)
    if t then return end
    if ControlRemap.control then
        -- Override
        Settings.controls[ControlRemap.control][ControlRemap.entry].type = "mouse"
        Settings.controls[ControlRemap.control][ControlRemap.entry].button = b
        ControlRemap.control = nil
        return
    end
    local screenWidth = 1280
    local screenHeight = 720
    local leftMargin = 160
    local rightMargin = 160
    local topMargin = (LogoPos+Logo:getHeight()*Settings.video.ui_scale+32)
    local baseScale = 1.5
    local topMarginUnscaled = (LogoPos+Logo:getHeight()*baseScale+32)
    local bottomMargin = 64-(LogoPos-16)
    local centerpoint = {
        (leftMargin+(love.graphics.getWidth()-rightMargin))/2,
        (topMargin+(love.graphics.getHeight()-bottomMargin))/2
    }
    local scale = math.min((love.graphics.getWidth()-leftMargin-rightMargin)/(screenWidth-leftMargin-rightMargin), (love.graphics.getHeight()-topMargin-bottomMargin)/(screenHeight-topMarginUnscaled-bottomMargin))
    local m_x = (x-centerpoint[1])/scale
    local m_y = (y-centerpoint[2])/scale
    local hasDialog = #Dialogs > 0
    for d = #Dialogs, 1, -1 do
        local dialog = Dialogs[d]
        if (dialog.element or {}).click then
            local hit,elem = (dialog.element or {}):click((x-love.graphics.getWidth()/2)/scale,(y-love.graphics.getHeight()/2)/scale,b)
            if hit then
                break
            end
        end
    end
    if (Menus[CurrentMenu] or {}).click and not hasDialog then
        (Menus[CurrentMenu] or {}):click(m_x, m_y, b)
    end
end

function scene.mousereleased(x, y, b)
    local screenWidth = 1280
    local screenHeight = 720
    local leftMargin = 160
    local rightMargin = 160
    local topMargin = (LogoPos+Logo:getHeight()*Settings.video.ui_scale+32)
    local baseScale = 1.5
    local topMarginUnscaled = (LogoPos+Logo:getHeight()*baseScale+32)
    local bottomMargin = 64-(LogoPos-16)
    local centerpoint = {
        (leftMargin+(love.graphics.getWidth()-rightMargin))/2,
        (topMargin+(love.graphics.getHeight()-bottomMargin))/2
    }
    local scale = math.min((love.graphics.getWidth()-leftMargin-rightMargin)/(screenWidth-leftMargin-rightMargin), (love.graphics.getHeight()-topMargin-bottomMargin)/(screenHeight-topMarginUnscaled-bottomMargin))
    local m_x = (x-centerpoint[1])/scale
    local m_y = (y-centerpoint[2])/scale
    local hasDialog = #Dialogs > 0
    for d = #Dialogs, 1, -1 do
        local dialog = Dialogs[d]
        if (dialog.element or {}).release then
            local hit,elem = (dialog.element or {}):release((x-love.graphics.getWidth()/2)/scale,(y-love.graphics.getHeight()/2)/scale,b)
            if hit then
                break
            end
        end
    end
    if (Menus[CurrentMenu] or {}).release and not hasDialog then
        (Menus[CurrentMenu] or {}):release(m_x, m_y, b)
    end
end

function scene.touchpressed(id,x,y)
    allowScroll = true

    local screenWidth = 1280
    local screenHeight = 720
    local leftMargin = 160
    local rightMargin = 160
    local topMargin = (LogoPos+Logo:getHeight()*Settings.video.ui_scale+32)
    local baseScale = 1.5
    local topMarginUnscaled = (LogoPos+Logo:getHeight()*baseScale+32)
    local bottomMargin = 64-(LogoPos-16)
    local centerpoint = {
        (leftMargin+(love.graphics.getWidth()-rightMargin))/2,
        (topMargin+(love.graphics.getHeight()-bottomMargin))/2
    }
    local scale = math.min((love.graphics.getWidth()-leftMargin-rightMargin)/(screenWidth-leftMargin-rightMargin), (love.graphics.getHeight()-topMargin-bottomMargin)/(screenHeight-topMarginUnscaled-bottomMargin))
    local m_x = (x-centerpoint[1])/scale
    local m_y = (y-centerpoint[2])/scale
    local hasDialog = #Dialogs > 0
    for d = #Dialogs, 1, -1 do
        local dialog = Dialogs[d]
        if (dialog.element or {}).touch then
            local hit,elem,preventScroll = (dialog.element or {}):touch((x-love.graphics.getWidth()/2)/scale,(y-love.graphics.getHeight()/2)/scale)
            if hit then
                if preventScroll then
                    allowScroll = false
                end
                break
            end
        end
    end
    if (Menus[CurrentMenu] or {}).touch and not hasDialog then
        local hit,elem,preventScroll = (Menus[CurrentMenu] or {}):touch(m_x, m_y)
        if hit then
            if preventScroll then
                allowScroll = false
            end
        end
    end

    scrollTarget = {m_x,m_y}
    scrollVelocity = 0
    isPress = true
    isTouchHeld = true
end

function scene.touchmoved(id,x,y,dx,dy)
    local screenWidth = 1280
    local screenHeight = 720
    local leftMargin = 160
    local rightMargin = 160
    local topMargin = (LogoPos+Logo:getHeight()*Settings.video.ui_scale+32)
    local baseScale = 1.5
    local topMarginUnscaled = (LogoPos+Logo:getHeight()*baseScale+32)
    local bottomMargin = 64-(LogoPos-16)
    local centerpoint = {
        (leftMargin+(love.graphics.getWidth()-rightMargin))/2,
        (topMargin+(love.graphics.getHeight()-bottomMargin))/2
    }
    local scale = math.min((love.graphics.getWidth()-leftMargin-rightMargin)/(screenWidth-leftMargin-rightMargin), (love.graphics.getHeight()-topMargin-bottomMargin)/(screenHeight-topMarginUnscaled-bottomMargin))
    local m_x = scrollTarget[1]
    local m_y = scrollTarget[2]
    local m_x2 = (x-centerpoint[1])/scale
    local m_y2 = (y-centerpoint[2])/scale
    local m_dx = dx/scale
    local m_dy = dy/scale

    if allowScroll then
        if math.abs(m_x2-m_x) >= 16 or math.abs(m_y2-m_y) >= 16 then
            isPress = false
            scrollVelocity = m_dy/16
            scroll(scrollTarget[1],scrollTarget[2],0,m_dy/16)
        end
    else
        scene.mousemoved(x,y,dx,dy)
    end
end

function scene.touchreleased(id,x,y)
    if isPress and allowScroll then
        scene.mousepressed(x,y,1)
    end
    scene.mousereleased(x,y,1)
    isPress = false
    isTouchHeld = false
end

function scene.wheelmoved(x, y)
    scroll(love.mouse.getX(),love.mouse.getY(),x,y)
end

---@param stick love.Joystick
---@param button love.GamepadButton
function scene.gamepadpressed(stick,button)
    if ControlRemap.control then
        -- Override
        Settings.controls[ControlRemap.control][ControlRemap.entry].type = "gpbutton"
        Settings.controls[ControlRemap.control][ControlRemap.entry].button = button
        ControlRemap.control = nil
        return
    end

    if button == "a" then
        local selection
        if Dialogs[1] then
            selection = Dialogs[1].selection
        else
            selection = MenuSelection
        end
        if ((selection or {}).element or {}).clickInstance then
            ((selection or {}).element or {}):clickInstance()
        end
    end

    local selection

    local matches = MatchControl({type = "gpbutton", button = button})

    if table.index(matches, "menu_right") then
        selection = GetSelectionTarget({1,0}) or selection
    end
    if table.index(matches, "menu_left") then
        selection = GetSelectionTarget({-1,0}) or selection
    end
    if table.index(matches, "menu_down") then
        selection = GetSelectionTarget({0,1}) or selection
    end
    if table.index(matches, "menu_up") then
        selection = GetSelectionTarget({0,-1}) or selection
    end

    if selection then
        if Dialogs[1] then
            Dialogs[1].selection = selection
        else
            MenuSelection = selection
        end
    end
end

function scene.gamepadaxis(stick,axis,value)
    if ControlRemap.control then
        if math.abs(value) >= 0.5 then
            -- Override
            Settings.controls[ControlRemap.control][ControlRemap.entry].type = AxisRebindMethods[ControlRemap.control] or "gpaxis"
            Settings.controls[ControlRemap.control][ControlRemap.entry].axis = axis .. (value < 0 and "-" or "+")
            ControlRemap.control = nil
        end
        return
    end

    local selection

    if WasControlTriggered("menu_right") then
        selection = GetSelectionTarget({1,0}) or selection
    end
    if WasControlTriggered("menu_left") then
        selection = GetSelectionTarget({-1,0}) or selection
    end
    if WasControlTriggered("menu_down") then
        selection = GetSelectionTarget({0,1}) or selection
    end
    if WasControlTriggered("menu_up") then
        selection = GetSelectionTarget({0,-1}) or selection
    end
    
    if selection then
        if Dialogs[1] then
            Dialogs[1].selection = selection
        else
            MenuSelection = selection
        end
    end
end

return scene
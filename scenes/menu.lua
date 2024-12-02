local scene = {}

love.keyboard.setKeyRepeat(true)

function SetMenu(m)
    CurrentMenu = m
    MenuSelection = GetDefaultSelection(Menus[CurrentMenu])
    -- if (Menus[CurrentMenu] or {}).unpackChildren then
    --     for _,child in ipairs((Menus[CurrentMenu] or {}):unpackChildren(nil,nil,nil,1)) do
    --         if child.element.defaultSelected and not child.element.hidden then
    --             MenuSelection = child
    --             break
    --         end
    --     end
    -- end
end

function OpenDialog(element)
    local selection = GetDefaultSelection(element)
    -- if (element or {}).unpackChildren then
    --     for _,child in ipairs((element or {}):unpackChildren(nil,nil,nil,1)) do
    --         if child.element.defaultSelected and not child.element.hidden then
    --             selection = child
    --             break
    --         end
    --     end
    -- end
    table.insert(Dialogs, 1, {element = element, selection = selection})
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
    -- OnScreenKeyboard(false,UI.TextInput:new({}))

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
        entry = 1,
        startTime = love.timer.getTime()
    }

    table.insert(MenuVersions, {name = "LÖVE", version = major .. "." .. minor .. " (" .. name .. ")"})
end

local keyboardLayout = {
    letters = {
        {"Q",-200,0,32,32},
        {"W",-160,0,32,32},
        {"E",-120,0,32,32},
        {"R",-80,0,32,32},
        {"T",-40,0,32,32},
        {"Y",0,0,32,32},
        {"U",40,0,32,32},
        {"I",80,0,32,32},
        {"O",120,0,32,32},
        {"P",160,0,32,32},
        {string.char(0x00).."backspace", 248, 0, 128, 32, "keyboard.backspace"},
        {"A",-200+12,40,32,32},
        {"S",-160+12,40,32,32},
        {"D",-120+12,40,32,32},
        {"F",-80+12,40,32,32},
        {"G",-40+12,40,32,32},
        {"H",0+12,40,32,32},
        {"J",40+12,40,32,32},
        {"K",80+12,40,32,32},
        {"L",120+12,40,32,32},
        {string.char(0x00).."return", 248, 40, 128, 32, "button.confirm"},
        {"Z",-200+24,80,32,32},
        {"X",-160+24,80,32,32},
        {"C",-120+24,80,32,32},
        {"V",-80+24,80,32,32},
        {"B",-40+24,80,32,32},
        {"N",0+24,80,32,32},
        {"M",40+24,80,32,32},
        {string.char(0x01).."case", -288, 40, 128, 32},
        {string.char(0x01).."special", 248, 80, 128, 32},
        {",", -152, 120, 32, 32},
        {" ", 0, 120, 256, 32},
        {".", 152, 120, 32, 32},
        {string.char(0x00).."escape", 248, 120, 128, 32, "button.cancel"},
    },
    special = {
        {"1",-200,0,32,32},
        {"2",-160,0,32,32},
        {"3",-120,0,32,32},
        {"4",-80,0,32,32},
        {"5",-40,0,32,32},
        {"6",0,0,32,32},
        {"7",40,0,32,32},
        {"8",80,0,32,32},
        {"9",120,0,32,32},
        {"0",160,0,32,32},
        {string.char(0x00).."backspace", 248, 0, 128, 32, "Backspace"},
        {"@",-200,40,32,32},
        {"#",-160,40,32,32},
        {"$",-120,40,32,32},
        {"_",-80,40,32,32},
        {"&",-40,40,32,32},
        {"-",0,40,32,32},
        {"+",40,40,32,32},
        {"(",80,40,32,32},
        {")",120,40,32,32},
        {"/",160,40,32,32},
        {string.char(0x00).."return", 248, 40, 128, 32, "Confirm"},
        {"*",-200,80,32,32},
        {"\"",-160,80,32,32},
        {"'",-120,80,32,32},
        {":",-80,80,32,32},
        {";",-40,80,32,32},
        {"!",0,80,32,32},
        {"?",40,80,32,32},
        {"~",80,80,32,32},
        {"=",120,80,32,32},
        {"\\",160,80,32,32},
        {string.char(0x01).."special", 248, 80, 128, 32},
        {",", -152, 120, 32, 32},
        {" ", 0, 120, 256, 32},
        {".", 152, 120, 32, 32},
        {string.char(0x00).."escape", 248, 120, 128, 32, "Cancel"},
    }
}

local keyboard = UI.Element:new({id = "keyboard", case = 1, set = 0, children = {
    UI.Element:new({
        id = "letters",
        hidden = false,
        children = {}
    }),
    UI.Element:new({
        id = "special",
        hidden = true,
        children = {}
    })
}})

local function addKeyButton(object,letter,i)
    object:addChild(
        UI.Button:new({
            defaultSelected = i == 1,
            id = letter[1],
            x = letter[2],
            y = letter[3],
            width = letter[4],
            height = letter[5],
            background = function() return GetTheme().button_secondary.background end,
            border = function() return GetTheme().button_secondary.border end,
            children = {
                UI.Text:new({
                    x = 0,
                    y = 0,
                    width = letter[4],
                    height = letter[5],
                    text = function(self)
                        if letter[1] == string.char(0x01).."case" then
                            return Localize("keyboard." .. (self.parent.parent.parent.case == 0 and "lowercase" or (self.parent.parent.parent.case == 1 and "uppercase" or "caps_lock")))
                        end
                        if letter[1] == string.char(0x01).."special" then
                            return self.parent.parent.parent.set == 1 and "ABC" or "123 !@#"
                        end
                        return (letter[6] ~= nil and Localize(letter[6]) or nil) or (self.parent.parent.parent.case == 0 and letter[1]:lower() or letter[1]:upper())
                    end,
                    font = lgfont_2x,
                    fontScale = function (self)
                        local text = (type(self.text) == "function" and self:text()) or (self.text or "")
                        local font = (type(self.font) == "function" and self:font()) or (self.font or mdfont)
                        local width = font:getWidth(text)
                        return math.min(0.5,(letter[4])/width)
                    end,
                    alignHoriz = "center",
                    alignVert = "center",
                    clickThrough = true
                })
            },
            onclick = function(self)
                local char = letter[1]
                if char:sub(1,1) == string.char(0x00) then
                    SceneManager.KeyPressed(char:sub(2,-1))
                elseif char:sub(1,1) == string.char(0x01) then
                    if char:sub(2,-1) == "case" then
                        self.parent.parent.case = (self.parent.parent.case + 1) % 3
                    end
                    if char:sub(2,-1) == "special" then
                        self.parent.parent.set = (self.parent.parent.set + 1) % 2
                        self.parent.parent:getChildById("letters").hidden = self.parent.parent.set == 1
                        self.parent.parent:getChildById("special").hidden = self.parent.parent.set == 0
                        local specialCharsButton = (self.parent.parent.set == 0 and self.parent.parent:getChildById("letters") or self.parent.parent:getChildById("special")):getChildById(string.char(0x01).."special");
                        (Dialogs[1] or {}).selection = {element = specialCharsButton, x = ((Dialogs[1] or {}).selection or {}).x, y = ((Dialogs[1] or {}).selection or {}).y}
                    end
                else
                    SceneManager.TextInput(self.parent.parent.case == 0 and char:lower() or char:upper())
                    if self.parent.parent.case == 1 then
                        self.parent.parent.case = 0
                    end
                end
            end
        })
    )
end

for i,letter in ipairs(keyboardLayout.letters) do
    addKeyButton(keyboard:getChildById("letters"), letter, i)
end
for i,letter in ipairs(keyboardLayout.special) do
    addKeyButton(keyboard:getChildById("special"), letter, i)
end

function OnScreenKeyboard(showKeyboard,input)
    local originalContent = ((input or {}).input or {}).content or ""
    local base = UI.Element:new({children = {
        UI.Text:new({
            id = "title",
            x = 0,
            y = -240,
            width = 512,
            height = lgfont:getHeight(),
            font = lgfont_2x,
            fontScale = 0.5,
            text = function() return Localize("text_input") end,
            alignHoriz = "center",
            alignVert = "center"
        })
    }})

    local textView = UI.Panel:new({
        id = "text_view",
        x = 0,
        y = -200,
        width = 128,
        height = 24,
        background = function() return GetTheme().button_secondary.background end,
        border = function() return GetTheme().button_secondary.border end,
        draw = function(me,...)
            UI.TextInput.draw(me,...)
        end,
        -- click = function(me,...)
        --     UI.TextInput.click(me,...);
        --     (input or {}).selected = me.selected
        -- end,
        clickInstance = function(me,...)
            UI.TextInput.clickInstance(me,...);
            (input or {}).selected = me.selected
        end,
        selected = true,
        input = (input or {}).input,
        children = {
            UI.Text:new({
                text = function(me) return ((input or {}).input or {}).content or "" end,
                textinputInstance = function(me,t)
                    ---@type Input
                    local inputobj = (input or {}).input
                    if inputobj then
                        inputobj:textinput(t)
                    end
                end,
                keypressInstance = function(me,k)
                    ---@type Input
                    local inputobj = (input or {}).input
                    if inputobj then
                        inputobj:defaultKeyboard(k)
                    end
                    if k == "return" then
                        if (input or {}).keypressInstance then
                            (input or {}):keypressInstance(k)
                        end
                    end
                    if k == "escape" then
                        inputobj.content = originalContent;
                        (input or {}).selected = false
                    end
                end,
                font = mdfont_2x,
                fontScale = 0.5,
                color = function() return GetTheme().button_secondary.text end,
                width = 128,
                height = 24,
                alignHoriz = "center",
                alignVert = "center",
                clickThrough = true
            })
        }
    })

    local scrollLeft = UI.Button:new({
        id = "scroll_left",
        width = 24,
        height = 24,
        x = -84,
        y = -200,
        background = function() return GetTheme().button_secondary.background end,
        border = function() return GetTheme().button_secondary.border end,
        children = {
            UI.Text:new({
                clickThrough = true,
                x = 0,
                y = 0,
                width = 24,
                height = 24,
                text = function() return "<" end,
                color = function() return GetTheme().button_secondary.text end,
                font = lgfont_2x,
                fontScale = 0.5,
                alignHoriz = "center",
                alignVert = "center"
            })
        },
        onclick = function()
            if input then
                input:keypressInstance("left")
            end
        end
    })

    local scrollRight = UI.Button:new({
        id = "scroll_right",
        width = 24,
        height = 24,
        x = 84,
        y = -200,
        background = function() return GetTheme().button_secondary.background end,
        border = function() return GetTheme().button_secondary.border end,
        children = {
            UI.Text:new({
                clickThrough = true,
                x = 0,
                y = 0,
                width = 24,
                height = 24,
                text = function() return ">" end,
                color = function() return GetTheme().button_secondary.text end,
                font = lgfont_2x,
                fontScale = 0.5,
                alignHoriz = "center",
                alignVert = "center"
            })
        },
        onclick = function()
            if input then
                input:keypressInstance("right")
            end
        end
    })

    local confirmButton = UI.Button:new({
        id = "confirm",
        width = 192,
        height = 24,
        x = 0,
        y = -168,
        background = function() return GetTheme().button_secondary.background end,
        border = function() return GetTheme().button_secondary.border end,
        children = {
            UI.Text:new({
                clickThrough = true,
                x = 0,
                y = 0,
                width = 184,
                height = 24,
                text = function() return Localize("button.confirm") end,
                color = function() return GetTheme().button_secondary.text end,
                font = mdfont_2x,
                fontScale = 0.5,
                alignHoriz = "center",
                alignVert = "center"
            })
        },
        onclick = function()
            if input then
                input:keypressInstance("return")
            end
        end
    })

    if showKeyboard then base:addChild(keyboard) end
    
    (input or {}).selected = true
    base:addChild(scrollLeft)
    base:addChild(textView)
    base:addChild(scrollRight)
    base:addChild(confirmButton)
    OpenDialog(base)
    Dialogs[1].isKeyboard = true
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

function scene.update(dt)
    if ControlRemap.control and love.timer.getTime() - ControlRemap.startTime >= 3 then
        ControlRemap.control = nil
    end
    MenuTime = MenuTime + dt
    local blend = math.pow(1/((8/7)^60), dt)
    LogoPos = blend*(LogoPos-16)+16

    scrollVelocity = math.max(0,math.abs(scrollVelocity)-dt)*math.sign(scrollVelocity)
    if not isTouchHeld then
        scroll(scrollTarget[1],scrollTarget[2],0,scrollVelocity)
    end
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
    for i = #Dialogs, 1, -1 do
        local dialog = Dialogs[i]
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
    for i = #Dialogs, 1, -1 do
        local dialog = Dialogs[i]
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
    
    love.graphics.setFont(mdfont)
    for i,v in ipairs(MenuVersions) do
        love.graphics.print(v.name .. " v" .. v.version .. (v.extra and (" - " .. table.concat(v.extra, ", "))or ""), 0, love.graphics.getHeight() - mdfont:getHeight()*(#MenuVersions-i+1))
    end

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
    if k == "escape" then
        if Dialogs[1] then
            table.remove(Dialogs, 1)
        end
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

local function mousepress(x, y, b)
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

function scene.mousepressed(x, y, b, t)
    if t or (not t and IsMobile) then return end
    if ControlRemap.control then
        -- Override
        Settings.controls[ControlRemap.control][ControlRemap.entry].type = "mouse"
        Settings.controls[ControlRemap.control][ControlRemap.entry].button = b
        ControlRemap.control = nil
        return
    end
    mousepress(x,y,b)
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
        mousepress(x,y,1)
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

    if button == "b" then
        SceneManager.KeyPressed("escape")
    end

    if (Dialogs[1] or {}).isKeyboard then
        if button == "x" then
            SceneManager.KeyPressed("backspace")
        end
        if button == "y" then
            SceneManager.KeyPressed("return")
        end
        if (Dialogs[1] or {}).element then
            local special = Dialogs[1].element:getChildById(string.char(0x01).."special")
            local case = Dialogs[1].element:getChildById(string.char(0x01).."case")
            if button == "rightshoulder" then
                special:clickInstance()
            end
            if button == "leftshoulder" then
                case:clickInstance()
            end
        end
    end

    if button == "a" then
        local selection
        if Dialogs[1] then
            selection = Dialogs[1].selection
        else
            selection = MenuSelection
        end
        if ((selection or {}).element or {}).clickInstance then
            ((selection or {}).element or {}):clickInstance(nil,nil,1)
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

    if WasAxisTriggered("triggerright") then
        SceneManager.KeyPressed("right")
    end
    if WasAxisTriggered("triggerleft") then
        SceneManager.KeyPressed("left")
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
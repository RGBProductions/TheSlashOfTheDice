local scene = {}

--[[

ザ・スッラッシュ・オブ・ザ・ダイスには
急速に動くパターンが含まれており、
光感受性てんかんをお持ちの方には
発作や他の健康問題を
引き起こす可能性があります。

この症状やその他の光感受性の問題がある方は、
このゲームのプレイを避けてください！




ザ・スッラッシュ・オブ・ザ・ダイスには
急速に動くパターンが含まれており、
光感受性てんかんをお持ちの方には
発作や他の健康問題を
引き起こす可能性があります。

この症状やその他の光感受性の問題がある方は、
このゲームのプレイを避けてください！



The Slash of the Dice contains
rapidly moving patterns
that may trigger
seizures or other health complications
for individuals with photosensitive epilepsy.

If you suffer from this or another photosensitive condition,
please avoid playing this game!



]]

---@diagnostic disable-next-line: param-type-mismatch
local photosensitivity = love.graphics.newText(lgfont_2x)
photosensitivity:addf({{1,1,1}, Localize("photosensitivity1"), {1,0.5,0.4}, Localize("photosensitivity2"), {1,1,1}, Localize("photosensitivity3"), {1,0.5,0.4}, Localize("photosensitivity4"), {1,1,1}, Localize("photosensitivity5"), {1,0.5,0.4}, Localize("photosensitivity6")}, (1280-64)*2, "center", 0, 0)

local menu = UI.Element:new({
    children = {
        UI.Button:new({
            defaultSelected = true,
            scrollThrough = true,
            id = "continue",
            x = -136,
            y = 200,
            width = 256,
            height = 64,
            background = function() return GetTheme().button_secondary.background end,
            border = function() return GetTheme().button_secondary.border end,
            cursor = "hand",
            children = {
                UI.Text:new({
                    clickThrough = true,
                    x = 0,
                    y = 0,
                    width = 256,
                    height = 64,
                    text = function(self) return Localize("photosensitivity."..self.parent.id) end,
                    font = lgfont_2x,
                    fontScale = 0.5,
                    alignHoriz = "center",
                    alignVert = "center"
                })
            },
            onclick = function(self)
                if self.parent:getChildById("dont_show_again").value then
                    love.filesystem.write("hidephotosensitivity", "")
                end
                SceneManager.LoadScene("scenes/menu")
            end
        }),
        UI.Button:new({
            scrollThrough = true,
            id = "exit",
            x = 136,
            y = 200,
            width = 256,
            height = 64,
            background = function() return GetTheme().button_back.background end,
            border = function() return GetTheme().button_back.border end,
            cursor = "hand",
            children = {
                UI.Text:new({
                    clickThrough = true,
                    x = 0,
                    y = 0,
                    width = 256,
                    height = 64,
                    text = function(self) return Localize("photosensitivity."..self.parent.id) end,
                    font = lgfont_2x,
                    fontScale = 0.5,
                    alignHoriz = "center",
                    alignVert = "center"
                })
            },
            onclick = function(self) love.event.push("quit") end
        }),
        
        UI.Toggle:new({
            id = "dont_show_again",
            scrollThrough = true,
            cursor = "hand",
            x = function()
                return -(32+lgfont:getWidth(Localize("photosensitivity.dont_show_again")))/2+16
            end,
            y = 264,
            width = 32,
            height = 32,
            initWith = false,
            children = {
                UI.Text:new({
                    text = function() return Localize("photosensitivity.dont_show_again") end,
                    font = lgfont_2x,
                    fontScale = 0.5,
                    x = function() return lgfont:getWidth(Localize("photosensitivity.dont_show_again"))/2+24 + 32 end,
                    y = 0,
                    width = function()
                        return lgfont:getWidth(Localize("photosensitivity.dont_show_again")) + 64
                    end,
                    height = 32,
                    alignHoriz = "left",
                    alignVert = "center"
                })
            }
        }),
    }
})

local currentSelection = GetDefaultSelection(menu)

function scene.draw()
    local screenWidth = 1280
    local screenHeight = 720
    local leftMargin = 0
    local rightMargin = 0
    local topMargin = 0
    local bottomMargin = 0
    local centerpoint = {
        (leftMargin+(love.graphics.getWidth()-rightMargin))/2,
        (topMargin+(love.graphics.getHeight()-bottomMargin))/2
    }
    local scale = math.min(love.graphics.getWidth()/screenWidth, love.graphics.getHeight()/screenHeight)
    
    love.graphics.push()
    love.graphics.translate(centerpoint[1], centerpoint[2])
    love.graphics.scale(scale,scale)

    love.graphics.setFont(xlfont_2x)
    love.graphics.setColor(1,0,0)
    love.graphics.printf(Localize("photosensitivity.warning"), -640, -200-xlfont:getHeight()/2, 1280*2, "center", 0, 0.5)
    love.graphics.setColor(1,1,1)
    love.graphics.draw(photosensitivity, 32-640, (720-photosensitivity:getHeight()/2)/2-360, 0, 0.5, 0.5)
    menu:draw()
    if Gamepads[1] then menu:drawSelected(currentSelection) end
    
    local c = menu:getCursor((love.mouse.getX()-centerpoint[1])/scale, (love.mouse.getY()-centerpoint[2])/scale) or "arrow"
    local s,r = pcall(love.mouse.getSystemCursor, c)
    if s then
        love.mouse.setCursor(r)
    end

    love.graphics.pop()
end

function scene.mousepressed(x, y, b, t)
    local screenWidth = 1280
    local screenHeight = 720
    local leftMargin = 0
    local rightMargin = 0
    local topMargin = 0
    local bottomMargin = 0
    local centerpoint = {
        (leftMargin+(love.graphics.getWidth()-rightMargin))/2,
        (topMargin+(love.graphics.getHeight()-bottomMargin))/2
    }
    local scale = math.min(love.graphics.getWidth()/screenWidth, love.graphics.getHeight()/screenHeight)
    local m_x = (x-centerpoint[1])/scale
    local m_y = (y-centerpoint[2])/scale
    menu:click(m_x, m_y, b)
end

function scene.gamepadpressed(stick,button)
    if button == "a" then
        if ((currentSelection or {}).element or {}).clickInstance then
            ((currentSelection or {}).element or {}):clickInstance(nil,nil,1)
        end
    end

    local selection

    local matches = MatchControl({type = "gpbutton", button = button})

    if table.index(matches, "menu_right") then
        selection = GetSelectionTarget({1,0}, menu, currentSelection) or selection
    end
    if table.index(matches, "menu_left") then
        selection = GetSelectionTarget({-1,0}, menu, currentSelection) or selection
    end
    if table.index(matches, "menu_down") then
        selection = GetSelectionTarget({0,1}, menu, currentSelection) or selection
    end
    if table.index(matches, "menu_up") then
        selection = GetSelectionTarget({0,-1}, menu, currentSelection) or selection
    end

    if selection then
        currentSelection = selection
    end
end

function scene.gamepadaxis(stick,axis,value)
    local selection

    if WasControlTriggered("menu_right") then
        selection = GetSelectionTarget({1,0}, menu, currentSelection) or selection
    end
    if WasControlTriggered("menu_left") then
        selection = GetSelectionTarget({-1,0}, menu, currentSelection) or selection
    end
    if WasControlTriggered("menu_down") then
        selection = GetSelectionTarget({0,1}, menu, currentSelection) or selection
    end
    if WasControlTriggered("menu_up") then
        selection = GetSelectionTarget({0,-1}, menu, currentSelection) or selection
    end
    
    if selection then
        currentSelection = selection
    end
end

return scene
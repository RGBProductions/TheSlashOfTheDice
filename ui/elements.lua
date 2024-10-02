---@diagnostic disable: duplicate-set-field

--#region Button

UI.Button = UI.Element:new({canSelect = true})

function UI.Button:drawInstance()
    local w = (type(self.width) == "function" and self.width(self)) or (self.width or 0)
    local h = (type(self.height) == "function" and self.height(self)) or (self.height or 0)
    
    local background = self.background or {1,1,1}
    local border = self.border or {color = {1,1,1}, width = 0}
    local rounding = self.rounding or 0

    if type(background) == "function" then background = background(self) end
    if type(border) == "function" then border = border(self) end
    if type(rounding) == "function" then rounding = rounding(self) end

    local r,g,b,a = love.graphics.getColor()
    local lw = love.graphics.getLineWidth()

    if type(background) == "table" then
        love.graphics.setColor(background)
        love.graphics.rectangle("fill", -w/2, -h/2, w, h)
    elseif type(background.getWidth) == "function" then
        love.graphics.setColor(1,1,1)
        love.graphics.draw(background, -w/2, -h/2, 0, w/background:getWidth(), h/background:getHeight())
    end

    if border and (border.width or 0) > 0 then
        love.graphics.setColor(border.color or {1,1,1})
        love.graphics.setLineWidth(border.width or 0)
        love.graphics.rectangle("line", -w/2+(border.width or 0)/2, -h/2+(border.width or 0)/2, w-(border.width or 0), h-(border.width or 0), rounding)
    end

    if ShowDebugInfo then
        love.graphics.setLineWidth(2)
        love.graphics.setColor(1,1,1)
        love.graphics.rectangle("line", -w/2, -h/2, w, h)
    end

    love.graphics.setColor(r,g,b,a)
    love.graphics.setLineWidth(lw)
end

function UI.Button:drawSelectedInstance()
    local w = (type(self.width) == "function" and self.width(self)) or (self.width or 0)
    local h = (type(self.height) == "function" and self.height(self)) or (self.height or 0)
    
    love.graphics.setLineWidth(8)
    love.graphics.setColor(0,0,0)
    love.graphics.rectangle("line", -w/2, -h/2, w, h)
    love.graphics.setLineWidth(4)
    love.graphics.setColor(1,1,1)
    love.graphics.rectangle("line", -w/2, -h/2, w, h)
end

function UI.Button:clickInstance(mx,my,b)
    if type(self.onclick) == "function" then self:onclick(mx,my,b) end
end

--#endregion

--#region Toggle

UI.Toggle = UI.Element:new({canSelect = true})

function UI.Toggle:initInstance()
    if type(self.initWith) == "function" then
        self.value = self.initWith(self)
    else
        self.value = self.initWith
    end
end

function UI.Toggle:drawInstance()
    local w = (type(self.width) == "function" and self.width(self)) or (self.width or 0)
    local h = (type(self.height) == "function" and self.height(self)) or (self.height or 0)
    
    local background = self.background or {1,1,1}
    local fill = self.fill or {0,0.5,1}
    local border = self.border or {color = {1,1,1}, width = 0}
    local rounding = self.rounding or 0

    if type(background) == "function" then background = background(self) end
    if type(fill) == "function" then fill = fill(self) end
    if type(border) == "function" then border = border(self) end
    if type(rounding) == "function" then rounding = rounding(self) end

    local r,g,b,a = love.graphics.getColor()
    local lw = love.graphics.getLineWidth()

    if type(background) == "table" then
        love.graphics.setColor(background)
        love.graphics.rectangle("fill", -w/2, -h/2, w, h)
    elseif type(background.getWidth) == "function" then
        love.graphics.setColor(1,1,1)
        love.graphics.draw(background, -w/2, -h/2, 0, w/background:getWidth(), h/background:getHeight())
    end

    if self.value then
        if type(fill) == "table" then
            love.graphics.setColor(fill)
            love.graphics.rectangle("fill", -(w*0.75)/2, -(h*0.75)/2, (w*0.75), (h*0.75))
        elseif type(fill.getWidth) == "function" then
            love.graphics.setColor(1,1,1)
            love.graphics.draw(fill, -(w*0.75)/2, -(h*0.75)/2, 0, (w*0.75)/fill:getWidth(), (h*0.75)/fill:getHeight())
        end
    end

    if border and (border.width or 0) > 0 then
        love.graphics.setColor(border.color or {1,1,1})
        love.graphics.setLineWidth(border.width or 0)
        love.graphics.rectangle("line", -w/2+(border.width or 0)/2, -h/2+(border.width or 0)/2, w-(border.width or 0), h-(border.width or 0), rounding)
    end

    if ShowDebugInfo then
        love.graphics.setLineWidth(2)
        love.graphics.setColor(1,1,1)
        love.graphics.rectangle("line", -w/2, -h/2, w, h)
    end

    love.graphics.setColor(r,g,b,a)
    love.graphics.setLineWidth(lw)
end

function UI.Toggle:drawSelectedInstance()
    local w = (type(self.width) == "function" and self.width(self)) or (self.width or 0)
    local h = (type(self.height) == "function" and self.height(self)) or (self.height or 0)
    
    love.graphics.setLineWidth(8)
    love.graphics.setColor(0,0,0)
    love.graphics.rectangle("line", -w/2, -h/2, w, h)
    love.graphics.setLineWidth(4)
    love.graphics.setColor(1,1,1)
    love.graphics.rectangle("line", -w/2, -h/2, w, h)
end

function UI.Toggle:clickInstance(mx,my,b)
    self.value = not self.value
    if type(self.ontoggle) == "function" then self:ontoggle(self.value) end
end

--#endregion

--#region Text

UI.Text = UI.Element:new({})

function UI.Text:drawInstance()
    local w = (type(self.width) == "function" and self.width(self)) or (self.width or 0)
    local h = (type(self.height) == "function" and self.height(self)) or (self.height or 0)
    
    local color = self.color or {1,1,1}
    local font = self.font or lgfont
    local fontScale = self.fontScale or 1
    local text = self.text or ""

    if type(color) == "function" then color = color(self) end
    if type(font) == "function" then font = font(self) end
    if type(text) == "function" then text = text(self) end
    if type(fontScale) == "function" then fontScale = fontScale(self) end

    local r,g,b,a = love.graphics.getColor()
    local oldFont = love.graphics.getFont()

    love.graphics.setColor(color)
    love.graphics.setFont(font)
    local maxWidth,lines = font:getWrap(text, w/fontScale)
    local y = 0
    if self.alignVert == "center" then
        y = (h-(#lines*font:getHeight()*fontScale))/2
    end
    if self.alignVert == "bottom" then
        y = h-(#lines*font:getHeight()*fontScale)
    end
    love.graphics.printf(text, -w/2, -h/2+y, w/fontScale, self.alignHoriz, 0, fontScale)

    if ShowDebugInfo then
        local lw = love.graphics.getLineWidth()
        love.graphics.setLineWidth(2)
        love.graphics.setColor(1,1,1)
        love.graphics.rectangle("line", -w/2, -h/2, w, h)
        love.graphics.setLineWidth(lw)
    end

    love.graphics.setColor(r,g,b,a)
    love.graphics.setFont(oldFont)
end

--#endregion

--#region Image

UI.Image = UI.Element:new({})

function UI.Image:drawInstance()
    local w = (type(self.width) == "function" and self.width(self)) or (self.width or 0)
    local h = (type(self.height) == "function" and self.height(self)) or (self.height or 0)

    local r,g,b,a = love.graphics.getColor()

    local tint = self.tint or {1,1,1}
    local image = self.image or Logo

    if type(tint) == "function" then tint = tint(self) end
    if type(image) == "function" then image = image(self) end

    love.graphics.setColor(tint or {1,1,1})
    love.graphics.draw(image, -w/2, -h/2, 0, w/self.image:getWidth(), h/self.image:getHeight())

    if ShowDebugInfo then
        local lw = love.graphics.getLineWidth()
        love.graphics.setLineWidth(2)
        love.graphics.setColor(1,1,1)
        love.graphics.rectangle("line", -w/2, -h/2, w, h)
        love.graphics.setLineWidth(lw)
    end

    love.graphics.setColor(r,g,b,a)
end

--#endregion

--#region Panel

UI.Panel = UI.Element:new({})

function UI.Panel:drawInstance()
    local w = (type(self.width) == "function" and self.width(self)) or (self.width or 0)
    local h = (type(self.height) == "function" and self.height(self)) or (self.height or 0)
    
    local background = self.background or {1,1,1}
    local border = self.border or {color = {1,1,1}, width = 0}
    local rounding = self.rounding or 0

    if type(background) == "function" then background = background(self) end
    if type(border) == "function" then border = border(self) end
    if type(rounding) == "function" then rounding = rounding(self) end

    local r,g,b,a = love.graphics.getColor()
    local lw = love.graphics.getLineWidth()

    if type(background) == "table" then
        love.graphics.setColor(background)
        love.graphics.rectangle("fill", -w/2, -h/2, w, h)
    elseif type(background.getWidth) == "function" then
        love.graphics.setColor(1,1,1)
        love.graphics.draw(background, -w/2, -h/2, 0, w/background:getWidth(), h/background:getHeight())
    end

    if border and (border.width or 0) > 0 then
        love.graphics.setColor(border.color or {1,1,1})
        love.graphics.setLineWidth(border.width or 0)
        love.graphics.rectangle("line", -w/2+(border.width or 0)/2, -h/2+(border.width or 0)/2, w-(border.width or 0), h-(border.width or 0), rounding)
    end

    if ShowDebugInfo then
        love.graphics.setLineWidth(2)
        love.graphics.setColor(1,1,1)
        love.graphics.rectangle("line", -w/2, -h/2, w, h)
    end

    love.graphics.setColor(r,g,b,a)
    love.graphics.setLineWidth(lw)
end

--#endregion

--#region Text Input

UI.TextInput = UI.Element:new({canSelect = true})

function UI.TextInput:initInstance()
    if not self.input then
        local initWith = (type(self.initWith) == "function" and self.initWith(self)) or (self.initWith or "")
        self.input = typingutil.newInputObj(tostring(initWith), self.maxLength)
    end
end

function UI.TextInput:draw(stencilValue)
    stencilValue = stencilValue or 0
    local x = (type(self.x) == "function" and self.x(self)) or (self.x or 0)
    local y = (type(self.y) == "function" and self.y(self)) or (self.y or 0)
    
    local w = (type(self.width) == "function" and self.width(self)) or (self.width or 0)
    local h = (type(self.height) == "function" and self.height(self)) or (self.height or 0)

    love.graphics.push()
    love.graphics.translate(x, y)

    if not self.hidden then
        if type(self.drawInstance) == "function" then
            self:drawInstance()
        end

        for _,child in ipairs(type(self.children) == "table" and self.children or {}) do
            if type(child) == "table" and type(child.draw) == "function" then
                child:draw(stencilValue)
            end
        end
    end

    if self.selected then
        local searchX,searchY,searchW,searchH = 0,0,w,h
        local align = "center"
        local font = mdfont
        local fontscale = 1
        local text = self:getChildByType(UI.Text,true)
        if text then
            searchX = (type(text.x) == "function" and text.x(text)) or (text.x or 0)
            searchY = (type(text.y) == "function" and text.y(text)) or (text.y or 0)
            searchW = (type(text.width) == "function" and text.width(text)) or (text.width or 0)
            searchH = (type(text.height) == "function" and text.height(text)) or (text.height or 0)
            align = (type(text.alignHoriz) == "function" and text.alignHoriz(text)) or (text.alignHoriz or "left")
            font = (type(text.font) == "function" and text.font(text)) or (text.font or lgfont)
            fontscale = (type(text.fontScale) == "function" and text.fontScale(text)) or (text.fontScale or 1)
        end
        local textWidth = font:getWidth(self.input.content)*fontscale
        local baseX = searchX-searchW/2
        local ox = 0
        if align == "center" then
            ox = (searchW-textWidth)/2
        end
        if align == "right" then
            ox = searchW-textWidth
        end
        local startX = baseX+ox
        local textA = utf8.sub(self.input.content, 1, self.input:getMinSelection())
        local textB = utf8.sub(self.input.content, 1, self.input:getMaxSelection())
        local a = font:getWidth(textA)*fontscale
        local b = font:getWidth(textB)*fontscale
        if self.input:hasLargeSelection() then
            love.graphics.setColor(0,0.5,1,0.5)
            love.graphics.rectangle("fill", startX+a, -h/2, b-a, h)
        elseif (love.timer.getTime() - (self.clickTime or 0))%1 <= 0.5 then
            love.graphics.setColor(1,1,1)
            love.graphics.rectangle("fill", startX+a-1, -h/2, 2, h)
        end
        love.graphics.setColor(1,1,1)
    end

    love.graphics.pop()
end

function UI.TextInput:drawInstance()
    local w = (type(self.width) == "function" and self.width(self)) or (self.width or 0)
    local h = (type(self.height) == "function" and self.height(self)) or (self.height or 0)
    
    local background = self.background or {1,1,1}
    local border = self.border or {color = {1,1,1}, width = 0}
    local rounding = self.rounding or 0

    if type(background) == "function" then background = background(self) end
    if type(border) == "function" then border = border(self) end
    if type(rounding) == "function" then rounding = rounding(self) end

    local r,g,b,a = love.graphics.getColor()
    local lw = love.graphics.getLineWidth()

    if type(background) == "table" then
        love.graphics.setColor(background)
        love.graphics.rectangle("fill", -w/2, -h/2, w, h)
    elseif type(background.getWidth) == "function" then
        love.graphics.setColor(1,1,1)
        love.graphics.draw(background, -w/2, -h/2, 0, w/background:getWidth(), h/background:getHeight())
    end

    if border and (border.width or 0) > 0 then
        love.graphics.setColor(border.color or {1,1,1})
        love.graphics.setLineWidth(border.width or 0)
        love.graphics.rectangle("line", -w/2+(border.width or 0)/2, -h/2+(border.width or 0)/2, w-(border.width or 0), h-(border.width or 0), rounding)
    end

    if ShowDebugInfo then
        love.graphics.setLineWidth(2)
        love.graphics.setColor(1,1,1)
        love.graphics.rectangle("line", -w/2, -h/2, w, h)
    end

    love.graphics.setColor(r,g,b,a)
    love.graphics.setLineWidth(lw)
end

function UI.TextInput:drawSelectedInstance()
    local w = (type(self.width) == "function" and self.width(self)) or (self.width or 0)
    local h = (type(self.height) == "function" and self.height(self)) or (self.height or 0)
    
    love.graphics.setLineWidth(8)
    love.graphics.setColor(0,0,0)
    love.graphics.rectangle("line", -w/2, -h/2, w, h)
    love.graphics.setLineWidth(4)
    love.graphics.setColor(1,1,1)
    love.graphics.rectangle("line", -w/2, -h/2, w, h)
end

function UI.TextInput:click(mx,my,b)
    local x = (type(self.x) == "function" and self.x(self)) or (self.x or 0)
    local y = (type(self.y) == "function" and self.y(self)) or (self.y or 0)
    
    local w = (type(self.width) == "function" and self.width(self)) or (self.width or 0)
    local h = (type(self.height) == "function" and self.height(self)) or (self.height or 0)

    if self.clickThrough or self.hidden then
        return false, self
    end

    local children = (type(self.children) == "table" and self.children or {})
    for i = #children, 1, -1 do
        local child = children[i]
        if type(child) == "table" and type(child.click) == "function" then
            local clicked = child:click(mx-x,my-y,b)
            if clicked then
                return clicked,child
            end
        end
    end
    
    if mx-x >= -w/2 and mx-x < w/2 and my-y >= -h/2 and my-y < h/2 then
        if (not self.disabled) and type(self.clickInstance) == "function" then self:clickInstance(mx-x,my-y,b) end
        return true, self
    else
        if type(self.onconfirm) == "function" then
            self:onconfirm(self.input.content)
        end
        self.selected = false
        love.keyboard.setTextInput(false)
    end
    return false, self
end

function UI.TextInput:clickInstance(mx,my,b)
    if b == 1 then
        self.selected = true
        love.keyboard.setTextInput(true)
        self.clickTime = love.timer.getTime()
        local w = (type(self.width) == "function" and self.width(self)) or (self.width or 0)
        local h = (type(self.height) == "function" and self.height(self)) or (self.height or 0)
        local searchX,searchY,searchW,searchH = 0,0,w,h
        local align = "center"
        local font = mdfont
        local fontscale = 1
        local text = self:getChildByType(UI.Text,true)
        if text then
            searchX = (type(text.x) == "function" and text.x(text)) or (text.x or 0)
            searchY = (type(text.y) == "function" and text.y(text)) or (text.y or 0)
            searchW = (type(text.width) == "function" and text.width(text)) or (text.width or 0)
            searchH = (type(text.height) == "function" and text.height(text)) or (text.height or 0)
            align = (type(text.alignHoriz) == "function" and text.alignHoriz(text)) or (text.alignHoriz or "left")
            font = (type(text.font) == "function" and text.font(text)) or (text.font or lgfont)
            fontscale = (type(text.fontScale) == "function" and text.fontScale(text)) or (text.fontScale or 1)
        end

        local textWidth = font:getWidth(self.input.content)*fontscale
        local baseX = searchX-searchW/2
        local ox = 0
        if align == "center" then
            ox = (searchW-textWidth)/2
        end
        if align == "right" then
            ox = searchW-textWidth
        end
        local startX = baseX+ox
        local lastTextPos = 0
        local textPos = 0
        while startX + font:getWidth(utf8.sub(self.input.content, 1, textPos))*fontscale < mx and textPos <= utf8.len(self.input.content) do
            lastTextPos = textPos
            textPos = textPos + 1
        end
        local d1 = math.abs((startX + font:getWidth(utf8.sub(self.input.content, 1, lastTextPos))*fontscale) - mx)
        local d2 = math.abs((startX + font:getWidth(utf8.sub(self.input.content, 1, textPos))*fontscale) - mx)
        local sel = textPos
        if d1 < d2 then
            sel = lastTextPos
        end
        self.input.selection[1] = sel
        self.input.selection[2] = sel
    end
end

function UI.TextInput:textinputInstance(t)
    if self.selected then
        self.input:textinput(t)
        if type(self.onvaluechanged) == "function" then
            self:onvaluechanged(self.input.content)
        end
    end
end

function UI.TextInput:keypressInstance(k)
    if self.selected then
        self.input:defaultKeyboard(k)
        if type(self.onvaluechanged) == "function" then
            self:onvaluechanged(self.input.content)
        end
        if k == "return" then
            if type(self.onconfirm) == "function" then
                self:onconfirm(self.input.content)
            end
            self.selected = false
            love.keyboard.setTextInput(false)
        end
    end
end

--#endregion

--#region Slider

UI.Slider = UI.Element:new({canSelect = true})

function UI.Slider:initInstance()
    local initWith = (type(self.initWith) == "function" and self.initWith(self)) or (self.initWith or self.fill)
    self.fill = initWith
end

function UI.Slider:drawInstance()
    local w = (type(self.width) == "function" and self.width(self)) or (self.width or 0)
    local h = (type(self.height) == "function" and self.height(self)) or (self.height or 0)
    
    local barEmpty = self.barEmpty or {0.25,0.25,0.25}
    local barFill = self.barFill or {1,1,1}
    local barFillBorder = (self.barFillBorder or self.barBorder) or {color = {1,1,1}, width = 0}
    local barEmptyBorder = (self.barEmptyBorder or self.barBorder) or {color = {1,1,1}, width = 0}
    local barWidth = self.barWidth or 0.5
    local barRoundness = self.barRoundness or barWidth*h/2
    local thumbFill = self.thumbFill or {1,1,1}
    local thumbBorder = self.thumbBorder or {color = {0.5,0.5,0.5}, width = 2}
    local thumbSize = self.thumbSize or 1
    
    if type(barEmpty) == "function" then barEmpty = barEmpty(self) end
    if type(barFill) == "function" then barFill = barFill(self) end
    if type(barFillBorder) == "function" then barFillBorder = barFillBorder(self) end
    if type(barEmptyBorder) == "function" then barEmptyBorder = barEmptyBorder(self) end
    if type(barWidth) == "function" then barWidth = barWidth(self) end
    if type(barRoundness) == "function" then barRoundness = barRoundness(self) end
    if type(thumbFill) == "function" then thumbFill = thumbFill(self) end
    if type(thumbBorder) == "function" then thumbBorder = thumbBorder(self) end
    if type(thumbSize) == "function" then thumbSize = thumbSize(self) end

    local r,g,b,a = love.graphics.getColor()
    local lw = love.graphics.getLineWidth()

    love.graphics.setColor(barEmpty)
    love.graphics.rectangle("fill", -w/2, -h/2+(h-h*barWidth)/2, w, h*barWidth, barRoundness, barRoundness)
    love.graphics.setColor(barFill)
    love.graphics.rectangle("fill", -w/2, -h/2+(h-h*barWidth)/2, w*(((self.fill or 0)-(self.min or 0))/((self.max or 1)-(self.min or 0))), h*barWidth, barRoundness, barRoundness)
    if type(barEmptyBorder) == "table" and (barEmptyBorder.width or 0) > 0 then
        love.graphics.setColor(barEmptyBorder.color)
        love.graphics.setLineWidth(barEmptyBorder.width)
        love.graphics.rectangle("line", -w/2, -h/2+(h-h*barWidth)/2, w, h*barWidth, barRoundness, barRoundness)
    end
    if type(barFillBorder) == "table" and (barFillBorder.width or 0) > 0 then
        love.graphics.setColor(barFillBorder.color)
        love.graphics.setLineWidth(barFillBorder.width)
        love.graphics.rectangle("line", -w/2, -h/2+(h-h*barWidth)/2, w*(((self.fill or 0)-(self.min or 0))/((self.max or 1)-(self.min or 0))), h*barWidth, barRoundness, barRoundness)
    end
    
    love.graphics.setColor(thumbFill)
    love.graphics.circle("fill", -w/2 + w*(((self.fill or 0)-(self.min or 0))/((self.max or 1)-(self.min or 0))), 0, thumbSize/2*h)
    if type(thumbBorder) == "table" and (thumbBorder.width or 0) > 0 then
        love.graphics.setColor(thumbBorder.color)
        love.graphics.setLineWidth(thumbBorder.width)
        love.graphics.circle("line", -w/2 + w*(((self.fill or 0)-(self.min or 0))/((self.max or 1)-(self.min or 0))), 0, thumbSize/2*h)
    end

    if ShowDebugInfo then
        love.graphics.setLineWidth(2)
        love.graphics.setColor(1,1,1)
        love.graphics.rectangle("line", -w/2, -h/2, w, h)
        local thumbX = w*(((self.fill or 0)-(self.min or 0))/((self.max or 1)-(self.min or 0)))
        local thumbSize = self.thumbSize or 1
        love.graphics.rectangle("line", -w/2+thumbX-thumbSize/2*h, -thumbSize/2*h, (-w/2+thumbX+thumbSize/2*h)-(-w/2+thumbX-thumbSize/2*h), (thumbSize/2*h)-(-thumbSize/2*h))
    end

    love.graphics.setColor(r,g,b,a)
    love.graphics.setLineWidth(lw)
end

function UI.Slider:drawSelectedInstance()
    local w = (type(self.width) == "function" and self.width(self)) or (self.width or 0)
    local h = (type(self.height) == "function" and self.height(self)) or (self.height or 0)
    
    local thumbSize = self.thumbSize or 1

    if type(thumbSize) == "function" then thumbSize = thumbSize(self) end
    
    love.graphics.setLineWidth(8)
    love.graphics.setColor(0,0,0)
    love.graphics.circle("line", -w/2 + w*(((self.fill or 0)-(self.min or 0))/((self.max or 1)-(self.min or 0))), 0, thumbSize/2*h)
    love.graphics.setLineWidth(4)
    love.graphics.setColor(1,1,1)
    love.graphics.circle("line", -w/2 + w*(((self.fill or 0)-(self.min or 0))/((self.max or 1)-(self.min or 0))), 0, thumbSize/2*h)
end

function UI.Slider:touchInstance(mx,my)
    self:clickInstance(mx,my,1)
    return true -- dont allow scroll
end

function UI.Slider:clickInstance(mx,my,b)
    if b == 1 then
        local w = (type(self.width) == "function" and self.width(self)) or (self.width or 0)
        local h = (type(self.height) == "function" and self.height(self)) or (self.height or 0)
        
        local thumbX = w*(((self.fill or 0)-(self.min or 0))/((self.max or 1)-(self.min or 0)))
        local thumbSize = self.thumbSize or 1
        if mx >= -w/2+thumbX-thumbSize/2*h and mx < -w/2+thumbX+thumbSize/2*h and my >= -thumbSize/2*h and my < thumbSize/2*h then
            self.grabThumb = true
        else
            local pos = mx-(-w/2)
            self.fill = math.max((self.min or 0),math.min((self.max or 1), ((self.max or 1)-(self.min or 0))*pos/w+(self.min or 0)))
            if self.step then
                self.fill = math.floor(self.fill*self.step)/self.step
            end
            if type(self.onvaluechanged) == "function" then
                self:onvaluechanged(self.fill)
            end
            self.grabThumb = true
        end
    end
end

function UI.Slider:mousemoveInstance(mx,my,dx,dy)
    if self.grabThumb then
        local w = (type(self.width) == "function" and self.width(self)) or (self.width or 0)
        local pos = mx-(-w/2)
        self.fill = math.max((self.min or 0),math.min((self.max or 1), ((self.max or 1)-(self.min or 0))*pos/w+(self.min or 0)))
        if self.step then
            self.fill = math.floor(self.fill*self.step)/self.step
        end
        if type(self.onvaluechanged) == "function" then
            self:onvaluechanged(self.fill)
        end
    end
end

function UI.Slider:release(mx,my,b)
    self.grabThumb = false
end

--#endregion

--#region ColorPicker

UI.ColorPicker = UI.Element:new({canSelect = true})

local colorPick = love.graphics.newShader("assets/shaders/color.glsl")
local blank = love.graphics.newImage("assets/images/ui/blank.png")

function UI.ColorPicker:drawInstance()
    local w = (type(self.width) == "function" and self.width(self)) or (self.width or 0)
    local h = (type(self.height) == "function" and self.height(self)) or (self.height or 0)
    
    local barWidth = self.barWidth or 32
    if type(barWidth) == "function" then barWidth = barWidth(self) end
        
    local previewHeight = self.previewHeight or 32
    if type(previewHeight) == "function" then previewHeight = previewHeight(self) end

    local mainWidth = w-barWidth-8
    local mainHeight = h-previewHeight-8

    local r,g,b,a = love.graphics.getColor()
    local lw = love.graphics.getLineWidth()
    local shader = love.graphics.getShader()

    love.graphics.setColor(1,1,1)
    love.graphics.setShader(colorPick)
    colorPick:send("hue", self.hue or 0)
    colorPick:send("justColor", false)
    colorPick:send("justHue", false)
    love.graphics.draw(blank, -w/2, -h/2, 0, mainWidth, mainHeight)
    colorPick:send("justHue", true)
    love.graphics.draw(blank, -w/2+mainWidth+8, -h/2, 0, barWidth, mainHeight)
    colorPick:send("hsv", {self.hue or 0, self.saturation or 0, self.value or 0})
    colorPick:send("justColor", true)
    love.graphics.draw(blank, -w/2, -h/2+mainHeight+8, 0, w, previewHeight)
    love.graphics.setShader(shader)
    love.graphics.setColor(1,1,1)
    love.graphics.circle("line", -w/2+(self.saturation or 0)*mainWidth, -h/2+(1-(self.value or 0))*mainHeight, 4)
    love.graphics.setLineWidth(2)
    love.graphics.rectangle("line", -w/2+mainWidth+8, -h/2+(1-(self.hue or 0))*mainHeight-2, barWidth, 4)
    love.graphics.rectangle("line", -w/2+1, -h/2+mainHeight+8+1, w-2, previewHeight-2)

    if ShowDebugInfo then
        love.graphics.setLineWidth(2)
        love.graphics.setColor(1,1,1)
        love.graphics.rectangle("line", -w/2, -h/2, w, h)
    end

    love.graphics.setColor(r,g,b,a)
    love.graphics.setLineWidth(lw)
end

function UI.ColorPicker:touchInstance(mx,my)
    self:clickInstance(mx,my,1)
    return true -- dont allow scroll
end

function UI.ColorPicker:clickInstance(mx,my,b)
    if b == 1 then
        local w = (type(self.width) == "function" and self.width(self)) or (self.width or 0)
        local h = (type(self.height) == "function" and self.height(self)) or (self.height or 0)
        
        local barWidth = self.barWidth or 32
        if type(barWidth) == "function" then barWidth = barWidth(self) end
        
        local previewHeight = self.previewHeight or 32
        if type(previewHeight) == "function" then previewHeight = previewHeight(self) end

        local mainWidth = w-barWidth-8
        local mainHeight = h-previewHeight-8
        
        local colorChanged = false

        if mx >= -w/2 and mx < -w/2+mainWidth and my >= -h/2 and my < -h/2+mainHeight then
            local saturation = (mx+w/2)/mainWidth
            local value = (my+h/2)/mainHeight
            
            self.saturation = math.max(0, math.min(1, saturation))
            self.value = 1-math.max(0, math.min(1, value))

            colorChanged = true

            self.grabMain = true
        end
        
        if mx >= -w/2+mainWidth+8 and mx < w/2 and my >= -h/2 and my < -h/2+mainHeight then
            local hue = math.max(0,math.min(1,(my+h/2)/mainHeight))
            self.hue = 1-hue

            colorChanged = true

            self.grabBar = true
        end

        if colorChanged and type(self.oncolorchanged) == "function" then self:oncolorchanged({self.hue or 0, self.saturation or 0, self.value or 0}, {hsx.hsv2rgb(self.hue or 0, self.saturation or 0, self.value or 0)}) end
    end
end

function UI.ColorPicker:mousemoveInstance(mx,my,dx,dy)
    local w = (type(self.width) == "function" and self.width(self)) or (self.width or 0)
    local h = (type(self.height) == "function" and self.height(self)) or (self.height or 0)
    
    local barWidth = self.barWidth or 32
    if type(barWidth) == "function" then barWidth = barWidth(self) end
        
    local previewHeight = self.previewHeight or 32
    if type(previewHeight) == "function" then previewHeight = previewHeight(self) end

    local mainWidth = w-barWidth-8
    local mainHeight = h-previewHeight-8
    
    local colorChanged = false

    if self.grabMain then
        local saturation = (mx+w/2)/mainWidth
        local value = (my+h/2)/mainHeight
        
        self.saturation = math.max(0, math.min(1, saturation))
        self.value = 1-math.max(0, math.min(1, value))

        colorChanged = true
    end

    if self.grabBar then
        local hue = math.max(0,math.min(1,(my+h/2)/mainHeight))
        
        self.hue = 1-hue

        colorChanged = true
    end

    if colorChanged and type(self.oncolorchanged) == "function" then self:oncolorchanged({self.hue or 0, self.saturation or 0, self.value or 0}, self:getRGB()) end
end

function UI.ColorPicker:release(mx,my,b)
    self.grabMain = false
    self.grabBar = false
end

function UI.ColorPicker:getRGB()
    return {hsx.hsv2rgb(self.hue or 0, self.saturation or 0, self.value or 0)}
end

function UI.ColorPicker:getHSV()
    return {self.hue or 0, self.saturation or 0, self.value or 0}
end

function UI.ColorPicker:setRGB(r,g,b)
    self.hue, self.saturation, self.value = hsx.rgb2hsv(r,g,b)
end

function UI.ColorPicker:setHSV(h,s,v)
    self.hue, self.saturation, self.value = h, s, v
end

--#endregion

--#region Player Display

UI.PlayerDisplay = UI.Element:new({})

function UI.PlayerDisplay:drawInstance()
    local w = (type(self.width) == "function" and self.width(self)) or (self.width or 0)
    local h = (type(self.height) == "function" and self.height(self)) or (self.height or 0)

    local r,g,b,a = love.graphics.getColor()

    local data = self.data or {}

    if type(data) == "function" then data = data(self) end
    
    love.graphics.push()
    local c = Camera
    Camera = {x = 0, y = 0, tx = 0, ty = 0}
    love.graphics.translate(Camera.x-love.graphics.getWidth()/2,Camera.y-love.graphics.getHeight()/2)
    EntityTypes.player.draw({x = 0, y = 0, hp = 100, maxhp = 100, get = Game.Entity.get, set = Game.Entity.set, data = data, hidehp = true})
    Camera = c
    love.graphics.pop()

    if ShowDebugInfo then
        local lw = love.graphics.getLineWidth()
        love.graphics.setLineWidth(2)
        love.graphics.setColor(1,1,1)
        love.graphics.rectangle("line", -w/2, -h/2, w, h)
        love.graphics.setLineWidth(lw)
    end

    love.graphics.setColor(r,g,b,a)
end

--#endregion

--#region Scrollable Panel

UI.ScrollablePanel = UI.Element:new({})

function UI.ScrollablePanel:draw(stencilValue)
    stencilValue = stencilValue or 0
    local x = (type(self.x) == "function" and self.x(self)) or (self.x or 0)
    local y = (type(self.y) == "function" and self.y(self)) or (self.y or 0)
    
    local w = (type(self.width) == "function" and self.width(self)) or (self.width or 0)
    local h = (type(self.height) == "function" and self.height(self)) or (self.height or 0)

    love.graphics.push()
    love.graphics.translate(x, y)

    if not self.hidden then
        local function draw()
            if type(self.drawInstance) == "function" then
                self:drawInstance()
            end
        end

        draw()

        love.graphics.stencil(draw, "increment")
        stencilValue = stencilValue + 1
        love.graphics.push()
        love.graphics.translate(-(self.scrollX or 0), -(self.scrollY or 0))

        for _,child in ipairs(type(self.children) == "table" and self.children or {}) do
            if type(child) == "table" and type(child.draw) == "function" then
                love.graphics.setStencilTest("gequal", stencilValue)
                child:draw(stencilValue)
                love.graphics.setStencilTest()
            end
        end

        love.graphics.pop()
        love.graphics.stencil(draw, "decrement")
    end

    love.graphics.pop()

    -- * hacky fix * --

    local children = self:unpackChildrenDefault(0,0)
    local hasSelectedChild = false
    local selection = MenuSelection
    if Dialogs[1] then
        selection = Dialogs[1].selection
    end
    for _,child in ipairs(children) do
        if child.element == (selection or {}).element then
            hasSelectedChild = true
        end
    end

    if Gamepads[1] then
        local scrollValue = Gamepads[1]:getGamepadAxis("righty")
        if math.abs(scrollValue) >= 0.2 then
            if hasSelectedChild then
                local _,u_pos = self:getHighestPoint()
                local _,d_pos = self:getLowestPoint()
                local minScrollY = math.min(0,u_pos+h/2)
                local maxScrollY = math.max(0,d_pos-h/2)
                local lastScrollY = self.scrollY
                self.scrollY = math.max(minScrollY, math.min(maxScrollY, (self.scrollY or 0) + scrollValue*512*love.timer.getDelta()))
                selection.y = selection.y-(self.scrollY-lastScrollY)
            end
        end
    end
end

function UI.ScrollablePanel:drawSelected()
    local x = (type(self.x) == "function" and self.x(self)) or (self.x or 0)
    local y = (type(self.y) == "function" and self.y(self)) or (self.y or 0)
    
    local w = (type(self.width) == "function" and self.width(self)) or (self.width or 0)
    local h = (type(self.height) == "function" and self.height(self)) or (self.height or 0)

    love.graphics.push()
    love.graphics.translate(x, y)

    if not self.hidden then
        local selection = MenuSelection
        if Dialogs[1] then selection = Dialogs[1].selection or selection end
        
        local function draw()
            if type(self.drawInstance) == "function" then
                self:drawInstance()
            end
        end

        if type(self.drawSelectedInstance) == "function" and self == selection.element then
            self:drawSelectedInstance()
        end

        love.graphics.stencil(draw, "increment")

        love.graphics.push()
        love.graphics.translate(-(self.scrollX or 0), -(self.scrollY or 0))

        for _,child in ipairs(type(self.children) == "table" and self.children or {}) do
            if type(child) == "table" and type(child.draw) == "function" then
                love.graphics.setStencilTest("gequal", 1)
                child:drawSelected()
                love.graphics.setStencilTest()
            end
        end

        love.graphics.pop()
        love.graphics.stencil(draw, "decrement")
    end

    love.graphics.pop()
end

function UI.ScrollablePanel:drawInstance()
    local w = (type(self.width) == "function" and self.width(self)) or (self.width or 0)
    local h = (type(self.height) == "function" and self.height(self)) or (self.height or 0)
    
    local background = self.background or {1,1,1}
    local border = self.border or {color = {1,1,1}, width = 0}
    local rounding = self.rounding or 0

    if type(background) == "function" then background = background(self) end
    if type(border) == "function" then border = border(self) end
    if type(rounding) == "function" then rounding = rounding(self) end

    local r,g,b,a = love.graphics.getColor()
    local lw = love.graphics.getLineWidth()

    if type(background) == "table" then
        love.graphics.setColor(background)
        love.graphics.rectangle("fill", -w/2, -h/2, w, h)
    elseif type(background.getWidth) == "function" then
        love.graphics.setColor(1,1,1)
        love.graphics.draw(background, -w/2, -h/2, 0, w/background:getWidth(), h/background:getHeight())
    end

    local _,u_pos = self:getHighestPoint()
    local _,d_pos = self:getLowestPoint()
    local _,l_pos = self:getLeftmostPoint()
    local _,r_pos = self:getRightmostPoint()
    local minScrollY = math.min(0,u_pos+h/2)
    local maxScrollY = math.max(0,d_pos-h/2)
    local minScrollX = math.min(0,l_pos+w/2)
    local maxScrollX = math.max(0,r_pos-w/2)
    local minScrollY2 = math.min(0,u_pos)
    local maxScrollY2 = math.max(0,d_pos)
    local minScrollX2 = math.min(0,l_pos)
    local maxScrollX2 = math.max(0,r_pos)
    local scrollDiff = maxScrollY-minScrollY
    local scrollDiff2 = maxScrollY2-minScrollY2
    local scrollFrac = ((self.scrollY or 0)+minScrollY)/scrollDiff
    if scrollDiff2 > h then
        love.graphics.setColor(0.25,0.25,0.25)
        love.graphics.rectangle("fill", w/2, -h/2, 8, h)
        love.graphics.setColor(1,1,1)
        local barH = h/math.max(h,scrollDiff2)*h
        love.graphics.rectangle("fill", w/2, -h/2+scrollFrac*(h-barH), 8, barH)
    end

    if border and (border.width or 0) > 0 then
        love.graphics.setColor(border.color or {1,1,1})
        love.graphics.setLineWidth(border.width or 0)
        love.graphics.rectangle("line", -w/2, -h/2, w, h, rounding)
    end

    if ShowDebugInfo then
        love.graphics.setLineWidth(2)
        love.graphics.setColor(1,1,1)
        love.graphics.rectangle("line", -w/2, -h/2, w, h)
    end

    love.graphics.setColor(r,g,b,a)
    love.graphics.setLineWidth(lw)
end

function UI.ScrollablePanel:click(mx,my,b)
    local x = (type(self.x) == "function" and self.x(self)) or (self.x or 0)
    local y = (type(self.y) == "function" and self.y(self)) or (self.y or 0)
    
    local w = (type(self.width) == "function" and self.width(self)) or (self.width or 0)
    local h = (type(self.height) == "function" and self.height(self)) or (self.height or 0)

    if self.clickThrough or self.hidden then
        return false, self
    end

    local children = (type(self.children) == "table" and self.children or {})
    for i = #children, 1, -1 do
        local child = children[i]
        if type(child) == "table" and type(child.click) == "function" then
            local clicked = child:click(mx-x+(self.scrollX or 0),my-y+(self.scrollY or 0),b)
            if clicked then
                return clicked,child
            end
        end
    end
    
    if mx-x >= -w/2 and mx-x < w/2 and my-y >= -h/2 and my-y < h/2 then
        if (not self.disabled) and type(self.clickInstance) == "function" then self:clickInstance(mx-x,my-y,b) end
        return true, self
    end
    return false, self
end

function UI.ScrollablePanel:scroll(mx,my,sx,sy)
    local x = (type(self.x) == "function" and self.x(self)) or (self.x or 0)
    local y = (type(self.y) == "function" and self.y(self)) or (self.y or 0)
    
    local w = (type(self.width) == "function" and self.width(self)) or (self.width or 0)
    local h = (type(self.height) == "function" and self.height(self)) or (self.height or 0)

    if self.scrollThrough or self.hidden then
        return false, self
    end

    local children = (type(self.children) == "table" and self.children or {})
    for i = #children, 1, -1 do
        local child = children[i]
        if type(child) == "table" and type(child.scroll) == "function" then
            local scrolled = child:scroll(mx-x+(self.scrollX or 0),my-y+(self.scrollY or 0),sx,sy)
            if scrolled then
                return scrolled, child
            end
        end
    end
    
    if (not self.disabled) and type(self.scrollInstance) == "function" then self:scrollInstance(mx-x,my-y,sx,sy) end
    return mx-x >= -w/2 and mx-x < w/2 and my-y >= -h/2 and my-y < h/2, self
end

function UI.ScrollablePanel:scrollInstance(mx,my,sx,sy)
    local w = (type(self.width) == "function" and self.width(self)) or (self.width or 0)
    local h = (type(self.height) == "function" and self.height(self)) or (self.height or 0)

    local _,u_pos = self:getHighestPoint()
    local _,d_pos = self:getLowestPoint()
    local _,l_pos = self:getLeftmostPoint()
    local _,r_pos = self:getRightmostPoint()
    local minScrollY = math.min(0,u_pos+h/2)
    local maxScrollY = math.max(0,d_pos-h/2)
    local minScrollX = math.min(0,l_pos+w/2)
    local maxScrollX = math.max(0,r_pos-w/2)
    self.scrollX = math.max(minScrollX, math.min(maxScrollX, (self.scrollX or 0) - sx*16))
    self.scrollY = math.max(minScrollY, math.min(maxScrollY, (self.scrollY or 0) - sy*16))
end

function UI.ScrollablePanel:mousemove(mx,my,dx,dy)
    local x = (type(self.x) == "function" and self.x(self)) or (self.x or 0)
    local y = (type(self.y) == "function" and self.y(self)) or (self.y or 0)
    
    local w = (type(self.width) == "function" and self.width(self)) or (self.width or 0)
    local h = (type(self.height) == "function" and self.height(self)) or (self.height or 0)

    if self.hidden then
        return false, self
    end

    local children = (type(self.children) == "table" and self.children or {})
    for i = #children, 1, -1 do
        local child = children[i]
        if type(child) == "table" and type(child.mousemove) == "function" then
            local moved = child:mousemove(mx-x+(self.scrollX or 0),my-y+(self.scrollY or 0),dx,dy)
            if moved then
                return moved, child
            end
        end
    end
    
    if (not self.disabled) and type(self.mousemoveInstance) == "function" then self:mousemoveInstance(mx-x,my-y,dx,dy) end
    return mx-x >= -w/2 and mx-x < w/2 and my-y >= -h/2 and my-y < h/2, self
end

function UI.ScrollablePanel:getCursor(mx,my)
    local x = (type(self.x) == "function" and self.x(self)) or (self.x or 0)
    local y = (type(self.y) == "function" and self.y(self)) or (self.y or 0)
    
    local w = (type(self.width) == "function" and self.width(self)) or (self.width or 0)
    local h = (type(self.height) == "function" and self.height(self)) or (self.height or 0)
    
    if self.hidden or self.clickThrough then
        return nil
    end

    local children = (type(self.children) == "table" and self.children or {})
    for i = #children, 1, -1 do
        local child = children[i]
        if type(child) == "table" and type(child.getCursor) == "function" then
            local cursor = child:getCursor(mx-x+(self.scrollX or 0),my-y+(self.scrollY or 0))
            if cursor then
                return cursor
            end
        end
    end
    
    if mx-x >= -w/2 and mx-x < w/2 and my-y >= -h/2 and my-y < h/2 then
        return self.cursor
    end
    return nil
end

UI.ScrollablePanel.unpackChildrenDefault = UI.Element.unpackChildren

function UI.ScrollablePanel:getSelectionTarget(dir,selection)
    local elements = self:unpackChildrenDefault() or {}
    local sort = {}
    for _,elem in ipairs(elements) do
        if elem.element ~= selection.element and elem.element.canSelect then
            local ox,oy = elem.x-selection.x, elem.y-selection.y
            local distance = math.sqrt(ox*ox+oy*oy)
            local m = (distance == 0 and 1 or distance)
            local nx,ny = ox/m,oy/m
            local parallel = math.dot(dir, {nx,ny})
            if parallel > 0 then
                local weight = (parallel^8*math.sign(parallel)) * 1/(distance/16)
                table.insert(sort, {element = elem, weight = weight})
            end
        end
    end
    if #sort == 0 then return nil end
    table.sort(sort, function (a, b)
        if b.weight == a.weight then
            if b.element.y == a.element.y then
                return b.element.x > a.element.x
            end
            return b.element.y > a.element.y
        end
        return b.weight < a.weight
    end)
    
    local w = (type(self.width) == "function" and self.width(self)) or (self.width or 0)
    local h = (type(self.height) == "function" and self.height(self)) or (self.height or 0)

    local lowest,lowy = sort[1].element.element:getLowestPoint()
    local highest,highy = sort[1].element.element:getHighestPoint()
    local sely = (type(sort[1].element.element.y) == "function" and sort[1].element.element.y(sort[1].element.element)) or (sort[1].element.element.y or 0)
    lowy = lowy + sely - self.scrollY
    highy = highy + sely - self.scrollY
    local isBelow = lowy > h/2
    local isAbove = highy < -h/2
    local target = self.scrollY
    if isAbove and isBelow then
        -- Target = middle
        target = ((lowy) + ((highy))) / 2 + self.scrollY
    elseif isAbove then
        -- Target = top
        target = lowy + self.scrollY
    elseif isBelow then
        -- Target = bottom
        target = highy + self.scrollY
    end

    if target ~= self.scrollY then
        self.scrollY = target
    end

    return sort[1].element
end

function UI.ScrollablePanel:unpackChildren(ox,oy,isChild,intent)
    if intent == 1 then
        self.scrollX = 0
        self.scrollY = 0
        return self:unpackChildrenDefault(ox,oy,isChild)
    end

    return {}
end

--#endregion

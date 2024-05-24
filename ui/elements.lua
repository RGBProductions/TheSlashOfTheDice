---@diagnostic disable: duplicate-set-field

--#region Button

UI.Button = UI.Element:new({})

function UI.Button:drawInstance()
    local w = (type(self.width) == "function" and self.width(self)) or (self.width or 0)
    local h = (type(self.height) == "function" and self.height(self)) or (self.height or 0)
    
    local background = self.background or {1,1,1}
    local border = self.border or {color = {1,1,1}, width = 0}
    local rounding = self.rounding or 0

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

--#endregion

--#region Text

UI.Text = UI.Element:new({})

function UI.Text:drawInstance()
    local w = (type(self.width) == "function" and self.width(self)) or (self.width or 0)
    local h = (type(self.height) == "function" and self.height(self)) or (self.height or 0)
    
    local color = self.color or {1,1,1}
    local font = self.font or lgfont

    local r,g,b,a = love.graphics.getColor()
    local oldFont = love.graphics.getFont()

    love.graphics.setColor(color)
    love.graphics.setFont(font)
    local maxWidth,lines = font:getWrap(self.text, w)
    local y = 0
    if self.alignVert == "center" then
        y = (h-(#lines*font:getHeight()))/2
    end
    if self.alignVert == "bottom" then
        y = h-(#lines*font:getHeight())
    end
    love.graphics.printf(self.text, -w/2, -h/2+y, w, self.alignHoriz)

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

    love.graphics.setColor(self.tint or {1,1,1})
    love.graphics.draw(self.image, -w/2, -h/2, 0, w/self.image:getWidth(), h/self.image:getHeight())

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

--#region Slider

UI.Slider = UI.Element:new({})

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
        if type(self.onvaluechanged) == "function" then
            self:onvaluechanged(self.fill)
        end
    end
end

function UI.Slider:release(mx,my,b)
    self.grabThumb = false
end

--#endregion


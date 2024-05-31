---@diagnostic disable: duplicate-set-field

--#region Button

UI.Button = UI.Element:new({})

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

function UI.Button:clickInstance(mx,my,b)
    if type(self.onclick) == "function" then self:onclick(mx,my,b) end
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

UI.ColorPicker = UI.Element:new({})

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


---@diagnostic disable: duplicate-set-field

UI.Button = UI.Element:new({})

function UI.Button:drawInstance()
    local w = (type(self.width) == "function" and self.width(self)) or (self.width or 0)
    local h = (type(self.height) == "function" and self.height(self)) or (self.height or 0)
    
    local background = self.background or {1,1,1}
    local border = self.border or {color = {1,1,1}, width = 0}
    local rounding = self.rounding or 0

    local r,g,b,a = love.graphics.getColor()

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

    love.graphics.setColor(r,g,b,a)
end
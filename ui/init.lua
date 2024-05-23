UI = {}

--#region Base Element

UI.Element = {}

function UI.Element:new(data)
    data = (type(data) == "table" and data) or {}

    local element = setmetatable(data, self)

    self.__index = self -- assign the index to this element
    return element
end

function UI.Element:draw()
    local x = (type(self.x) == "function" and self.x(self)) or (self.x or 0)
    local y = (type(self.y) == "function" and self.y(self)) or (self.y or 0)
    
    local w = (type(self.width) == "function" and self.width(self)) or (self.width or 0)
    local h = (type(self.height) == "function" and self.height(self)) or (self.height or 0)

    love.graphics.push()
    love.graphics.translate(x, y)

    if type(self.drawInstance) == "function" then
        self:drawInstance()
    end

    for _,child in ipairs(type(self.children) == "table" and self.children or {}) do
        if type(child) == "table" and type(child.draw) == "function" then
            child:draw()
        end
    end

    love.graphics.pop()
end

function UI.Element:click(mx,my,b)
    local x = (type(self.x) == "function" and self.x(self)) or (self.x or 0)
    local y = (type(self.y) == "function" and self.y(self)) or (self.y or 0)
    
    local w = (type(self.width) == "function" and self.width(self)) or (self.width or 0)
    local h = (type(self.height) == "function" and self.height(self)) or (self.height or 0)

    for _,child in ipairs(type(self.children) == "table" and self.children or {}) do
        if type(child) == "table" and type(child.click) == "function" then
            local clicked = child:click(mx-x,my-y,b)
            if clicked then
                return clicked,child
            end
        end
    end
    
    return mx-x >= -w/2 and mx-x < w/2 and my-y >= -h/2 and my-y < h/2, self
end

function UI.Element:scroll(mx,my,sx,sy)
    local x = (type(self.x) == "function" and self.x(self)) or (self.x or 0)
    local y = (type(self.y) == "function" and self.y(self)) or (self.y or 0)
    
    local w = (type(self.width) == "function" and self.width(self)) or (self.width or 0)
    local h = (type(self.height) == "function" and self.height(self)) or (self.height or 0)

    for _,child in ipairs(type(self.children) == "table" and self.children or {}) do
        if type(child) == "table" and type(child.scroll) == "function" then
            local scrolled = child:scroll(mx-x,my-y,sx,sy)
            if scrolled then
                return scrolled, child
            end
        end
    end
    
    return mx-x >= -w/2 and mx-x < w/2 and my-y >= -h/2 and my-y < h/2, self
end

function UI.Element:hover(mx,my)
    local x = (type(self.x) == "function" and self.x(self)) or (self.x or 0)
    local y = (type(self.y) == "function" and self.y(self)) or (self.y or 0)
    
    local w = (type(self.width) == "function" and self.width(self)) or (self.width or 0)
    local h = (type(self.height) == "function" and self.height(self)) or (self.height or 0)

    for _,child in ipairs(type(self.children) == "table" and self.children or {}) do
        if type(child) == "table" and type(child.hover) == "function" then
            local hovered = child:hover(mx-x,my-y)
            if hovered then
                return hovered, child
            end
        end
    end
    
    return mx-x >= -w/2 and mx-x < w/2 and my-y >= -h/2 and my-y < h/2, self
end

--#endregion

require "ui.elements"
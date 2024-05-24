UI = {}

function Color(code)
    local t = type(code)
    if t == "table" then return code end
    if t == "nil" then return {0,0,0} end
    if t == "function" then return code() end
    if code:sub(1,1) == "#" then code = code:sub(2,-1) end
    local r = tonumber(code:sub(1,2), 16)
    local g = tonumber(code:sub(3,4), 16)
    local b = tonumber(code:sub(5,6), 16)
    return {r/255,g/255,b/255}
end

--#region Base Element

UI.Element = {}

function UI.Element:new(data)
    data = (type(data) == "table" and data) or {}

    local element = setmetatable(data, self)
    if element.children then
        for _,child in ipairs(element.children) do
            if type(child) == "table" then
                child.parent = element
            end
        end
    end

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

function UI.Element:drawInstance()
    if ShowDebugInfo then
        local r,g,b,a = love.graphics.getColor()
        local lw = love.graphics.getLineWidth()
        local w = (type(self.width) == "function" and self.width(self)) or (self.width or 0)
        local h = (type(self.height) == "function" and self.height(self)) or (self.height or 0)
        love.graphics.setLineWidth(2)
        love.graphics.setColor(1,1,1)
        love.graphics.rectangle("line", -w/2, -h/2, w, h)
        love.graphics.setLineWidth(lw)
        love.graphics.setColor(r,g,b,a)
    end
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
    
    if mx-x >= -w/2 and mx-x < w/2 and my-y >= -h/2 and my-y < h/2 then
        if (not self.disabled) and type(self.clickInstance) == "function" then self:clickInstance(mx-x,my-y,b) end
        return true, self
    end
    return false, self
end

function UI.Element:clickInstance(mx,my,b) end

function UI.Element:release(mx,my,b)
    local x = (type(self.x) == "function" and self.x(self)) or (self.x or 0)
    local y = (type(self.y) == "function" and self.y(self)) or (self.y or 0)
    
    local w = (type(self.width) == "function" and self.width(self)) or (self.width or 0)
    local h = (type(self.height) == "function" and self.height(self)) or (self.height or 0)

    for _,child in ipairs(type(self.children) == "table" and self.children or {}) do
        if type(child) == "table" and type(child.release) == "function" then
            local released = child:release(mx-x,my-y,b)
            -- if released then
            --     return released,child
            -- end
        end
    end
    
    if (not self.disabled) and type(self.releaseInstance) == "function" then self:releaseInstance(mx,my,b) end
    return true,self
    -- return mx-x >= -w/2 and mx-x < w/2 and my-y >= -h/2 and my-y < h/2, self
end

function UI.Element:releaseInstance(mx,my,b) end

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
    
    if (not self.disabled) and type(self.scrollInstance) == "function" then self:scrollInstance(mx,my,sx,sy) end
    return mx-x >= -w/2 and mx-x < w/2 and my-y >= -h/2 and my-y < h/2, self
end

function UI.Element:scrollInstance(mx,my,sx,sy) end

function UI.Element:mousemove(mx,my,dx,dy)
    local x = (type(self.x) == "function" and self.x(self)) or (self.x or 0)
    local y = (type(self.y) == "function" and self.y(self)) or (self.y or 0)
    
    local w = (type(self.width) == "function" and self.width(self)) or (self.width or 0)
    local h = (type(self.height) == "function" and self.height(self)) or (self.height or 0)

    for _,child in ipairs(type(self.children) == "table" and self.children or {}) do
        if type(child) == "table" and type(child.mousemove) == "function" then
            local moved = child:mousemove(mx-x,my-y,dx,dy)
            if moved then
                return moved, child
            end
        end
    end
    
    if (not self.disabled) and type(self.mousemoveInstance) == "function" then self:mousemoveInstance(mx,my,dx,dy) end
    return mx-x >= -w/2 and mx-x < w/2 and my-y >= -h/2 and my-y < h/2, self
end

function UI.Element:mousemoveInstance(mx,my,dx,dy) end

function UI.Element:getChildById(id,dontRecurse)
    for _,child in ipairs(self.children or {}) do
        if type(child) == "table" then
            if child.id == id then
                return child
            elseif (not dontRecurse) then
                local found = child:getChildById(id)
                if found then
                    return found
                end
            end
        end
    end
    return nil
end

--#endregion

require "ui.elements"
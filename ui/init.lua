UI = {}

function Color(code)
    local t = type(code)
    if t == "nil" then return {0,0,0} end
    if t == "number" then return {code,code,code} end
    if t == "table" then return code end
    if t == "function" then return code() end
    if code:sub(1,1) == "#" then code = code:sub(2,-1) end
    if #code == 3 then code = code:sub(1,1):rep(2) .. code:sub(2,2):rep(2) .. code:sub(3,3):rep(2) end
    local r = tonumber(code:sub(1,2), 16)
    local g = tonumber(code:sub(3,4), 16)
    local b = tonumber(code:sub(5,6), 16)
    return {r/255,g/255,b/255}
end

function HexCodeOf(r,g,b)
    local R = string.format("%x", math.floor(r*255+0.5)):upper()
    local G = string.format("%x", math.floor(g*255+0.5)):upper()
    local B = string.format("%x", math.floor(b*255+0.5)):upper()
    R = ("0"):rep(2-#R)..R
    G = ("0"):rep(2-#G)..G
    B = ("0"):rep(2-#B)..B
    return "#"..R..G..B
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

    if type(element.initInstance) == "function" then
        element:initInstance()
    end

    return element
end

function UI.Element:initInstance() end

function UI.Element:setParent(parent, i)
    if self.parent then
        local j = table.index(self.parent.children, self)
        if j then
            table.remove(self.parent.children, j)
        end
    end
    self.parent = parent
    if parent then
        table.insert(parent.children, i or #parent.children+1, self)
    end
end

function UI.Element:addChild(child, i)
    child:setParent(self, i)
end

function UI.Element:removeChild(child)
    if child.parent == self then
        child:setParent(nil)
    end
end

function UI.Element:draw(stencilValue)
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

function UI.Element:drawSelected(selection)
    local x = (type(self.x) == "function" and self.x(self)) or (self.x or 0)
    local y = (type(self.y) == "function" and self.y(self)) or (self.y or 0)
    
    local w = (type(self.width) == "function" and self.width(self)) or (self.width or 0)
    local h = (type(self.height) == "function" and self.height(self)) or (self.height or 0)

    love.graphics.push()
    love.graphics.translate(x, y)

    if not self.hidden then
        if Dialogs[1] then
            selection = selection or Dialogs[1].selection
        else
            selection = selection or MenuSelection
        end
        if type(self.drawSelectedInstance) == "function" and self == selection.element then
            self:drawSelectedInstance(selection)
        end

        for _,child in ipairs(type(self.children) == "table" and self.children or {}) do
            if type(child) == "table" and type(child.draw) == "function" then
                child:drawSelected(selection)
            end
        end
    end

    love.graphics.pop()
end

function UI.Element:drawSelectedInstance(selection) end

function UI.Element:click(mx,my,b)
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
    end
    return false, self
end

function UI.Element:clickInstance(mx,my,b) end

function UI.Element:touch(mx,my)
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
        if type(child) == "table" and type(child.touch) == "function" then
            local clicked,_,v = child:touch(mx-x,my-y)
            if clicked then
                return clicked,child,v
            end
        end
    end
    
    if mx-x >= -w/2 and mx-x < w/2 and my-y >= -h/2 and my-y < h/2 then
        local v
        if (not self.disabled) and type(self.touchInstance) == "function" then v = self:touchInstance(mx-x,my-y) end
        return true, self, v
    end
    return false, self, nil
end

function UI.Element:touchInstance(mx,my,b) end

function UI.Element:release(mx,my,b)
    local x = (type(self.x) == "function" and self.x(self)) or (self.x or 0)
    local y = (type(self.y) == "function" and self.y(self)) or (self.y or 0)
    
    local w = (type(self.width) == "function" and self.width(self)) or (self.width or 0)
    local h = (type(self.height) == "function" and self.height(self)) or (self.height or 0)

    local children = (type(self.children) == "table" and self.children or {})
    for i = #children, 1, -1 do
        local child = children[i]
        if type(child) == "table" and type(child.release) == "function" then
            local released = child:release(mx-x,my-y,b)
            -- if released then
            --     return released,child
            -- end
        end
    end
    
    if (not self.disabled) and type(self.releaseInstance) == "function" then self:releaseInstance(mx-x,my-y,b) end
    return true,self
    -- return mx-x >= -w/2 and mx-x < w/2 and my-y >= -h/2 and my-y < h/2, self
end

function UI.Element:releaseInstance(mx,my,b) end

function UI.Element:keypress(k)
    local x = (type(self.x) == "function" and self.x(self)) or (self.x or 0)
    local y = (type(self.y) == "function" and self.y(self)) or (self.y or 0)
    
    local w = (type(self.width) == "function" and self.width(self)) or (self.width or 0)
    local h = (type(self.height) == "function" and self.height(self)) or (self.height or 0)

    local children = (type(self.children) == "table" and self.children or {})
    for i = #children, 1, -1 do
        local child = children[i]
        if type(child) == "table" and type(child.keypress) == "function" then
            local released = child:keypress(k)
            -- if released then
            --     return released,child
            -- end
        end
    end
    
    if (not self.disabled) and type(self.keypressInstance) == "function" then self:keypressInstance(k) end
    return true,self
    -- return mx-x >= -w/2 and mx-x < w/2 and my-y >= -h/2 and my-y < h/2, self
end

function UI.Element:keypressInstance(k) end

function UI.Element:textinput(t)
    local x = (type(self.x) == "function" and self.x(self)) or (self.x or 0)
    local y = (type(self.y) == "function" and self.y(self)) or (self.y or 0)
    
    local w = (type(self.width) == "function" and self.width(self)) or (self.width or 0)
    local h = (type(self.height) == "function" and self.height(self)) or (self.height or 0)

    local children = (type(self.children) == "table" and self.children or {})
    for i = #children, 1, -1 do
        local child = children[i]
        if type(child) == "table" and type(child.textinput) == "function" then
            local released = child:textinput(t)
            -- if released then
            --     return released,child
            -- end
        end
    end
    
    if (not self.disabled) and type(self.textinputInstance) == "function" then self:textinputInstance(t) end
    return true,self
    -- return mx-x >= -w/2 and mx-x < w/2 and my-y >= -h/2 and my-y < h/2, self
end

function UI.Element:textinputInstance(t) end

function UI.Element:scroll(mx,my,sx,sy)
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
            local scrolled = child:scroll(mx-x,my-y,sx,sy)
            if scrolled then
                return scrolled, child
            end
        end
    end
    
    if (not self.disabled) and type(self.scrollInstance) == "function" then self:scrollInstance(mx-x,my-y,sx,sy) end
    return mx-x >= -w/2 and mx-x < w/2 and my-y >= -h/2 and my-y < h/2, self
end

function UI.Element:scrollInstance(mx,my,sx,sy) end

function UI.Element:mousemove(mx,my,dx,dy)
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
            local moved = child:mousemove(mx-x,my-y,dx,dy)
            if moved then
                return moved, child
            end
        end
    end
    
    if (not self.disabled) and type(self.mousemoveInstance) == "function" then self:mousemoveInstance(mx-x,my-y,dx,dy) end
    return mx-x >= -w/2 and mx-x < w/2 and my-y >= -h/2 and my-y < h/2, self
end

function UI.Element:mousemoveInstance(mx,my,dx,dy) end

function UI.Element:getCursor(mx,my)
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
            local cursor = child:getCursor(mx-x,my-y)
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

function UI.Element:getChildByType(t,dontRecurse)
    for _,child in ipairs(self.children or {}) do
        if type(child) == "table" then
            if child.__index == t then
                return child
            elseif (not dontRecurse) then
                local found = child:getChildByType(t)
                if found then
                    return found
                end
            end
        end
    end
    return nil
end

function UI.Element:getHighestChild(dontRecurse,oy)
    oy = oy or 0
    local highest,pos = nil,math.huge
    for _,child in ipairs(self.children or {}) do
        if type(child) == "table" then
            local y = ((type(child.y) == "function" and child.y(child)) or (child.y or 0)) + oy
            if y < pos then
                highest = child
                pos = y
            end
            if (not dontRecurse) then
                local r_highest, r_pos = child:getHighestChild(dontRecurse,y)
                if r_pos < pos then
                    highest = r_highest
                    pos = r_pos
                end
            end
        end
    end
    return highest,pos
end

function UI.Element:getLowestChild(dontRecurse,oy)
    oy = oy or 0
    local lowest,pos = nil,-math.huge
    for _,child in ipairs(self.children or {}) do
        if type(child) == "table" then
            local y = ((type(child.y) == "function" and child.y(child)) or (child.y or 0)) + oy
            if y > pos then
                lowest = child
                pos = y
            end
            if (not dontRecurse) then
                local r_lowest, r_pos = child:getLowestChild(dontRecurse,y)
                if r_pos > pos then
                    lowest = r_lowest
                    pos = r_pos
                end
            end
        end
    end
    return lowest,pos
end

function UI.Element:getLeftmostChild(dontRecurse,ox)
    ox = ox or 0
    local leftmost,pos = nil,math.huge
    for _,child in ipairs(self.children or {}) do
        if type(child) == "table" then
            local x = ((type(child.x) == "function" and child.x(child)) or (child.x or 0)) + ox
            if x < pos then
                leftmost = child
                pos = x
            end
            if (not dontRecurse) then
                local r_leftmost, r_pos = child:getLeftmostChild(dontRecurse,x)
                if r_pos < pos then
                    leftmost = r_leftmost
                    pos = r_pos
                end
            end
        end
    end
    return leftmost,pos
end

function UI.Element:getRightmostChild(dontRecurse,ox)
    ox = ox or 0
    local rightest,pos = nil,-math.huge
    for _,child in ipairs(self.children or {}) do
        if type(child) == "table" then
            local x = ((type(child.x) == "function" and child.x(child)) or (child.x or 0)) + ox
            if x > pos then
                rightest = child
                pos = x
            end
            if (not dontRecurse) then
                local r_rightest, r_pos = child:getRightmostChild(dontRecurse,x)
                if r_pos > pos then
                    rightest = r_rightest
                    pos = r_pos
                end
            end
        end
    end
    return rightest,pos
end

function UI.Element:getHighestPoint(dontRecurse,oy)
    oy = oy or 0
    local h_self = (type(self.height) == "function" and self.height(self)) or (self.height or 0)
    local highest,pos = nil,-h_self/2
    for _,child in ipairs(self.children or {}) do
        if type(child) == "table" then
            local y = ((type(child.y) == "function" and child.y(child)) or (child.y or 0)) + oy
            local h = (type(child.height) == "function" and child.height(child)) or (child.height or 0)
            if y-h/2 < pos then
                highest = child
                pos = y-h/2
            end
            if (not dontRecurse) then
                local r_highest, r_pos = child:getHighestPoint(dontRecurse,y)
                if r_pos < pos then
                    highest = r_highest
                    pos = r_pos
                end
            end
        end
    end
    return highest,pos
end

function UI.Element:getLowestPoint(dontRecurse,oy)
    oy = oy or 0
    local h_self = (type(self.height) == "function" and self.height(self)) or (self.height or 0)
    local lowest,pos = nil,h_self/2
    for _,child in ipairs(self.children or {}) do
        if type(child) == "table" then
            local y = ((type(child.y) == "function" and child.y(child)) or (child.y or 0)) + oy
            local h = (type(child.height) == "function" and child.height(child)) or (child.height or 0)
            if y+h/2 > pos then
                lowest = child
                pos = y+h/2
            end
            if (not dontRecurse) then
                local r_lowest, r_pos = child:getLowestPoint(dontRecurse,y)
                if r_pos > pos then
                    lowest = r_lowest
                    pos = r_pos
                end
            end
        end
    end
    return lowest,pos
end

function UI.Element:getLeftmostPoint(dontRecurse,ox)
    ox = ox or 0
    local w_self = (type(self.width) == "function" and self.width(self)) or (self.width or 0)
    local leftmost,pos = nil,-w_self/2
    for _,child in ipairs(self.children or {}) do
        if type(child) == "table" then
            local x = ((type(child.x) == "function" and child.x(child)) or (child.x or 0)) + ox
            local w = (type(child.width) == "function" and child.width(child)) or (child.width or 0)
            if x-w/2 < pos then
                leftmost = child
                pos = x-w/2
            end
            if (not dontRecurse) then
                local r_leftmost, r_pos = child:getLeftmostPoint(dontRecurse,x)
                if r_pos < pos then
                    leftmost = r_leftmost
                    pos = r_pos
                end
            end
        end
    end
    return leftmost,pos
end

function UI.Element:getRightmostPoint(dontRecurse,ox)
    ox = ox or 0
    local w_self = (type(self.width) == "function" and self.width(self)) or (self.width or 0)
    local rightmost,pos = nil,w_self/2
    for _,child in ipairs(self.children or {}) do
        if type(child) == "table" then
            local x = ((type(child.x) == "function" and child.x(child)) or (child.x or 0)) + ox
            local w = (type(child.width) == "function" and child.width(child)) or (child.width or 0)
            if x+w/2 > pos then
                rightmost = child
                pos = x+w/2
            end
            if (not dontRecurse) then
                local r_rightmost, r_pos = child:getRightmostPoint(dontRecurse,x)
                if r_pos > pos then
                    rightmost = r_rightmost
                    pos = r_pos
                end
            end
        end
    end
    return rightmost,pos
end

function UI.Element:unpackChildren(ox,oy,isChild,intent)
    ox = ox or ((type(self.x) == "function" and self.x(self)) or (self.x or 0))
    oy = oy or ((type(self.y) == "function" and self.y(self)) or (self.y or 0))
    
    local children = {}
    for _,child in ipairs(self.children or {}) do
        local cx = ((type(child.x) == "function" and child.x(child)) or (child.x or 0))
        local cy = ((type(child.y) == "function" and child.y(child)) or (child.y or 0))
        table.insert(children, {element = child, x = cx+ox, y = cy+oy, isHighest = false, isLowest = false, isLeftmost = false, isRightmost = false})
        local subchildren = child:unpackChildren(ox+cx,oy+cy,true,intent)
        for _,sub in ipairs(subchildren) do
            table.insert(children, sub)
        end
    end

    if not isChild then
        local leftmost = self:getLeftmostChild(false,ox)
        local rightmost = self:getRightmostChild(false,ox)
        local highest = self:getHighestChild(false,oy)
        local lowest = self:getLowestChild(false,oy)

        for _,child in ipairs(children) do
            child.isLeftmost = child.element == leftmost
            child.isRightmost = child.element == rightmost
            child.isHighest = child.element == highest
            child.isLowest = child.element == lowest
        end
    end

    return children
end

function UI.Element:isHidden()
    if self.parent then
        if self.parent:isHidden() then return true end
    end
    return self.hidden == true
end

function UI.Element:getX()
    local x = (type(self.x) == "function" and self.x(self)) or (self.x or 0)
    if self.parent then
        x = x + self.parent:getX()
    end
    return x
end

function UI.Element:getY()
    local y = (type(self.y) == "function" and self.y(self)) or (self.y or 0)
    if self.parent then
        y = y + self.parent:getY()
    end
    return y
end

function UI.Element:onSelection(dir, from) end

--#endregion

require "ui.elements"
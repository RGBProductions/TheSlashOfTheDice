utf8 = require "utf8"

local typingutil = {}

---@class Input
---@field selection {[1]:integer,[2]:integer} # The full selection in the input's content. Starts at 0 (the left side of the first character) and ends at `utf8.len(content)` (the right side of the last character)
---@field content string
---@field maxLength number
---@field private __index self
local input_obj = {}
input_obj.__index = input_obj

function input_obj:getMinSelection()
    return math.min(self.selection[1], self.selection[2])
end

function input_obj:getMaxSelection()
    return math.max(self.selection[1], self.selection[2])
end

function input_obj:getSelection()
    return self:getMinSelection(),self:getMaxSelection()
end

function input_obj:getMinOffset()
    local a,b = self.selection[1],self.selection[2]
    local ao,bo = (a == 0 and 0 or utf8.offset(self.content, a)),(b == 0 and 0 or utf8.offset(self.content, b))
    return math.min(ao,bo)
end

function input_obj:getMaxOffset()
    local a,b = self.selection[1],self.selection[2]
    local ao,bo = (a == 0 and 0 or utf8.offset(self.content, a)),(b == 0 and 0 or utf8.offset(self.content, b))
    return math.max(ao,bo)
end

function input_obj:getOffset()
    return self:getMinOffset(),self:getMaxOffset()
end

function input_obj:getLength()
    return utf8.len(self.content)
end

function input_obj:hasLargeSelection()
    return self.selection[1] ~= self.selection[2]
end

function input_obj:getSelectedText()
    local a,b = self:getMinSelection(),self:getMaxSelection()
    local ao,bo = (a == 0 and 0 or utf8.offset(self.content, a)),(b == 0 and 0 or utf8.offset(self.content, b))
    return self.content:sub(ao+1,bo)
end

function input_obj:textinput(t)
    if self:hasLargeSelection() then
        -- Remove all characters in selection before inserting
        local a,b = self:getMinSelection(),self:getMaxSelection()
        local ao,bo = (a == 0 and 0 or utf8.offset(self.content, a)),(b == 0 and 0 or utf8.offset(self.content, b))
        local as,bs = self.content:sub(1,ao),self.content:sub(bo+1,-1)
        self.content = as..bs
        self.selection[1] = a
        self.selection[2] = a
    end
    if self:getLength() >= self.maxLength then return end
    local a,b = self:getMinSelection(),self:getMaxSelection()
    local ao,bo = (a == 0 and 0 or utf8.offset(self.content, a)),(b == 0 and 0 or utf8.offset(self.content, b))
    local as,bs = self.content:sub(0,ao),self.content:sub(bo+1,-1)
    self.content = as..t..bs
    self.selection[1] = b+1
    self.selection[2] = b+1
end

function input_obj:backspace()
    if self:hasLargeSelection() then
        -- Remove all characters in selection
        local a,b = self:getMinSelection(),self:getMaxSelection()
        local ao,bo = (a == 0 and 0 or utf8.offset(self.content, a)),(b == 0 and 0 or utf8.offset(self.content, b))
        local as,bs = self.content:sub(1,ao),self.content:sub(bo+1,-1)
        self.content = as..bs
        self.selection[1] = a
        self.selection[2] = a
    else
        local a,b = self:getMinSelection(),self:getMaxSelection()
        local ao,bo = (a == 0 and 0 or utf8.offset(self.content, a)),(b == 0 and 0 or utf8.offset(self.content, b))
        if ao > 0 then
            local as,bs = self.content:sub(0,ao-1),self.content:sub(bo+1,-1)
            self.content = as..bs
            self.selection[1] = a-1
            self.selection[2] = a-1
        end
    end
end

function input_obj:deleteKey()
    if self:hasLargeSelection() then
        -- Remove all characters in selection
        local a,b = self:getMinSelection(),self:getMaxSelection()
        local ao,bo = (a == 0 and 0 or utf8.offset(self.content, a)),(b == 0 and 0 or utf8.offset(self.content, b))
        local as,bs = self.content:sub(1,ao),self.content:sub(bo+1,-1)
        self.content = as..bs
        self.selection[1] = a
        self.selection[2] = a
    else
        local a,b = self:getMinSelection(),self:getMaxSelection()
        local ao,bo = (a == 0 and 0 or utf8.offset(self.content, a)),(b == 0 and 0 or utf8.offset(self.content, b))
        if ao < self:getLength() then
            local as,bs = self.content:sub(0,ao),self.content:sub(bo+2,-1)
            self.content = as..bs
            self.selection[1] = a
            self.selection[2] = a
        end
    end
end

function input_obj:clear()
    self.content = ""
    self.selection[1] = 0
    self.selection[2] = 0
end

function typingutil.newInputObj(content,maxLength)
    local i = setmetatable({},input_obj)

    i.content = content or ""
    i.selection = {0,0}
    i.maxLength = maxLength or math.huge

    return i
end

---@param k love.KeyConstant
function input_obj:defaultKeyboard(k)
    if k == "backspace" then
        self:backspace()
    end
    if k == "delete" then
        self:deleteKey()
    end
    if k == "right" then
        if love.keyboard.isDown("lshift") then
            self.selection[2] = self.selection[2] + 1
        else
            if self:hasLargeSelection() then
                self.selection[1] = self:getMaxSelection()
            else
                self.selection[1] = self.selection[1] + 1
            end
            self.selection[2] = self.selection[1]
        end
        self.selection[1] = math.min(self:getLength(),self.selection[1])
        self.selection[2] = math.min(self:getLength(),self.selection[2])
    end
    if k == "left" then
        if love.keyboard.isDown("lshift") then
            self.selection[2] = self.selection[2] - 1
        else
            if self:hasLargeSelection() then
                self.selection[1] = self:getMinSelection()
            else
                self.selection[1] = self.selection[1] - 1
            end
            self.selection[2] = self.selection[1]
        end
        self.selection[1] = math.max(0,self.selection[1])
        self.selection[2] = math.max(0,self.selection[2])
    end
    if k == "home" then
        if love.keyboard.isDown("lshift") then
            self.selection[2] = 0
        else
            self.selection[1] = 0
            self.selection[2] = 0
        end
    end
    if k == "end" then
        if love.keyboard.isDown("lshift") then
            self.selection[2] = self:getLength()
        else
            self.selection[1] = self:getLength()
            self.selection[2] = self:getLength()
        end
    end
    if k == "a" and love.keyboard.isDown("lctrl") then
        self.selection[1] = 0
        self.selection[2] = self:getLength()
    end
    if k == "c" and love.keyboard.isDown("lctrl") then
        if self:hasLargeSelection() then
            love.system.setClipboardText(self:getSelectedText())
        else
            love.system.setClipboardText("")
        end
    end
    if k == "x" and love.keyboard.isDown("lctrl") then
        if self:hasLargeSelection() then
            love.system.setClipboardText(self:getSelectedText())
            self:backspace()
        else
            love.system.setClipboardText("")
        end
    end
    if k == "v" and love.keyboard.isDown("lctrl") then
        local txt = love.system.getClipboardText()
        for i=1,#txt do
            local o = utf8.offset(txt,i)
            self:textinput(txt:sub(o,o))
        end
    end
end

return typingutil
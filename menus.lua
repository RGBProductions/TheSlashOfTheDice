Menu = {}
Menu.__index = Menu

function Menu:new(label,children)
    local menu = setmetatable({}, self)

    menu.label = label
    menu.children = children or {}

    return menu
end

function Menu:draw()
    love.graphics.push()
    local logo = Logo or {getHeight = function() return 0 end}
    local pos = (LogoPos or 16) + logo:getHeight()*Settings["video"]["ui_scale"]
    if self.label then
        love.graphics.setFont(xlfont)
        love.graphics.printf(Localize(self.label), 0, pos, love.graphics.getWidth(), "center")
    end
    love.graphics.translate(love.graphics.getWidth()/2, love.graphics.getHeight()/2+(LogoPos-16))
    for _,child in ipairs(self.children) do
        if type(child.draw) == "function" then
            child:draw()
        end
    end
    love.graphics.pop()
end

function Menu:click(x,y)
    x,y = x-love.graphics.getWidth()/2, y-love.graphics.getHeight()/2
    for i = #self.children, 1, -1 do local child = self.children[i]
        if type(child.click) == "function" then
            local clicked,element,cx,cy = child:click(x,y)
            if clicked then
                return clicked,element,cx,cy
            end
        end
    end
    return false, self, x, y
end

function Menu:scroll(x,y,dx,dy)
    x,y = x-love.graphics.getWidth()/2, y-love.graphics.getHeight()/2
    for _,child in ipairs(self.children) do
        if type(child.scroll) == "function" then
            local scrolled,element,cx,cy = child:scroll(x,y,dx,dy)
            if scrolled then
                return scrolled,element,cx,cy
            end
        end
    end
    return false, self, x, y
end

function Menu:getCursor(x,y)
    x,y = x-love.graphics.getWidth()/2, y-love.graphics.getHeight()/2
    for _,child in ipairs(self.children) do
        if type(child.getCursor) == "function" then
            local cursor = child:getCursor(x,y)
            if cursor then
                return cursor
            end
        end
    end
    return nil
end

MenuText = {}
MenuText.__index = MenuText

function MenuText:new(x,y,text,font,color,children)
    local textelem = setmetatable({}, self)

    textelem.x = x or 0
    textelem.y = y or 0
    textelem.text = text
    textelem.font = font or mdfont
    textelem.color = color or {1,1,1}
    textelem.children = children or {}

    return textelem
end

function MenuText:draw()
    love.graphics.push()
    love.graphics.translate(self.x, self.y)
    if self.text then
        local text = Localize(self.text)
        love.graphics.setFont(self.font)
        love.graphics.print(text, self.x-self.font:getWidth(text)/2, self.y-self.font:getHeight()/2)
    end
    for _,child in ipairs(self.children) do
        if type(child.draw) == "function" then
            child:draw()
        end
    end
    love.graphics.pop()
end

function MenuText:click(x,y)
    x,y = x-self.x, y-self.y
    for i = #self.children, 1, -1 do local child = self.children[i]
        if type(child.click) == "function" then
            local clicked,element,cx,cy = child:click(x,y)
            if clicked then
                return clicked,element,cx,cy
            end
        end
    end
    local text = Localize(self.text or "")
    if self.onclick and x >= -self.font:getWidth(text)/2 and x < -self.font:getWidth(text)/2 and y >= -self.font:getHeight()/2 and y < self.font:getHeight()/2 then
        return true, self, x, y
    end
    return false, self, x, y
end

function MenuText:scroll(x,y,dx,dy)
    x,y = x-love.graphics.getWidth()/2, y-love.graphics.getHeight()/2
    for _,child in ipairs(self.children) do
        if type(child.scroll) == "function" then
            local scrolled,element,cx,cy = child:scroll(x,y,dx,dy)
            if scrolled then
                return scrolled,element,cx,cy
            end
        end
    end
    return false, self, x, y
end

function MenuText:getCursor(x,y)
    local sx,sy = self.x,self.y
    if type(sx) == "function" then sx = sx(self) end
    if type(sy) == "function" then sy = sy(self) end
    x,y = x-sx, y-sy
    for _,child in ipairs(self.children) do
        if type(child.getCursor) == "function" then
            local cursor = child:getCursor(x,y)
            if cursor then
                return cursor
            end
        end
    end
    return nil
end

MenuImage = {}
MenuImage.__index = MenuImage

function MenuImage:new(x,y,image,width,height,children)
    local img = setmetatable({}, self)

    img.x = x or 0
    img.y = y or 0
    img.image = image
    img.width = width
    img.height = height
    if img.image then
        img.width = img.width or img.image:getWidth()
        img.height = img.height or img.image:getHeight()
    end
    img.children = children or {}

    return img
end

function MenuImage:draw()
    love.graphics.push()
    love.graphics.translate(self.x, self.y)
    if self.image then
        love.graphics.draw(self.image, -self.width/2, -self.height/2, 0, self.width/self.image:getWidth(), self.height/self.image:getHeight())
    end
    for _,child in ipairs(self.children) do
        if type(child.draw) == "function" then
            child:draw()
        end
    end
    love.graphics.pop()
end

function MenuImage:click(x,y)
    x,y = x-self.x, y-self.y
    for i = #self.children, 1, -1 do local child = self.children[i]
        if type(child.click) == "function" then
            local clicked,element,cx,cy = child:click(x,y)
            if clicked then
                return clicked,element,cx,cy
            end
        end
    end
    if self.onclick and x >= -self.width/2 and x < self.width/2 and y >= -self.height/2 and y < self.height/2 then
        return true, self, x, y
    end
    return false, self, x, y
end

function MenuImage:scroll(x,y,dx,dy)
    x,y = x-love.graphics.getWidth()/2, y-love.graphics.getHeight()/2
    for _,child in ipairs(self.children) do
        if type(child.scroll) == "function" then
            local scrolled,element,cx,cy = child:scroll(x,y,dx,dy)
            if scrolled then
                return scrolled,element,cx,cy
            end
        end
    end
    return false, self, x, y
end

function MenuImage:getCursor(x,y)
    local sx,sy = self.x,self.y
    local w,h = self.width,self.height
    if type(sx) == "function" then sx = sx(self) end
    if type(sy) == "function" then sy = sy(self) end
    if type(w) == "function" then w = w(self) end
    if type(h) == "function" then h = h(self) end
    x,y = x-sx, y-sy
    for _,child in ipairs(self.children) do
        if type(child.getCursor) == "function" then
            local cursor = child:getCursor(x,y)
            if cursor then
                return cursor
            end
        end
    end
    return nil
end

MenuButton = {}
MenuButton.__index = MenuButton

function MenuButton:new(x,y,width,height,label,font,bgcol,fgcol,outlineCol,outlineWidth,onclick,children)
    local button = setmetatable({}, self)

    button.x = x or 0
    button.y = y or 0
    button.width = width or 64
    button.height = height or 64
    button.label = label or "Button"
    button.font = font or lgfont
    button.bgcol = bgcol or {1,1,1}
    button.fgcol = fgcol or {0,0,0}
    button.outlineCol = outlineCol or {0,0,0}
    button.outlineWidth = outlineWidth or 0
    button.onclick = onclick
    button.children = children or {}

    return button
end

function MenuButton:draw()
    local x,y = self.x,self.y
    local w,h = self.width,self.height
    if type(x) == "function" then x = x(self) end
    if type(y) == "function" then y = y(self) end
    if type(w) == "function" then w = w(self) end
    if type(h) == "function" then h = h(self) end
    love.graphics.push()
    love.graphics.translate(x,y)
    love.graphics.setColor(self.bgcol)
    love.graphics.rectangle("fill", -w/2, -h/2, w, h)
    if self.outlineWidth > 0 then
        local lw = love.graphics.getLineWidth()
        love.graphics.setColor(self.outlineCol)
        love.graphics.setLineWidth(self.outlineWidth)
        love.graphics.rectangle("line", -w/2, -h/2, w, h)
        love.graphics.setLineWidth(lw)
        love.graphics.setColor(1,1,1)
    end
    if type(self.label.draw) == "function" then
        self.label:draw()
    else
        love.graphics.setFont(self.font)
        love.graphics.setColor(self.fgcol)
        love.graphics.printf(Localize(self.label), -w/2, -self.font:getHeight()/2, w, "center")
        love.graphics.setColor(1,1,1)
    end
    for _,child in ipairs(self.children) do
        if type(child.draw) == "function" then
            child:draw()
        end
    end
    love.graphics.pop()
end

function MenuButton:click(x,y)
    local sx,sy = self.x,self.y
    local w,h = self.width,self.height
    if type(sx) == "function" then sx = sx(self) end
    if type(sy) == "function" then sy = sy(self) end
    if type(w) == "function" then w = w(self) end
    if type(h) == "function" then h = h(self) end
    x,y = x-sx, y-sy
    for i = #self.children, 1, -1 do local child = self.children[i]
        if type(child.click) == "function" then
            local clicked,element,cx,cy = child:click(x,y)
            if clicked then
                return clicked,element,cx,cy
            end
        end
    end
    if self.onclick and x >= -w/2 and x < w/2 and y >= -h/2 and y < h/2 then
        return true,self,x,y
    end
    return false,self,x,y
end

function MenuButton:scroll(x,y,dx,dy)
    x,y = x-love.graphics.getWidth()/2, y-love.graphics.getHeight()/2
    for _,child in ipairs(self.children) do
        if type(child.scroll) == "function" then
            local scrolled,element,cx,cy = child:scroll(x,y,dx,dy)
            if scrolled then
                return scrolled,element,cx,cy
            end
        end
    end
    return false, self, x, y
end

function MenuButton:getCursor(x,y)
    local sx,sy = self.x,self.y
    local w,h = self.width,self.height
    if type(sx) == "function" then sx = sx(self) end
    if type(sy) == "function" then sy = sy(self) end
    if type(w) == "function" then w = w(self) end
    if type(h) == "function" then h = h(self) end
    x,y = x-sx, y-sy
    for _,child in ipairs(self.children) do
        if type(child.getCursor) == "function" then
            local cursor = child:getCursor(x,y)
            if cursor then
                return cursor
            end
        end
    end
    if x >= -w/2 and x < w/2 and y >= -h/2 and y < h/2 then
        return "hand"
    end
    return nil
end

ShapedMenuButton = {}
ShapedMenuButton.__index = ShapedMenuButton

local rectangleShape = {
    -1,-1,
    1,-1,
    1,1,
    -1,1
}

local function getBoundingBox(shape)
    local xmin,ymin = math.huge,math.huge
    local xmax,ymax = -math.huge,-math.huge
    for i = 1, #shape, 2 do
        xmin = math.min(shape[i],xmin)
        xmax = math.max(shape[i],xmax)
        ymin = math.min(shape[i+1],ymin)
        ymax = math.max(shape[i+1],ymax)
    end
    return {xmin,ymin,xmax-xmin,ymax-ymin}
end

function ShapedMenuButton:new(x,y,width,height,label,font,shape,bgcol,fgcol,outlineCol,outlineWidth,onclick,children)
    local button = setmetatable({}, self)

    button.x = x or 0
    button.y = y or 0
    button.width = width or 64
    button.height = height or 64
    button.label = label or "Button"
    button.font = font or lgfont
    button.onclick = onclick
    button.bgcol = bgcol or {1,1,1}
    button.fgcol = fgcol or {0,0,0}
    button.outlineCol = outlineCol or {0,0,0}
    button.outlineWidth = outlineWidth or 0
    button.shape = shape or rectangleShape
    button.triangles = love.math.triangulate(button.shape)
    button.boundingBox = getBoundingBox(button.shape)
    button.children = children or {}

    return button
end

function ShapedMenuButton:draw()
    love.graphics.push()
    love.graphics.translate(self.x,self.y)
    love.graphics.setColor(self.bgcol)
    love.graphics.push()
    love.graphics.scale(self.width,self.height)
    for _,tri in ipairs(self.triangles) do
        love.graphics.polygon("fill", tri)
    end
    if self.outlineWidth > 0 then
        local lw = love.graphics.getLineWidth()
        love.graphics.setColor(self.outlineCol)
        love.graphics.setLineWidth(self.outlineWidth)
        love.graphics.polygon("line", self.shape)
        love.graphics.setLineWidth(lw)
        love.graphics.setColor(1,1,1)
    end
    love.graphics.pop()
    if type(self.label.draw) == "function" then
        self.label:draw()
    else
        love.graphics.setFont(self.font)
        love.graphics.setColor(self.fgcol)
        love.graphics.printf(Localize(self.label), self.boundingBox[1]*self.width, self.boundingBox[2]*self.height+(self.boundingBox[4]*self.height-self.font:getHeight())/2, self.boundingBox[3]*self.width, "center")
    end
    love.graphics.setColor(1,1,1)
    for _,child in ipairs(self.children) do
        if type(child.draw) == "function" then
            child:draw()
        end
    end
    love.graphics.pop()
end

function ShapedMenuButton:click(x,y)
    x,y = x-self.x, y-self.y
    for i = #self.children, 1, -1 do local child = self.children[i]
        if type(child.click) == "function" then
            local clicked,element,cx,cy = child:click(x,y)
            if clicked then
                return clicked,element,cx,cy
            end
        end
    end
    if self.onclick and x >= self.boundingBox[1]*self.width and x < (self.boundingBox[1]+self.boundingBox[3])*self.width and y >= self.boundingBox[2]*self.height and y < (self.boundingBox[2]+self.boundingBox[4])*self.height then
        return true,self,x,y
    end
    return false,self,x,y
end

function ShapedMenuButton:scroll(x,y,dx,dy)
    x,y = x-love.graphics.getWidth()/2, y-love.graphics.getHeight()/2
    for _,child in ipairs(self.children) do
        if type(child.scroll) == "function" then
            local scrolled,element,cx,cy = child:scroll(x,y,dx,dy)
            if scrolled then
                return scrolled,element,cx,cy
            end
        end
    end
    return false, self, x, y
end

function ShapedMenuButton:getCursor(x,y)
    local sx,sy = self.x,self.y
    local w,h = self.width,self.height
    if type(sx) == "function" then sx = sx(self) end
    if type(sy) == "function" then sy = sy(self) end
    if type(w) == "function" then w = w(self) end
    if type(h) == "function" then h = h(self) end
    x,y = x-sx, y-sy
    for _,child in ipairs(self.children) do
        if type(child.getCursor) == "function" then
            local cursor = child:getCursor(x,y)
            if cursor then
                return cursor
            end
        end
    end
    if x >= self.boundingBox[1]*self.width and x < (self.boundingBox[1]+self.boundingBox[3])*self.width and y >= self.boundingBox[2]*self.height and y < (self.boundingBox[2]+self.boundingBox[4])*self.height then
        return "hand"
    end
    return nil
end

ScrollablePanel = {}
ScrollablePanel.__index = ScrollablePanel

function ScrollablePanel:new(x,y,width,height,children)
    local panel = setmetatable({}, self)

    panel.x = x or 0
    panel.y = y or 0
    panel.width = width
    panel.height = height
    panel.scrollAmount = 0
    panel.children = children or {}

    return panel
end

function ScrollablePanel:draw()
    local x,y = self.x,self.y
    local w,h = self.width,self.height
    if type(x) == "function" then x = x(self) end
    if type(y) == "function" then y = y(self) end
    if type(w) == "function" then w = w(self) end
    if type(h) == "function" then h = h(self) end
    love.graphics.push()
    love.graphics.translate(x,y)
    love.graphics.setColor(1,1,1)
    local stencil = function ()
        love.graphics.rectangle("fill", -w/2, -h/2, w, h)
    end
    love.graphics.rectangle("line", -w/2, -h/2, w, h)
    love.graphics.stencil(stencil)
    love.graphics.setStencilTest("gequal", 1)
    love.graphics.translate(0,-h/2-self.scrollAmount)
    for _,child in ipairs(self.children) do
        if type(child.draw) == "function" then
            child:draw()
        end
    end
    love.graphics.setStencilTest()
    love.graphics.pop()
end

function ScrollablePanel:click(x,y)
    local sx,sy = self.x,self.y
    local w,h = self.width,self.height
    if type(sx) == "function" then sx = sx(self) end
    if type(sy) == "function" then sy = sy(self) end
    if type(w) == "function" then w = w(self) end
    if type(h) == "function" then h = h(self) end
    x,y = x-sx, y-sy+h/2
    for i = #self.children, 1, -1 do local child = self.children[i]
        if type(child.click) == "function" then
            local clicked,element,cx,cy = child:click(x,y)
            if clicked then
                return clicked,element,cx,cy
            end
        end
    end
    return false,self,x,y
end

function ScrollablePanel:scroll(x,y,dx,dy)
    local sx,sy = self.x,self.y
    local w,h = self.width,self.height
    if type(sx) == "function" then sx = sx(self) end
    if type(sy) == "function" then sy = sy(self) end
    if type(w) == "function" then w = w(self) end
    if type(h) == "function" then h = h(self) end
    x,y = x-sx, y-sy
    for _,child in ipairs(self.children) do
        if type(child.scroll) == "function" then
            local scrolled,element,cx,cy = child:scroll(x,y,dx,dy)
            if scrolled then
                return scrolled,element,cx,cy
            end
        end
    end
    if x >= -w/2 and x < w/2 and y >= -h/2 and y < h/2 then
        self.scrollAmount = self.scrollAmount - dy*16
        return true, self, x, y
    end
    return false, self, x, y
end

function ScrollablePanel:getCursor(x,y)
    local sx,sy = self.x,self.y
    local w,h = self.width,self.height
    if type(sx) == "function" then sx = sx(self) end
    if type(sy) == "function" then sy = sy(self) end
    if type(w) == "function" then w = w(self) end
    if type(h) == "function" then h = h(self) end
    x,y = x-sx, y-sy+h/2
    for _,child in ipairs(self.children) do
        if type(child.getCursor) == "function" then
            local cursor = child:getCursor(x,y)
            if cursor then
                return cursor
            end
        end
    end
    return nil
end

local theme = {
    buttonBg = {0,0,0,0.75},
    buttonFg = {1,1,1},
    buttonOutline = {1,1,1},
    buttonLineWidth = 4
}

MainMenu = Menu:new(nil,{
    MenuButton:new(0, 0, 512, 144, "button.play", lrfont, theme.buttonBg, theme.buttonFg, theme.buttonOutline, theme.buttonLineWidth, function()
        CurrentMenu = "Singleplayer"
    end),
    MenuButton:new(-(512-(512/2-8))/2, 120, (512/2-8), 64, "button.achievements", lgfont, theme.buttonBg, theme.buttonFg, theme.buttonOutline, theme.buttonLineWidth, function()
        SceneManager.LoadScene("scenes/achievements")
    end),
    MenuButton:new((512-(512/2-8))/2, 120, (512/2-8), 64, "button.credits", lgfont, theme.buttonBg, theme.buttonFg, theme.buttonOutline, theme.buttonLineWidth, function()
        SceneManager.LoadScene("scenes/credits")
    end),
    MenuButton:new(-(512-(512/2-8))/2, 200, (512/2-8), 64, "button.settings", lgfont, theme.buttonBg, theme.buttonFg, theme.buttonOutline, theme.buttonLineWidth, function()
        print("settings")
    end),
    MenuButton:new((512-(512/2-8))/2, 200, (512/2-8), 64, "button.quit", lgfont, theme.buttonBg, theme.buttonFg, theme.buttonOutline, theme.buttonLineWidth, function()
        love.event.push("quit")
    end)
})

PlayMenu = Menu:new("title.menu.play",{
    ShapedMenuButton:new(-272, 32, 1, 1, "button.singleplayer", lrfont, {
        -256,-64,
        256+24,-64,
        256-24,64,
        -256,64
    },theme.buttonBg, theme.buttonFg, theme.buttonOutline, theme.buttonLineWidth, function()
        CurrentMenu = "Singleplayer"
    end),
    ShapedMenuButton:new(272, 32, 1, 1, "button.multiplayer", lrfont, {
        -256+24,-64,
        256,-64,
        256,64,
        -256-24,64
    },theme.buttonBg, theme.buttonFg, theme.buttonOutline, theme.buttonLineWidth, function()
        SceneManager.LoadScene("scenes/mpmenu")
    end),
    MenuButton:new(0, 192, 256, 64, "button.back", lgfont, theme.buttonBg, theme.buttonFg, theme.buttonOutline, theme.buttonLineWidth, function()
        CurrentMenu = "Main"
    end)
})

local spButtons = {}
for i,mode in ipairs(PlayModes) do
    table.insert(spButtons, MenuButton:new(0, (i-1)*(64+16)+32, function() return love.graphics.getWidth()-512 end, 64, "gamemode."..mode[2], lgfont, theme.buttonBg, theme.buttonFg, theme.buttonOutline, theme.buttonLineWidth, function() SceneManager.LoadScene("scenes/game", {mode = mode[2]}) end))
end

SingleplayerMenu = Menu:new("title.menu.singleplayer",{
    ScrollablePanel:new(0,function()
        local logo = Logo or {getHeight = function() return 0 end}
        local pos = (LogoPos or 16) + logo:getHeight()*Settings["video"]["ui_scale"]
        local top_pos = pos+xlfont:getHeight()
        local bottom_pos = love.graphics.getHeight()/2+256-32
        return (top_pos+bottom_pos)/2-(love.graphics.getHeight()/2)
    end,function() return love.graphics.getWidth()-512 end, function()
        local logo = Logo or {getHeight = function() return 0 end}
        local pos = (LogoPos or 16) + logo:getHeight()*Settings["video"]["ui_scale"]
        local top_pos = pos+xlfont:getHeight()
        local bottom_pos = love.graphics.getHeight()/2+256-32
        local height = bottom_pos-top_pos
        return height
    end, spButtons),
    MenuButton:new(0, 256, 256, 64, "button.back", lgfont, theme.buttonBg, theme.buttonFg, theme.buttonOutline, theme.buttonLineWidth, function() CurrentMenu = "Main" end)
})

return {
    Main = MainMenu,
    Play = PlayMenu,
    Singleplayer = SingleplayerMenu
}
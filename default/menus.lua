ButtonIcons = {}
for _,itm in ipairs(love.filesystem.getDirectoryItems("assets/images/ui/button_icons")) do
    local name,ext = unpack(itm:split_plain("."))
    if ext == "png" then
        ButtonIcons[name] = love.graphics.newImage("assets/images/ui/button_icons/"..itm)
    end
end
NoCosmeticIcon = love.graphics.newImage("assets/images/ui/none.png")

require "default.menus.main"
require "default.menus.play"
require "default.menus.settings"
require "default.menus.customize"
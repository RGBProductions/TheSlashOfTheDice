ButtonIcons = {}
for _,itm in ipairs(love.filesystem.getDirectoryItems("default/assets/default/images/ui/button_icons")) do
    local name,ext = unpack(itm:split_plain("."))
    if ext == "png" then
        ButtonIcons[name] = love.graphics.newImage("default/assets/default/images/ui/button_icons/"..itm)
    end
end
NoCosmeticIcon = love.graphics.newImage("default/assets/default/images/ui/none.png")

require "default.menus.main"
require "default.menus.play"
require "default.menus.settings"
require "default.menus.customize"
require "default.menus.mods"
local scene = {}

function scene.load()
    AchievementScroll = 0
end

local scrollVelocity = 0

function scene.draw()
    love.graphics.setColor(1,1,1)
    love.graphics.draw(MenuBGMesh, -((GlobalTime*48)%192), -((GlobalTime*48)%192))
    local pos = 0
    local unlocked = 0
    local total = 0
    local hidden = 0
    local iconScale = lgfont:getHeight()+mdfont:getHeight()*2
    for i,id in ipairs(Achievements.Order) do
        local wasHidden = false
        if Achievements.Achievements[id].hidden then
            hidden = hidden + 1
            wasHidden = true
        end
        if (Achievements.Achievements[id].hidden and Achievements.Achievements[id].progress >= Achievements.Achievements[id].maxProgress) or not Achievements.Achievements[id].hidden then
            hidden = (wasHidden and hidden - 1) or hidden
            local icon = Achievements.Achievements[id].icon
            local y = LogoPos + Logo:getHeight()*Settings.video.ui_scale + xlfont:getHeight()*2+lgfont:getHeight() + pos*(iconScale+16)*ViewScale - AchievementScroll
            love.graphics.setColor(1,1,1)
            unlocked = unlocked + 1
            if Achievements.Achievements[id].progress < Achievements.Achievements[id].maxProgress then
                unlocked = unlocked - 1
                love.graphics.setColor(0.3,0.3,0.3)
            end
            total = total + 1
            love.graphics.draw(icon, 0, y+ViewMargin, 0, (iconScale)/icon:getWidth()*ViewScale, (iconScale)/icon:getHeight()*ViewScale)
            love.graphics.setColor(1,1,1)
            love.graphics.setFont(lgfont)
            love.graphics.print(Localize("achievement."..id..".name"), ((iconScale+16)*ViewScale), y+ViewMargin)
            love.graphics.setFont(mdfont)
            love.graphics.print(Localize("achievement."..id..".description"), ((iconScale+16)*ViewScale), y+lgfont:getHeight()+ViewMargin)
            if Achievements.Achievements[id].maxProgress > 1 then
                love.graphics.print(Achievements.Achievements[id].progress .. " / " .. Achievements.Achievements[id].maxProgress, ((iconScale+16)*ViewScale), y+lgfont:getHeight()+mdfont:getHeight()+ViewMargin)
            end
            pos = pos + 1
        end
    end

    love.graphics.draw(Logo, love.graphics.getWidth()/2, LogoPos+ViewMargin, 0, Settings.video.ui_scale, Settings.video.ui_scale, Logo:getWidth()/2, 0)
    love.graphics.setFont(xlfont)
    love.graphics.printf(Localize("title.achievements"), 0, LogoPos + Logo:getHeight()*Settings.video.ui_scale + xlfont:getHeight()+ViewMargin, love.graphics.getWidth(), "center")
    love.graphics.setFont(lgfont)
    if not ShowMobileUI then
        love.graphics.printf(Localize(Gamepads[1] ~= nil and "gamepad.goback" or "key.goback"), 0, LogoPos + Logo:getHeight()*Settings.video.ui_scale + xlfont:getHeight()*2+ViewMargin, love.graphics.getWidth(), "center")
    else
        love.graphics.draw(BackIcon, 64, 64, 0, 64/BackIcon:getWidth()*Settings.video.ui_scale, 64/BackIcon:getHeight()*Settings.video.ui_scale)
    end
    love.graphics.printf(unlocked .. " / " .. total .. " (" .. hidden .. " hidden)", 0, LogoPos + Logo:getHeight()*Settings.video.ui_scale + xlfont:getHeight()*2+lgfont:getHeight()+ViewMargin, love.graphics.getWidth(), "center")
end

function scene.wheelmoved(x, y)
    AchievementScroll = AchievementScroll - y*32
end

function scene.update(dt)
    local lefty = 0
    if Gamepads[1] ~= nil then
        lefty = Gamepads[1]:getGamepadAxis("lefty")
        lefty = ((math.max(0.2, math.abs(lefty))-0.2)/0.8) * math.sign(lefty)
    end
    local scrollUp = math.max(0, math.min(1, (love.keyboard.isDown("up") and 1 or 0) - lefty))
    local scrollDown = math.max(0, math.min(1, (love.keyboard.isDown("down") and 1 or 0) + lefty))
    local scroll = math.max(-1, math.min(1, scrollUp-scrollDown))
    AchievementScroll = AchievementScroll - 16*60*dt*scroll
    
    scrollVelocity = math.max(0,math.abs(scrollVelocity)-dt*16)*math.sign(scrollVelocity)
    if not love.mouse.isDown(1) then
        AchievementScroll = AchievementScroll - scrollVelocity*60*dt
    end

    local num = 0
    for i,id in ipairs(Achievements.Order) do
        if (Achievements.Achievements[id].hidden and Achievements.Achievements[id].progress >= Achievements.Achievements[id].maxProgress) or not Achievements.Achievements[id].hidden then
            num = num + 1
        end
    end

    local iconScale = lgfont:getHeight()+mdfont:getHeight()*2
    AchievementScroll = math.max(0,math.min(iconScale*num+16*(num-1), AchievementScroll))
end

function scene.keypressed(k)
    if k == "escape" then
        SceneManager.LoadScene("scenes/menu")
    end
end

function scene.gamepadpressed(stick,b)
    if b == "b" then
        SceneManager.LoadScene("scenes/menu")
    end
end

function scene.mousepressed(x,y)
    scrollVelocity = 0
end

function scene.mousemoved(x,y,dx,dy)
    if love.mouse.isDown(1) then
        scrollVelocity = dy
        AchievementScroll = AchievementScroll - dy
    end
end

function scene.touchreleased(id,x,y)
    if x >= 64 and x < 64+64*Settings.video.ui_scale and y >= 64 and y < 64+64*Settings.video.ui_scale and ShowMobileUI then
        SceneManager.LoadScene("scenes/menu")
    end
end

return scene
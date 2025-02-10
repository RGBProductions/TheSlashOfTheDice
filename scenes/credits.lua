local scene = {}

function scene.load()
    Credits = json.decode(love.filesystem.read("assets/text/credits.json"))
    CreditScroll = 0
end

function scene.draw()
    love.graphics.setColor(1,1,1)
    love.graphics.draw(MenuBGMesh, -((GlobalTime*48)%192), -((GlobalTime*48)%192))
    love.graphics.setFont(xlfont)
    love.graphics.printf(Localize("title.credits"), 0, LogoPos + Logo:getHeight()*Settings.video.ui_scale + xlfont:getHeight() - CreditScroll+ViewMargin, love.graphics.getWidth(), "center")
    love.graphics.setFont(lgfont)
    if not ShowMobileUI then
        love.graphics.printf(Localize(Gamepads[1] ~= nil and "gamepad.goback" or "key.goback"), 0, LogoPos + Logo:getHeight()*Settings.video.ui_scale + xlfont:getHeight()*2+ViewMargin - CreditScroll+ViewMargin, love.graphics.getWidth(), "center")
    else
        love.graphics.draw(BackIcon, 64, 64, 0, 64/BackIcon:getWidth()*Settings.video.ui_scale, 64/BackIcon:getHeight()*Settings.video.ui_scale)
    end

    local pos = 0
    local lastType = "header"
    for i = 1, #Credits do
        if Credits[i]["type"] == "header" and lastType == "name" then
            pos = pos + lrfont:getHeight()
        end
        love.graphics.setFont(xlfont)
        if Credits[i]["type"] == "name" then
            love.graphics.setFont(lrfont)
        end
        love.graphics.printf(Localize(Credits[i]["label"]), 0, LogoPos + Logo:getHeight()*Settings.video.ui_scale + xlfont:getHeight()*3 + pos - CreditScroll+ViewMargin, love.graphics.getWidth(), "center")
        pos = pos + love.graphics.getFont():getHeight()
        lastType = Credits[i]["type"]
    end

    love.graphics.draw(Logo, love.graphics.getWidth()/2, LogoPos+ViewMargin, 0, Settings.video.ui_scale, Settings.video.ui_scale, Logo:getWidth()/2, 0)
end

function scene.wheelmoved(x, y)
    CreditScroll = CreditScroll - y*24
end

local scrollVelocity = 0
function scene.update(dt)
    local lefty = 0
    if Gamepads[1] ~= nil then
        lefty = Gamepads[1]:getGamepadAxis("lefty")
        lefty = ((math.max(0.2, math.abs(lefty))-0.2)/0.8) * math.sign(lefty)
    end
    local scrollUp = math.max(0, math.min(1, (love.keyboard.isDown("up") and 1 or 0) - lefty))
    local scrollDown = math.max(0, math.min(1, (love.keyboard.isDown("down") and 1 or 0) + lefty))
    local scroll = math.max(-1, math.min(1, scrollUp-scrollDown))
    CreditScroll = CreditScroll - 16*60*dt*scroll

    scrollVelocity = math.max(0,math.abs(scrollVelocity)-dt*16)*math.sign(scrollVelocity)
    if not love.mouse.isDown(1) then
        CreditScroll = CreditScroll - scrollVelocity*60*dt
    end

    local pos = 0
    local lastType = "header"
    for i = 1, #Credits do
        if Credits[i]["type"] == "header" and lastType == "name" then
            pos = pos + lrfont:getHeight()
        end
        local font = xlfont
        if Credits[i]["type"] == "name" then
            font = lrfont
        end
        pos = pos + font:getHeight()
        lastType = Credits[i]["type"]
    end
    CreditScroll = math.max(0,math.min(pos,CreditScroll))
    
    local blend = math.pow(1/((8/7)^60), dt)
    LogoPos = blend*(LogoPos-16)+16
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
        CreditScroll = CreditScroll - dy
    end
end

function scene.touchreleased(id,x,y)
    if x >= 64 and x < 64+64*Settings.video.ui_scale and y >= 64 and y < 64+64*Settings.video.ui_scale and ShowMobileUI then
        SceneManager.LoadScene("scenes/menu")
    end
end

return scene
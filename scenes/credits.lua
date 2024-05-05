local scene = {}

function scene.load()
    Credits = json.decode(love.filesystem.read("assets/text/credits.json"))
    CreditScroll = 0
end

function scene.draw()
    love.graphics.setColor(1,1,1)
    if not IsMobile then
        love.graphics.setShader(BGShader)
        BGShader:send("time", GlobalTime*48)
        love.graphics.rectangle("fill", 0, 0, love.graphics.getWidth(), love.graphics.getHeight())
        love.graphics.setShader()
    else
        love.graphics.draw(MenuBGMobile, -((GlobalTime*48)%192), -((GlobalTime*48)%192))
    end
    love.graphics.setFont(xlfont)
    love.graphics.printf("Credits", 0, LogoPos + Logo:getHeight()*Settings["Video"]["UI Scale"] + xlfont:getHeight() - CreditScroll+ViewMargin, love.graphics.getWidth(), "center")
    love.graphics.setFont(lgfont)
    if not IsMobile then
        love.graphics.printf("Press escape to go back", 0, LogoPos + Logo:getHeight()*Settings["Video"]["UI Scale"] + xlfont:getHeight()*2+ViewMargin - CreditScroll+ViewMargin, love.graphics.getWidth(), "center")
    else
        love.graphics.draw(BackIcon, 64, 64, 0, 64/BackIcon:getWidth()*Settings["Video"]["UI Scale"], 64/BackIcon:getHeight()*Settings["Video"]["UI Scale"])
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
        love.graphics.printf(Credits[i]["label"], 0, LogoPos + Logo:getHeight()*Settings["Video"]["UI Scale"] + xlfont:getHeight()*3 + pos - CreditScroll+ViewMargin, love.graphics.getWidth(), "center")
        pos = pos + love.graphics.getFont():getHeight()
        lastType = Credits[i]["type"]
    end

    love.graphics.draw(Logo, love.graphics.getWidth()/2, LogoPos+ViewMargin, 0, Settings["Video"]["UI Scale"], Settings["Video"]["UI Scale"], Logo:getWidth()/2, 0)
end

function scene.wheelmoved(x, y)
    CreditScroll = CreditScroll - y*24
end

local scrollVelocity = 0
function scene.update(dt)
    if love.keyboard.isDown("up") then
        CreditScroll = CreditScroll - 8
    end
    if love.keyboard.isDown("down") then
        CreditScroll = CreditScroll + 8
    end

    scrollVelocity = math.max(0,math.abs(scrollVelocity)-dt*16)*math.sign(scrollVelocity)
    if not love.mouse.isDown(1) then
        CreditScroll = CreditScroll - scrollVelocity
    end
end

function scene.keypressed(k)
    if k == "escape" then
        SceneManager.LoadScene("scenes/menu")
    end
end

function scene.mousepressed(x,y)
    scrollVelocity = 0
    if x >= 64 and x < 64+64*Settings["Video"]["UI Scale"] and y >= 64 and y < 64+64*Settings["Video"]["UI Scale"] then
        SceneManager.LoadScene("scenes/menu")
    end
end

function scene.mousemoved(x,y,dx,dy)
    if love.mouse.isDown(1) then
        scrollVelocity = dy
        CreditScroll = CreditScroll - dy
    end
end

return scene
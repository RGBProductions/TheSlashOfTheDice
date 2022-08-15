local scene = {}

function scene.load()
    Credits = json.decode(love.filesystem.read("assets/text/credits.json"))
    CreditScroll = 0
end

function scene.draw()
    love.graphics.setColor(1,1,1)
    love.graphics.setFont(xlfont)
    love.graphics.printf("Credits", 0, LogoPos + Logo:getHeight()*Settings["Video"]["UI Scale"] + xlfont:getHeight() - CreditScroll, love.graphics.getWidth(), "center")

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
        love.graphics.printf(Credits[i]["label"], 0, LogoPos + Logo:getHeight()*Settings["Video"]["UI Scale"] + xlfont:getHeight()*3 + pos - CreditScroll, love.graphics.getWidth(), "center")
        pos = pos + love.graphics.getFont():getHeight()
        lastType = Credits[i]["type"]
    end

    love.graphics.draw(Logo, love.graphics.getWidth()/2, LogoPos, 0, Settings["Video"]["UI Scale"], Settings["Video"]["UI Scale"], Logo:getWidth()/2, 0)
end

function scene.wheelmoved(x, y)
    CreditScroll = CreditScroll - y*24
end

function scene.update(dt)
    if love.keyboard.isDown("up") then
        CreditScroll = CreditScroll - 8
    end
    if love.keyboard.isDown("down") then
        CreditScroll = CreditScroll + 8
    end
end

function scene.keypressed(k)
    if k == "escape" then
        SceneManager.LoadScene("scenes/menu")
    end
end

return scene
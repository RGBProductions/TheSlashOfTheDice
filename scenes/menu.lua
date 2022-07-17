local scene = {}

smfont = love.graphics.getFont()
lgfont = love.graphics.newFont(24)
xlfont = love.graphics.newFont(48)

function scene.load()
    Logo = love.graphics.newImage("assets/images/ui/logo-new.png")
    LogoPos = love.graphics.getHeight()
end

function scene.update(dt)
    LogoPos = LogoPos - ((LogoPos-16)/8)
end

function scene.draw()
    love.graphics.draw(Logo, love.graphics.getWidth()/2, LogoPos, 0, Settings["UI Scale"], Settings["UI Scale"], Logo:getWidth()/2, 0)
    love.graphics.setFont(xlfont)
    love.graphics.printf("Press t for the tutorial", 0, (love.graphics.getHeight()-love.graphics.getFont():getHeight())/2 + LogoPos, love.graphics.getWidth(), "center")
    love.graphics.printf("Press space to start", 0, (love.graphics.getHeight()-love.graphics.getFont():getHeight())/2 + LogoPos + xlfont:getHeight(), love.graphics.getWidth(), "center")
    love.graphics.printf("Press escape to exit", 0, (love.graphics.getHeight()-love.graphics.getFont():getHeight())/2 + LogoPos + xlfont:getHeight()*2, love.graphics.getWidth(), "center")
end

function scene.keypressed(k)
    if k == "t" then
        SceneManager.LoadScene("scenes/tutorial")
    end
    if k == "space" then
        SceneManager.LoadScene("scenes/game")
    end
    if k == "escape" then
        love.event.push("quit")
    end
end

return scene
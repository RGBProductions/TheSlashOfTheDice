local scene = {}

local cur = 1
local music = {
    {"assets/music/Tutorial.ogg", "Tutorial"},
    {"assets/music/Fight.ogg", "Fight"}
}

function scene.load()
    AchievementScroll = 0
    LoadMusic(music[cur][1])
end

function scene.draw()
    love.graphics.setColor(1,1,1)
    love.graphics.draw(MenuBGMesh, -((GlobalTime*48)%MenuBG:getWidth()), -((GlobalTime*48)%MenuBG:getHeight()))
    love.graphics.draw(Logo, love.graphics.getWidth()/2, love.graphics.getHeight()/2+ViewMargin, 0, Settings["video"]["ui_scale"], Settings["video"]["ui_scale"], Logo:getWidth()/2, Logo:getHeight()/2)
    love.graphics.setFont(xlfont)
    love.graphics.printf(music[cur][2], 0, love.graphics.getHeight()/2 + Logo:getHeight()*ViewScale+ViewMargin, love.graphics.getWidth(), "center")
end

function scene.wheelmoved(x, y)
    AchievementScroll = AchievementScroll - y*24
end

function scene.update(dt)
    if love.keyboard.isDown("up") then
        AchievementScroll = AchievementScroll - 8
    end
    if love.keyboard.isDown("down") then
        AchievementScroll = AchievementScroll + 8
    end
end

function scene.keypressed(k)
    if k == "escape" then
        SceneManager.LoadScene("scenes/menu")
    end
    if k == "right" then
        cur = (cur%#music) + 1
        StopMusic()
        LoadMusic(music[cur][1])
    end
    if k == "left" then
        cur = ((cur-2)%#music) + 1
        StopMusic()
        LoadMusic(music[cur][1])
    end
    if k == "space" then
        if not Music then
            LoadMusic(music[cur][1])
        elseif Music:isPlaying() then
            StopMusic()
        else
            LoadMusic(music[cur][1])
        end
    end
end

return scene
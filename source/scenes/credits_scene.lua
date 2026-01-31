--[[
    WIN SCENE
    Shown when all boids are happy.

    Like the menu scene, this overrides update() directly.

    To get here from the boid scene, call:
        GAME_WORLD:queueScene(WinScene())
]]

local gfx = playdate.graphics

function CreditScene()
    local scene = Scene.new("win")

    function scene:onEnter()
        -- TODO: Play victory sound, save score, etc.
    end

    function scene:update()
        gfx.clear(gfx.kColorWhite)

        local ypos = -60

        gfx.drawTextAligned("*Thanks for playing!*", 200, 80 + ypos, kTextAlignment.center)
        gfx.drawTextAligned("Game by The Big Mahjong Boys!", 200, 110+ ypos, kTextAlignment.center)
        gfx.drawTextAligned("Dennis", 200, 160+ ypos, kTextAlignment.center)
        gfx.drawTextAligned("Kiyoma", 200, 190+ ypos, kTextAlignment.center)
        gfx.drawTextAligned("RodAraujo", 200, 220+ ypos, kTextAlignment.center)
        gfx.drawTextAligned("Vidsneeze(Oscar)", 200, 250+ ypos, kTextAlignment.center)

        if playdate.buttonJustPressed(playdate.kButtonA) then
            GAME_WORLD:queueScene(BoidScene())
        end
    end

    function scene:onExit()
        -- Clean up
    end

    return scene
end

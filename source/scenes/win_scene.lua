--[[
    WIN SCENE
    Shown when all boids are happy.

    Like the menu scene, this overrides update() directly.

    To get here from the boid scene, call:
        GAME_WORLD:queueScene(WinScene())
]]

local gfx = playdate.graphics

function WinScene()
    local scene = Scene.new("win")

    function scene:onEnter()
        -- TODO: Play victory sound, save score, etc.
    end

    function scene:update()
        gfx.clear(gfx.kColorWhite)

        gfx.drawTextAligned("*YOU WIN!*", 200, 80, kTextAlignment.center)
        gfx.drawTextAligned("Everyone is happy!", 200, 110, kTextAlignment.center)
        gfx.drawTextAligned("Press A to play again", 200, 140, kTextAlignment.center)

        if playdate.buttonJustPressed(playdate.kButtonA) then
            GAME_WORLD:queueScene(CreditScene())
        end
    end

    function scene:onExit()
        -- Clean up
    end

    return scene
end

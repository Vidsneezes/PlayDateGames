--[[
    GAME OVER SCENE
    Shown when the game ends.

    Like the menu scene, this overrides update() directly.

    To get here from the game scene, any system can call:
        GAME_WORLD:queueScene(GameOverScene())
]]

local gfx = playdate.graphics

function GameOverScene()
    local scene = Scene.new("gameover")

    function scene:onEnter()
        -- TODO: Play game over sound, save high score, etc.
    end

    function scene:update()
        gfx.clear(gfx.kColorWhite)

        -- TODO: Replace with your game over screen
        gfx.drawTextAligned("*GAME OVER*", 200, 80, kTextAlignment.center)
        gfx.drawTextAligned("Press A to Restart", 200, 140, kTextAlignment.center)

        if playdate.buttonJustPressed(playdate.kButtonA) then
            SoundBank.playSfx("coin")
            GAME_WORLD:queueScene(MenuScene())
        end
    end

    function scene:onExit()
        -- TODO: Clean up
    end

    return scene
end

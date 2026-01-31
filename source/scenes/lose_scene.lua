--[[
    LOSE SCENE
    Shown when all boids become angry.

    Like the menu scene, this overrides update() directly.

    To get here from the boid scene, call:
        GAME_WORLD:queueScene(LoseScene())
]]

local gfx = playdate.graphics

function LoseScene()
    local scene = Scene.new("lose")

    function scene:onEnter()
        -- TODO: Play lose sound, etc.
    end

    function scene:update()
        gfx.clear(gfx.kColorWhite)

        gfx.drawTextAligned("*YOU LOSE*", 200, 80, kTextAlignment.center)
        gfx.drawTextAligned("Everyone is angry!", 200, 110, kTextAlignment.center)
        gfx.drawTextAligned("Press A to try again", 200, 140, kTextAlignment.center)

        if playdate.buttonJustPressed(playdate.kButtonA) then
            GAME_WORLD:queueScene(MenuScene())
        end
    end

    function scene:onExit()
        -- Clean up
    end

    return scene
end

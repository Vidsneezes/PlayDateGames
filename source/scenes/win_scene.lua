--[[
    WIN SCENE
    Shown when all boids are happy.

    Like the menu scene, this overrides update() directly.

    To get here from the boid scene, call:
        GAME_WORLD:queueScene(WinScene())
]]

local gfx = playdate.graphics

function WinScene(boidCount, explosionsHappy, explosionsAngry)
    local scene = Scene.new("win")
    local totalBoids = boidCount or 0
    local happyExplosions = explosionsHappy or 0
    local angryExplosions = explosionsAngry or 0

    function scene:onEnter()
        -- TODO: Play victory sound, save score, etc.
    end

    function scene:update()
        gfx.clear(gfx.kColorWhite)

        gfx.drawTextAligned("*YOU WIN!*", 200, 70, kTextAlignment.center)
        gfx.drawTextAligned("You made " .. totalBoids .. " boids happy!", 200, 95, kTextAlignment.center)

        -- Show explosion stats
        if happyExplosions > 0 or angryExplosions > 0 then
            gfx.drawTextAligned("Explosions:", 200, 120, kTextAlignment.center)
            if happyExplosions > 0 then
                gfx.drawTextAligned("Too happy: " .. happyExplosions, 200, 135, kTextAlignment.center)
            end
            if angryExplosions > 0 then
                gfx.drawTextAligned("Too angry: " .. angryExplosions, 200, 150, kTextAlignment.center)
            end
            gfx.drawTextAligned("Press A to continue", 200, 175, kTextAlignment.center)
        else
            gfx.drawTextAligned("Perfect! No explosions!", 200, 120, kTextAlignment.center)
            gfx.drawTextAligned("Press A to continue", 200, 150, kTextAlignment.center)
        end

        if playdate.buttonJustPressed(playdate.kButtonA) then
            GAME_WORLD:queueScene(CreditScene())
        end
    end

    function scene:onExit()
        -- Clean up
    end

    return scene
end

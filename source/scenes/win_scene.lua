--[[
    WIN SCENE
    Shown when all boids are happy.

    Like the menu scene, this overrides update() directly.

    To get here from the boid scene, call:
        GAME_WORLD:queueScene(WinScene())
]]

local gfx = playdate.graphics

function WinScene(explosionsHappy, explosionsAngry)
    local scene = Scene.new("win")
    local totalExplosions = (explosionsHappy or 0) + (explosionsAngry or 0)

    function scene:onEnter()
        -- Play victory music!
        SoundBank.playMusic("win")
        SoundBank.setTrackVolume("bass", 0.9)
        SoundBank.setTrackVolume("melody", 0.8)
        SoundBank.setTrackVolume("drums", 0.6)
    end

    function scene:update()
        gfx.clear(gfx.kColorWhite)

        gfx.drawTextAligned("*YOU WIN!*", 200, 70, kTextAlignment.center)
        gfx.drawTextAligned("You made everybody happy!", 200, 95, kTextAlignment.center)

        -- Show explosion stats
        if totalExplosions > 0 then
            gfx.drawTextAligned("But " .. totalExplosions .. " people exploded!", 200, 120, kTextAlignment.center)
            gfx.drawTextAligned("Press A to continue", 200, 150, kTextAlignment.center)
        else
            gfx.drawTextAligned("And nobody exploded!", 200, 120, kTextAlignment.center)
            gfx.drawTextAligned("Press A to continue", 200, 150, kTextAlignment.center)
        end

        if playdate.buttonJustPressed(playdate.kButtonA) then
            GAME_WORLD:queueScene(CreditScene())
        end
    end

    function scene:onExit()
        -- Stop victory music
        SoundBank.stopMusic()
    end

    return scene
end

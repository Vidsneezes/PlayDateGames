--[[
    LOSE SCENE
    Shown when all boids become angry.

    Like the menu scene, this overrides update() directly.

    To get here from the boid scene, call:
        GAME_WORLD:queueScene(LoseScene())
]]

local gfx = playdate.graphics

function LoseScene(explosionsHappy, explosionsAngry)
    local scene = Scene.new("lose")
    local totalExplosions = (explosionsHappy or 0) + (explosionsAngry or 0)

    function scene:onEnter()
        -- Play defeat music (sad descending tones)
        SoundBank.playMusic("lose")
        SoundBank.setTrackVolume("bass", 0.8)
        SoundBank.setTrackVolume("melody", 0.7)
        SoundBank.setTrackVolume("drums", 0.3)
    end

    function scene:update()
        gfx.clear(gfx.kColorWhite)

        gfx.drawTextAligned("*YOU LOSE*", 200, 80, kTextAlignment.center)
        gfx.drawTextAligned(totalExplosions .. " people exploded!", 200, 110, kTextAlignment.center)
        gfx.drawTextAligned("Press A to try again", 200, 140, kTextAlignment.center)

        if playdate.buttonJustPressed(playdate.kButtonA) then
            GAME_WORLD:queueScene(MenuScene())
        end
    end

    function scene:onExit()
        -- Stop defeat music
        SoundBank.stopMusic()
    end

    return scene
end

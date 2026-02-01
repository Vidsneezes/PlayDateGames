--[[
    MENU SCENE
    Title screen / main menu.

    This scene overrides update() directly instead of using systems,
    since menus usually don't need entity processing.

    To transition to the game:
        GAME_WORLD:queueScene(GameScene())
]]

local gfx = playdate.graphics

function MenuScene()
    local scene = Scene.new("menu")

    function scene:onEnter()
        -- Start menu music (procedural jazz track)
        SoundBank.playMusic("menu")
        SoundBank.setTrackVolume("bass", 0.8)
        SoundBank.setTrackVolume("melody", 0.6)
        SoundBank.setTrackVolume("drums", 0.4)
    end

    function scene:update()
        gfx.clear(gfx.kColorWhite)

        -- Title screen with two scene options
        gfx.drawTextAligned("Masked Boidlings", 200, 60, kTextAlignment.center)
        gfx.drawTextAligned("Press A to start", 200, 120, kTextAlignment.center)

        if playdate.buttonJustPressed(playdate.kButtonA) then
            GAME_WORLD:queueScene(BoidScene())
        end
    end

    function scene:onExit()
        -- Stop menu music when leaving
        SoundBank.stopMusic()
    end

    return scene
end

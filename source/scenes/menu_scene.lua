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
        -- TODO: Load menu assets, play title music, etc.
    end

    function scene:update()
        gfx.clear(gfx.kColorWhite)

        -- Title screen with two scene options
        gfx.drawTextAligned("*GAME JAM*", 200, 60, kTextAlignment.center)
        gfx.drawTextAligned("Press A for Game Scene", 200, 120, kTextAlignment.center)
        gfx.drawTextAligned("Press B for Boid Scene", 200, 140, kTextAlignment.center)
        gfx.drawTextAligned("Press DOWN for Test Audio Scene", 200, 160, kTextAlignment.center)

        if playdate.buttonJustPressed(playdate.kButtonA) then
            GAME_WORLD:queueScene(GameScene())
        elseif playdate.buttonJustPressed(playdate.kButtonB) then
            GAME_WORLD:queueScene(BoidScene())
        elseif playdate.buttonJustPressed(playdate.kButtonDown) then
            GAME_WORLD:queueScene(TestAudioScene())
        end
    end

    function scene:onExit()
        -- TODO: Stop title music, clean up, etc.
    end

    return scene
end

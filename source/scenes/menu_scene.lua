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

        -- TODO: Replace with your title screen
        gfx.drawTextAligned("*GAME TITLE*", 200, 80, kTextAlignment.center)
        gfx.drawTextAligned("Press A to Start", 200, 140, kTextAlignment.center)

        if playdate.buttonJustPressed(playdate.kButtonA) then
            GAME_WORLD:queueScene(GameScene())
        end
    end

    function scene:onExit()
        -- TODO: Stop title music, clean up, etc.
    end

    return scene
end

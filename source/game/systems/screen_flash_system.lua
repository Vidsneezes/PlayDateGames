--[[
    SCREEN FLASH SYSTEM
    Renders a white flash effect over the entire screen.

    Used for the SAD Bomb visual feedback.
    Draws a full-screen white rectangle when scene.screenFlash > 0.

    ── Playdate SDK Quick Reference ──────────────────────

    Drawing:
        gfx.setColor(gfx.kColorWhite)
        gfx.fillRect(x, y, width, height)

    ──────────────────────────────────────────────────────
]]

local gfx = playdate.graphics

ScreenFlashSystem = System.new("screenFlash", {}, function(entities, scene)
    -- Check if flash is active
    if scene.screenFlash > 0 then
        -- Draw full-screen white flash
        gfx.setColor(gfx.kColorWhite)
        gfx.fillRect(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT)

        -- Decrement flash timer
        scene.screenFlash -= 1
    end
end)

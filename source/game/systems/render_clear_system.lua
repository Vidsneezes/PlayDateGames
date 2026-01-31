--[[
    CLEAR RENDER SYSTEM
    Clears the screen to white at the start of each frame.

    This system should be registered FIRST in the render pipeline
    so all other render systems draw on a clean canvas.

    ── Playdate SDK Quick Reference ──────────────────────

    Graphics:
        gfx.clear(gfx.kColorWhite)  -- Clear screen to white
        gfx.clear(gfx.kColorBlack)  -- Clear screen to black

    ──────────────────────────────────────────────────────
]]

local gfx = playdate.graphics

RenderClearSystem = System.new("renderClear", {}, function(entities, scene)
    gfx.clear(gfx.kColorWhite)
end)

--[[
    CAPTURED RENDER SYSTEM
    Draws square outlines around captured boids.

    Runs after sprite rendering to show capture state.

    ── Playdate SDK Quick Reference ──────────────────────

    Drawing:
        gfx.setColor(gfx.kColorBlack / kColorWhite)
        gfx.drawRect(x, y, w, h)  -- outline

    ──────────────────────────────────────────────────────
]]

local gfx = playdate.graphics

RenderCapturedSystem = System.new("renderCaptured", {"transform", "captured"}, function(entities, scene)
    -- Get camera offset
    local camX = 0
    local camY = 0
    if scene.camera then
        camX = scene.camera.x
        camY = scene.camera.y
    end

    -- Draw square around each captured boid
    for _, e in ipairs(entities) do
        local screenX = e.transform.x - camX
        local screenY = e.transform.y - camY

        -- Draw square outline (slightly larger than sprite)
        local squareSize = 36
        local squareX = screenX - squareSize / 2
        local squareY = screenY - squareSize / 2

        gfx.setColor(gfx.kColorBlack)
        gfx.setLineWidth(2)
        gfx.drawRect(squareX, squareY, squareSize, squareSize)
        gfx.setLineWidth(1)
    end
end)

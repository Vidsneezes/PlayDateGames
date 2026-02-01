--[[
    CAPTURED BUBBLE RENDER SYSTEM
    Draws ghost bubbles showing captured boids.

    Bubbles stay on screen for the entire game, showing capture progress.

    ── Playdate SDK Quick Reference ──────────────────────

    Sprites:
        sprite:moveTo(x, y)  -- Move sprite to screen position

    ──────────────────────────────────────────────────────
]]

local gfx = playdate.graphics

RenderCapturedSystem = System.new("renderCaptured", {"transform", "capturedBubble"}, function(entities, scene)
    -- Get camera offset
    local camX = 0
    local camY = 0
    if scene.camera then
        camX = scene.camera.x
        camY = scene.camera.y
    end

    -- Move all bubble sprites to their screen positions
    for _, e in ipairs(entities) do
        local screenX = e.transform.x - camX
        local screenY = e.transform.y - camY

        e.capturedBubble.sprite:setImage(animationGhost:image())
        e.capturedBubble.sprite:moveTo(screenX, screenY)
    end
end)

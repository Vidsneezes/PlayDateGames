--[[
    EXPLOSION MARK RENDER SYSTEM
    Draws permanent X marks where boids exploded.

    These marks stay on screen for the entire game, creating a visual
    history of all explosions.

    ── Playdate SDK Quick Reference ──────────────────────

    Drawing:
        gfx.setColor(gfx.kColorBlack / kColorWhite)
        gfx.drawLine(x1, y1, x2, y2)
        gfx.setLineWidth(width)

    ──────────────────────────────────────────────────────
]]

local gfx = playdate.graphics

-- Load RIP sprite (cached)
local ripSprite = nil

RenderExplosionMarkSystem = System.new("renderExplosionMark", {"transform", "explosionMark"}, function(entities, scene)
    -- Get camera offset
    local camX = 0
    local camY = 0
    if scene.camera then
        camX = scene.camera.x
        camY = scene.camera.y
    end

    -- Draw all explosion marks
    for _, e in ipairs(entities) do
        local screenX = e.transform.x - camX
        local screenY = e.transform.y - camY

        e.explosionMark.sprite:moveTo(screenX, screenY)
    end
end)

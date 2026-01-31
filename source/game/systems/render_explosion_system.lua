--[[
    EXPLOSION RENDER SYSTEM
    Draws explosion effects and cleans up exploding entities.

    Runs after all other rendering to ensure explosions are visible.

    ── Playdate SDK Quick Reference ──────────────────────

    Drawing:
        gfx.setColor(gfx.kColorBlack / kColorWhite)
        gfx.fillRect(x, y, w, h)

    ──────────────────────────────────────────────────────
]]

local gfx = playdate.graphics

RenderExplosionSystem = System.new("renderExplosion", { "transform", "exploding" }, function(entities, scene)
    -- Get camera offset
    local camX = 0
    local camY = 0
    if scene.camera then
        camX = scene.camera.x
        camY = scene.camera.y
    end

    -- Draw explosions and mark for cleanup
    for _, e in ipairs(entities) do
        local screenX = e.transform.x - camX
        local screenY = e.transform.y - camY
        local explosionSize = 40

        -- Draw explosion square (placeholder)
        gfx.setColor(gfx.kColorBlack)
        gfx.fillRect(screenX - explosionSize / 2, screenY - explosionSize / 2, explosionSize, explosionSize)

        -- Mark entity for deletion after drawing
        e.active = false

        -- Play sfx sound
        SynthTriggerSFX("explosion")
    end
end)

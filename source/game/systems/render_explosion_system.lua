--[[
    EXPLOSION RENDER SYSTEM
    Draws explosion effects.

    Handles two types of explosion entities:
    1. Legacy "exploding" component (boids) - rendered once then deleted
    2. "explosionEffect" component (new dedicated entities) - rendered for their lifetime

    Runs after all other rendering to ensure explosions are visible.

    ── Playdate SDK Quick Reference ──────────────────────

    Drawing:
        gfx.setColor(gfx.kColorBlack / kColorWhite)
        gfx.fillRect(x, y, w, h)

    ──────────────────────────────────────────────────────
]]

local gfx = playdate.graphics

RenderExplosionSystem = System.new("renderExplosion", { "transform", "explosionAnim" }, function(entities, scene)
    -- Get camera offset
    local camX = 0
    local camY = 0
    if scene.camera then
        camX = scene.camera.x
        camY = scene.camera.y
    end

    -- Draw explosions
    for _, e in ipairs(entities) do
        -- Only render entities with explosion-related components
        if e.exploding or e.explosionEffect then
            local screenX = e.transform.x - camX
            local screenY = e.transform.y - camY
            local explosionSize = 28

            -- Draw explosion square (placeholder - teammate will replace with animation)
            e.explosionAnim.animation:draw(screenX - explosionSize / 2, screenY - explosionSize / 2, explosionSize, explosionSize)

            -- Legacy: clean up old "exploding" boids immediately
            if e.exploding then
                e.active = false
                SoundBank.playSfx("explosion")
            end
        end
    end
end)

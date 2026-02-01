--[[
    EXPLOSION EFFECT SYSTEM
    Manages the lifetime of explosion effect entities.

    These are separate entities spawned when boids explode.
    They live for a set duration (~1 second) then clean themselves up.

    ── Playdate SDK Quick Reference ──────────────────────

    No SDK calls needed - pure component logic.

    ──────────────────────────────────────────────────────
]]

ExplosionEffectSystem = System.new("explosionEffect", {"explosionEffect", "transform"}, function(entities, scene)
    for _, e in ipairs(entities) do
        -- Increment age
        e.explosionEffect.age += 1

        -- Remove when lifetime expires
        if e.explosionEffect.age >= e.explosionEffect.lifetime then
            e.active = false
        end
    end
end)

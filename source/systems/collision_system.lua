--[[
    COLLISION SYSTEM
    Detects collisions between entities that have transform + collider components.

    ── Playdate SDK Quick Reference ──────────────────────

    Geometry helpers:
        playdate.geometry.rect.new(x, y, w, h)
        rect1:intersects(rect2)                    -- true/false

    Sprite-based collisions (if using the sprite system):
        sprite:setCollideRect(x, y, w, h)          -- set collision bounds
        sprite:setGroups({1})                       -- this sprite's group(s)
        sprite:setCollidesWithGroups({2, 3})        -- groups it collides with

        -- Move with collision response:
        local ax, ay, collisions, len = sprite:moveWithCollisions(goalX, goalY)

        -- Check overlaps without moving:
        local overlaps = sprite:overlappingSprites()

        -- Collision response types:
        sprite:setCollisionResponse(gfx.sprite.kCollisionTypeSlide)
        -- kCollisionTypeSlide   -- slide along surfaces
        -- kCollisionTypeFreeze  -- stop at collision point
        -- kCollisionTypeBounce  -- bounce off
        -- kCollisionTypeOverlap -- pass through (just detect)

    Manual AABB check (no sprites needed):
        local function aabb(ax, ay, aw, ah, bx, by, bw, bh)
            return ax < bx+bw and ax+aw > bx and ay < by+bh and ay+ah > by
        end

    Circle collision (distance-based):
        local dx = a.transform.x - b.transform.x
        local dy = a.transform.y - b.transform.y
        local dist = math.sqrt(dx*dx + dy*dy)
        if dist < (radiusA + radiusB) then
            -- collision!
        end

    ──────────────────────────────────────────────────────
]]

CollisionSystem = System.new("collision", {"transform", "collider"}, function(entities, scene)
    -- Simple O(n^2) pair check -- perfectly fine for small entity counts
    for i = 1, #entities do
        for j = i + 1, #entities do
            local a = entities[i]
            local b = entities[j]

            -- TODO: Choose your collision shape and implement detection
            --
            -- Example (AABB):
            -- local ax, ay = a.transform.x, a.transform.y
            -- local bx, by = b.transform.x, b.transform.y
            -- if ax < bx + b.collider.width and ax + a.collider.width > bx
            --     and ay < by + b.collider.height and ay + a.collider.height > by then
            --     onCollision(a, b, scene)
            -- end
        end
    end
end)

-- TODO: Define what happens when two entities collide
-- local function onCollision(a, b, scene)
--     -- Example: destroy one, play a sound, add score, etc.
--     -- b.active = false
--     -- if a.audioSource then a.audioSource.shouldPlay = true end
-- end

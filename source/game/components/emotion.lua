--[[
    EMOTION COMPONENTS
    Separate components for each boid emotion type.
    Each has its own parameters for customization.

    Usage:
        local happyBoid = Entity.new({
            transform = Transform(100, 50),
            velocity = Velocity(0, 0),
            happyBoid = HappyBoid(),  -- or HappyBoid(2.0) for custom speed
            sprite = SpriteComp(image)
        })

    Emotion types:
        HappyBoid - moves toward center of world
        SadBoid   - moves toward nearest edge of world
        AngryBoid - moves toward closest non-angry boid
]]

-- Happy boids move toward the center of the world
function HappyBoid(speed)
    return {
        speed = speed or 1.5,  -- movement speed
    }
end

-- Sad boids move toward the nearest edge of the world
function SadBoid(speed)
    return {
        speed = speed or 1.0,  -- movement speed
    }
end

-- Angry boids chase other (non-angry) boids
function AngryBoid(speed, detectionRange)
    return {
        speed = speed or 2.5,              -- movement speed (was 2.0)
        detectionRange = detectionRange or 999,  -- how far they can detect targets
    }
end

-- Emotional battery - determines emotion state over time
-- 0-30: Angry, 31-60: Sad, 61+: Happy
function EmotionalBattery(value)
    return {
        value = value or 100,  -- current battery level (0-100)
        max = 100,
    }
end

-- Explosion marker (entity will be deleted after rendering)
function Exploding()
    return {
        frameCount = 0  -- frames to show explosion
    }
end

-- Captured marker (entity is frozen in place with locked happiness)
function Captured()
    return {
        frozen = true  -- movement and happiness frozen
    }
end

-- ExplosionEffect - separate entity for explosion animations
-- This component marks entities that are explosion effects (not boids)
function ExplosionEffect(lifetime)
    return {
        age = 0,                    -- frames since creation
        lifetime = lifetime or 30,  -- frames before cleanup (30 = 1 second at 30 FPS)
    }
end

-- ExplosionMark - permanent X mark showing where a boid exploded
-- These marks never disappear, creating a visual history of explosions
function ExplosionMark()
    local spriteX = playdate.graphics.sprite.new(tombstoneImage)
    spriteX:setZIndex(-200)
    spriteX:add()
    return {
        markType = "X",  -- could support different mark types later
        sprite = spriteX
    }
end

-- CapturedBubble - permanent ghost bubble showing a captured boid
-- These marks never disappear, showing all captured boids
function CapturedBubble()
    local bubbleSprite = playdate.graphics.sprite.new(bubbleHappyImage)
    bubbleSprite:setZIndex(-200)
    bubbleSprite:add()
    return {
        sprite = bubbleSprite
    }
end

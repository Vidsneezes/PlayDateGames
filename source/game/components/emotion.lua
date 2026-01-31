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
        speed = speed or 2.0,              -- movement speed
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

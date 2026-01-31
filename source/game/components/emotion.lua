--[[
    EMOTION COMPONENT
    Defines the emotional state of a boid, which drives its behavior.

    Usage:
        local boid = Entity.new({
            transform = Transform(100, 50),
            velocity = Velocity(0, 0),
            emotion = Emotion("happy"),
            sprite = SpriteComp(image)
        })

    Emotion types:
        "happy" - moves toward center of world
        "sad"   - moves toward nearest edge of world
        "angry" - moves toward closest non-angry boid
]]

function Emotion(type)
    return {
        type = type,  -- "happy", "sad", or "angry"
    }
end

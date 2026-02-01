--[[
    UTILITIES
    Shared helper functions available everywhere.

    These are loaded early so all systems and scenes can use them.
]]

-- Screen dimensions (Playdate is always 400x240)
SCREEN_WIDTH = 400
SCREEN_HEIGHT = 240

-- World dimensions (adjust for testing - set to screen size for easy testing)
WORLD_WIDTH = 1200   -- Set to 400 to match viewport for testing
WORLD_HEIGHT = 800   -- Set to 240 to match viewport for testing

-- Clamp a value between min and max
function clamp(val, min, max)
    return math.max(min, math.min(max, val))
end

-- Random float in range [min, max]
function random_float(min, max)
    return min + math.random() * (max - min)
end

-- Linear interpolation from a to b by factor t (0-1)
function lerp(a, b, t)
    return a + (b - a) * t
end

-- Distance between two points
function distance(x1, y1, x2, y2)
    local dx = x2 - x1
    local dy = y2 - y1
    return math.sqrt(dx * dx + dy * dy)
end

-- Check if a boid is within a camera frame
-- frameInset: 40 for influence mode, 80 for capture mode
function isInCameraFrame(transform, camera, frameInset)
    if not camera then return true end

    frameInset = frameInset or 40  -- Default to influence mode

    local camX = camera.x
    local camY = camera.y
    local screenX = transform.x - camX
    local screenY = transform.y - camY

    local statusBarHeight = 35
    local frameLeft = frameInset
    local frameTop = frameInset
    local frameRight = frameInset + (SCREEN_WIDTH - (frameInset * 2))
    local frameBottom = frameInset + ((SCREEN_HEIGHT - statusBarHeight) - (frameInset * 2))

    return screenX >= frameLeft and screenX <= frameRight and
           screenY >= frameTop and screenY <= frameBottom
end

-- Create sprite image for emotion type
function createEmotionSprite(emotionType)
    local img = boidSpriteHappy

    if emotionType == "happy" then
        img = animationBoidHeadHappy:image()
    elseif emotionType == "sad" then
        img = animationBoidHeadSad:image()
    elseif emotionType == "angry" then
        img = animationBoidHeadAngry:image()
    end

    return img
end

-- Load a JSON config file via Playdate datastore
-- Usage: local config = loadConfig("Data")
function loadConfig(path)
    return playdate.datastore.read(path)
end

-- Set a fullscreen background image
-- Usage: setBackground("Images/background")
function setBackground(imagePath)
    local gfx = playdate.graphics
    local bgImage = gfx.image.new(imagePath)
    if bgImage then
        gfx.sprite.setBackgroundDrawingCallback(function()
            bgImage:draw(0, 0)
        end)
    end
end

function getCameraPosition(camera, gfx)
    camX = camera.x
    camY = camera.y

    -- Draw world background pattern
    gfx.setColor(gfx.kColorBlack)
    local gridSize = 40
    local worldW = camera.worldWidth
    local worldH = camera.worldHeight

    -- Draw grid lines (only visible portion)
    local startX = math.floor(camX / gridSize) * gridSize
    local startY = math.floor(camY / gridSize) * gridSize

    for x = startX, camX + SCREEN_WIDTH, gridSize do
        local screenX = x - camX
        gfx.drawLine(screenX, 0, screenX, SCREEN_HEIGHT)
    end

    for y = startY, camY + SCREEN_HEIGHT, gridSize do
        local screenY = y - camY
        gfx.drawLine(0, screenY, SCREEN_WIDTH, screenY)
    end

    -- Draw world border
    gfx.setLineWidth(2)
    local borderX = 0 - camX
    local borderY = 0 - camY
    gfx.drawRect(borderX, borderY, worldW, worldH)
    gfx.setLineWidth(1)
end

-- Spawn an explosion effect entity at the given position
-- Returns the created entity (in case you need to track it)
function spawnExplosion(scene, x, y, lifetime)
    -- Play explosion sound
    SynthTriggerSFX("explosion")

    -- Create a new explosion entity
    local explosion = Entity.new({
        transform = Transform(x, y),
        explosionEffect = ExplosionEffect(lifetime or 10),-- default 1 second
        explosionAnim = ExplosionAnim()
    })

    scene:addEntity(explosion)
    return explosion
end

--[[
    UTILITIES
    Shared helper functions available everywhere.

    These are loaded early so all systems and scenes can use them.
]]

-- Screen dimensions (Playdate is always 400x240)
SCREEN_WIDTH = 400
SCREEN_HEIGHT = 240

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

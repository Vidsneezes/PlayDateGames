--[[
    RENDER SYSTEM
    Draws entities that have a transform and a sprite component.
    This system should be registered LAST so it draws on top of everything.

    ── Playdate SDK Quick Reference ──────────────────────

    Graphics basics:
        local gfx = playdate.graphics

        gfx.clear(gfx.kColorWhite)                  -- clear screen
        gfx.setColor(gfx.kColorBlack)                -- kColorBlack or kColorWhite
        gfx.drawText("Hello", x, y)                  -- draw text at position
        gfx.drawTextAligned("Hi", x, y, align)       -- align: kTextAlignment.center/left/right
        gfx.drawRect(x, y, w, h)                     -- rectangle outline
        gfx.fillRect(x, y, w, h)                     -- filled rectangle
        gfx.drawCircleAtPoint(x, y, r)               -- circle outline
        gfx.fillCircleAtPoint(x, y, r)               -- filled circle

    Images:
        local img = gfx.image.new("Images/myImage")  -- load from file (no extension)
        local img = gfx.image.new(w, h)              -- create blank image
        img:draw(x, y)                               -- draw at position
        img:drawCentered(x, y)                        -- draw centered at position

        -- Draw INTO an image:
        gfx.lockFocus(img)
            gfx.fillRect(0, 0, 10, 10)
        gfx.unlockFocus()

    Sprites (managed drawing):
        local sprite = gfx.sprite.new(image)
        sprite:moveTo(x, y)
        sprite:add()                                 -- add to display list
        sprite:remove()                              -- remove from display list
        gfx.sprite.update()                          -- redraws all sprites

    Animation:
        -- Image table: load a series of frames
        local imgTable = gfx.imagetable.new("Images/anim")
        local anim = gfx.animation.loop.new(delay_ms, imgTable, shouldLoop)
        anim:draw(x, y)

    Text styling:
        gfx.drawText("*bold* _italic_ ~custom~", x, y)
        gfx.setFont(font)

    Screen: 400 x 240 pixels, 1-bit color (black and white only)

    ──────────────────────────────────────────────────────
]]

local gfx = playdate.graphics

RenderSystem = System.new("render", {"transform", "sprite"}, function(entities, scene)

    -- Get camera offset
    local camX = 0
    local camY = 0
    if scene.camera then
        camX = scene.camera.x
        camY = scene.camera.y

        -- GRID DISABLED FOR TESTING
        -- Draw world background pattern
        -- gfx.setColor(gfx.kColorBlack)
        -- local gridSize = 40
        -- local worldW = scene.camera.worldWidth
        -- local worldH = scene.camera.worldHeight

        -- -- Draw grid lines (only visible portion)
        -- local startX = math.floor(camX / gridSize) * gridSize
        -- local startY = math.floor(camY / gridSize) * gridSize

        -- for x = startX, camX + SCREEN_WIDTH, gridSize do
        --     local screenX = x - camX
        --     gfx.drawLine(screenX, 0, screenX, SCREEN_HEIGHT)
        -- end

        -- for y = startY, camY + SCREEN_HEIGHT, gridSize do
        --     local screenY = y - camY
        --     gfx.drawLine(0, screenY, SCREEN_WIDTH, screenY)
        -- end

        -- -- Draw world border
        -- gfx.setLineWidth(2)
        -- local borderX = 0 - camX
        -- local borderY = 0 - camY
        -- gfx.drawRect(borderX, borderY, worldW, worldH)
        -- gfx.setLineWidth(1)
    end

    -- Draw entities with camera offset
    for _, e in ipairs(entities) do
        local t = e.transform
        local s = e.sprite

        if s.visible and s.image then
            local screenX = t.x - camX
            local screenY = t.y - camY
            s.image:draw(screenX, screenY)
        end
    end

    -- Draw debug info (FPS and boid counter) in upper right corner
    gfx.setColor(gfx.kColorBlack)

    -- Get FPS
    local fps = math.floor(playdate.getFPS())
    local fpsText = "FPS: " .. tostring(fps)

    -- Count boids (entities with happy, sad, or angry boid components)
    local boidCount = 0
    for _, entity in ipairs(scene.entities) do
        if entity.happyBoid or entity.sadBoid or entity.angryBoid then
            boidCount += 1
        end
    end
    local boidText = "Boids: " .. tostring(boidCount)

    -- Draw FPS counter (right-aligned)
    local fpsWidth = gfx.getTextSize(fpsText)
    gfx.drawText(fpsText, SCREEN_WIDTH - fpsWidth - 5, 5)

    -- Draw boid counter below FPS (right-aligned)
    local boidWidth = gfx.getTextSize(boidText)
    gfx.drawText(boidText, SCREEN_WIDTH - boidWidth - 5, 20)
end)

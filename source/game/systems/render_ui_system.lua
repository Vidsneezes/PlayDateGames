--[[
    HAPPINESS UI SYSTEM
    Draws the happiness meter showing total happiness of visible boids.

    Displays a vertical bar on the right side of the screen.
    Bar fill represents: (total happiness of visible boids) / (max possible happiness)

    ── Playdate SDK Quick Reference ──────────────────────

    Drawing:
        gfx.setColor(gfx.kColorBlack / kColorWhite)
        gfx.drawRect(x, y, w, h)    -- outline
        gfx.fillRect(x, y, w, h)    -- filled
        gfx.setLineWidth(width)
        gfx.drawText(text, x, y)

    ──────────────────────────────────────────────────────
]]

local gfx = playdate.graphics

-- Helper: Check if a boid is visible in the current viewport
local function isVisible(transform, camera)
    local camX = camera.x
    local camY = camera.y

    return transform.x >= camX and transform.x <= camX + SCREEN_WIDTH and
           transform.y >= camY and transform.y <= camY + SCREEN_HEIGHT
end

RenderUISystem = System.new("renderUI", {"transform", "emotionalBattery"}, function(entities, scene)
    if not scene.camera then return end

    -- Only show happiness gauge while paused
    if not scene.isPaused then
        return
    end

    -- Find visible boids and calculate happiness
    local visibleCount = 0
    local totalHappiness = 0

    for _, e in ipairs(entities) do
        if isVisible(e.transform, scene.camera) then
            visibleCount += 1
            totalHappiness += e.emotionalBattery.value
        end
    end

    -- Calculate happiness ratio
    local maxHappiness = visibleCount * 100
    local happinessRatio = 0
    if maxHappiness > 0 then
        happinessRatio = totalHappiness / maxHappiness
    end

    -- Draw happiness bar on right side with white background panel
    local panelX = SCREEN_WIDTH - 30  -- 30px from right edge
    local panelY = 0  -- reaches all the way to the top
    local panelWidth = 30
    local statusBarHeight = 35
    local panelHeight = SCREEN_HEIGHT - statusBarHeight  -- full height minus status bar

    -- Draw white background panel
    gfx.setColor(gfx.kColorWhite)
    gfx.fillRect(panelX, panelY, panelWidth, panelHeight)

    -- Draw panel border
    gfx.setColor(gfx.kColorBlack)
    gfx.drawRect(panelX, panelY, panelWidth, panelHeight)

    -- Draw happiness bar inside panel
    local barX = panelX + 7  -- centered in panel
    local barY = panelY + 10
    local barWidth = 16
    local barHeight = panelHeight - 20

    -- Draw bar outline
    gfx.setColor(gfx.kColorBlack)
    gfx.setLineWidth(2)
    gfx.drawRect(barX, barY, barWidth, barHeight)

    -- Draw fill (current happiness)
    local fillHeight = barHeight * happinessRatio
    local fillY = barY + (barHeight - fillHeight)  -- Fill from bottom

    if fillHeight > 0 then
        gfx.setColor(gfx.kColorBlack)
        gfx.fillRect(barX + 2, fillY + 2, barWidth - 4, fillHeight - 4)
    end
end)

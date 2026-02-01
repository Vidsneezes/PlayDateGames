--[[
    UI RENDER SYSTEM
    Draws all UI elements for the game.

    Shows:
    - Captured count (Happy: X/5)
    - Explosion count (Exp: X/5)
    - Bomb charges (vertical B letters in upper right)
    - Mode indicator
    - Camera frame with corners
    - Center cross
    - Capture progress bar

    ── Playdate SDK Quick Reference ──────────────────────

    Drawing:
        gfx.setColor(gfx.kColorBlack / kColorWhite)
        gfx.drawRect(x, y, w, h)    -- outline
        gfx.fillRect(x, y, w, h)    -- filled
        gfx.drawLine(x1, y1, x2, y2)
        gfx.drawText(text, x, y)
        gfx.getTextSize(text) -> width, height

    ──────────────────────────────────────────────────────
]]

local gfx = playdate.graphics

RenderUISystem = System.new("renderUI", {}, function(entities, scene)
    -- Count captured boids and total explosions
    local capturedCount = 0
    for _, entity in ipairs(scene.entities) do
        if entity.captured then
            capturedCount += 1
        end
    end

    local totalExplosions = scene.explosionsHappy + scene.explosionsAngry

    -- UI Layout constants
    local statusBarHeight = 35
    local frameSize = 10

    -- Draw bottom status bar (white background)
    gfx.setColor(gfx.kColorWhite)
    gfx.fillRect(0, SCREEN_HEIGHT - statusBarHeight, SCREEN_WIDTH, statusBarHeight)

    -- Draw status bar border
    gfx.setColor(gfx.kColorBlack)
    gfx.drawLine(0, SCREEN_HEIGHT - statusBarHeight, SCREEN_WIDTH, SCREEN_HEIGHT - statusBarHeight)

    -- Draw status bar text (captured and explosions)
    local statusY = SCREEN_HEIGHT - statusBarHeight + 10
    animationBoidHeadHappy:draw(2, statusY - 8)
    gfx.drawText(capturedCount .. "/5", 32, statusY)

--    gfx.drawText("Happy: " .. capturedCount .. "/5  Exp: " .. totalExplosions .. "/5", 10, statusY)

    -- Draw mode indicator in lower right (UI area)
    local modeText
    if scene.currentMode == "influence" then
        modeText = "Mode: Influence"
    else -- capture mode
        modeText = "Mode: Capture"
    end

    local textWidth = gfx.getTextSize(modeText)
    local boxPadding = 5
    local modeX = SCREEN_WIDTH - 34
    local modeY = SCREEN_HEIGHT - statusBarHeight + 10

    -- Simple box with black text
    if scene.currentMode == "influence" then
        animationUIMask:draw(modeX, statusY - 8)
    else
        animationUINoMask:draw(modeX, statusY - 8)
    end
    --gfx.setColor(gfx.kColorWhite)
    --gfx.fillRect(modeX - boxPadding, modeY - 3, textWidth + boxPadding * 2, 20)
    --gfx.setColor(gfx.kColorBlack)
    --gfx.drawRect(modeX - boxPadding, modeY - 3, textWidth + boxPadding * 2, 20)
    --gfx.drawText(modeText, modeX, modeY)

    -- Draw bombs vertically in upper right corner
    local bombX = SCREEN_WIDTH - 32
    local bombStartY = 5
    local bombSpacing = 15

    for i = 1, scene.sadBombs do
        animationBomb:draw(bombX, bombStartY + (i - 1) * bombSpacing)
    end

    -- Draw camera frame (size depends on mode)
    local frameInset = (scene.currentMode == "capture") and 40 or 64
    local frameWidth = SCREEN_WIDTH - (frameInset * 2)
    local frameHeight = (SCREEN_HEIGHT - statusBarHeight) - (frameInset * 2)

    local playLeft = frameInset
    local playTop = frameInset
    local playRight = frameInset + frameWidth
    local playBottom = frameInset + frameHeight

    -- Top-left corner
    gfx.drawLine(playLeft, playTop, playLeft + frameSize, playTop)
    gfx.drawLine(playLeft, playTop, playLeft, playTop + frameSize)

    -- Top-right corner
    gfx.drawLine(playRight - frameSize, playTop, playRight, playTop)
    gfx.drawLine(playRight, playTop, playRight, playTop + frameSize)

    -- Bottom-left corner
    gfx.drawLine(playLeft, playBottom, playLeft + frameSize, playBottom)
    gfx.drawLine(playLeft, playBottom - frameSize, playLeft, playBottom)

    -- Bottom-right corner
    gfx.drawLine(playRight - frameSize, playBottom, playRight, playBottom)
    gfx.drawLine(playRight, playBottom - frameSize, playRight, playBottom)

    -- Center cross (in middle of playable area)
    local centerX = (playLeft + playRight) / 2
    local centerY = (playTop + playBottom) / 2
    local crossSize = 5
    gfx.drawLine(centerX - crossSize, centerY, centerX + crossSize, centerY)
    gfx.drawLine(centerX, centerY - crossSize, centerX, centerY + crossSize)

    -- Show capture progress bar below center cross (only when there's meaningful progress)
    if scene.currentMode == "capture" and scene.captureProgress >= 10 then
        local progBarWidth = 80
        local progBarHeight = 6
        local progBarX = centerX - progBarWidth / 2
        local progBarY = centerY + 15 -- below the cross

        -- Background
        gfx.setColor(gfx.kColorWhite)
        gfx.fillRect(progBarX, progBarY, progBarWidth, progBarHeight)

        -- Border
        gfx.setColor(gfx.kColorBlack)
        gfx.drawRect(progBarX, progBarY, progBarWidth, progBarHeight)

        -- Fill based on progress (0-180 degrees)
        local fillWidth = (scene.captureProgress / 180) * progBarWidth
        if fillWidth > 0 then
            gfx.setColor(gfx.kColorBlack)
            gfx.fillRect(progBarX + 1, progBarY + 1, fillWidth - 2, progBarHeight - 2)
        end
    end
end)

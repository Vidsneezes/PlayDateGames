--[[
    BOID HP RENDER SYSTEM
    Draws individual HP bars below each boid showing their happiness level.

    Registers AFTER sprite rendering so HP bars appear on top.

    ── Playdate SDK Quick Reference ──────────────────────

    Drawing:
        gfx.setColor(gfx.kColorBlack / kColorWhite)
        gfx.drawRect(x, y, w, h)    -- outline
        gfx.fillRect(x, y, w, h)    -- filled
        gfx.drawLine(x1, y1, x2, y2)

    ──────────────────────────────────────────────────────
]]

local gfx = playdate.graphics

RenderBoidHPSystem = System.new("renderBoidHP", {"transform", "emotionalBattery"}, function(entities, scene)
    -- Get camera offset
    local camX = 0
    local camY = 0
    if scene.camera then
        camX = scene.camera.x
        camY = scene.camera.y
    end

    -- Draw HP bar for each boid
    for _, e in ipairs(entities) do
        local t = e.transform
        local battery = e.emotionalBattery

        local screenX = t.x - camX
        local screenY = t.y - camY

        -- HP bar dimensions
        local barWidth = 30
        local barHeight = 4
        local barX = screenX - barWidth / 2
        local barY = screenY + 20  -- below sprite

        -- Background (empty bar)
        gfx.setColor(gfx.kColorWhite)
        gfx.fillRect(barX, barY, barWidth, barHeight)

        -- Border
        gfx.setColor(gfx.kColorBlack)
        gfx.drawRect(barX, barY, barWidth, barHeight)

        -- Fill based on battery value (0-100)
        local fillWidth = (battery.value / 100) * barWidth
        if fillWidth > 0 then
            gfx.setColor(gfx.kColorBlack)
            gfx.fillRect(barX + 1, barY + 1, fillWidth - 2, barHeight - 2)
        end

        -- Mark the middle (50%)
        local midX = barX + (barWidth / 2)
        gfx.setColor(gfx.kColorBlack)
        gfx.drawLine(midX, barY, midX, barY + barHeight)
    end
end)

--[[
    CRANK SYSTEM
    Reads the Playdate crank and updates entities with a crankInput component.

    ── Playdate SDK Quick Reference ──────────────────────

    Crank position (absolute):
        playdate.getCrankPosition()
        -- Returns 0-360 degrees
        -- 0 = pointing straight up, increases clockwise

    Crank change (relative, per frame):
        playdate.getCrankChange()
        -- Degrees rotated since last frame
        -- Positive = clockwise, Negative = counter-clockwise

    Crank docked (folded away):
        playdate.isCrankDocked()               -- true if crank is put away

    Crank ticks (for discrete steps):
        playdate.getCrankTicks(stepsPerRevolution)
        -- Returns -1, 0, or 1 for each "tick"
        -- Great for menus, level select, inventory scrolling
        -- Example: playdate.getCrankTicks(12) = 12 stops per full turn

    Crank callbacks (alternative to polling):
        function playdate.cranked(change, acceleratedChange)
            -- called every frame the crank moves
        end

        function playdate.crankDocked()
            -- called when crank is folded away
        end

        function playdate.crankUndocked()
            -- called when crank is pulled out
        end

    Common patterns:
        -- Dial/gauge (use absolute position)
        local angle = playdate.getCrankPosition()
        entity.transform.rotation = angle

        -- Scrolling/movement (use relative change)
        local change = playdate.getCrankChange()
        entity.transform.x += change * 0.5

        -- Menu selection (use ticks for snappy feel)
        local ticks = playdate.getCrankTicks(8)
        if ticks ~= 0 then selectedIndex += ticks end

    ──────────────────────────────────────────────────────
]]

CrankSystem = System.new("crank", {"crankInput"}, function(entities, scene)
    -- Skip processing if crank is docked
    -- (Remove this check if your game uses docked/undocked as a mechanic)
    if playdate.isCrankDocked() then return end

    local angle = playdate.getCrankPosition()
    local change = playdate.getCrankChange()

    for _, e in ipairs(entities) do
        local crank = e.crankInput
        crank.angle = angle
        crank.change = change

        -- TODO: Map crank input to game actions
        -- Examples:
        --   e.transform.rotation = angle
        --   e.transform.x += change * 0.5
        --   e.velocity.dx = math.sin(math.rad(angle)) * speed
        --   e.velocity.dy = -math.cos(math.rad(angle)) * speed
    end
end)

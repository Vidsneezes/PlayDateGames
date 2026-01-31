--[[
    PLAYER SYSTEM
    Reads button/d-pad input and applies it to entities with a playerInput component.

    ── Playdate SDK Quick Reference ──────────────────────

    Button polling (check every frame):
        playdate.buttonIsPressed(button)           -- held down right now
        playdate.buttonJustPressed(button)          -- pressed THIS frame
        playdate.buttonJustReleased(button)         -- released THIS frame

    Button constants:
        playdate.kButtonA
        playdate.kButtonB
        playdate.kButtonUp
        playdate.kButtonDown
        playdate.kButtonLeft
        playdate.kButtonRight

    Examples:
        if playdate.buttonIsPressed(playdate.kButtonLeft) then
            entity.transform.x -= speed
        end

        if playdate.buttonJustPressed(playdate.kButtonA) then
            -- fire projectile, jump, interact, etc.
        end

    Multiple buttons at once:
        local current, pressed, released = playdate.getButtonState()
        -- 'current' is a bitmask of all currently held buttons
        -- Example: if current & playdate.kButtonA ~= 0 then ... end

    Accelerometer (optional, uses battery):
        playdate.startAccelerometer()
        local x, y, z = playdate.readAccelerometer()
        playdate.stopAccelerometer()

    ──────────────────────────────────────────────────────
]]

PlayerSystem = System.new("player", {"transform", "playerInput"}, function(entities, scene)
    for _, e in ipairs(entities) do
        local t = e.transform
        local input = e.playerInput
        local speed = input.speed or 2

        -- TODO: Implement player controls
        -- Example: D-pad movement
        -- if playdate.buttonIsPressed(playdate.kButtonUp) then t.y -= speed end
        -- if playdate.buttonIsPressed(playdate.kButtonDown) then t.y += speed end
        -- if playdate.buttonIsPressed(playdate.kButtonLeft) then t.x -= speed end
        -- if playdate.buttonIsPressed(playdate.kButtonRight) then t.x += speed end

        -- Clamp to screen bounds
        -- t.x = clamp(t.x, 0, SCREEN_WIDTH)
        -- t.y = clamp(t.y, 0, SCREEN_HEIGHT)
    end
end)

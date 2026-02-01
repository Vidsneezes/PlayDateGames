--[[
    BOMB SYSTEM
    Handles the SAD Bomb mechanic.

    When player presses B button (and has charges remaining):
    - Sets all boids to happiness value 60 (highest sad value)
    - This prevents explosions and gives player emergency control
    - Triggers screen flash effect
    - Decrements bomb charges

    ── Playdate SDK Quick Reference ──────────────────────

    Button input:
        playdate.buttonJustPressed(playdate.kButtonB)

    ──────────────────────────────────────────────────────
]]

local pd = playdate

BombSystem = System.new("bomb", {}, function(entities, scene)
    -- Check for B button press
    if pd.buttonJustPressed(pd.kButtonB) then
        -- Check if player has bombs remaining
        if scene.sadBombs > 0 then
            -- Use one bomb
            scene.sadBombs -= 1

            -- Set all boids to sad (value 60 - highest sad value)
            local affectedCount = 0
            for _, entity in ipairs(scene.entities) do
                if entity.emotionalBattery and not entity.captured then
                    entity.emotionalBattery.value = 60
                    affectedCount += 1
                end
            end

            -- Trigger screen flash effect
            scene.screenFlash = 2  -- Flash for 2 frames

            -- Debug output
            print("SAD BOMB! Affected " .. affectedCount .. " boids. Bombs remaining: " .. scene.sadBombs)
        else
            print("No bombs remaining!")
        end
    end
end)

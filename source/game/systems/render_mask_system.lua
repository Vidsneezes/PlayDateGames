--[[
    MASK RENDER SYSTEM
    Draws mode-specific mask overlays on top of the game.

    - mask-freeze.png: Influence mode (wide view, paused)
    - mask-focus.png: Capture mode (narrow view, active)

    Masks are drawn after all game elements but before UI.

    ── Playdate SDK Quick Reference ──────────────────────

    Drawing images:
        gfx.image.new("Images/name")  -- load image
        image:draw(x, y)              -- draw at position

    ──────────────────────────────────────────────────────
]]

local gfx = playdate.graphics

-- Load masks once (cached)
local maskFreeze = nil  -- Influence mode (wide view)
local maskFocus = nil   -- Capture mode (narrow view)

RenderMaskSystem = System.new("renderMask", {}, function(entities, scene)
    -- Load masks on first frame
    if not maskFreeze then
        maskFreeze = gfx.image.new("Images/mask-freeze")
        if not maskFreeze then
            print("ERROR: Failed to load Images/mask-freeze.png")
        end
    end

    if not maskFocus then
        maskFocus = gfx.image.new("Images/mask-focus")
        if not maskFocus then
            print("ERROR: Failed to load Images/mask-focus.png")
        end
    end

    -- Draw appropriate mask based on current mode
    if scene.currentMode == "influence" then
        -- Influence mode: wide view mask (freeze)
        if maskFreeze then
            maskFreeze:draw(0, 0)
        end
    elseif scene.currentMode == "capture" then
        -- Capture mode: narrow view mask (focus)
        if maskFocus then
            maskFocus:draw(0, 0)
        end
    end
end)

--[[
    MASK RENDER SYSTEM
    Draws mode-specific mask overlays on top of the game.

    - mask-focus.png: Influence mode only (narrow view, paused)
    - Capture mode: No mask (full screen view)

    Masks are drawn after all game elements but before UI.

    ── Playdate SDK Quick Reference ──────────────────────

    Drawing images:
        gfx.image.new("Images/name")  -- load image
        image:draw(x, y)              -- draw at position

    ──────────────────────────────────────────────────────
]]

local gfx = playdate.graphics

-- Load mask once (cached)
local maskFocus = nil   -- Influence mode (narrow view)

RenderMaskSystem = System.new("renderMask", {}, function(entities, scene)
    -- Load mask on first frame
    if not maskFocus then
        maskFocus = gfx.image.new("Images/mask-focus")
        if not maskFocus then
            print("ERROR: Failed to load Images/mask-focus.png")
        end
    end

    -- Only draw mask in influence mode (capture mode has no mask)
    if scene.currentMode == "influence" then
        if maskFocus then
            maskFocus:draw(0, 0)
        end
    end
end)

--[[
    MASK RENDER SYSTEM
    Draws the mask overlay in influence mode.

    - Images/mask-focus.png: Influence mode mask (narrow view)
    - Capture mode: No mask (full screen view)

    ── Playdate SDK Quick Reference ──────────────────────

    Drawing images:
        gfx.image.new("Images/name")  -- load image
        image:draw(x, y)              -- draw at position

    ──────────────────────────────────────────────────────
]]

local gfx = playdate.graphics

-- Load mask once (cached)
local maskFocus = nil

RenderMaskSystem = System.new("renderMask", {}, function(entities, scene)
    -- Only draw mask in influence mode (capture mode has no mask)
    if scene.currentMode == "influence" then
        maskFocusImage:draw(0, 0)
    end
end)

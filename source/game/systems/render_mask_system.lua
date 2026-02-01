--[[
    MASK RENDER SYSTEM
    Draws mode-specific mask overlays with simple 3-frame animation.

    Teammate creates 3 mask images:
    - Images/mask-1.png (minimal/starting)
    - Images/mask-2.png (partial)
    - Images/mask-3.png (full mask)

    Animation:
    - Putting on: 1 → 2 → 3 (stays on 3 in influence mode)
    - Taking off: 3 → 2 → 1 → no mask

    ── Playdate SDK Quick Reference ──────────────────────

    Drawing images:
        gfx.image.new("Images/name")  -- load image
        image:draw(x, y)              -- draw at position

    ──────────────────────────────────────────────────────
]]

local gfx = playdate.graphics

-- Load mask frames (cached)
local mask1 = nil
local mask2 = nil
local mask3 = nil

RenderMaskSystem = System.new("renderMask", {}, function(entities, scene)
    -- Load mask frames on first frame
    if not mask1 then
        mask1 = gfx.image.new("Images/mask-1")
        mask2 = gfx.image.new("Images/mask-2")
        mask3 = gfx.image.new("Images/mask-3")

        if not mask1 or not mask2 or not mask3 then
            print("WARNING: Mask animation frames not found - using instant transitions")
        end
    end

    local anim = scene.maskAnimation

    -- Determine which mask to show based on animation state
    local maskToShow = nil

    if anim.state == "putting_on" then
        -- Putting on: 1 → 2 → 3
        if anim.frame == 0 then
            maskToShow = mask1
        elseif anim.frame == 1 then
            maskToShow = mask2
        elseif anim.frame >= 2 then
            maskToShow = mask3
            -- Animation complete after frame 2
            if anim.frame >= 3 then
                scene.currentMode = anim.targetMode
                anim.state = "idle"
            end
        end

    elseif anim.state == "taking_off" then
        -- Taking off: 3 → 2 → 1 → none
        if anim.frame == 0 then
            maskToShow = mask3
        elseif anim.frame == 1 then
            maskToShow = mask2
        elseif anim.frame == 2 then
            maskToShow = mask1
        else
            -- Animation complete - no mask
            maskToShow = nil
            scene.currentMode = anim.targetMode
            anim.state = "idle"
        end

    elseif anim.state == "idle" then
        -- Idle: show final mask if in influence mode
        if scene.currentMode == "influence" then
            maskToShow = mask3
        end
        -- Capture mode: no mask
    end

    -- Draw the selected mask
    if maskToShow then
        maskToShow:draw(0, 0)
    end
end)

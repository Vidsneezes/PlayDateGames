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
local maskFocus = nil  -- Fallback simple mask
local useAnimation = false

RenderMaskSystem = System.new("renderMask", {}, function(entities, scene)
    -- Load mask frames on first frame
    if not mask1 and not maskFocus then
        mask1 = gfx.image.new("Images/mask-1")
        mask2 = gfx.image.new("Images/mask-2")
        mask3 = gfx.image.new("Images/mask-3")

        if mask1 and mask2 and mask3 then
            useAnimation = true
            print("Loaded mask animation frames")
        else
            -- Fallback to simple mask
            maskFocus = gfx.image.new("Images/mask-focus")
            if maskFocus then
                print("Using simple mask (mask-focus.png)")
            else
                print("ERROR: No mask images found")
            end
        end
    end

    local anim = scene.maskAnimation
    local maskToShow = nil

    if useAnimation then
        -- Use animation frames
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
        end
    else
        -- Fallback: use simple mask (instant transitions)
        if anim.state ~= "idle" then
            -- Complete animation instantly
            scene.currentMode = anim.targetMode
            anim.state = "idle"
        end

        -- Show simple mask in influence mode
        if scene.currentMode == "influence" and maskFocus then
            maskToShow = maskFocus
        end
    end

    -- Draw the selected mask
    if maskToShow then
        maskToShow:draw(0, 0)
    end
end)

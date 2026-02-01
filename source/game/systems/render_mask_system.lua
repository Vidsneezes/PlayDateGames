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

local lastMaskFocusMode = nil

local yPosition = -30

local animationDuration = 250
local startY,endY = -384,-75
local easingFunction = playdate.easingFunctions.outBounce
local easingFunctionTakeOff = playdate.easingFunctions.inQuart
local animator = nil

RenderMaskSystem = System.new("renderMask", {}, function(entities, scene)
    
    if not (lastMaskFocusMode == nil) then
        
        if not (lastMaskFocusMode == scene.currentMode) then
            if scene.currentMode == "influence" then
                animator = playdate.graphics.animator.new(animationDuration, startY, endY, easingFunction)
                animator.repeatCount = 0
            elseif scene.currentMode == "capture" then
                 animator = playdate.graphics.animator.new(animationDuration, endY, startY, easingFunctionTakeOff)
                animator.repeatCount = 0
            end
        end


    end

    -- Only draw mask in influence mode (capture mode has no mask)
    if animator then
        maskFocusImage:draw(0, animator:currentValue())
    else 
        maskFocusImage:draw(0, startY)
    end


    lastMaskFocusMode = scene.currentMode

end)

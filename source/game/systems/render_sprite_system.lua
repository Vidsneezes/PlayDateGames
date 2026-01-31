--[[
    SPRITE RENDER SYSTEM
    Renders all Playdate sprites in the correct order.

    This system should be registered AFTER background rendering
    but BEFORE UI rendering to ensure correct layering.

    ── Playdate SDK Quick Reference ──────────────────────

    Sprites:
        gfx.sprite.update()  -- Redraws all sprites in display list
        sprite:setBackgroundDrawingCallback() -- Custom background drawing

    ──────────────────────────────────────────────────────
]]

local gfx = playdate.graphics

RenderSpriteSystem = System.new("renderSprite", {}, function(entities, scene)
    -- Render all Playdate sprites (does NOT clear screen)
    gfx.sprite.update()
end)

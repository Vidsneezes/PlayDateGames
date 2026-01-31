--[[
    SPRITE RENDER SYSTEM
    Renders all Playdate sprites in the correct order.

    This system should be registered AFTER background rendering
    but BEFORE UI rendering to ensure correct layering.

    ── Playdate SDK Quick Reference ──────────────────────

    Sprites:
        gfx.sprite.update()  -- Redraws all sprites in display list
        gfx.sprite.setBackgroundDrawingCallback() -- Preserve custom background

    ──────────────────────────────────────────────────────
]]

local gfx = playdate.graphics

RenderSpriteSystem = System.new("renderSprite", {}, function(entities, scene)
    -- Set up background drawing callback to preserve tilemap when sprites move
    gfx.sprite.setBackgroundDrawingCallback(function(x, y, width, height)
        -- Redraw the tilemap in the dirty rect area
        if scene.backgroundTilemap and scene.camera then
            gfx.setClipRect(x, y, width, height)
            scene.backgroundTilemap:draw(-scene.camera.x, -scene.camera.y)
            gfx.clearClipRect()
        end
    end)

    -- Render all Playdate sprites
    gfx.sprite.update()
end)

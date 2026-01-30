--[[
    RENDER SYSTEM
    Draws entities that have a transform and a sprite component.
    This system should be registered LAST so it draws on top of everything.

    ── Playdate SDK Quick Reference ──────────────────────

    Graphics basics:
        local gfx = playdate.graphics

        gfx.clear(gfx.kColorWhite)                  -- clear screen
        gfx.setColor(gfx.kColorBlack)                -- kColorBlack or kColorWhite
        gfx.drawText("Hello", x, y)                  -- draw text at position
        gfx.drawTextAligned("Hi", x, y, align)       -- align: kTextAlignment.center/left/right
        gfx.drawRect(x, y, w, h)                     -- rectangle outline
        gfx.fillRect(x, y, w, h)                     -- filled rectangle
        gfx.drawCircleAtPoint(x, y, r)               -- circle outline
        gfx.fillCircleAtPoint(x, y, r)               -- filled circle

    Images:
        local img = gfx.image.new("Images/myImage")  -- load from file (no extension)
        local img = gfx.image.new(w, h)              -- create blank image
        img:draw(x, y)                               -- draw at position
        img:drawCentered(x, y)                        -- draw centered at position

        -- Draw INTO an image:
        gfx.lockFocus(img)
            gfx.fillRect(0, 0, 10, 10)
        gfx.unlockFocus()

    Sprites (managed drawing):
        local sprite = gfx.sprite.new(image)
        sprite:moveTo(x, y)
        sprite:add()                                 -- add to display list
        sprite:remove()                              -- remove from display list
        gfx.sprite.update()                          -- redraws all sprites

    Animation:
        -- Image table: load a series of frames
        local imgTable = gfx.imagetable.new("Images/anim")
        local anim = gfx.animation.loop.new(delay_ms, imgTable, shouldLoop)
        anim:draw(x, y)

    Text styling:
        gfx.drawText("*bold* _italic_ ~custom~", x, y)
        gfx.setFont(font)

    Screen: 400 x 240 pixels, 1-bit color (black and white only)

    ──────────────────────────────────────────────────────
]]

local gfx = playdate.graphics

RenderSystem = System.new("render", {"transform", "sprite"}, function(entities, scene)
    -- Clear screen at the start of each frame
    gfx.clear(gfx.kColorWhite)

    for _, e in ipairs(entities) do
        local t = e.transform
        local s = e.sprite

        if s.visible and s.image then
            s.image:draw(t.x, t.y)
        end
    end

    -- TODO: Draw UI elements (score, health, etc.) here
    -- Example:
    -- gfx.setColor(gfx.kColorBlack)
    -- gfx.drawText("Score: " .. tostring(score), 5, 5)
end)

--[[
    VISUAL COMPONENTS
    Components related to rendering, sprites, and animations.
    Add new visual-related components at the bottom of this file.

    Usage:
        local entity = Entity.new({
            transform = Transform(100, 50),
            sprite = SpriteComp(gfx.image.new("Images/player")),
        })
]]

-- Visual representation (used by RenderSystem)
function BoidSpriteComp(imgHead)
    local spriteBody = playdate.graphics.sprite.new(animationBoidBodyMove:image())
    spriteBody:setOpaque(false)  -- Transparent background (don't cover grass)
    spriteBody:add()
    local spriteHead = playdate.graphics.sprite.new(imgHead)
    spriteHead:setOpaque(false)
    spriteHead:add()
    return {
        head = spriteHead,
        body = spriteBody,
        visible = true,
    }
end
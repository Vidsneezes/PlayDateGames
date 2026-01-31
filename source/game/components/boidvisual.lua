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
function BoidSpriteComp(imgBody, imgBubble)
    local spriteBody = playdate.graphics.sprite.new(imgBody)
    spriteBody:add()
    return {
        body = spriteBody,      
        visible = true,
    }
end
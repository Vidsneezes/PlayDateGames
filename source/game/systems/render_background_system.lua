--[[
    BACKGROUND SYSTEM
    Draws the tilemap background using Playdate's efficient tilemap rendering.

    Creates a tilemap once and draws it with camera offset each frame.
    Uses random tile selection from the grass image table for natural variation.

    ── Playdate SDK Quick Reference ──────────────────────

    Tilemap:
        local tilemap = gfx.tilemap.new()
        tilemap:setImageTable(imageTable)
        tilemap:setSize(columns, rows)
        tilemap:setTileAtPosition(x, y, tileIndex)  -- 1-indexed
        tilemap:draw(x, y)  -- draw at position

    Image table:
        local imageTable = gfx.imagetable.new("path")  -- no extension
        -- For "grass-table-4-1.png", loads 4 tiles in a row

    ──────────────────────────────────────────────────────
]]

local gfx = playdate.graphics

RenderBackgroundSystem = System.new("renderBackground", {}, function(entities, scene)
    -- Create tilemap once if it doesn't exist
    if not scene.backgroundTilemap then
        -- Load grass tiles (file: Images/grass-table-32-32.png)
        local grassTiles = gfx.imagetable.new("Images/grass")

        if not grassTiles then
            print("ERROR: Failed to load Images/grass-table-32-32.png")
            return
        end

        -- Create and configure tilemap
        local tilemap = gfx.tilemap.new()
        tilemap:setImageTable(grassTiles)

        -- Calculate tilemap size (32x32 tiles)
        local tileSize = 32
        local worldW = scene.camera and scene.camera.worldWidth or 800
        local worldH = scene.camera and scene.camera.worldHeight or 480
        local tilesWide = math.ceil(worldW / tileSize)
        local tilesHigh = math.ceil(worldH / tileSize)

        tilemap:setSize(tilesWide, tilesHigh)

        -- Border width in tiles (100px padding = ~3 tiles at 32px each)
        local borderWidth = 3

        -- Fill with grass tiles and black border
        for y = 1, tilesHigh do
            for x = 1, tilesWide do
                -- Check if this tile is in the border area
                local isBorder = (x <= borderWidth or x > tilesWide - borderWidth or
                                  y <= borderWidth or y > tilesHigh - borderWidth)

                if isBorder then
                    tilemap:setTileAtPosition(x, y, 5)  -- Black border tile
                else
                    tilemap:setTileAtPosition(x, y, math.random(1, 4))  -- Random grass
                end
            end
        end

        scene.backgroundTilemap = tilemap
        scene.backgroundTileSize = tileSize
    end

    -- Draw tilemap with camera offset
    if scene.backgroundTilemap and scene.camera then
        scene.backgroundTilemap:draw(-scene.camera.x, -scene.camera.y)
    end
end)

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

BackgroundSystem = System.new("background", {}, function(entities, scene)
    -- Create tilemap once if it doesn't exist
    if not scene.backgroundTilemap then
        -- Load grass tiles (4 tiles horizontally)
        -- Try different naming conventions
        local grassTiles = gfx.imagetable.new("Images/grass")

        if not grassTiles then
            -- Try alternative naming
            grassTiles = gfx.imagetable.new("Images/bg-grass-table-4-1")
        end

        if not grassTiles then
            -- Try without table suffix (might be separate files)
            grassTiles = gfx.imagetable.new("Images/bg-grass")
        end

        if not grassTiles then
            print("ERROR: Failed to load grass tilemap. Tried:")
            print("  Images/bg-grass-table-4-1")
            print("  Images/bg grass-table-4-1")
            print("  Images/bg-grass")
            print("Please check:")
            print("  1. File exists in Images/ folder")
            print("  2. File is named: bg-grass-table-4-1.png (for image table)")
            print("  3. Or use 4 separate files: bg-grass-1.png through bg-grass-4.png")
            return
        end

        print("SUCCESS: Loaded grass tilemap with " .. grassTiles:getLength() .. " tiles")

        -- Create tilemap
        local tilemap = gfx.tilemap.new()
        tilemap:setImageTable(grassTiles)

        -- Calculate tilemap size based on world dimensions
        -- Using 32x32 grass tiles
        local tileSize = 32
        local worldW = scene.camera and scene.camera.worldWidth or 800
        local worldH = scene.camera and scene.camera.worldHeight or 480
        local tilesWide = math.ceil(worldW / tileSize)
        local tilesHigh = math.ceil(worldH / tileSize)

        tilemap:setSize(32, 32)

        -- Fill tilemap with random grass tiles (1-4)
        for y = 1, tilesHigh do
            for x = 1, tilesWide do
                local randomTile = math.random(1, 4)
                tilemap:setTileAtPosition(x, y, randomTile)
            end
        end

        -- Store tilemap on scene
        scene.backgroundTilemap = tilemap
        scene.backgroundTileSize = tileSize
    end

    -- Draw tilemap with camera offset
    if scene.backgroundTilemap and scene.camera then
        local camX = scene.camera.x
        local camY = scene.camera.y

        -- Draw tilemap at negative camera position (world space)
        scene.backgroundTilemap:draw(-camX, -camY)
    end
end)

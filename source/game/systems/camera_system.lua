--[[
    CAMERA SYSTEM
    Moves the scene camera based on arrow key input.
    The camera determines what portion of the world is visible.

    Expects scene.camera to exist with:
        - x, y (current position)
        - worldWidth, worldHeight (world bounds)

    ── Playdate SDK Quick Reference ──────────────────────

    Button input:
        local pd = playdate

        pd.buttonIsPressed(btn)     -- true if button is held down
        pd.buttonJustPressed(btn)   -- true only on first frame of press
        pd.buttonJustReleased(btn)  -- true only on first frame of release

        Buttons:
            pd.kButtonUp, pd.kButtonDown, pd.kButtonLeft, pd.kButtonRight
            pd.kButtonA, pd.kButtonB

    D-pad returns values in range [-1, 1]:
        local x, y = pd.getButtonState()
        -- x: -1 (left), 0 (neutral), 1 (right)
        -- y: -1 (up), 0 (neutral), 1 (down)

    ──────────────────────────────────────────────────────
]]

local pd = playdate

CameraSystem = System.new("camera", {}, function(entities, scene)
    -- Camera should be a scene property, not a component
    if not scene.camera then
        return
    end

    -- Camera frozen while paused
    if scene.isPaused then
        return
    end

    local cam = scene.camera
    local speed = 15  -- pixels per frame at 30 FPS (faster for quick navigation)

    -- Read arrow keys
    local dx = 0
    local dy = 0

    if pd.buttonIsPressed(pd.kButtonLeft) then
        dx -= speed
    end
    if pd.buttonIsPressed(pd.kButtonRight) then
        dx += speed
    end
    if pd.buttonIsPressed(pd.kButtonUp) then
        dy -= speed
    end
    if pd.buttonIsPressed(pd.kButtonDown) then
        dy += speed
    end

    -- Update camera position
    cam.x += dx
    cam.y += dy

    -- Clamp camera to world bounds (keep viewport within world)
    -- Camera position is top-left of viewport
    local maxX = cam.worldWidth - SCREEN_WIDTH
    local maxY = cam.worldHeight - SCREEN_HEIGHT

    cam.x = clamp(cam.x, 0, maxX)
    cam.y = clamp(cam.y, 0, maxY)
end)

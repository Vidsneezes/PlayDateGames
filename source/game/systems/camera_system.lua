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

    -- Camera frozen in influence mode (paused), movable in capture mode
    if scene.isPaused then
        return
    end

    local cam = scene.camera
    local speed = 20  -- pixels per frame at 30 FPS (was 15 - faster for hectic gameplay)

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

    -- If camera moved in capture mode, reset capture progress!
    if (dx ~= 0 or dy ~= 0) and scene.currentMode == "capture" then
        scene.captureProgress = 0
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

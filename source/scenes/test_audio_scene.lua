--[[
    TEST AUDIO SCENE
    Demonstrates the new ECS-based Audio Architecture:
    1. Polyphonic SFX Pool
    2. Reactive Music Sequencer (Multi-track)
]]

local gfx = playdate.graphics

function TestAudioScene()
    local scene = Scene.new("test_audio")

    -- UI State for visualization
    local musicPlaying = false
    local trackStates = {
        bass = true,   -- Starts ON
        drums = true,  -- Starts ON
        melody = false -- Starts OFF (Classic "add layer later" usage)
    }

    -- Only one entity is needed to drive the audio (The "AudioController")
    local audioController

    function scene:onEnter()
        -- Create our controller entity with the new SynthEmitter
        audioController = Entity.new({
            synthEmitter = SynthEmitter()
        })
        scene:addEntity(audioController)

        -- Start music immediately via ECS trigger
        audioController.synthEmitter.musicTrigger = "theme"
        musicPlaying = true

        -- Set initial volumes
        -- Melody starts muted (0.0)
        audioController.synthEmitter.trackVolumes = {
            bass = 1.0,
            drums = 1.0,
            melody = 0.0
        }
    end

    -- Helper to toggle a track
    local function toggleTrack(trackName)
        trackStates[trackName] = not trackStates[trackName]
        local newVol = trackStates[trackName] and 1.0 or 0.0

        -- Send volume command to ECS
        audioController.synthEmitter.trackVolumes[trackName] = newVol
    end

    function scene:update()
        -- IMPORTANT: Manually run the SynthSystem because we are overriding update()
        -- Find entities with synthEmitter and update them
        local synthEntities = scene:getEntitiesWith("synthEmitter")
        SynthSystem.update(synthEntities, scene)

        gfx.clear(gfx.kColorWhite)

        -- Title
        gfx.drawTextAligned("*REACTIVE AUDIO TEST*", 200, 15, kTextAlignment.center)

        -- SFX SECTION
        gfx.drawText("--- SFX (Polyphonic Pool) ---", 20, 40)

        gfx.drawText("UP: Jump (Tri)", 40, 60)
        gfx.drawText("DOWN: Coin (Sine)", 40, 80)
        gfx.drawText("LEFT: Explosion (Noise)", 40, 100)
        gfx.drawText("RIGHT: Hit (Saw)", 40, 120)

        -- MUSIC SECTION
        gfx.drawText("--- MUSIC (Multi-Track) ---", 20, 150)
        gfx.drawText("A: Toggle Melody", 40, 170)
        gfx.drawText("B: Toggle Drums", 40, 190)

        -- Visual Indicators for Tracks
        local function drawTrackStatus(name, y)
            local on = trackStates[name]
            local label = name:upper() .. ": " .. (on and "ON" or "MUTED")
            local x = 250

            if on then
                gfx.fillRoundRect(x, y, 100, 20, 4)
                gfx.setImageDrawMode(gfx.kDrawModeInverted)
                gfx.drawTextAligned(label, x + 50, y + 2, kTextAlignment.center)
                gfx.setImageDrawMode(gfx.kDrawModeCopy)
            else
                gfx.drawRoundRect(x, y, 100, 20, 4)
                gfx.drawTextAligned(label, x + 50, y + 2, kTextAlignment.center)
            end
        end

        drawTrackStatus("melody", 170)
        drawTrackStatus("drums", 190)

        -- INPUT HANDLERS (Populating the ECS Component)

        -- SFX Triggers
        if playdate.buttonJustPressed(playdate.kButtonUp) then
            table.insert(audioController.synthEmitter.sfxTriggers, "jump")
        end
        if playdate.buttonJustPressed(playdate.kButtonDown) then
            table.insert(audioController.synthEmitter.sfxTriggers, "coin")
        end
        if playdate.buttonJustPressed(playdate.kButtonLeft) then
            table.insert(audioController.synthEmitter.sfxTriggers, "explosion")
        end
        if playdate.buttonJustPressed(playdate.kButtonRight) then
            table.insert(audioController.synthEmitter.sfxTriggers, "hit")
        end

        -- Music Layer Toggles
        if playdate.buttonJustPressed(playdate.kButtonA) then
            toggleTrack("melody")
        end
        if playdate.buttonJustPressed(playdate.kButtonB) then
            toggleTrack("drums")
        end

        -- Exit
        gfx.drawTextAligned("Crank: Menu", 200, 220, kTextAlignment.center)

        if playdate.isCrankDocked() == false then
            GAME_WORLD:setScene(MenuScene()) -- Simple check to exit if crank moved (optional)
        end
    end

    function scene:onExit()
        -- Stop SoundBank
        SoundBank.stopMusic()

        -- Stop music cleanly
        --if audioController then
        --    audioController.synthEmitter.musicTrigger = "stop"
        --end
        -- Actual cleanup happens in system, but we force a stop command
    end

    return scene
end

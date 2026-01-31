-- TestAudioScene.lua
local gfx = playdate.graphics

function TestAudioScene()
    local scene = Scene.new("test_audio")

    -- Variables de estado de la escena
    local currentScreen = "sfx"
    local synth1, synth2, synth3, melodySynth
    local melody = { 262, 294, 330, 349, 392, 392, 440, 440, 392, 0, 349, 349, 330, 330, 294, 294, 262 }
    local musicPlaying = false
    local currentNote = 1
    local musicTimer = nil

    -- Inicialización de audio
    local function initSynths()
        synth1 = playdate.sound.synth.new(playdate.sound.kWaveTriangle)
        synth2 = playdate.sound.synth.new(playdate.sound.kWaveSine)
        synth3 = playdate.sound.synth.new(playdate.sound.kWaveSawtooth)
        melodySynth = playdate.sound.synth.new(playdate.sound.kWaveSquare)
        melodySynth:setVolume(0.3)
    end

    -- Lógica de la melodía (recursiva con timer)
    local function playMelody()
        if not musicPlaying then return end
        local freq = melody[currentNote]
        if freq > 0 then
            melodySynth:playNote(freq, 0.3, 0.15)
        end
        currentNote = (currentNote % #melody) + 1
        musicTimer = playdate.timer.performAfterDelay(200, playMelody)
    end

    local function toggleMusic()
        if musicPlaying then
            musicPlaying = false
            if musicTimer then musicTimer:remove() end
        else
            musicPlaying = true
            currentNote = 1
            playMelody()
        end
    end

    function scene:onEnter()
        initSynths()
    end

    function scene:update()
        gfx.clear(gfx.kColorWhite)

        if currentScreen == "sfx" then
            gfx.drawTextAligned("*SFX TEST*", 200, 20, kTextAlignment.center)
            gfx.drawText("UP: Jump (Triangle)", 80, 90)
            gfx.drawText("DOWN: Coin (Sine)", 80, 115)
            gfx.drawText("LEFT: Error (Sawtooth)", 80, 140)
            gfx.drawTextAligned("RIGHT: Go to Music Test", 200, 190, kTextAlignment.center)
            gfx.drawTextAligned("B: Back to Menu", 200, 215, kTextAlignment.center)

            if playdate.buttonJustPressed(playdate.kButtonUp) then synth1:playNote(300, 0.4, 0.15) end
            if playdate.buttonJustPressed(playdate.kButtonDown) then
                synth2:playNote(523, 0.3, 0.1)
                playdate.timer.performAfterDelay(100, function() synth2:playNote(659, 0.3, 0.1) end)
            end
            if playdate.buttonJustPressed(playdate.kButtonLeft) then synth3:playNote(150, 0.5, 0.3) end
            if playdate.buttonJustPressed(playdate.kButtonRight) then currentScreen = "music" end
            if playdate.buttonJustPressed(playdate.kButtonB) then GAME_WORLD:queueScene(MenuScene()) end
        else
            gfx.drawTextAligned("*MUSIC TEST*", 200, 20, kTextAlignment.center)
            local btnY = 90

            if musicPlaying then
                gfx.fillRoundRect(100, btnY, 200, 50, 8)
                gfx.setImageDrawMode(gfx.kDrawModeInverted)
                gfx.drawTextAligned("A: STOP", 200, btnY + 17, kTextAlignment.center)
                gfx.setImageDrawMode(gfx.kDrawModeCopy)
                gfx.drawTextAligned("Note: " .. currentNote .. "/" .. #melody, 200, 155, kTextAlignment.center)
            else
                gfx.drawRoundRect(100, btnY, 200, 50, 8)
                gfx.drawTextAligned("A: PLAY", 200, btnY + 17, kTextAlignment.center)
            end

            gfx.drawTextAligned("LEFT: Back to SFX Test", 200, 190, kTextAlignment.center)

            if playdate.buttonJustPressed(playdate.kButtonA) then toggleMusic() end
            if playdate.buttonJustPressed(playdate.kButtonLeft) then
                if musicPlaying then toggleMusic() end
                currentScreen = "sfx"
            end
        end
    end

    function scene:onExit()
        if musicTimer then musicTimer:remove() end
        musicPlaying = false
    end

    return scene
end

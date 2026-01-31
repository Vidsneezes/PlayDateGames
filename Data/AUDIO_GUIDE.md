# 🎵 Playdate Audio Quick Reference

## Audio Paths (No Extension!)
```lua
-- Sound Effects
local sfx = playdate.sound.sampleplayer.new("sfx/player/jump")

-- Background Music  
local music = playdate.sound.fileplayer.new("music/theme")
```

## SamplePlayer (Short SFX)
```lua
local sfx = playdate.sound.sampleplayer.new("sfx/jump")
sfx:play()           -- play once
sfx:play(3)          -- repeat 3 times
sfx:play(0)          -- loop forever
sfx:stop()
sfx:setVolume(0.5)   -- 0.0 to 1.0
```

## FilePlayer (Background Music)
```lua
local music = playdate.sound.fileplayer.new("music/theme")
music:play(0)        -- loop forever
music:stop()
music:pause()
music:setVolume(0.3)
```

## Synth (No Files Needed!)
```lua
local synth = playdate.sound.synth.new(playdate.sound.kWaveSquare)
synth:playNote(440, 0.5, 0.2)  -- freq, volume, duration

-- Waveforms: kWaveSine, kWaveSquare, kWaveSawtooth, kWaveTriangle, kWaveNoise
```

## ECS Integration
```lua
-- Create entity with audio
local sfx = playdate.sound.sampleplayer.new("sfx/jump")
local player = Entity.new({
    transform = Transform(200, 120),
    audioSource = AudioSource(sfx),
})

-- Trigger from any system
entity.audioSource.shouldPlay = true  -- AudioSystem handles playback
```

## File Formats
- ✅ WAV, AIFF
- ❌ NO MP3, NO OGG

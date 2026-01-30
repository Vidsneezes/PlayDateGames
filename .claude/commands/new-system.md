Create a new ECS system file for this Playdate game project.

The system name is: $ARGUMENTS

Follow these steps:

1. Create a new file at `source/systems/$ARGUMENTS_system.lua`
2. Follow the exact pattern of existing system files in `source/systems/`:
   - Start with a multiline comment block containing:
     - A brief description of what the system does
     - A "Playdate SDK Quick Reference" section with the most relevant SDK functions for this system's domain
   - Define the system using `System.new(name, requiredComponents, updateFn)`
   - Include commented-out TODO examples in the update function
3. If this system needs a new component, add it at the bottom of `source/components.lua`
4. Add the `import` line in `source/main.lua` in the systems section (between the systems comment and the scenes comment)
5. Add `self:addSystem()` in `source/scenes/game_scene.lua` inside `onEnter()`, respecting execution order: input systems first, then logic, then audio, then render (render is always last)

Important Playdate notes:
- Use `import` not `require`
- No `io`, `os`, or `package` standard libraries
- Screen is 400x240, 1-bit (black and white)
- Audio: WAV/AIFF only, load without extension
- Images: load without extension

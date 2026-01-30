Create a new scene file for this Playdate game project.

The scene name is: $ARGUMENTS

Follow these steps:

1. Create a new file at `source/scenes/$ARGUMENTS_scene.lua`
2. Follow the exact pattern of existing scene files in `source/scenes/`:
   - Add `local gfx = playdate.graphics` at the top
   - Define a constructor function (e.g., `function MyScene()`) that:
     - Creates a scene with `Scene.new("name")`
     - Defines `onEnter()`, `onExit()`, and optionally `update()` methods
     - Returns the scene table
   - For simple scenes (menus, dialogs, screens): override `update()` for direct drawing
   - For gameplay scenes: register systems in `onEnter()` and let the default `Scene:update()` handle the ECS loop
3. Add the `import` line in `source/main.lua` in the scenes section
4. Include a brief comment block at the top explaining the scene's purpose and how to transition to it

Scene transitions use: `GAME_WORLD:queueScene(MyScene())`

Important Playdate notes:
- Use `import` not `require`
- Screen is 400x240, 1-bit (black and white)
- Text alignment: `kTextAlignment.center`, `kTextAlignment.left`, `kTextAlignment.right`
- Check buttons with `playdate.buttonJustPressed(playdate.kButtonA)`

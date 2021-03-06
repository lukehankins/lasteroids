# Binocles
Debugging Love2D in a simple way. (Work in progress)

Binocles si a module base on Monocle https://github.com/kjarvi/monocle.
this module give the ability to easily :
  1. watch variables and complex expressions.
  2. watch files and reload them when they change.
  3. Reloads after any watched files have been changed.
  4. Custom colors.
  5. Add Global variables to the listener from the console by providing there name.
  6. Restarts the game without relaunching the executable.

The setup of a basic main.lua file is as follows:

Note : Make sure to run the game from the console or use --console so you can see the listener output.

```lua
Object   = require "classicc";
Binocles = require "binocles";

--Test variable
test = 0;

function love.load(arg)
  watcher = Binocles({
      active = true,
      customPrinter = true,
      debugToggle =   'f1',
      consoleToggle = 'f2',
      colorToggle   = 'f3',
      watchedFiles = {
        'main.lua',
      },
    });
    -- Watch the FPS
    watcher:watch("FPS", function() return math.floor(1/love.timer.getDelta()) end);
    -- Watch the test global variable
    watcher:watch("test",function() return test end);
end


function love.update(dt)
  watcher:update();
end

function love.draw()
  watcher:draw();
end

function love.keypressed(key)
  test = test + 1; -- inc test every time a key is pressed
  watcher:keypressed(key);
end
```

Options :

```lua
options.active -- if bonocles is active (drawing)  
options.customPrinter -- activate printing to console
options.draw_x -- x pos of the Bonocles instance (Used in :draw())
options.draw_y  -- y pos of the Bonocles instance (Used in :draw())
options.printColor -- text color (will be sent to love.graphics.setColor())
options.debugToggle -- Toggle (change the satate of self.active)
options.consoleToggle -- Start the interaction with the listener from the console
options.colorToggle -- toggle to change the printing color
options.watchedFiles  -- files to watch

options.restart --[[
* if true :  Restarts the game without relaunching the executable. 
             This cleanly shuts down the main Lua state instance and creates a brand new one.
             * You will lose the watched globals that you added from the console.
* if false : will reload only the watched file after it is modified (ctrl-s).
]]--

```

Console Example :

![ConsoleEX](./public/imgs/ConsoleEX.png)

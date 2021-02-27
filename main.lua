Game = {
    debug = false,

    -- constants
    drag = 0.995, -- Actually, 1 - drag
    fire_cooldown = 0.5,
    max_player_speed = 512,
    shot_speed = 70,
    shield_duration = 4,

    -- globals
    friendly_mode = true,
    player_count = 0,
    coop_mode = true,

    start_time = love.timer.getTime(),
    watched = "fnord",

    controls = {},
    player_color = {{48 / 255, 79 / 255, 1}, {1, 0, 0}}
}

Game.controls[1] = {
    controls = {
        rotate_ccw = {"key:left"},
        rotate_cw = {"key:right"},
        thrust = {"key:up"},
        teleport = {"key:down"},
        fire = {"key:m", "button:a"},
        shield = {"key:n", "button:a"}
    }
}

Game.controls[2] = {
    controls = {
        rotate_ccw = {"key:a"},
        rotate_cw = {"key:d"},
        thrust = {"key:w"},
        teleport = {"key:s"},
        fire = {"key:e"},
        shield = {"key:q"}
    }
}

function love.load(arg)
    package.path = "./lib/?.lua;" .. package.path
    Object = require("lib.classic.classic")
    Binocles = require("lib.Binocles.Binocles")
    HC = require("lib.HC")
    Collider = HC.new()
    local lovetoys = require("lib.lovetoys")
    lovetoys.initialize({globals = true, debug = true})
    -- require("lib/pl")
    -- stringx.import()
    Vector = require("lib.hump.vector")
    -- Pprint = require("lib.pprint")
    Baton = require("lib.baton.baton")
    Game.state = require("lib.hump.gamestate")

    RequireDirectory("components")
    RequireDirectory("systems")
    RequireDirectory("events")
    RequireDirectory("states")

    Watcher = Binocles({
        active = false,
        customPrinter = true,
        draw_x = (love.graphics.getWidth() / 2) - 100,
        draw_y = 0,
        debugToggle = "7",
        consoleToggle = "8",
        colorToggle = "9"
    })
    -- Watch the FPS
    Watcher:watch("FPS",
                  function() return math.floor(1 / love.timer.getDelta()) end)
    -- Watch the test global variable
    Watcher:watch("watched", function() return Game.watched end)
    -- Watch the game state
    Watcher:watch("gamestate", function() return Game.state.current().name() end)

    Font = {
        scoreboard = love.graphics.newFont(
            "fonts/PS_Hyperspace/Hyperspace Bold.otf", 18),
        huge = love.graphics.newFont("fonts/PS_Hyperspace/Hyperspace Bold.otf",
                                     64),
        medium = love.graphics.newFont(
            "fonts/PS_Hyperspace/Hyperspace Bold.otf", 32),
        small = love.graphics.newFont("fonts/PS_Hyperspace/Hyperspace Bold.otf",
                                      16),
        tiny = love.graphics.newFont("fonts/PS_Hyperspace/Hyperspace Bold.otf",
                                     8),
        watcher = love.graphics.newFont(14)
    }

    Game.state.registerEvents()
    Game.state.switch(AttractState)

end

function love.update(dt)
    Game.engine:update(dt)
    Watcher:update()
end

function love.draw() Game.engine:draw() end

function love.keypressed(key)
    Watcher:keypressed(key)
    if key == "escape" then love.event.quit() end
end

function RequireDirectory(basePath)
    for _, item in ipairs(love.filesystem.getDirectoryItems(basePath)) do
        local basename = string.match(item, "(.*)%.lua")
        if basename then require(basePath .. "." .. basename) end
    end
end

function GenerateAsteroid(size)
    local points = {}
    local radius = size
    local max_deviation = math.modf(size / 3)
    local steps = 12
    for angle = 0, math.pi * 2, math.pi * 2 / steps do
        local surface = math.random(radius - max_deviation,
                                    radius + max_deviation)
        points[#points + 1] = math.cos(angle) * surface
        points[#points + 1] = math.sin(angle) * surface
    end
    return points
end

function AddRocks(count, size)
    local x, y
    local players = Game.engine:getEntitiesWithComponent("IsPlayer")
    for i = 1, count do
        local e = Entity()
        repeat
            x = love.math.random(0, love.graphics.getWidth())
            y = love.math.random(0, love.graphics.getHeight())
            local min_distance = 3000
            for _, p in pairs(players) do
                local bx, by = p:get("Body").body:center()
                local dx = x - bx
                local dy = y - by
                local dist = math.sqrt(dx * dx + dy * dy)
                min_distance = math.min(min_distance, dist)
            end
        until min_distance > 50

        local v = Vector.new(x, y)
        local dr = love.math.random(-200, 200) / 100
        e:add(Movement(Vector.randomDirection(1, 10), dr))
        local size = 32
        local poly = GenerateAsteroid(size)
        local b = HC.polygon(unpack(poly))
        b:moveTo(x, y)
        b.entity = e
        e:add(Body(b))
        e:add(IsRock(i, size))
        Game.engine:addEntity(e)
    end
end


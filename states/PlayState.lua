PlayState = {}

function PlayState:name() return "PlayState" end

function PlayState:enter()

    Game.engine = Engine()
    Game.engine:addSystem(MoveSystem(), "update")
    Game.engine:addSystem(CollisionSystem(), "update")
    Game.engine:addSystem(RenderSystem(), "draw")
    Game.engine:addSystem(ControlSystem(), "update")

    HC.resetHash()

    Game.level = 1

    for p = 1, Game.player_count do
        local e = Entity()
        local x = love.math.random(100, love.graphics.getWidth() - 100)
        local y = love.math.random(150, love.graphics.getHeight() - 100)
        e:add(Movement(Vector.new(0, 0), 0))
        local b = HC.polygon(24, 0, -24, 18, -18, 0, -24, -18)
        b:scale(0.5)
        b:moveTo(x, y)
        b.entity = e
        e:add(Body(b))
        local input = Baton.new(Game.controls[p])
        e:add(Controller(input))
        e:add(IsPlayer(p))
        e:add(Scoreboard(p))
        e.name = "Player " .. p
        Game.engine:addEntity(e)
        print("Adding " .. p .. " pc " .. Game.player_count)
    end

    -- Add Rocks
    AddRocks(4)
end

function PlayState:keypressed(key) end

function PlayState:draw() end

function PlayState:update()
    local gameover = true
    for _, player in pairs(Game.engine:getEntitiesWithComponent("IsPlayer")) do
        if player:get("IsPlayer").lives > 0 then gameover = false end
    end
    if gameover then Game.state.switch(GameOverState) end

    if Game.engine:getEntityCount("IsRock") == 0 then
        Game.level = Game.level + 1
        AddRocks(4 * Game.level)
    end

end

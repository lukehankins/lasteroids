AttractState = {}

function AttractState:name() return "AttractState" end

function AttractState:init()
    local keymap = {
        controls = {
            change_mode = {"key:m"},
            one_player = {"key:1"},
            two_player = {"key:2"}
        }
    }
    self.input = Baton.new(keymap)
end

function AttractState:enter()
    HC.resetHash()

    Game.engine = Engine()
    Game.engine:addSystem(MoveSystem(), "update")
    Game.engine:addSystem(RenderSystem(), "draw")

    AddRocks(10)
    -- Add Rocks
    -- for i = 1, 10, 1 do
    --     local e = Entity()
    --     -- TODO: regenerate if it's near the player
    --     local x = love.math.random(0, love.graphics.getWidth())
    --     local y = love.math.random(0, love.graphics.getHeight())
    --     local v = Vector.new(x, y)
    --     local dr = love.math.random(-200, 200) / 100
    --     e:add(Movement(Vector.randomDirection(1, 10), dr))
    --     local size = 32
    --     local poly = generate_asteroid(size)
    --     local b = HC.polygon(unpack(poly))
    --     b:moveTo(x, y)
    --     b.entity = e
    --     e:add(Body(b))
    --     e:add(IsRock(i, size))
    --     print(v.unpack, dr)
    --     Game.engine:addEntity(e)
    -- end
end

function AttractState:update(dt)
    self.input:update()

    if self.input:pressed("one_player") then
        Game.player_count = 1
        Game.state.switch(PlayState)
    end

    if self.input:pressed("two_player") then
        Game.player_count = 2
        Game.state.switch(PlayState)
    end

    if self.input:pressed("change_mode") then
        Game.friendly_mode = not (Game.friendly_mode)
    end
end

function AttractState:draw()

    -- title
    love.graphics.setColor(0, 1, 0)
    local font = Font["huge"]
    love.graphics.setFont(font)
    local text = "LASTEROIDS"
    love.graphics.printf(text,
                         ((love.graphics.getWidth() - font:getWidth(text)) / 2),
                         100, font:getWidth(text), "center")

    -- 1/2 player start
    love.graphics.setFont(Font["medium"])
    local text = "Press\n(1) or (2)\nto start"
    love.graphics.printf(text,
                         ((love.graphics.getWidth() - font:getWidth(text)) / 2),
                         250, font:getWidth(text), "center")

    -- keymaps
    love.graphics.setFont(Font["small"])
    for p = 1, 2 do
        love.graphics.setColor(Game.player_color[p])
        local text = "Player " .. p .. "\n--------"
        -- TODO: Sort this
        for k, v in pairs(Game.controls[p].controls) do
            text = text .. "\n" .. k .. " = " .. string.sub(v[1], 5)
        end
        love.graphics.printf(text, 50 + ((p - 1) * 550), 350,
                             font:getWidth(text))
    end

    -- friendly mode
    love.graphics.setFont(Font["small"])
    love.graphics.setColor(0, 1, 0)
    local onoff = Game.friendly_mode and "on" or "off"
    local text = "Friendy (m)ode is:\n" .. onoff
    love.graphics.printf(text,
                         ((love.graphics.getWidth() - font:getWidth(text)) / 2),
                         450, font:getWidth(text), "center")

    -- escape to quotient
    love.graphics.setFont(Font["tiny"])
    love.graphics.setColor(0, 1, 0)
    local text = "<ESC> to quit"
    love.graphics.printf(text, 10, 10, font:getWidth(text))
end

-- function AttractState:resume()
-- end

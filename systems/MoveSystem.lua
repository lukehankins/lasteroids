MoveSystem = class("MoveSystem", System)

function MoveSystem:update(dt)
    local width, height = love.graphics.getDimensions()
    for _, v in pairs(self.targets.body) do
        local movement = v:get("Movement")
        local vbody = v:get("Body").body
        dv = movement.v * dt
        vbody:move(dv:unpack())
        local x, y = vbody:center()
        if x <= 0 then
            x = (width + x) % width
        elseif x >= width then
            x = x % width
        end
        if y <= 0 then
            y = (height + y) % height
        elseif y >= height then
            y = y % height
        end
        vbody:moveTo(x, y)
        vbody:rotate(movement.r * dt)
    end

    for _, v in pairs(self.targets.players) do
        local movement = v:get("Movement")
        movement.v = movement.v * Game.drag
    end
end

function MoveSystem:requires() return {body = {"Body"}, players = {"IsPlayer"}} end

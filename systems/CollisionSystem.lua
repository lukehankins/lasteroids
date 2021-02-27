CollisionSystem = class("CollisionSystem", System)

function CollisionSystem:update()
    -- get list of all collisions
    local collisions = {}
    for _, v in pairs(self.targets.body) do
        local vbody = v:get("Body").body
        if next(HC.collisions(vbody)) ~= nil then
            for a, _ in pairs(HC.collisions(vbody)) do
                collisions[#collisions + 1] = {v, a.entity}
            end
        end
    end

    local to_destroy = {}

    for _, bonkpair in pairs(collisions) do
        local actor, hit = bonkpair[1], bonkpair[2]
        -- bullet
        if actor:has("IsBullet") then
            if hit:has("IsRock") then
                -- bullet vs rock
                actor:getParent():get("IsPlayer").score =
                    actor:getParent():get("IsPlayer").score + Game.level
                to_destroy[#to_destroy + 1] = actor
            end
        end
        -- player vs anything not my child
        if actor:has("IsPlayer") then
            if hit:has("IsRock") or
                (not (Game.friendly_mode) and hit:getParent().id ~= actor.id) then
                if actor:get("IsPlayer").shield_until < love.timer.getTime() then
                    actor:get("IsPlayer").lives =
                        actor:get("IsPlayer").lives - 1
                    if actor:get("IsPlayer").lives > 0 then
                        local x = love.math.random(100,
                                                   love.graphics.getWidth() -
                                                       100)
                        local y = love.math.random(150, love.graphics
                                                       .getHeight() - 100)
                        actor:set(Movement(Vector.new(0, 0), 0))
                        actor:get("Body").body:moveTo(x, y)
                        actor:get("IsPlayer").shield_until =
                            love.timer.getTime() + 0.3
                    else
                        print("he ded")
                        -- XXX what assumes a body?
                        HC.remove(actor:get("Body").body)
                        actor:remove("Body")
                    end
                end
            end
        end
        -- rock vs player or bullet
        if actor:has("IsRock") then
            if hit:has("IsPlayer") or hit:has("IsBullet") then
                -- rock vs bullet
                -- rock vs player
                to_destroy[#to_destroy + 1] = actor
                local new_size = actor:get("IsRock").size / 2
                if new_size > 4 then
                    for i = 1, 2 do
                        local new_rock = Entity()
                        local new_poly = GenerateAsteroid(new_size)
                        local x, y = actor:get("Body").body:center()
                        local v = Vector.new(x, y) +
                                      Vector.randomDirection(new_size / 2,
                                                             new_size / 2)
                        local dr = love.math.random(-200, 200) / 100
                        new_rock:add(Movement(
                                         Vector.randomDirection(
                                             30 + 32 - new_size,
                                             30 + 32 - new_size), dr))
                        local b = HC.polygon(unpack(new_poly))
                        b:moveTo(x, y)
                        b.entity = new_rock
                        new_rock:add(Body(b))
                        new_rock:add(IsRock(i, new_size))
                        Game.engine:addEntity(new_rock)
                    end
                end
            end
        end

    end

    for _, victim in pairs(to_destroy) do
        HC.remove(victim:get("Body").body)
        Game.engine:removeEntity(victim)
    end
end

function CollisionSystem:requires() return {body = {"Body"}} end

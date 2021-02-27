ControlSystem = class("ControlSystem", System)

function ControlSystem:update(dt)
	local rotspeed = 1.5
	local thrust = 5
	for _, v in pairs(self.targets.controller) do
		local input = v:get("Controller").input
		local movement = v:get("Movement")
		local vbody = v:get("Body").body

		input:update()

		movement.r = 0
		if input:down("rotate_ccw") or input:down("rotate_cw") then
			if input:down("rotate_ccw") then
				movement.r = movement.r - rotspeed
			end
			if input:down("rotate_cw") then
				movement.r = movement.r + rotspeed
			end
		end

		if input:down("thrust") then
			local rotation = vbody:rotation()
			local da = Vector.fromPolar(rotation, thrust)
			movement.v = movement.v + da
			movement.v = movement.v:trimmed(Game.max_player_speed)
		end

		if input:pressed("teleport") then
			local x = love.math.random(100, love.graphics.getWidth() - 100)
			local y = love.math.random(150, love.graphics.getHeight() - 100)
			v:set(Movement(Vector.new(0, 0), 0))
			vbody:moveTo(x, y)
		end

		if input:pressed("shield") then
			if v:get("IsPlayer").shields > 0 and v:get("IsPlayer").shield_until < love.timer.getTime() then
				v:get("IsPlayer").shield_until = love.timer.getTime() + Game.shield_duration
				v:get("IsPlayer").shields = v:get("IsPlayer").shields - 1
			end
		end

		if input:down("fire") then
			-- get all my bullets
			now = love.timer.getTime()
			local children = v.children
			local allow_shoot = 1
			local child_count = 0
			local oldest_child = nil
			for _, child in pairs(children) do
				local child_created = child:get("IsBullet").created
				if now - child_created < Game.fire_cooldown then
					allow_shoot = 0
				end
				child_count = child_count + 1
				if oldest_child == nil then
					oldest_child = child
				elseif child_created < oldest_child:get("IsBullet").created then
					oldest_child = child
				end
			end
			if allow_shoot == 1 then
				if child_count >= 4 then
					HC.remove(oldest_child:get("Body").body)
					Game.engine:removeEntity(oldest_child)
				end
				-- add new bullet
				local e = Entity()

				local parentxy = Vector.new(vbody:center())
				local parentmove = v:get("Movement").v
				local rvec = Vector.fromPolar(vbody:rotation())
				local px, py = parentxy:unpack()

				-- where is the bullet
				local nosexy = parentxy + (rvec * 15)
				local bx, by = nosexy:unpack()
				local b = HC.circle(bx, by, 1)

				-- velocity of the bullet
				local movev = (rvec * Game.shot_speed) + parentmove
				e:add(Movement(movev, 0))

				e:setParent(v)
				e.name = "Bullet " .. now
				b.entity = e
				e:add(Body(b))
				e:add(IsBullet(now))
				Game.engine:addEntity(e)
			end
		end

	end
end

function ControlSystem:requires()
	return {
		controller = { "Controller", "Movement", "Body" },
	}
end

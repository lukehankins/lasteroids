RenderSystem = class("RenderSystem", System)

function RenderSystem:draw()
	-- Draw scoreboards
	love.graphics.setColor(0, 1, 0, 0.8)
	love.graphics.setFont(Font["scoreboard"])
	-- Why doesn't this work?
	-- for _, v in pairs(self.targets.scoreboard) do
	for _, v in pairs(Game.engine:getEntitiesWithComponent("Scoreboard")) do
		local basex = v:get("Scoreboard").x
		local player = v:get("IsPlayer")
		local text = player.name .. "\n"
		text = text .. "Score: " .. player.score .. "\n"
		text = text .. "Lives: " .. player.lives .. "\n"
		text = text .. "Shields: "
		for s = 1, player.shields, 1 do
			text = text .. "*"
		end
		text = text .. "\n"
		love.graphics.printf(text, basex, 10, 150)
	end

	-- Draw rocks
	if Game.state.current().name() == "AttractState" then
		love.graphics.setColor(0, 1, 0, 0.3)
	else
		love.graphics.setColor(0, 1, 0)
	end
	for _, v in pairs(self.targets.rocks) do
		local vbody = v:get("Body").body
		vbody:draw("line")
	end

	-- Draw bullets
	love.graphics.setColor(0, 1, 0)
	for _, v in pairs(self.targets.bullets) do
		if not (Game.friendly_mode) then
			love.graphics.setColor(v:getParent():get("IsPlayer").color)
		end
		local vbody = v:get("Body").body
		vbody:draw("line")
	end

	-- Draw player
	for _, v in pairs(self.targets.players) do
		local vbody = v:get("Body").body
		love.graphics.setColor(v:get("IsPlayer").color)
		vbody:draw("line")

		-- Draw shield
		if v:get("IsPlayer").shield_until > love.timer.getTime() then
			local alpha = math.max(0.3, math.min(1, v:get("IsPlayer").shield_until - love.timer.getTime()))
			love.graphics.setColor(0, 1, 0, alpha)
			local vbody = v:get("Body").body
			local x, y = vbody:center()
			local sides = math.random(6, 13)
			love.graphics.circle("line", x, y, 20, sides)
		end
	end

	-- Draw watcher
	love.graphics.setColor(0, 1, 0)
	love.graphics.setFont(Font["watcher"])
	Watcher:draw()
end

function RenderSystem:requires()
	return {
		rocks = { "IsRock", "Body" },
		players = { "IsPlayer", "Body" },
		bullets = { "IsBullet", "Body" },
		scoreboard = { "ScoreBoard" },
	}
end

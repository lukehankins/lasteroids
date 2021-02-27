IsPlayer = class("IsPlayer")

function IsPlayer:initialize(id)
	self.id = id
	self.name = "Player " .. id
	self.lives = 3
	self.shields = 2
	self.shield_until = love.timer.getTime() + 0.05
	self.score = 0

	if Game.player_count == 1 then
		self.color = { 0, 1, 0 }
	else
		self.color = Game.player_color[id]
	end
end

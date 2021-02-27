Scoreboard = class("Scoreboard")

function Scoreboard:initialize(player, x)
	self.player = player
	if player == 1 then
		self.x = x or 30
	else
		self.x = x or love.graphics.getWidth() - 200
	end
end

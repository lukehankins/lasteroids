GameOverState = {}

function GameOverState:name()
	return "GameOverState"
end

-- function GameOverState:init()

-- end

function GameOverState:enter()
	Game.engine:stopSystem("ControlSystem")
	Game.engine:stopSystem("CollisionSystem")
end

function GameOverState:keypressed(key)
	if key == "space" then
		Game.state.switch(AttractState)
	end
end

function GameOverState:draw()
	love.graphics.setColor(0, 1, 0)
	love.graphics.setFont(Font["huge"])
	local text = "GAME OVER\nPRESS SPACE"
	local text_width = Font["huge"]:getWidth(text)
	local start_x = (love.graphics.getWidth() - text_width) / 2
	love.graphics.printf(text, start_x, 200, text_width, "center")
end

-- function GameOverState:update()
-- end

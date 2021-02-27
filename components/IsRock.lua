IsRock = class("IsRock")

function IsRock:initialize(id, size)
	self.id = id
	self.size = size
	self.name = "Rock " .. id
end

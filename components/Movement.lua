Movement = class("Movement")

function Movement:initialize(v, r)
	self.v = v
	self.r = r or 0
end

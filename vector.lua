local class = require 'middleclass'
local Vector = class('Vector')

function Vector:initialize(x, y)
	self.x, self.y = x, y
end

function Vector:__add(other)
	return Vector:new({x=(self.x + other.x), y=(self.y + other.y)})
end

function Vector:__sub(other)
	return Vector:new({x=(self.x - other.x), y=(self.y - other.y)})
end

return Vector
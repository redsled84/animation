local class 	= require 'middleclass'
local Rectangle = class('Rectangle')

function Rectangle:initialize(x, y, w, h, t)
	self.x1 = x
	self.y1 = y
	self.x2 = x + w
	self.y2 = y + h
	self.w = w
	self.h = h

	self.t = t or 'wall'
end

function Rectangle:center()
	return math.floor((self.x1 + self.x2) / 2), math.floor((self.y1 + self.y2) / 2)
end

function Rectangle:intersect(other)
	return (self.x1 <= other.x2 and self.x2 >= other.x1 and
			self.y1 <= other.y2 and self.y2 >= other.y1)
end

function Rectangle:getWidth()
	return self.w
end

function Rectangle:getHeight()
	return self.h
end	

function Rectangle:draw()
	love.graphics.setColor(255, 255, 255)
	love.graphics.rectangle('fill', self.x1, self.y1, self.w, self.h)
end

return Rectangle
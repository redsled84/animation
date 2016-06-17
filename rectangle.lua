local class 	= require 'middleclass'
local Rectangle = class('Rectangle')

function Rectangle:initialize(x, y, w, h)
	self.x = x
	self.y = y
	self.w = w
	self.h = h
end

function Rectangle:getWidth()
	return self.w
end

function Rectangle:getHeight()
	return self.h
end	

function Rectangle:draw()
	love.graphics.setColor(255, 255, 255)
	love.graphics.rectangle('line', self.x, self.y, self.w, self.h)
end

return Rectangle
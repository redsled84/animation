local class 	= require 'middleclass'
local Quads 	= require 'quads'
local Animation = class('Animation')

function Animation:initialize(image, f, e, delay, x, y)
	self.image = image
	self.delay = delay
	self.timer = 0
	self.dnum = 1
	self.quads = Quads:loadQuads(image, f, e)
end

function Animation:update(dt)
	if self.timer < self.delay then
		self.timer = self.timer + dt
	else
		self.dnum = self.dnum + 1
		self.timer = 0
	end
	if self.dnum > #self.quads then
		self.dnum = 1
	end
end

function Animation:draw(x, y)
	love.graphics.draw(self.image, self.quads[self.dnum], x, y)
end

return Animation
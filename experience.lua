local class = require 'middleclass'
local Collision = require 'collision'
local Timer = require 'timer'
local Player = require 'player'
local Experience = class('Experience')

function Experience:initialize(x, y, n)
	self.amount = n
	self.x = x
	self.y = y
	self.w = 8
	self.h = 8
	self.xvel = 0
	self.yvel = 0
	self.active = true
	self.activeTimer = Timer:new(math.random(.2, .3))
	self.spd = math.random(50, 100)
	self.ySpd = math.random(30, 70)
	self.pickedup = false
	self.radius = 50
	self.distance = 0
	self.dirX = math.random(-20, 20)
	self.t = 'experience'
end

function Experience:pickUp()
	self.pickedup = true
	self = nil
end

function Experience:updateTimer(dt)
	self.activeTimer:update(dt, function()
		self.active = false
	end)
end

function Experience:collide(o)
	local col, rect = Collision:aabbCollision(o, self)
	if col and rect.t == 'wall' then
		local nx, ny = Collision:getCollidingSide(rect, self)
		self.x, self.y, self.xvel, self.yvel = Collision:solveCollision(nx, ny, rect, self)
	end
end

function Experience:update(dt)
	if not self.pickedup and self.active then
		self:updateTimer(dt)
		if self.dirX > 0 then
			self.xvel = (self.xvel + self.spd) + self.dirX * dt
		elseif self.dirX < 0 then
			self.xvel = (self.xvel - self.spd) - self.dirX * dt     
		end 
		self.yvel = self.yvel + self.ySpd * dt

		self.spd = self.spd * 1.75 * dt

		self.x = self.x + self.xvel * dt
		self.y = self.y + self.yvel * dt
	end
end

function Experience:draw()
	if not self.pickedup then
		love.graphics.setColor(0,255,0)
		love.graphics.rectangle('fill', self.x, self.y, self.w, self.h)
		love.graphics.setColor(0,80,0)
		love.graphics.rectangle('line', self.x, self.y, self.w, self.h)

		-- love.graphics.setColor(255,255,255)
		-- love.graphics.circle('line', self.x, self.y, self.radius)
	end
end

return Experience
local Collision 	= require 'collision'
local Globals 		= require 'globals'
local tileW, tileH 	= Globals.tileW, Globals.tileH
local Hook 			= {}

Hook.w, Hook.h 		= tileW / 2, tileH / 2
Hook.spd 			= 600

function Hook:set(v1, v2)
	self.x, self.y 		 = v1.x, v1.y
	self.sx, self.sy 	 = v1.x, v1.y
	self.ex, self.ey 	 = v2.x, v2.y
	self.distance   	 = math.sqrt(math.pow(v2.x-v1.x, 2)+math.pow(v2.y-v1.y, 2))
	self.directionX 	 = (v2.x - v1.x) / self.distance
	self.directionY 	 = (v2.y - v1.y) / self.distance
	self.xvel, self.yvel = self.directionX * self.spd, self.directionY * self.spd
	self.activated 		 = true
end

function Hook:unset()
	if self.activated then
		self.xvel, self.yvel = 0, 0
	end
end

function Hook:unactivate()
	self.activated = false
end

function Hook:collide(o)
	if self.activated then
		local col, rect = Collision:aabbCollision(o, self)
		if col then
			local nx, ny 	= Collision:getCollidingSide(rect, self)
			self.x, self.y  = Collision:solveCollision(nx, ny, rect, self)
			Hook:unset()
		end
	end
end

function Hook:update(dt)
	if self.activated then
		self.x = self.x + self.xvel * dt
		self.y = self.y + self.yvel * dt

		if math.sqrt(math.pow(self.x - self.sx, 2)+math.pow(self.y - self.sy, 2)) >= self.distance then
			self:unset()
		end
	end
end

function Hook:draw()
	if self.activated then
		love.graphics.setColor(255, 0, 0)
		love.graphics.rectangle('line', self.x, self.y, self.w, self.h)
	end
end

function Hook:getWidth()
	return self.w
end

function Hook:getHeight()
	return self.h
end

function Hook:getVelocities()
	return self.xvel, self.yvel
end

function Hook:getActive()
	return self.activated
end

return Hook
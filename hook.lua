local Hook = {}

function Hook:load(w, h)
	self.active = false
	self.freeze = false
	self.spd = 100
	self.w, self.h = w, h
end

function Hook:destantiate()
	self.x, self.y = nil, nil
	self.gx, self.gy = nil, nil
	self.dx, self.dy = nil, nil
	self.dir = nil
end

function Hook:setStart(sx, sy)
	self.x = sx
	self.y = sy
end

function Hook:setGoal(gx, gy)
	self.gx = gx
	self.gy = gy
end

function Hook:activate()
	self.dx, self.dy = self.gx - self.x, self.gy - self.y
	self.dir = math.atan2(self.dy, self.dx)
	self.active = true
end

function Hook:getWidth()
	return self.w
end

function Hook:getHeight()
	return self.h
end

function Hook:solveCollision(nx, ny, rect)
	if nx < 0 then
		self.x = rect.x - self.w
	elseif nx > 0 then
		self.x = rect.x + rect.w
	end
	if ny < 0 then
		self.y = rect.y - self.h
	elseif ny > 0 then
		self.y = rect.y + rect.h
	end
end

function Hook:update(dt)
	if self.active and not self.freeze then
		self.x = self.x + self.spd * math.cos(self.dir) * dt
		self.y = self.y + self.spd * math.sin(self.dir) * dt

		if self.x >= self.gx and self.y >= self.gy then
			self.x = self.gx
			self.y = self.gy
			self.active = false
			self:destantiate()
		end
	end
end

function Hook:draw()
	if self.active then
		love.graphics.setColor(255, 0, 0)
		love.graphics.rectangle('line', self.x, self.y, self.w, self.h)
	end
end

return Hook
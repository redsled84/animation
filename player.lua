local Animation = require 'animation'
local Player 	= {}

function Player:load(x, y, w, h, image)
	self.x = x
	self.y = y
	self.w = w
	self.h = h
	self.spd = 220
	self.xvel = 0
	self.yvel = 0
	self.currentAnimation = 'IdleRight'
	self.animations = {
		{
			name = 'RunRight',
			animation = Animation:new(image, 1, 4, .2, self.x, self.y)
		},
		{
			name = 'RunLeft',
			animation = Animation:new(image, 5, 8, .2, self.x, self.y)
		},
		{
			name = 'RunDown',
			animation = Animation:new(image, 9, 12, .2, self.x, self.y)
		},
		{
			name = 'RunUp',
			animation = Animation:new(image, 13, 16, .2, self.x, self.y)
		},
		{
			name = 'IdleRight',
			animation = Animation:new(image, 17, 18, .4, self.x, self.y)
		},
		{
			name = 'IdleLeft',
			animation = Animation:new(image, 19, 20, .4, self.x, self.y)
		}
	}
end

function Player:move(dt)
	local lk = love.keyboard
	
	if lk.isDown('s') then
		self.yvel = self.spd
		self.currentAnimation = 'RunUp'
	elseif lk.isDown('w') then
		self.yvel = -self.spd
		self.currentAnimation = 'RunDown'
	else
		self.yvel = 0
	end

	if lk.isDown('d') then
		self.xvel = self.spd
		self.currentAnimation = 'RunRight'
	elseif lk.isDown('a') then
		self.xvel = -self.spd
		self.currentAnimation = 'RunLeft'
	else
		self.xvel = 0
	end

	if not lk.isDown('d') and not lk.isDown('a') and
	not lk.isDown('s') and not lk.isDown('w') then
		if self.currentAnimation == 'RunDown' or self.currentAnimation == 'RunLeft' then
			self.currentAnimation = 'IdleLeft'
		end
		if self.currentAnimation == 'RunUp' or self.currentAnimation == 'RunRight' then
			self.currentAnimation = 'IdleRight'
		end
	end

	self.x = self.x + self.xvel * dt
	self.y = self.y + self.yvel * dt
end

function Player:update(dt)
	self:move(dt)
	for _, v in ipairs(self.animations) do
		if v.name == self.currentAnimation then
			v.animation:update(dt)
		end
	end
end

function Player:draw()
	love.graphics.setColor(255, 255, 255)
	for _, v in ipairs(self.animations) do
		if v.name == self.currentAnimation then
			v.animation:draw(self.x, self.y)
		end
	end

	love.graphics.setColor(255, 255, 0)
	love.graphics.rectangle('line', self.x, self.y, self.w, self.h)
end

function Player:solveCollision(nx, ny, rect)
	if nx < 0 then
		self.x = rect.x - self.w
		self.xvel = 0
	elseif nx > 0 then
		self.x = rect.x + rect.w
		self.xvel = 0
	end
	if ny < 0 then
		self.y = rect.y - self.h
		self.yvel = 0
	elseif ny > 0 then
		self.y = rect.y + rect.h
		self.yvel = 0
	end
end

function Player:getWidth()
	return self.w
end

function Player:getHeight()
	return self.h
end

return Player
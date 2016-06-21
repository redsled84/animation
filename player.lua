local Animation = require 'animation'
local Collision = require 'collision'
local Hook 		= require 'hook'
local Vector  	= require 'vector'
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

function Player:moveWithKeys(dt)
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

function Player:moveByVelocity(dt)
	if self.tmp then
		self.x = self.x + self.tmp.x * dt
		self.y = self.y + self.tmp.y * dt
	end
end

function Player:checkHook(dt)
	if Hook:getActive() then
		local distance = math.sqrt(math.pow(self.x - Hook.sx, 2) + math.pow(self.y - Hook.sy, 2))
		if distance >= Hook.distance then
			Hook:unactivate()
		end
	end
end

function Player:movement(dt)
	local xvel, yvel = Hook:getVelocities()
	if Hook:getActive() and xvel == 0 and yvel == 0 then
		self:moveByVelocity(dt)
	elseif not Hook:getActive() then
		self:moveWithKeys(dt)
	end
	self:checkHook(dt)
end

function Player:disableHookOnCollide()
	if Hook:getActive() then
		self.tmp.x, self.tmp.y = 0, 0
		Hook:unactivate()
	end
end

function Player:collide(o)
	local col, rect = Collision:aabbCollision(o, self)
	if col then
		local nx, ny = Collision:getCollidingSide(rect, self)
		self.x, self.y, self.xvel, self.yvel = Collision:solveCollision(nx, ny, rect, self)

		self:disableHookOnCollide()
	end
end

function Player:update(dt)
	self:movement(dt)
	
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

function Player:getWidth()
	return self.w
end

function Player:getHeight()
	return self.h
end

function Player:getCenter()
	return self.x + self.w / 2, self.y + self.h / 2
end

return Player
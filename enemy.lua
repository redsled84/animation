local class = require 'middleclass'
local Animation = require 'animation'
local Globals = require 'globals'; local tileW, tileH = Globals.tileW, Globals.tileH
local Collision = require 'collision'
local Player = require 'player'
local Bullet = require 'bullet'
local Timer = require 'timer'
local Enemy = class('Enemy')

local image = love.graphics.newImage('enemies.png')
image:setFilter('nearest', 'nearest', 1, 1)

function Enemy:initialize(x, y, t, room)
	self.x = x
	self.y = y
	self.xvel = 0
	self.yvel = 0
	self.room = room
	self.isHurt = false
	self.hurtTimer = Timer:new(.2)
	if t >= 75 then
		self.w = tileW * 1.5
		self.h = tileH * 2
		self.xpMin = 6
		self.xpMax = 10
		self.spdConstant = 50
		self.spd = self.spdConstant
		self.minAtkPwr = 15 * Player.level
		self.maxAtkPwr = 20 * Player.level
		self.critical = 15
		self.rof = math.random(1.5, 2.25)
		self.bulletSpd = 650
		self.bulletW = tileW / 1.5
		self.bulletH = tileH / 1.5
		self.maxHealth = 250
		self.health = self.maxHealth
		self.fovRadius = 375
		self.animations = {
			{
				name = 'RunLeft',
				animation = Animation:new(image, 13, 15, .3, self.x, self.y)
			},
			{
				name = 'RunRight',
				animation = Animation:new(image, 16, 18, .3, self.x, self.y)
			},
			{
				name = 'RunDown',
				animation = Animation:new(image, 19, 21, .3, self.x, self.y)
			},
			{
				name = 'RunUp',
				animation = Animation:new(image, 22, 24, .3, self.x, self.y)
			},
			{
				name = 'IdleRight',
				animation = Animation:new(image, 16, 16, .4, self.x, self.y)
			},
			{
				name = 'IdleLeft',
				animation = Animation:new(image, 13, 13, .4, self.x, self.y)
			}
		}
	elseif t < 75 then
		self.w = tileW
		self.h = tileH
		self.xpMin = 2
		self.xpMax = 4
		self.spdConstant = 100
		self.spd = self.spdConstant
		self.minAtkPwr = 5 * Player.level
		self.maxAtkPwr = 15 * Player.level
		self.critical = 8
		self.rof = math.random(0.6, 1.0)
		self.bulletSpd = 800
		self.bulletW = tileW / 2.2
		self.bulletH = tileH / 2.2
		self.maxHealth = 100
		self.health = self.maxHealth
		self.fovRadius = 325
		self.inFov = false
		self.animations = {
			{
				name = 'RunLeft',
				animation = Animation:new(image, 1, 3, .2, self.x, self.y)
			},
			{
				name = 'RunRight',
				animation = Animation:new(image, 4, 6, .2, self.x, self.y)
			},
			{
				name = 'RunDown',
				animation = Animation:new(image, 7, 9, .2, self.x, self.y)
			},
			{
				name = 'RunUp',
				animation = Animation:new(image, 10, 12, .2, self.x, self.y)
			},
			{
				name = 'IdleRight',
				animation = Animation:new(image, 1, 1, .4, self.x, self.y)
			},
			{
				name = 'IdleLeft',
				animation = Animation:new(image, 4, 4, .4, self.x, self.y)
			}
		}
	end
	self.t = t
	self.bullets = {}
	self.damageStats = {}
	self.timer = 0
	self.currentAnimation = 'IdleRight'
	self.animationChance = math.random(1, 2)
end

function Enemy:destroyBullets(o)
	for i = #self.bullets, 1, -1 do
		v = self.bullets[i]
		if Collision:aabbCollision(v, o) then
			table.remove(self.bullets, i)
		end
	end
end

function Enemy:computeFOV()
	local x1, x2 = self.x + self.w / 2, Player.x + Player.w / 2
	local y1, y2 = self.y + self.h / 2, Player.y + Player.h / 2
	local distance = math.sqrt(math.pow(x2 - x1, 2) + math.pow(y2 - y1, 2))
	return distance <= self.fovRadius
end

function Enemy:resetPos()
	local x = math.random((self.room.x1+1)*tileW, self.room.x2*tileW-self.w)*2
	local y = math.random((self.room.y1+1)*tileH, self.room.y2*tileH-self.h)*2

	local distance = math.sqrt(math.pow(x - self.x, 2) + math.pow(y - self.y, 2))

	self.pos = {x = x, y = y, distance = distance}
	self.xvel = (x - self.x) / distance
	self.yvel = (y - self.y) / distance
	self.animationChance = math.random(1, 2)
end

function Enemy:movement(room, dt)
	if self.pos ~= nil then

		self.x = self.x + self.xvel * self.spd * dt
		self.y = self.y + self.yvel * self.spd * dt

		local distance = math.sqrt(math.pow(self.pos.x - self.x, 2) + math.pow(self.pos.y - self.y, 2))
		if math.floor(self.pos.distance - distance) <= 0 then
			self:resetPos()
			self.inFov = true
		else self.inFov = false end
	end
end

function Enemy:animateX()
	if self.xvel > 0 then
		self.currentAnimation = 'RunRight'
	else
		self.currentAnimation = 'RunLeft'
	end
end

function Enemy:animateY()
	if self.yvel > 0 then
		self.currentAnimation = 'RunDown'
	else
		self.currentAnimation = 'RunUp'
	end
end

function Enemy:animate()
	if self.animationChance == 1 then
		self:animateY()
		self:animateX()
	else
		self:animateX()
		self:animateY()
	end	

	if self.xvel == 0 and self.yvel == 0 then
		if self.currentAnimation == 'RunDown' or self.currentAnimation == 'RunLeft' then
			self.currentAnimation = 'IdleLeft'
		end
		if self.currentAnimation == 'RunUp' or self.currentAnimation == 'RunRight' then
			self.currentAnimation = 'IdleRight'
		end
	end
end

function Enemy:collision(o)
	local col, rect = Collision:aabbCollision(o, self)
	if col then
		local nx, ny = Collision:getCollidingSide(rect, self)
		self.x, self.y, self.xvel, self.yvel = Collision:solveCollision(nx, ny, rect, self)
		self:resetPos()
	end

	for i = #self.bullets, 1, -1 do
		local bullet = self.bullets[i]
		if Collision:aabbCollision(o, bullet) then
			table.remove(self.bullets, i)
		end
	end
end

function Enemy:update(dt)
	self:animate()
	self:movement(self.room, dt)
	
	if self:computeFOV() then
		self.timer = self.timer + dt
		if self.timer > self.rof then
			self:shoot(Player.x, Player.y)
			self.timer = 0
		end
		self.spd = self.spdConstant / 2
	else
		self.spd = self.spdConstant
	end
	
	for _, v in ipairs(self.bullets) do
		v:update(dt)
	end
	for _, v in ipairs(self.animations) do
		if v.name == self.currentAnimation then
			v.animation:update(dt)
		end
	end
end

function Enemy:draw()
	love.graphics.setColor(255, 255, 255)
	for _, v in ipairs(self.animations) do
		if v.name == self.currentAnimation then
			if self.t >= 75 then
				v.animation:draw(self.x, self.y, 1.5, 2)
			else
				v.animation:draw(self.x, self.y)
			end
		end
	end

	love.graphics.setColor(255,255,255)
	love.graphics.rectangle('fill', self.x - 12, self.y - 22, self.w+24, 14)

	if self.health > 0 then
		love.graphics.setColor(232,44,12)
		local p = self.health / self.maxHealth
		love.graphics.rectangle('fill', self.x - 10, self.y - 20, (self.w + 20) * p, 10)
	end
	
	-- love.graphics.circle('line', self.x+self.w/2, self.y+self.h/2, self.fovRadius)

	for j = 1, #self.bullets do
		local bullet = self.bullets[j]
		-- love.graphics.setColor(255,255,255)
		-- love.graphics.rectangle('fill', bullet.x1-2, bullet.y1-2, bullet.w+4, bullet.h+4)
		love.graphics.setColor(240, 240, 240)
		love.graphics.rectangle('fill', bullet.x1, bullet.y1, bullet.w, bullet.h)
	end
end

function Enemy:damage(damage)
	self.health = self.health - damage
end

function Enemy:shoot(x, y)
	local critical = 0
	local atkPwr = math.random(self.minAtkPwr, self.maxAtkPwr)
	if math.random(1, 100) > 75 then
		critical = self.critical
	end
	table.insert(self.bullets, Bullet:new(self.x+self.w/2, self.y+self.h/2, x, y,
		self.bulletW, self.bulletH, atkPwr + critical, self.bulletSpd))
end

return Enemy
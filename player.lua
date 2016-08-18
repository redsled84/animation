local Globals = require 'globals'; local tileW, tileH = Globals.tileW, Globals.tileH

local Animation = require 'animation'
local Bullet    = require 'bullet'
local Collision = require 'collision'
local Hook 		= require 'hook'
local Timer		= require 'timer'
local Vector  	= require 'vector'
local Player 	= {
	level = 1,
	maxArmor = 65,
	armor = 65,
	maxXp = 40,
	xp = 0,
	maxAmmo = 50,
	ammo = 0,
	maxHealth = 100,
	health = 100
}

function Player:load(x, y, w, h, image)
	self.x = x
	self.y = y
	self.w = w
	self.h = h
	self.spd = 400
	self.xvel = 0
	self.yvel = 0
	self.bullets = {}
	self.bulletSpd = 700
	self.minAtkPwr = 18
	self.maxAtkPwr = 30
	self.critical = 10
	self.currentAnimation = 'IdleRight'
	self.nextLevel = false
	self.action = false
	self.isHurt = false
	self.canShoot = true
	self.rof = .15
	self.shootTimer = Timer:new(self.rof)
	self.hurtTimer = Timer:new(.3)
	self.knockback = 700
	self.stunned = false
	self.stunnedTimer = Timer:new(.3)
	self.dirX, self.dirY = 0, 0

	self.multiplier = 1.25

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

function Player:setStats(health, armor, ammo, xp)
	self.health = health
	self.armor = armor
	self.ammo = ammo
	self.xp = xp
end

function Player:resetStats()
	self.level = 1
	self.maxArmor = 65
	self.armor = 65
	self.maxXp = 40
	self.xp = 0
	self.maxAmmo = 50
	self.ammo = 0
	self.maxHealth = 100
	self.health = 100
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

function Player:collide(o)
	local col, rect = Collision:aabbCollision(o, self)
	if col and rect.t == 'wall' then
		local nx, ny = Collision:getCollidingSide(rect, self)
		self.x, self.y, self.xvel, self.yvel = Collision:solveCollision(nx, ny, rect, self)
	elseif col and rect.t == 'downstair' then
		self.nextLevel = true
	elseif col then
		local nx, ny = Collision:getCollidingSide(rect, self)
		self.x, self.y, self.xvel, self.yvel = Collision:solveCollision(nx, ny, rect, self)
		-- trigger hurting here
	end
end

function Player:collideEnemy(enemy, dt)
	local col, rect = Collision:aabbCollision(enemy, self)
	if col and type(enemy.t) == 'number' then
		self:hurt(enemy, dt)
		self.health = self.health - .02 * dt
	end
end

function Player:collideBullets(o, callback)
	for i=#self.bullets, 1, -1 do
		local v = self.bullets[i]
		if Collision:aabbCollision(o, v) then
			table.remove(self.bullets, i)
			if callback then
				callback(v.atkPwr)
			end
		end
	end
end

function Player:updateBullets(dt)
	for _, v in ipairs(self.bullets) do
		v:update(dt)
	end
end

function Player:update(dt)
	self:updateBullets(dt)
	if not self.stunned then
		self:movement(dt)
	end
	self:updateTimers(dt)

	self:levelUp()

	for _, v in ipairs(self.animations) do
		if v.name == self.currentAnimation then
			v.animation:update(dt)
		end
	end
end

function Player:draw()
	love.graphics.setColor(255, 255, 255)

	if self.isHurt then
		love.graphics.setColor(255, 0, 0)
	end

	for _, v in ipairs(self.animations) do
		if v.name == self.currentAnimation then
			v.animation:draw(self.x, self.y)
		end
	end

	for _, v in ipairs(self.bullets) do
		-- love.graphics.setColor(255,255,255)
		-- love.graphics.rectangle('fill', v.x1-2, v.y1-2, v.w+4, v.h+4)
		love.graphics.setColor(240, 240, 240)
		love.graphics.rectangle('fill', v.x1, v.y1, v.w, v.h)
	end

	-- love.graphics.setColor(255, 255, 0)
	-- love.graphics.rectangle('line', self.x, self.y, self.w, self.h)
end

function Player:damage(damage)
	if self.armor <= 0 then
		self.health = self.health - damage
		self.armor = 0
	end
	if self.armor > 0 then
		self.armor = self.armor - damage
	end

	self:hurt()
end

function Player:resetHealth(n)
	self.health = n
end

function Player:addXp()
	self.xp = self.xp + 1
end

function Player:levelUp()
	if self.xp >= self.maxXp then
		self.level = self.level + 1
		self.maxHealth = math.ceil(self.maxHealth * self.multiplier)
		self.health = self.maxHealth
		self.maxArmor = math.ceil(self.maxArmor * self.multiplier)
		self.armor = self.maxArmor
		self.xp = 0
		self.maxXp = math.ceil(self.maxXp * self.multiplier)
	end
end

function Player:hurt(enemy, dt)
	self.isHurt = true

	if enemy ~= nil and dt ~= nil then
		self.stunned = true

		if self.dirX == 0 and self.dirY == 0 then
			self.dirX = math.random(1, 2)
			self.dirY = math.random(1, 2)
		end
	end
end

function Player:updateTimers(dt)
	if self.isHurt then
		self.hurtTimer:update(dt, function()
			self.isHurt = false
		end)
	end
	if not self.canShoot then
		self.shootTimer:update(dt, function()
			self.canShoot = true
		end)
	end
	if self.stunned then
		if self.dirX == 1 then
			self.xvel = self.xvel + self.knockback * dt
		else
			self.xvel = self.xvel - self.knockback * dt
		end
		if self.dirY == 1 then
			self.yvel = self.yvel + self.knockback * dt
		else
			self.yvel = self.yvel - self.knockback * dt
		end
		self.x = self.x + self.xvel * dt
		self.y = self.y + self.yvel * dt
		self.stunnedTimer:update(dt, function()
			self.stunned = false
			self.dirX, self.dirY = 0, 0
		end)
	end
end

function Player:shoot(x, y, button)
	if button == 1 and self.canShoot then
		local critical = 0
		local atkPwr = math.random(self.minAtkPwr, self.maxAtkPwr)
		if math.random(1, 100) > 80 then
			local critical = self.critical
		end
		table.insert(self.bullets, Bullet:new(self.x+self.w/2, self.y+self.h/2, x, y, tileW / 4, tileH / 4, atkPwr + critical, self.bulletSpd))
		self.canShoot = false
	end
end

function Player:actionKey(key, callback)
	if key == 'f' and self.nextLevel then
		callback()
	end
end

function Player:hasDied()
	return self.health < 0
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
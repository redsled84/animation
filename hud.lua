local class = require 'middleclass'
local Player = require 'player'

local Hud = class('Hud')

function Hud:initialize(health)
	self.scale = 1
	self.healthbar = {
		w = 0,
		h = 20,
		xOffset = 70,
		yOffset = 20
	}
	self.armorbar = {
		w = 0,
		h = 20,
		xOffset = 70,
		yOffset = 50
	}
end

function Hud:drawUpdateBar()
	self.healthbar.w = Player.health * self.scale
	self.armorbar.w = Player.armor * self.scale
end

function Hud:draw(cx, cy, cw, ch)
	self:drawUpdateBar()

	love.graphics.setColor(0,0,0,180)
	love.graphics.rectangle('fill', cx+5, cy+5, Player.maxHealth + self.healthbar.xOffset + 20, self.armorbar.yOffset + 60)

	love.graphics.setColor(255,255,255)
	love.graphics.print('Health', cx+10, cy+self.healthbar.yOffset)
	love.graphics.setColor(255,255,255)
	love.graphics.rectangle('fill', cx + self.healthbar.xOffset-2, cy + self.healthbar.yOffset-2, 
		Player.maxHealth+4, self.healthbar.h+4)
	if Player.health > 0 then
		love.graphics.setColor(232,44,12)
		love.graphics.rectangle('fill', cx + self.healthbar.xOffset, cy + self.healthbar.yOffset, 
			self.healthbar.w, self.healthbar.h)
	end

	if Player.armor > 0 then
		love.graphics.setColor(255,255,255)
		love.graphics.print('Armor', cx+10, cy+self.armorbar.yOffset)
		love.graphics.setColor(255,255,255)
		love.graphics.rectangle('fill', cx + self.armorbar.xOffset-2, cy + self.armorbar.yOffset-2, 
			Player.maxArmor+4, self.armorbar.h+4)
	
		love.graphics.setColor(100,100,100)
		love.graphics.rectangle('fill', cx + self.armorbar.xOffset, cy + self.armorbar.yOffset, 
			self.armorbar.w, self.armorbar.h)
	end

	love.graphics.setColor(255,255,255)
	love.graphics.print('Levels', cx + 10, cy + self.armorbar.yOffset + 30)
	for i = 1, Player.level do
		love.graphics.rectangle('fill', cx + self.armorbar.xOffset + (i*8) - 8, cy + self.armorbar.yOffset + 28, 6, 16)
	end

	love.graphics.setColor(0,0,0,180)
	love.graphics.rectangle('fill', cx + 20, cy + ch - 50, cw - 40, 40)
	
	if Player.xp > 0 then
		love.graphics.setColor(255,255,255)
		love.graphics.rectangle('fill', cx + 38, cy + ch - 37, cw - 78, 14)
		local p = Player.xp / Player.maxXp
		love.graphics.setColor(0,200,0)
		love.graphics.rectangle('fill', cx + 40, cy + ch - 35, (cw - 80) * p, 10)
	end
end

return Hud
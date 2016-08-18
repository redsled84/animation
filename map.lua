local class = require 'middleclass'
local Globals = require 'globals'; local tileW, tileH = Globals.tileW*2, Globals.tileH*2
local Rectangle = require 'rectangle'
local Enemy = require 'enemy'
local Experience = require 'experience'
local Quads = require 'quads'
local Map = class('Map')

local scale = 2

local Spritesheet = love.graphics.newImage('maptileset.png')
Spritesheet:setFilter('nearest', 'nearest', 1, 1)

local Tile = {
	Floor = 0,
	Solid = 1,
	Door  = 2,
	Corridor = 3,
	Room = 4,
	Downstair = 5
}

local DrawTile = {
	Solid = Quads:loadQuad(Spritesheet, 5),
	Downstair = Quads:loadQuad(Spritesheet, 9),
	Floor = Quads:loadQuad(Spritesheet, 15)
}

Map.depth = 1
function Map:initialize(width, height)
	self.width = width
	self.height = height
	self.map = {}
	self.rooms = {}
	self.rectangles = {}
	self.enemies = {}
	self.xp = {}
	for y = 1, height do
		local tmp = {}
		for x = 1, width do
			tmp[#tmp+1] = Tile.Solid
		end
		self.map[y] = tmp
	end
end

function Map:generate(width, height, mrooms, minEnemies, maxEnemies, depth)
	self:initialize(width, height)

	local roomMinSize = 4
	local roomMaxSize = 9
	local nEnemies = math.random(minEnemies, maxEnemies)

	for r = 1, mrooms do
		local w = math.random(roomMinSize, roomMaxSize)
		local h = math.random(roomMinSize, roomMaxSize)
		local x = math.random(2, self.width - w - 1)
		local y = math.random(2, self.height - h - 1)

		local newRoom = Rectangle:new(x, y, w, h)
		local failed = false
		if #self.rooms > 0 then
			for i = 1, #self.rooms do
				local room = self.rooms[i]
				if newRoom:intersect(room) then
					failed = true
					break
				end
			end
		end

		if not failed then
			self:createRoom(newRoom)

			newX, newY = newRoom:center()

			if #self.rooms > 1 then
				prevX, prevY = self.rooms[#self.rooms-1]:center()

				if math.random(0, 1) == 1 then
					self:createHorizontalTunnel(prevX, newX, prevY)
					self:createVerticalTunnel(prevY, newY, newX)
				else
					self:createVerticalTunnel(prevY, newY, prevX)
					self:createHorizontalTunnel(prevX, newX, newY)
				end
			end

			table.insert(self.rooms, newRoom)
		end
	end

	for y = 1, self.height do
		for x = 1, self.width do
			if self.map[y][x] == 1 then
				table.insert(self.rectangles, Rectangle:new(x*tileW, y*tileH, tileW, tileH))
			end
		end
	end

	self:generateEnemies(nEnemies)

	local lastRoom = self.rooms[#self.rooms]
	local rx, ry = math.random(lastRoom.x1+1, lastRoom.x2-1), math.random(lastRoom.y1+1, lastRoom.y2-1)
	table.insert(self.rectangles, Rectangle:new(rx*tileW, ry*tileH, tileW, tileH, 'downstair'))
	self:createDownstairs(rx, ry)
end

function Map:generateEnemies(nEnemies)
	for n = 1, #self.rooms do
		local room = self.rooms[n]
		local num = math.random(1, 3)
		if num + #self.enemies <= nEnemies then
			for j = 1, num do
				local t = math.random(1, 100)
				local enemy = Enemy:new(nil, nil, t, room)
				enemy.x = math.random((room.x1+1)*tileW, room.x2*tileW-enemy.w)
				enemy.y = math.random((room.y1+1)*tileH, room.y2*tileH-enemy.h)
				enemy:resetPos()

				table.insert(self.enemies, enemy)
			end
		else
			break
		end
	end
end

function Map:createRoom(room)
	for y = room.y1+1, room.y2-1 do
		for x = room.x1+1, room.x2-1 do
			self.map[y][x] = Tile.Room
		end
	end
end

function Map:createHorizontalTunnel(x1, x2, y)
	for x = math.min(x1, x2), math.max(x1, x2) do
		self.map[y][x] = Tile.Corridor
	end
end

function Map:createVerticalTunnel(y1, y2, x)
	for y = math.min(y1, y2), math.max(y1, y2) do
		self.map[y][x] = Tile.Corridor
	end
end

function Map:createDoor(x, y)
	self.map[y][x] = Tile.Door
end

function Map:createDownstairs(x, y)
	self.map[y][x] = Tile.Downstair
end

function Map:update(dt)
	for i = #self.enemies, 1, -1 do
		local enemy = self.enemies[i]
		local x, y = enemy.x, enemy.y
		enemy:update(dt)

		if enemy.health <= 0 then
			enemy.health = 0
			table.remove(self.enemies, i)

			local xp = math.random(enemy.xpMin, enemy.xpMax) * (self.depth / 2)
			for j = 1, xp do
				local amount = 1
				table.insert(self.xp, Experience:new(enemy.x+enemy.w/2, enemy.y+enemy.h/2, amount))
			end
		end
	end

	for i = #self.xp, 1, -1 do
		local xp = self.xp[i]
		xp:update(dt)
	end
end

function Map.drawFloor(x, y, map)
	if map[y][x] == Tile.Room or map[y][x] == Tile.Corridor then
		love.graphics.draw(Spritesheet, DrawTile.Floor, x * tileW, y * tileH, 0, 2, 2)
	end
end

function Map.drawSolid(x, y, map)
	if map[y][x] == Tile.Solid then
		love.graphics.draw(Spritesheet, DrawTile.Solid, x * tileW, y * tileH, 0, 2, 2)
	end
end

function Map.drawDownstair(x, y, map)
	if map[y][x] == Tile.Downstair then
		love.graphics.draw(Spritesheet, DrawTile.Downstair, x * tileW, y * tileH, 0, 2, 2)
	end
end

function Map:drawEnemies()
	for i = 1, #self.enemies do
		local enemy = self.enemies[i]
		enemy:draw()
	end
end

function Map:drawExperience()
	for i = 1, #self.xp do
		local xp = self.xp[i]
		xp:draw()
	end
end

function Map:drawLayer(cX, cY, cW, cH, layer)
	for y = 2, self.width do
		for x = 2, self.height do
			if x*tileW > cX - tileW and x*tileW < cX + cW + tileW and
			y*tileH > cY - tileH and y*tileH < cY + cH + tileH then
				love.graphics.setColor(255,255,255)
				layer(x, y, self.map)
			end
		end
	end
end

return Map
math.randomseed(os.time())
math.random();math.random();math.random();

local globals      = require 'globals'
local tileW, tileH = globals.tileW, globals.tileH
local Camera 	   = require 'camera'

local Collision    = require 'collision'
-- local Hook 		   = require 'hook'
	  LightWorld   = require 'lib'
local Map 		   = require 'map'
local Hud 		   = require 'hud'
local Player 	   = require 'player'
local Rectangle    = require 'rectangle'
local Vector       = require 'vector'

local shadows = {}

local gameState = 'play'

local mapWidth = 50
local mapHeight = 50
local maxSize = 65
local sizeIncrement = 5

local minEnemies = 5
local maxEnemies = 12
local enemyIncrement = 2
local nEnemies = 30

local maxRooms = 10
local roomIncrement = 4
local nRooms = 75

local function increaseWorldDifficulty()
	if mapWidth < maxSize and mapHeight < maxSize then
		mapWidth = mapWidth + sizeIncrement
		mapHeight = mapHeight + sizeIncrement
	end
	if maxEnemies < nEnemies then
		minEnemies = minEnemies + enemyIncrement
		maxEnemies = maxEnemies + enemyIncrement
	end
	if maxRooms < nRooms then
		maxRooms = maxRooms + roomIncrement
	end
end

local healthbarW = 0
local lightWorld
local function newWorld()
	shadows = {}
	lightWorld = LightWorld({
		ambient = {10,10,10},
		refractionStrength = 32.0,
		reflectionVisibility = 0.75,
	})


	Map.enemies = {}
	Map.rectangles = {}
	Map.xp = {}
	Map.rooms = {}
	Map.map = {}
	lightWorld.rectangles = {}
	Map:generate(mapWidth, mapHeight, maxRooms, minEnemies, maxEnemies, depth)

	local viableList = {}
	for i = 1, #Map.rooms-1 do
		viableList[i] = {room = Map.rooms[i], index = i}
	end

	for i = #viableList, 1, -1 do
		local v = viableList[i]
		for _, enemy in ipairs(Map.enemies) do
			if v ~= nil then
				if v.room == enemy.room then
					table.remove(viableList, i)
					break
				end	
			end
		end
	end

	local rn = math.random(1, #viableList)
	local cx, cy

	if #viableList == 0 then
		cx, cy = Map.rooms[1]:center()
	else
		cx, cy = viableList[rn].room:center()
	end

	local Spritesheet = love.graphics.newImage('tileset.png')
	Spritesheet:setFilter('nearest', 'nearest', 1, 1)

	if Map.depth == 1 then
		Player:load(cx*(tileW*2), cy*(tileH*2), tileW, tileH, Spritesheet)
	else
		Player:load(cx*(tileW*2), cy*(tileH*2), tileW, tileH, Spritesheet)
		Player:setStats(Player.health, Player.armor, Player.ammo, Player.xp)
	end

	light = nil
	-- create light
	light = lightWorld:newLight(Player.x+Player.w, Player.y+Player.h, 100, 140, 180, 500)
	light:setGlowStrength(0.3)

	camera = Camera(love.graphics.getWidth()/2, love.graphics.getHeight()/2)
	camera:zoom(1)

	lightWorld.rectangles = {}
	for i=1, #Map.rectangles do
		local rect = Map.rectangles[i]
		table.insert(lightWorld.rectangles, lightWorld:newRectangle(rect.x1+tileW, rect.y1+tileH, rect.x2-rect.x1, rect.y2-rect.y1))
	end

	increaseWorldDifficulty()

	Hud:initialize()
	Map.depth = Map.depth + 1
	print(Player.x, Player.y, camera.x, camera.y, lightWorld.l, lightWorld.t)

	camera:lookAt(Player.x, Player.y)

    lightWorld.l = -camera.x + love.graphics.getWidth()/2
    lightWorld.t = -camera.y + love.graphics.getHeight()/2

	light:setPosition(Player.x+Player.w/2, Player.y+Player.h/2, 1)
end



local function getCameraWindow()
	return camera.x - love.graphics.getWidth() / 2 * (1 / camera.scale),
			camera.y - love.graphics.getHeight() / 2 * (1 / camera.scale),
			love.graphics.getWidth() * (1 / camera.scale),
			love.graphics.getHeight() * (1 / camera.scale)
end

--[[

MAIN

]]

function love.load()
	newWorld()
end

function love.update(dt)
	if gameState == 'play' then
		
		Player:update(dt)
		Map:update(dt)

		for _, v in ipairs(Map.rectangles) do
			Player:collide(v)
			Player:collideBullets(v)
			for _, enemy in ipairs(Map.enemies) do
				enemy:collision(v)
			end
			for _, xp in ipairs(Map.xp) do
				xp:collide(v)
			end
			-- Hook:collide(v)
		end

		for i = #Map.xp, 1, -1 do
			local xp = Map.xp[i]
			if Collision:aabbCollision(Player, xp) then
				xp:pickUp()
				Player:addXp()
				table.remove(Map.xp, i)
			end
		end

		for _, enemy in ipairs(Map.enemies) do
			for i = #enemy.bullets, 1, -1 do
				local bullet = enemy.bullets[i]
				if Collision:aabbCollision(Player, bullet) then
					table.remove(enemy.bullets, i)
					Player:damage(bullet.atkPwr)
				end
			end

			Player:collideEnemy(enemy, dt)

			Player:collideBullets(enemy, function(atkPwr)
				enemy:damage(atkPwr)
			end)
		end

	    camera:lookAt(Player.x, Player.y)

	    lightWorld.l = -camera.x + love.graphics.getWidth()/2
	    lightWorld.t = -camera.y + love.graphics.getHeight()/2
	    lightWorld:update(dt)
		light:setPosition(Player.x+Player.w/2, Player.y+Player.h/2, 1)

		if Player:hasDied() then
			Player.health = 0
			Player:resetStats()
			gameState = 'dead'
		end
	end
end

local function getEllipse(o)
	local x = (o.x or o.x1) + o.w / 2
	local y = (o.y or o.y1) + o.h
	local rw, rh = o.w, o.h / 2
	return x, y, rw, rh
end

function love.draw()
	local cx, cy, cw, ch = getCameraWindow()
	camera:attach()
	lightWorld:draw(function()
		-- love.graphics.setColor(255, 255, 255)
	 --  	love.graphics.rectangle("fill", -camera.x/camera.scale, -camera.y/camera.scale,
	 --  		Map.width*tileW/camera.scale, Map.height*tileH/camera.scale)
		Map:drawLayer(cx, cy, cw, ch, Map.drawFloor)
		Map:drawLayer(cx, cy, cw, ch, Map.drawDownstair)

		--Shadows
		for i, enemy in ipairs(Map.enemies) do
			local x, y, rw, rh = getEllipse(enemy)
			love.graphics.setColor(0, 0, 0, 120)
			love.graphics.ellipse('fill', x, y, rw, rh)
		end

		local x, y, rw, rh = getEllipse(Player)
		love.graphics.setColor(0, 0, 0, 120)
		love.graphics.ellipse('fill', x, y, rw, rh)

		Map:drawExperience()
		Map:drawEnemies()
		Player:draw()

		Map:drawLayer(cx, cy, cw, ch, Map.drawSolid)

		-- for i=1, #lightWorld.rectangles do
		-- 	local rect = lightWorld.rectangles[i]
		-- 	love.graphics.polygon("line", rect:getPoints())
		-- end

	end)
	Hud:draw(cx, cy, cw, ch)

	-- for _, rect in ipairs(Map.rectangles) do
	-- 	love.graphics.setColor(255,255,255)
	-- 	love.graphics.rectangle('line', rect.x1, rect.y1, tileW, tileH)
	-- end

	--Debug printing to the screen
	local thing = tostring( love.timer.getFPS() )
	love.graphics.setColor(255,255,255)
	love.graphics.print(thing, cx, cy)

	--Dead overlay
	if gameState == 'dead' then
		love.graphics.setColor(0,0,0,100)
		love.graphics.rectangle('fill', cx, cy, cw, ch)
		love.graphics.setColor(255,255,255)
		love.graphics.print("Press 'R' to restart", cx + cw / 2, cy + ch / 2)
	end

	camera:detach()
end

function love.keypressed(key)
	if key == 'escape' then
		love.event.quit()
	end
	if key == 'r' and gameState == 'dead' then
		gameState = 'play'
		newWorld()

	end
	Player:actionKey(key, newWorld)
end

function love.mousepressed(x, y, button)
	local mx, my = camera:mousePosition()
	Player:shoot(mx, my, button)
end
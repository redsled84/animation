local globals      = require 'globals'
local tileW, tileH = globals.tileW, globals.tileH

-- new

local Hook 		   = require 'hook'
local Player       = require 'player'
local Rectangle    = require 'rectangle'
local Collision    = require 'collision'

math.randomseed(os.time())
math.random();math.random();math.random();

function love.load()
	rectangles = {
		Rectangle:new(100, 100, 128, 128),
		Rectangle:new(100, 36, 64, 64),
		Rectangle:new(400, 200, 32, 32),
		Rectangle:new(300, 200, 100, 64)
	}
	spritesheet = love.graphics.newImage('tileset.png')
	Player:load(0, 0, tileW, tileH, spritesheet)

	-- new

	Hook:load(tileW / 2, tileH / 2)
end

function love.update(dt)
	Player:update(dt)

	-- new

	Hook:update(dt)
	for _, rect in ipairs(rectangles) do
		local col, b = Collision:aabbCollision(rect, Player)
		if col then
			local nx, ny = Collision:getCollidingSide(Player, rect)
			Player:solveCollision(nx, ny, rect)
		end

		-- new

		if Hook.active then
			local col, b = Collision:aabbCollision(rect, Hook)
			if col then
				Hook.freeze = true
			end
		end
	end
end

function love.draw()
	Player:draw()

	-- new

	Hook:draw()
	for _, rect in ipairs(rectangles) do
		rect:draw()
	end

	local thing = tostring( collectgarbage('count') )
	love.graphics.print(thing, 10, 10)
end

function love.keypressed(key)
	if key == 'escape' then
		love.event.quit()
	end
end

-- new

function love.mousepressed(x, y, button)
	if button == 1 then
		Hook:setStart(Player.x, Player.y)
		Hook:setGoal(x, y)
		Hook:activate()
	end
end
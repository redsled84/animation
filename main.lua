local globals      = require 'globals'
local tileW, tileH = globals.tileW, globals.tileH

-- new

local Collision    = require 'collision'
local Hook 		   = require 'hook'
local Player       = require 'player'
local Rectangle    = require 'rectangle'
local Vector       = require 'vector'

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
end

function love.update(dt)
	Player:update(dt)
	Hook:update(dt)

	for _, v in ipairs(rectangles) do
		Player:collide(v)
		Hook:collide(v)
	end
end

function love.draw()
	Player:draw()
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

function love.mousepressed(x, y, button)
end

function love.mousereleased(x, y, button)
	if button == 1 then
		local px, py = Player:getCenter()
		px = px - Hook:getWidth() / 2
		py = py - Hook:getHeight() / 2
		local v1 = Vector:new(px, py)
		local v2 = Vector:new(x, y)
		Hook:set(v1, v2)
		Player.tmp = Vector:new(Hook.xvel, Hook.yvel)
	end
end
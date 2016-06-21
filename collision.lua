local class 	= require 'middleclass'
local Collision = class('Collision')

function Collision:aabbCollision(rect, o)
	if rect.x + rect:getWidth() > o.x and
		rect.x < o.x + o:getWidth() and
		rect.y + rect:getHeight() > o.y and
		rect.y < o.y + o:getHeight() then
		return true, rect
	else
		return false, nil
	end
end

function Collision:getCollidingSide(rect, o)
	local rectBottom = rect.y + rect:getHeight()
	local oBottom = o.y + o:getHeight()
	local rectRight = rect.x + rect:getWidth()
	local oRight = o.x + o:getWidth()
	local bCollision = rectBottom - o.y
	local tCollision = oBottom - rect.y
	local lCollision = oRight - rect.x
	local rCollision = rectRight - o.x

	local nx, ny = 0, 0

	if tCollision < bCollision and tCollision < lCollision and tCollision < rCollision then
		ny = -1
	end
	if bCollision < tCollision and bCollision < lCollision and bCollision < rCollision then
		ny = 1
	end
	if lCollision < rCollision and lCollision < tCollision and lCollision < bCollision then
		nx = -1
	end
	if rCollision < lCollision and rCollision < tCollision and rCollision < bCollision then
		nx = 1
	end

	return nx, ny
end

function Collision:solveCollision(nx, ny, rect, o)
	local x, y, xvel, yvel = o.x, o.y, o.xvel or 0, o.yvel or 0
	local w, h = o.w, o.h
	if nx < 0 then
		x = rect.x - w
		xvel = 0
	elseif nx > 0 then
		x = rect.x + rect.w
		xvel = 0
	end
	if ny < 0 then
		y = rect.y - h
		yvel = 0
	elseif ny > 0 then
		y = rect.y + rect.h
		yvel = 0
	end
	return x, y, xvel, yvel
end

return Collision
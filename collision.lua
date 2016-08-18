local class 	= require 'middleclass'
local Collision = class('Collision')

function Collision:aabbCollision(rect, o)
	local x = o.x or o.x1
	local y = o.y or o.y1
	local rx1, rx2 = rect.x1 or rect.x, rect.x2 or rect.x + rect.w
	local ry1, ry2 = rect.y1 or rect.y, rect.y2 or rect.y + rect.h
	if rx2 > x and
		rx1 < x + o.w and
		ry2 > y and
		ry1 < y + o.h then
		return true, rect
	else
		return false, nil
	end
end

function Collision:getCollidingSide(rect, o)
	local rectBottom = (rect.y1 or rect.y) + rect.h
	local oBottom = o.y + o.h
	local rectRight = (rect.x1 or rect.x) + rect.w
	local oRight = o.x + o.w
	local bCollision = rectBottom - o.y
	local tCollision = oBottom - (rect.y1 or rect.y)
	local lCollision = oRight - (rect.x1 or rect.x)
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
		x = rect.x1 - w
		xvel = 0
	elseif nx > 0 then
		x = rect.x2
		xvel = 0
	end
	if ny < 0 then
		y = rect.y1 - h
		yvel = 0
	elseif ny > 0 then
		y = rect.y2
		yvel = 0
	end
	return x, y, xvel, yvel
end

return Collision
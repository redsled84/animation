local class 	= require 'middleclass'
local Collision = class('Collision')

function Collision:aabbCollision(a, b)
	if a.x + a:getWidth() > b.x and
		a.x < b.x + b:getWidth() and
		a.y + a:getHeight() > b.y and
		a.y < b.y + b:getHeight() then
		return true, b
	else
		return false, nil
	end
end

function Collision:getCollidingSide(a, b)
	local aBottom = a.y + a:getHeight()
	local bBottom = b.y + b:getHeight()
	local aRight = a.x + a:getWidth()
	local bRight = b.x + b:getWidth()
	local bCollision = bBottom - a.y
	local tCollision = aBottom - b.y
	local lCollision = aRight - b.x
	local rCollision = bRight - a.x

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

return Collision
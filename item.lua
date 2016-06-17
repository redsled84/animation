local class = require 'middleclass'
local Item 	= class('Item')

function Item:initialize(x, y, w, h, name)
	self.x = x
	self.y = y
	self.w = w
	self.h = h
	self.name = name
	self.visible = true
end

function Item:setSprite(sprite)
	self.sprite = sprite
end

function Item:pickUp()
	self.visible = false
	return self
end

function Item:drop(x, y)
	self.visible = true
end

return Item
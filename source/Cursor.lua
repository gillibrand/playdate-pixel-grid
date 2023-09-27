import "CoreLibs/graphics"
import "CoreLibs/sprites"
import "CoreLibs/object"
import "CoreLibs/timer"

local pd <const> = playdate
local gfx <const> = pd.graphics

class('Cursor').extends(gfx.sprite)

function Cursor:init(col, row)
	Cursor.super.init(self)
	self:setLocation(col, row)

	self._isBig = false
	self._wasBig = true
end

function Cursor:setLocation(col, row)
	self._col = col
	self._row = row
	self:moveTo((col - 1) * PxSize + HalfSize, (row - 1) * 20 + HalfSize)
	self:setZIndex(100)
end

function Cursor:getLocation()
	return self._col, self._row
end

function Cursor:update()
	if self._wasBig == self._isBig then
		-- nothing to do since size matches
		return
	end

	local image = gfx.image.new(20, 20)
	gfx.pushContext(image)
	local size = 5
	if self._isBig then size += 1 end
	gfx.setColor(gfx.kColorWhite)
	gfx.fillCircleAtPoint(HalfSize, HalfSize, 7)
	gfx.setColor(gfx.kColorBlack)
	gfx.fillCircleAtPoint(HalfSize, HalfSize, size)
	gfx.popContext()
	self:setImage(image)

	self._wasBig = self._isBig

	function toggleBig()
		self._isBig = not self._isBig
	end

	pd.timer.new(500, toggleBig)
end

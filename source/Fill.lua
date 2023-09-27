import "CoreLibs/graphics"
import "CoreLibs/sprites"
import "CoreLibs/object"
import "CoreLibs/timer"

local pd <const> = playdate
local gfx <const> = pd.graphics

class('Fill').extends(gfx.sprite)

function Fill:init(col, row)
	Fill.super.init(self)
	self:setLocation(col, row)

	local image = gfx.image.new(20, 20)
	gfx.pushContext(image)
	gfx.fillRect(0, 0, 20, 20)
	gfx.popContext();

	self:setImage(image)
end

function Fill:setLocation(col, row)
	self._col = col
	self._row = row
	self:moveTo((col - 1) * PxSize + HalfSize, (row - 1) * 20 + HalfSize)
end

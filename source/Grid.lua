import "CoreLibs/graphics"
import "CoreLibs/sprites"
import "CoreLibs/object"

local pd <const> = playdate
local gfx <const> = pd.graphics

-- local PxSize <const> = 20

class('Grid').extends(gfx.sprite)

function Grid:init()
	Grid.super.init(self)

	local image = gfx.image.new(pd.display.getSize())
	gfx.pushContext(image)
	for i = 1, 19 do
		local x = i * kPxSize
		gfx.drawLine(x, 0, x, 240)
	end
	for i = 1, 11 do
		local y = i * kPxSize
		gfx.drawLine(0, y, 400, y)
	end
	gfx.popContext()

	self:setUpdatesEnabled(false)
	self:setZIndex(-32000)
	self:moveTo(200, 120)
	self:setImage(image)
end

import "CoreLibs/graphics"

kPxSize = 20
kHalfPxSize = kPxSize / 2

kRows = 12
kCols = 20

local pd <const> = playdate
local gfx <const> = pd.graphics

--- Util to call code in a push/popContext block.
function inContext(image, callback)
	gfx.pushContext(image)
	pcall(callback)
	gfx.popContext()
end

function callback(fun)
	if fun then pcall(fun) end
end

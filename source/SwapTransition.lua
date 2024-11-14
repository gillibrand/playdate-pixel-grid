import "CoreLibs/graphics"
import "CoreLibs/sprites"
import "CoreLibs/object"
import "CoreLibs/timer"

local pd <const> = playdate
local gfx <const> = pd.graphics

class('SwapTransition').extends(gfx.sprite)

--- Effect to swap the entire screen when transitioning between drawings. Start with the
--  current drawing. During on `midCallback` load the new drawing and it will slide in.
--
-- @param isForward Moves sceens from left to right is true; else right to left.
-- @param midCallback Once the screen move off display this is called and should update the new
-- screen to animate in.
-- @param endCallback Called when the swap is complete. This removes itself automatically.
function SwapTransition:init(isForward, midCallback, endCallback)
	self.midCallback = midCallback
	self.endCallback = endCallback

	self.dir = isForward and 1 or -1

	self.outAnim = gfx.animator.new(200, 0, self.dir * -400, pd.easingFunctions.inQuad)
	self.inAnim = nil
	self:setUpdatesEnabled(true)

	self:add()
end

function SwapTransition:update()
	if self.outAnim then
		if not self.outAnim:ended() then
			pd.display.setOffset(self.outAnim:currentValue(), 0)
		else
			self.outAnim = nil
			self.inAnim = gfx.animator.new(200, self.dir * 400, 0, pd.easingFunctions.outQuad)
			self.midCallback()
		end
	elseif self.inAnim then
		if not self.inAnim:ended() then
			pd.display.setOffset(self.inAnim:currentValue(), 0)
		else
			self.inAnim = nil
			self.endCallback()
			self:remove()
		end
	end
end

import "CoreLibs/graphics"
import "CoreLibs/sprites"
import "CoreLibs/object"
import "CoreLibs/timer"
-- import "CoreLibs/geometry"

local pd <const> = playdate
local gfx <const> = pd.graphics

class('Block').extends(gfx.sprite)

function Block:init(col, row)
  Block.super.init(self)
  self:setLocation(col, row)

  local image = gfx.image.new(20, 20)
  gfx.pushContext(image)
  gfx.fillRect(0, 0, 20, 20)
  gfx.popContext();

  self:setImage(image)
  self:updatesEnabled(false)
end

function Block:setLocation(col, row)
  self._col = col
  self._row = row
  self:moveTo((col - 1) * PxSize + HalfSize, (row - 1) * 20 + HalfSize)
end

function Block:fall()
  local line = pd.geometry.lineSegment.new(self.x, self.y, self.x, 280)
  self._anim = gfx.animator.new(1000, line, pd.easingFunctions.outBounce)
  self:setAnimator(self._anim)
  self:updatesEnabled(true)
end

function Block:update()
  if not self._anim then return end

  if self._anim and self._anim:ended() then
    self._anim = nil
    self:updatesEnabled(false)
    self:remove()
  end
end

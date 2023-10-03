import "CoreLibs/graphics"
import "CoreLibs/sprites"
import "CoreLibs/object"
import "CoreLibs/timer"

local pd <const> = playdate
local gfx <const> = pd.graphics

--- A square block "pixel" in a drawing. Each is a sprite that can be animated away.
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

--- Positions this block on the grid. 1 indexed. Starts from top-left.
function Block:setLocation(col, row)
  self._col = col
  self._row = row
  self:moveTo((col - 1) * kPxSize + kHalfPxSize, (row - 1) * 20 + kHalfPxSize)
end

--- Animates this block so it falls off the screen. Is removed at the end.
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

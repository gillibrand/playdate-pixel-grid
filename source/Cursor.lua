import "CoreLibs/graphics"
import "CoreLibs/sprites"
import "CoreLibs/object"
import "CoreLibs/timer"

local pd <const> = playdate
local gfx <const> = pd.graphics

--- The blinking cursor where a block will be toggled on or off.
class('Cursor').extends(gfx.sprite)

function Cursor:init(col, row)
  Cursor.super.init(self)
  self:setLocation(col, row)

  self._isBig = false
  self._wasBig = true
  self._isVisible = true
end

--- Sets the location of the cursor on the grid. 1 index. Starts from top left.
function Cursor:setLocation(col, row)
  self._col = math.max(1, math.min(20, col))
  self._row = math.max(1, math.min(12, row))
  self:moveTo((self._col - 1) * kPxSize + kHalfPxSize, (self._row - 1) * 20 + kHalfPxSize)
  self:setZIndex(100)
end

function Cursor:getLocation()
  return self._col, self._row
end

--- Sets the visibility. Used to hide the cursor when a dialog is open, but not removing it from its
--  location.
function Cursor:setVisible(on)
  self._isVisible = on
end

function Cursor:update()
  if not self._isVisible then
    self:setImage(nil)
    return
  end

  if self._wasBig == self._isBig then
    -- nothing to do since size matches
    return
  end

  local image = gfx.image.new(20, 20)
  inContext(image, function()
    local size = 5
    -- print('self._isBig', self._isBig)
    if self._isBig then size += 1 end
    gfx.setColor(gfx.kColorWhite)
    gfx.fillCircleAtPoint(kHalfPxSize, kHalfPxSize, 7)
    gfx.setColor(gfx.kColorBlack)
    gfx.fillCircleAtPoint(kHalfPxSize, kHalfPxSize, size)
  end)
  self:setImage(image)

  self._wasBig = self._isBig

  pd.timer.new(500, function()
    self._isBig = not self._isBig
  end)
end

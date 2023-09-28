import "CoreLibs/graphics"
import "Grid"
import "Cursor"
import "Block"
import "matrix"

PxSize = 20
HalfSize = PxSize / 2

local pd <const> = playdate
local gfx <const> = pd.graphics

local grid = Grid()
grid:add()

local cursorCol = 2
local cursorRow = 2

local cursor = Cursor(cursorCol, cursorRow)
cursor:add()

-- local blocks = {}
local blocks = matrix.new(20, 12)

-- m = matrix.new(3, 2)
-- -- print(m)
-- matrix.set(m, 1, 2, true)
-- matrix.set(m, 2, 1, 'hi')
-- matrix.set(m, 2, 2, 'two')
-- matrix.dump(m)

function playdate.update()
  gfx.sprite.update()
  pd.timer.updateTimers()
end

function updateCursor()
  cursor:setLocation(cursorCol, cursorRow)
end

function pd.downButtonDown()
  cursorRow = math.min(12, cursorRow + 1)
  updateCursor()
end

function pd.upButtonDown()
  cursorRow = math.max(1, cursorRow - 1)
  updateCursor()
end

function pd.rightButtonDown()
  cursorCol = math.min(20, cursorCol + 1)
  updateCursor()
end

function pd.leftButtonDown()
  cursorCol = math.max(1, cursorCol - 1)
  updateCursor()
end

function pd.AButtonDown()
  local col, row = cursor:getLocation()
  local oldBlock = matrix.remove(blocks, col, row)
  if oldBlock ~= nil then
    oldBlock:remove()
  else
    local block = Block(col, row)
    matrix.set(blocks, col, row, block)
    block:add()
  end
end

function pd.BButtonDown()
  clearBlocks()
end

function clearBlocks()
  local fallingBlocks = blocks
  blocks = matrix.new(20, 12)

  local x = matrix.all(fallingBlocks)
  for _, block in ipairs(matrix.all(fallingBlocks)) do
    block:fall()
  end
end

pd.getSystemMenu():addMenuItem('Erase All', clearBlocks)

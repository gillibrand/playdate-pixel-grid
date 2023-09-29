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

local didRemoveBlock = false

local cursor = Cursor(2, 2)
cursor:add()

ROWS = 12
COLS = 20

-- local blocks = {}
local blocks = matrix.new(COLS, ROWS)
local PIX1 <const> = 'pix1'
local META <const> = 'metadata'

function addBlock(col, row)
  local block = Block(col, row)
  matrix.set(blocks, col, row, block)
  block:add()
end

function save()
  -- Save matrix file
  local blockCoords = {}
  matrix.log(blocks)

  for row = 1, COLS do
    for col = 1, ROWS do
      if matrix.get(blocks, row, col) then
        table.insert(blockCoords, {
          row, col
        })
      end
    end
  end

  -- Save cursor loc (metadata file)
  pd.datastore.write(blockCoords, PIX1)

  local row, col = cursor:getLocation()
  local metadata = {}
  metadata.cursor = { row, col }
  pd.datastore.write(metadata, META)
  local x = pd.datastore.read(META)
end

--- Clears all visible blocks and animates them away
function clearBlocks()
  local fallingBlocks = blocks
  blocks = matrix.new(20, 12)

  local x = matrix.all(fallingBlocks)
  for _, block in ipairs(matrix.all(fallingBlocks)) do
    block:fall()
  end
end

function logTable(t)
  print('logTable', t)
  for k, v in pairs(t) do
    print(k, v)
  end
  print('done')
end

function load()
  clearBlocks()

  local blockCoords = pd.datastore.read(PIX1)
  if blockCoords then
    for i, coord in ipairs(blockCoords) do
      addBlock(coord[1], coord[2])
    end
  end

  local metadata = pd.datastore.read(META)
  if metadata then
    local coords = metadata['cursor']
    if coords then
      cursor:setLocation(coords[1], coords[2])
    end
  end
end

load()

function playdate.update()
  gfx.sprite.update()
  pd.timer.updateTimers()
end

function toggleBlockIfAButtonDown()
  if not pd.buttonIsPressed(pd.kButtonA) then return end

  local col, row = cursor:getLocation()
  local currentBlock = matrix.get(blocks, col, row)

  if not didRemoveBlock and not currentBlock then
    addBlock(col, row)
  elseif didRemoveBlock and currentBlock then
    matrix.remove(blocks, col, row)
    currentBlock:remove()
  end
end

-- function pd.downButtonDown()
--   local col, row = cursor:getLocation()
--   cursor:setLocation(col, row + 1)
--   toggleBlockIfAButtonDown()
-- end

-- function pd.upButtonDown()
--   local col, row = cursor:getLocation()
--   cursor:setLocation(col, row - 1)
--   toggleBlockIfAButtonDown()
-- end

function whileDpadDown()
  local col, row = cursor:getLocation()
  local state = pd.getButtonState()

  if state & pd.kButtonRight ~= 0 then col += 1 end
  if state & pd.kButtonLeft ~= 0 then col -= 1 end
  if state & pd.kButtonUp ~= 0 then row -= 1 end
  if state & pd.kButtonDown ~= 0 then row += 1 end

  cursor:setLocation(col, row)
  toggleBlockIfAButtonDown()
end

function startDpadPolling()
  if keyTimer then return end
  keyTimer = pd.timer.keyRepeatTimerWithDelay(300, 30, whileDpadDown)
end

function stopDpadPolling()
  if not keyTimer then return end
  keyTimer:remove()
  keyTimer = nil
end

function pd.rightButtonDown()
  startDpadPolling()
end

function pd.rightButtonUp()
  stopDpadPolling()
end

function pd.leftButtonDown()
  startDpadPolling()
end

function pd.leftButtonUp()
  stopDpadPolling()
end

function pd.upButtonDown()
  startDpadPolling()
end

function pd.upButtonUp()
  stopDpadPolling()
end

function pd.downButtonDown()
  startDpadPolling()
end

function pd.downButtonUp()
  stopDpadPolling()
end

function pd.AButtonDown()
  local col, row = cursor:getLocation()
  local oldBlock = matrix.remove(blocks, col, row)

  if oldBlock ~= nil then
    didRemoveBlock = true
    oldBlock:remove()
  else
    didRemoveBlock = false
    addBlock(col, row)
  end
end

function pd.BButtonDown()
  clearBlocks()
end

pd.getSystemMenu():addMenuItem('Erase All', clearBlocks)



function pd.gameWillTerminate()
  save()
end

function pd.deviceWillSleep()
  save()
end

import "CoreLibs/graphics"

import "Grid"
import "Cursor"
import "Block"
import "matrix"
import "dialog"

PxSize = 20
HalfSize = PxSize / 2

local pd <const> = playdate
local gfx <const> = pd.graphics

local grid = Grid()
grid:add()

local didRemoveBlock = false

local cursor = Cursor(2, 2)
cursor:add()

local dialog

ROWS = 12
COLS = 20

InDraw = 0
InDialog = 1

local state = InDraw

local blocks = matrix.new(COLS, ROWS)

local Pix1 <const> = 'pix1'
local Pix2 <const> = 'pix2'
local Metadata <const> = 'metadata'

function addBlock(col, row)
  local block = Block(col, row)
  matrix.set(blocks, col, row, block)
  block:add()
end

function save()
  -- Save matrix file
  local blockCoords = {}
  -- matrix.log(blocks)

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
  pd.datastore.write(blockCoords, Pix1)

  local row, col = cursor:getLocation()
  local metadata = {}
  metadata.cursor = { row, col }
  pd.datastore.write(metadata, Metadata)
  local x = pd.datastore.read(Metadata)
end

--- Erases all visible blocks and animates them away
function eraseAllBlocks()
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
  eraseAllBlocks()

  local blockCoords = pd.datastore.read(Pix1)
  if blockCoords then
    for i, coord in ipairs(blockCoords) do
      addBlock(coord[1], coord[2])
    end
  end

  local metadata = pd.datastore.read(Metadata)
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
  -- pd.drawFPS(10, 10)

  handleInput()
end

-- function pd.debugDraw()
--   pd.drawFPS(10, 10)
-- end

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

function handleInput()
  if state == InDraw then
    handleDrawInput()
  elseif state == InDialog then
    handleEraseDialogInput()
  end
end

function handleEraseDialogInput()
  if pd.buttonJustPressed(pd.kButtonA) then
    eraseAllBlocks()
    closeDialog()
  elseif pd.buttonJustPressed(pd.kButtonB) then
    closeDialog()
  end
end

function handleDrawInput()
  if pd.buttonJustPressed(pd.kButtonUp)
      or pd.buttonJustPressed(pd.kButtonRight)
      or pd.buttonJustPressed(pd.kButtonDown)
      or pd.buttonJustPressed(pd.kButtonLeft) then
    startCursorPolling()
  elseif pd.buttonJustReleased(pd.kButtonUp)
      or pd.buttonJustReleased(pd.kButtonRight)
      or pd.buttonJustReleased(pd.kButtonDown)
      or pd.buttonJustReleased(pd.kButtonLeft) then
    stopCursorPolling()
  end

  if pd.buttonJustPressed(pd.kButtonA) then
    toggleBlockUnderCursor()
  end

  if pd.buttonJustPressed(pd.kButtonB) then
    openDialog()
  end
end

function toggleBlockUnderCursor()
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

function openDialog()
  state = InDialog
  dialog = Dialog('Ⓐ *Erase drawing*\nⒷ *Cancel*')
  cursor:setFlash(false)
end

function closeDialog()
  state = InDraw
  dialog:remove()
  dialog = nil
  cursor:setFlash(true)
end

function startCursorPolling()
  if keyTimer then return end
  keyTimer = pd.timer.keyRepeatTimerWithDelay(300, 30, whileDpadDown)
end

function stopCursorPolling()
  if not keyTimer then return end
  keyTimer:remove()
  keyTimer = nil
end

-- pd.getSystemMenu():addMenuItem('Erase All', eraseAllBlocks)

function pd.gameWillTerminate()
  save()
end

function pd.deviceWillSleep()
  save()
end

import "CoreLibs/graphics"

import "PixApp"
import "Grid"
import "Cursor"
import "Block"
import "matrix"
import "Dialog"
import "Swap"

PxSize = 20
HalfSize = PxSize / 2


local grid

local didRemoveBlock = false

local isShowGrid = true

local cursor = Cursor(2, 2)
cursor:add()

local dialog

ROWS = 12
COLS = 20

InDraw = 0
InDialog = 1
InLoad = 2

local appState = InDraw

local blocks = matrix.new(COLS, ROWS)

local Pix1 <const> = 'Drawing 1'
local Pix2 <const> = 'Drawing 2'
local Pix3 <const> = 'Drawing 3'
local Metadata <const> = 'metadata'

local currentFilename = Pix1

function addBlock(col, row)
  local block = Block(col, row)
  matrix.set(blocks, col, row, block)
  block:add()
end

function saveDrawingFile(name)
  local blockCoords = {}

  for row = 1, COLS do
    for col = 1, ROWS do
      if matrix.get(blocks, row, col) then
        table.insert(blockCoords, {
          row, col
        })
      end
    end
  end

  pd.datastore.write(blockCoords, currentFilename)
end

function saveState()
  -- Save matrix file
  saveDrawingFile(currentFilename)

  -- Save cursor loc (metadata file)
  local row, col = cursor:getLocation()
  local metadata = {}
  metadata.cursor = { row, col }
  metadata.currentFile = currentFilename
  metadata.isShowGrid = isShowGrid

  pd.datastore.write(metadata, Metadata)
  local x = pd.datastore.read(Metadata)
end

--- Erases all visible blocks and animates them away
function eraseAllBlocks(animate)
  local fallingBlocks = blocks
  blocks = matrix.new(20, 12)

  local x = matrix.all(fallingBlocks)
  for _, block in ipairs(matrix.all(fallingBlocks)) do
    if animate then
      block:fall()
    else
      block:remove()
    end
  end
end

function logTable(t)
  print('logTable', t)
  for k, v in pairs(t) do
    print(k, v)
  end
  print('done')
end

function loadDrawingFile(file)
  eraseAllBlocks(false)

  local blockCoords = pd.datastore.read(file)

  if blockCoords then
    for i, coord in ipairs(blockCoords) do
      addBlock(coord[1], coord[2])
    end
  end
end

function restoreState()
  local metadata = pd.datastore.read(Metadata)

  if metadata then
    isShowGrid = metadataisShowGrid
    if isShowGrid == nil then
      isShowGrid = true
    end

    toggleGrid(isShowGrid)

    local coords = metadata.cursor
    if coords then
      cursor:setLocation(coords[1], coords[2])
    end

    currentFilename = metadata.currentFile or Pix1
  end

  loadDrawingFile(currentFilename)

  local menu = playdate.getSystemMenu()
  menu:removeAllMenuItems()
  menu:addOptionsMenuItem('Open', { Pix1, Pix2, Pix3 }, currentFilename, swapDrawing)
  menu:addCheckmarkMenuItem('Show Grid', isShowGrid, toggleGrid)
end

function toggleGrid(show)
  isShowGrid = show

  if isShowGrid and grid == nil then
    grid = Grid()
    grid:add()
  elseif not isShowGrid and grid ~= nil then
    grid:remove()
    grid = nil
  end
end

function swapDrawing(newFilename)
  appState = InLoad
  saveDrawingFile(currentFilename)

  local animateForward = newFilename > currentFilename
  Swap(
    animateForward,
    function()
      loadDrawingFile(newFilename)
      currentFilename = newFilename
    end,
    function()
      appState = InDraw
    end)
end

function endSwap()

end

restoreState()


function playdate.update()
  gfx.sprite.update()
  pd.timer.updateTimers()

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
  if appState == InDraw then
    handleDrawInput()
  elseif appState == InDialog then
    handleEraseDialogInput()
  end
end

function handleEraseDialogInput()
  if pd.buttonJustPressed(pd.kButtonA) then
    eraseAllBlocks(true)
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
  appState = InDialog
  dialog = Dialog('Ⓐ *Erase drawing*\nⒷ *Cancel*')
  cursor:setFlash(false)
end

function closeDialog()
  appState = InDraw
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

function pd.gameWillTerminate()
  saveState()
end

function pd.deviceWillSleep()
  saveState()
end

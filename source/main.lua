import "CoreLibs/graphics"

import "Grid"
import "Cursor"
import "Block"
import "matrix"
import "Dialog"
import "SwapTransition"

local pd <const> = playdate
local gfx <const> = pd.graphics

local grid
local didRemoveBlock = false
local isShowGrid = true

local cursor = Cursor(2, 2)
cursor:add()

local dialog

InDraw = 0
InDialog = 1
InLoad = 2

local appState = InDraw

local blocks = matrix.new(kCols, kRows)

local Pix1 <const> = 'Drawing 1'
local Pix2 <const> = 'Drawing 2'
local Pix3 <const> = 'Drawing 3'
local Metadata <const> = 'metadata'

local currentFilename = Pix1

function setup()
  restoreState()
  cursor:add()
end

function playdate.update()
  gfx.sprite.update()
  pd.timer.updateTimers()

  handleInput()
end

function addBlock(col, row)
  local block = Block(col, row)
  matrix.set(blocks, col, row, block)
  block:add()
end

function saveDrawingAs(name)
  local blockCoords = {}

  for row = 1, kCols do
    for col = 1, kRows do
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
  saveDrawingAs(currentFilename)

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

function loadDrawingFrom(file)
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
    isShowGrid = metadata.isShowGrid
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

  loadDrawingFrom(currentFilename)

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
  if dialog then
    dialog:remove()
    dialog = nil
  end

  appState = InLoad
  saveDrawingAs(currentFilename)

  local animateForward = newFilename > currentFilename

  SwapTransition(
    animateForward,
    function()
      loadDrawingFrom(newFilename)
      currentFilename = newFilename
    end,
    function()
      appState = InDraw
    end)
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
  if appState ~= InDraw then
    return
  end
  handleDrawInput()
end

function pd.BButtonDown()
  openDialog()
end

function pd.AButtonDown()
  toggleBlockUnderCursor()
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
  cursor:setVisible(false)

  dialog = Dialog('Ⓐ *Erase drawing*\nⒷ *Cancel*')

  dialog.onClose = function()
    dialog = nil
    cursor:setVisible(true)
    appState = InDraw
  end

  dialog.onOk = function()
    eraseAllBlocks(true)
  end
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

setup()

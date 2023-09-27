import "CoreLibs/graphics"
import "Grid"
import "Cursor"
import "Fill"

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

local fills = {}

function playdate.update()
    gfx.sprite.update()
    pd.timer.updateTimers()
end

function updateCursor()
    cursor:setLocation(cursorCol, cursorRow)
end

function pd.downButtonDown()
    cursorRow += 1
    updateCursor()
end

function pd.upButtonDown()
    cursorRow -= 1
    updateCursor()
end

function pd.rightButtonDown()
    cursorCol += 1
    updateCursor()
end

function pd.leftButtonDown()
    cursorCol -= 1
    updateCursor()
end

function pd.AButtonDown()
    local col, row = cursor:getLocation()
    print(col .. ', ' .. row)
    local fill = Fill(col, row)
    table.insert(fills, fill)
    fill:add()
end

function pd.BButtonDown()
    for i, fill in ipairs(fills) do
        fill:remove()
    end

    fills = {}
end
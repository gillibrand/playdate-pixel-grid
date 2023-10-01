import "CoreLibs/graphics"
import "CoreLibs/object"

local pd <const> = playdate
local gfx <const> = pd.graphics


class('Dialog').extends(gfx.sprite)

local kMargin = 2
local kPadding = 13
local kRadius = 5
local kBorder = 2
local kLeading = 12

class('Background').extends(gfx.sprite)

function inContext(image, callback)
	gfx.pushContext(image)
	pcall(callback)
	gfx.popContext()
end

function Background:init()
	Background.super.init(self)

	-- All black image
	local image = gfx.image.new(pd.display.getSize())
	inContext(image, function()
		gfx.fillRect(pd.display.getRect())
	end)

	-- Draw the black with a dither pattern
	local alpha = gfx.image.new(pd.display.getSize())
	inContext(alpha, function()
		image:drawFaded(0, 0, .25, gfx.image.kDitherTypeBayer4x4)
	end)

	self:setCenter(0, 0)
	self:setImage(alpha)
end

function Dialog:init(message)
	Dialog.super.init(self)
	local w, h = gfx.getTextSize(message, nil, kLeading)
	local dw = w + 2 * kPadding + 2 * kBorder + 2 * kMargin
	local dh = h + 2 * kPadding + 2 * kBorder + 2 * kMargin
	local image = gfx.image.new(dw, dh)

	gfx.pushContext(image)
	do
		-- clear background
		gfx.setColor(gfx.kColorWhite)
		gfx.fillRoundRect(0, 0, dw, dh, kRadius)

		-- border border. Since line widths grow OUT from the line, this actually eats into the margin.
		-- I just set a bigger margin to offset that
		gfx.setLineWidth(kBorder)
		gfx.setColor(gfx.kColorBlack)
		gfx.drawRoundRect(kMargin, kMargin, dw - 2 * kMargin, dh - 2 * kMargin, kRadius)

		gfx.drawText(message, kMargin + kBorder + kPadding, kMargin + kBorder + kPadding, nil, kLeading)
	end
	gfx.popContext()
	self:setImage(image)

	self:moveTo(200, 120)
	self:setZIndex(200)

	self.bg = Background()
	self.bg:setZIndex(199)
	self.bg:add()

	self:add()
end

function Dialog:remove()
	self.bg:remove()
	Dialog.super.remove(self)
end

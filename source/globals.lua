import "CoreLibs/graphics"

pd = playdate
gfx = pd.graphics


--- Util to call code in a push/popContext block.
function inContext(image, callback)
	gfx.pushContext(image)
	pcall(callback)
	gfx.popContext()
end

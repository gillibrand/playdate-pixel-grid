matrix = {}

function new(w, h)
	return {
		_cols = w,
		_rows = h
	}
end

matrix.new = new

function index(mat, x, y)
	-- print(string.format('x%d, y%d', x, y))
	local i = (mat._rows * (y - 1)) + x
	-- print('index', i)
	return i
end

function set(mat, x, y, value)
	local i = index(mat, x, y);
	-- print('set index', i)
	mat[i] = value
end

matrix.set = set

function get(mat, x, y)
	return mat[index(mat, x, y)]
end

matrix.get = get

function remove(mat, x, y)
	local i = index(mat, x, y)
	local value = mat[i]
	mat[i] = nil
	return value
end

matrix.remove = remove

function dump(mat)
	-- print('mat._w' .. mat._w)
	-- for i = 1, #mat do
	-- 	print(mat[i])
	-- end

	for col = 1, mat._cols do
		local line = ""

		for row = 1, mat._rows do
			local value = get(mat, row, col)
			line = line .. (value and 'x' or '-') .. ', '
		end
		print(line)
	end
end

matrix.print = dump

function all(mat)
	-- local i = 1
	local n = mat._rows * mat._cols

	local list = {}
	for i = 1, n do
		local value = mat[i]
		if value ~= nil then
			table.insert(list, mat[i])
		end
	end

	return list
	-- end
	-- -- iter, t, i = ipairs(mat)
	-- return function()
	-- 	while true do
	-- 		if i > n then
	-- 			print('end')
	-- 			return nil
	-- 		end

	-- 		local value = mat[i]
	-- 		if value ~= nil then return value end
	-- 	end
	-- end
end

matrix.all = all

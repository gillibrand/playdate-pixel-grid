matrix = {}

function matrix.new(w, h)
	return {
		_cols = w,
		_rows = h
	}
end

function index(mat, x, y)
	local i = (mat._cols * (y - 1)) + x
	return i
end

function matrix.set(mat, x, y, value)
	local i = index(mat, x, y);
	mat[i] = value
end

function matrix.get(mat, x, y)
	local i = index(mat, x, y)
	print('i', i)
	return mat[i]
end

--- Removes element at given coords.
-- @param mat The matrix to modify.
-- @param x X position to remove.
-- @param y Y position to remove.
-- @return The old value, or nil is was aleady empty.
function matrix.remove(mat, x, y)
	local i = index(mat, x, y)
	local value = mat[i]
	mat[i] = nil
	return value
end

function matrix.log(mat)
	for col = 1, mat._rows do
		local line = ""

		for row = 1, mat._cols do
			local value = matrix.get(mat, row, col)
			line = line .. (value and 'x' or '.')
		end
		print(line)
	end
end

function matrix.size(mat)
	return mat._cols, mat._rows
end

function matrix.all(mat)
	local n = mat._rows * mat._cols

	local list = {}
	for i = 1, n do
		local value = mat[i]
		if value ~= nil then
			table.insert(list, mat[i])
		end
	end

	return list
end

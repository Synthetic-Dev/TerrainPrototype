local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Modules = ReplicatedStorage.Common.Modules
local Tables = require(Modules.Tables)
local TDim = Tables.TDim
local TDim2 = Tables.TDim2

local Triangle = require(script.Parent.Util.Triangle)

local Chunk = {}
Chunk.__index = Chunk

local function DEBUG(label, start)
	local dots = string.sub(string.rep(" .", 15), #label)
	if string.sub(dots, 1, 1) == "." then
		dots = " " .. string.sub(dots, 2)
	end
	print(label .. dots .. " " .. math.round((os.clock() - start) * 100000) / 100 .. "ms")
end

function Chunk.new(options)
	local pos = options.Position

	local model = Instance.new("Model")
	model.Name = string.format("Chunk [%i, %i]", pos.X, pos.Y)

	local self = setmetatable({
		Instance = model,
		Position = pos,
		WorldPosition = Vector3.new(),

		_sizes = {
			CellSize = options.Sizes.CellSize,
			ChunkSize = options.Sizes.ChunkSize,
		},
		_noise = options.Noise,
		_vertices = {},
		_triangles = {},
		_neighbours = {},

		_generated = false,
	}, Chunk)

	for _, neighbour in TDim2:neighbours(options.Chunks, pos.X, pos.Y) do
		table.insert(self._neighbours, neighbour)
	end

	return self
end

function Chunk:GenerateVertices()
	-- Loop through neighbours and get border vertices
	for chunk in TDim:values(self._neighbours) do
		local offset = self.Position - chunk.Position
		local cx, cy = math.max(0, offset.X * self._sizes.ChunkSize), math.max(0, offset.Y * self._sizes.ChunkSize)

		if offset.X == 0 or offset.Y == 0 then
			local ax, ay = math.abs(offset.X), math.abs(offset.Y)
			for i = 0, self._sizes.ChunkSize do
				local x, y = ay * i + cx, ax * i + cy
				local vertex = chunk._vertices[x][y]

				-- TODO: Turn this into an expression because this is dumb
				if offset.X == 0 then
					x, y = x, self._sizes.ChunkSize - y
				else
					x, y = self._sizes.ChunkSize - x, y
				end

				if not self._vertices[x] then
					self._vertices[x] = {}
				end

				self._vertices[x][y] = vertex
			end
		elseif chunk._vertices[cx] then
			local vertex = chunk._vertices[cx][cy]

			cx, cy = self._sizes.ChunkSize - cx, self._sizes.ChunkSize - cy
			if not self._vertices[cx] then
				self._vertices[cx] = {}
			end

			self._vertices[cx][cy] = vertex
		end
	end

	-- Generate chunk vertices
	for x = 0, self._sizes.ChunkSize do
		for y = 0, self._sizes.ChunkSize do
			if not self._vertices[x] then
				self._vertices[x] = {}
			end
			if self._vertices[x][y] then
				continue
			end

			local cellPosition = Vector2.new(x, y)
			local vertexPosition = cellPosition * self._sizes.CellSize
			local worldPosition = self.Position * self._sizes.ChunkSize * self._sizes.CellSize + vertexPosition
			local height, color = self._noise(worldPosition)

			local vertex = {
				CellPosition = cellPosition,
				Chunk = self,
				_neighbours = {},
				_edges = {},
				_triangles = {},
			}

			vertex.Position = Vector3.new(vertexPosition.X, height, vertexPosition.Y)
			vertex.Color = color

			self._vertices[x][y] = vertex
		end
	end

	for x, y, vertex in TDim2:iter(self._vertices) do
		for index, neighbour in TDim2:neighbours(self._vertices, x, y) do
			if index == 1 or index == 8 or not neighbour then
				continue
			end

			table.insert(vertex._neighbours, neighbour)
		end

		for neighbour in TDim:values(vertex._neighbours) do
			if vertex._edges[neighbour] then
				continue
			end

			local edge = {}
			vertex._edges[neighbour] = edge

			neighbour._edges = neighbour._edges or {}
			neighbour._edges[vertex] = edge
		end
	end
end

function Chunk:RegenerateVertices()
	for vertex in TDim2:values(self._vertices) do
		local vertexPosition = vertex.CellPosition * self._sizes.CellSize
		local worldPosition = self.Position * self._sizes.ChunkSize * self._sizes.CellSize + vertexPosition
		local height, color = self._noise(worldPosition)

		-- vertex._triangles =
		vertex.Position = Vector3.new(vertexPosition.X, height, vertexPosition.Y)
		vertex.Color = color
	end
end

function Chunk:CreateInstances(oldTris, regen)
	oldTris = oldTris or {}

	for vertexA in TDim2:values(self._vertices) do
		-- Check to see if a vertex already has all of its tris
		if #vertexA._triangles >= 6 then
			continue
		end

		-- Compare neighbouring vertices and create triangle
		for vertexB in TDim:values(vertexA._neighbours) do
			for vertexC in TDim:values(vertexA._neighbours) do
				if not vertexB._edges[vertexC] then
					continue
				end

				local flag = false
				for tri in TDim:values(vertexA._triangles) do
					if table.find(tri._vertices, vertexB) and table.find(tri._vertices, vertexC) then
						flag = true
						break
					end
				end
				if flag then
					continue
				end

				-- Generate a triangle if non existant
				local tri = table.remove(oldTris, 1)
				if tri then
					tri:SetVertices(vertexA, vertexB, vertexC)
				else
					tri = Triangle.new(vertexA, vertexB, vertexC, self.Instance)
				end

				-- local color = Color3.fromHSV(0, 0, 1 - tri.Gradient)
				-- for _, instance in pairs(tri.Instance:GetChildren()) do
				-- 	instance.Color = color
				-- end

				table.insert(self._triangles, tri)
				if not regen then
					table.insert(vertexA._triangles, tri)
					table.insert(vertexB._triangles, tri)
					table.insert(vertexC._triangles, tri)
				end
			end
		end
	end

	for vertex in TDim2:values(self._vertices) do
		vertex._edges = {}
	end
end

function Chunk:SetChunkPosition(position)
	self.Position = position
	-- self._vertices = {}
	-- self._neighbours = {}
	-- for _, neighbour in TDim2:neighbours(chunks, position.X, position.Y) do
	-- 	table.insert(self._neighbours, neighbour)
	-- end

	self:RegenerateVertices()

	-- for tri in TDim:values(self._triangles) do
	-- 	tri:Destroy()
	-- end

	-- local oldTris = self._triangles
	-- self._triangles = {}
	-- self:CreateInstances(oldTris, true)

	-- for vertex in TDim2:values(self._vertices) do
	-- 	vertex._edges = {}
	-- end

	-- for tri in TDim:values(self._triangles) do
	-- 	local newVertices = {}
	-- 	for i, vertex in pairs(tri._vertices) do
	-- 		local newVertex = self._vertices[vertex.CellPosition.X][vertex.CellPosition.Y]
	-- 		newVertices[i] = newVertex
	-- 		table.insert(newVertex._triangles, tri)
	-- 	end
	-- 	tri._vertices = newVertices
	-- end
end

function Chunk:Move(position)
	position = position or Vector2.new()
	position *= self._sizes.ChunkSize * self._sizes.CellSize
	self.WorldPosition = Vector3.new(position.X, 0, position.Y)
end

function Chunk:Update()
	for tri in TDim:values(self._triangles) do
		tri:Update()
	end
end

function Chunk:Generate(position)
	position = position or Vector2.new()
	position *= self._sizes.ChunkSize * self._sizes.CellSize
	self.WorldPosition = Vector3.new(position.X, 0, position.Y)

	local DEBUGGING = false

	local OVERALL_START = os.clock()
	local DEBUG_START = os.clock()
	local DEBUG_PROFILE = "chunkCreation"
	if DEBUGGING then
		debug.profilebegin(DEBUG_PROFILE)
	end

	if DEBUGGING then
		debug.profileend()
		DEBUG(DEBUG_PROFILE, DEBUG_START)
		DEBUG_START = os.clock()
		DEBUG_PROFILE = "chunkVertices"
		debug.profilebegin(DEBUG_PROFILE)
	end

	self:GenerateVertices()

	if DEBUGGING then
		debug.profileend()
		DEBUG(DEBUG_PROFILE, DEBUG_START)
		DEBUG_START = os.clock()
		DEBUG_PROFILE = "chunkTriangles"
		debug.profilebegin(DEBUG_PROFILE)
	end

	self:CreateInstances()

	if DEBUGGING then
		debug.profileend()
		DEBUG(DEBUG_PROFILE, DEBUG_START)
		DEBUG_START = os.clock()
		DEBUG_PROFILE = "chunkLoad"
		debug.profilebegin(DEBUG_PROFILE)
	end

	self._generated = true
	self.Instance.Parent = workspace

	if DEBUGGING then
		debug.profileend()
		DEBUG(DEBUG_PROFILE, DEBUG_START)
		DEBUG("OverallChunkCreation", OVERALL_START)
	end
end

return Chunk

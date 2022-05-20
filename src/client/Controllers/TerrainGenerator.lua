local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Packages = ReplicatedStorage.Packages
local Knit = require(Packages.Knit)
local Kache = require(Packages.Kache)

local Common = ReplicatedStorage.Common
local Chunk = require(Common.Generation.Chunk)
local Biomes = require(Common.Generation.Biomes)
local Noise = require(Common.Modules.Noise)
local Tables = require(Common.Modules.Tables)
local TDim2 = Tables.TDim2

local TerrainGenerator = Knit.CreateController({
	Name = "TerrainGenerator",
})

local SEED = 503825 --8324123

local CHUNK_SIZE = 10
local CELL_SIZE = 6.4

local Perlin = Noise.Perlin.new(SEED)
local NOISE_FUNCTION = function(pos)
	local height = Biomes:GetHeight(pos, Perlin)
	local color = Biomes:GetColor(pos, Perlin)

	return height * 300, color
end

function TerrainGenerator:KnitInit()
	self.HeightsCache = Kache.new(3600)
end

function TerrainGenerator:KnitStart()
	local chunks = {}

	do
		local X, Y = 60, 30
		local x, y = 0, 0
		local dx, dy = 0, -1

		for _ = 0, math.max(X, Y) ^ 2 do
			if (-X / 2 < x and x <= X / 2) and (-Y < y and y <= Y / 2) then
				task.wait()

				if not chunks[x] then
					chunks[x] = {}
				end

				local chunk = Chunk.new({
					Chunks = chunks,
					Position = Vector2.new(x, y),
					Sizes = {
						CellSize = CELL_SIZE,
						ChunkSize = CHUNK_SIZE,
					},
					Noise = NOISE_FUNCTION,
				})

				chunk:Generate(Vector2.new(x, y))
				chunks[x][y] = chunk
			end

			if x == y or (x < 0 and x == -y) or (x > 0 and x == 1 - y) then
				dx, dy = -dy, dx
			end

			x, y = x + dx, y + dy
		end
	end

	-- task.wait(2)

	-- while true do
	-- 	task.wait(1)
	-- 	print("Shift")

	-- 	local newChunks = {}

	-- 	for x, y, chunk in TDim2:iter(chunks) do
	-- 		task.wait()
	-- 		x = x + 2
	-- 		if not newChunks[x] then
	-- 			newChunks[x] = {}
	-- 		end
	-- 		chunk:SetChunkPosition(Vector2.new(x, y))
	-- 		newChunks[x][y] = chunk
	-- 	end

	-- 	chunks = newChunks

	-- 	for chunk in TDim2:values(chunks) do
	-- 		chunk:Update()
	-- 	end
	-- end
end

return TerrainGenerator

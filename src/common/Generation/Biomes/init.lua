local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Packages = ReplicatedStorage.Packages
local Kache = require(Packages.Kache)

local Common = ReplicatedStorage.Common
local Tables = require(Common.Modules.Tables)
local TDim = Tables.TDim

local Struct = require(script.BiomeStruct)

local Biomes = {}

do
	Biomes._biomes = {}
	for _, biome in pairs(script.Biomes:GetChildren()) do
		table.insert(Biomes._biomes, require(biome))
	end

	Biomes._cache = Kache.new(1800)
end

function Biomes:GetBiome(position, noise): Struct.Biome
	local data = self._cache:Get(position)
	if data then
		return data.Biome, data.Factors
	end

	local temperaturePos = position / 3000
	local temperature = noise:WarpedNoise(0.2, temperaturePos.X, temperaturePos.Y)

	local humidityPos = position / 1450
	local humidity = noise(humidityPos.X, humidityPos.Y)

	local altitudePos = position / 2000
	local altitude = noise(altitudePos.X, altitudePos.Y) --, NumberRange.new(-1, 1))
	local altitudeBias = 2
	altitude = math.pow(altitude, altitudeBias)

	local rand = Random.new(noise._seed)

	local neighbourBiome, neighbourDistance = nil, math.huge
	local resultBiome, resultDistance = nil, math.huge
	for biome in TDim:values(self._biomes) do
		-- Get the Euclidian distance between values and biome centre
		local distance = (temperature - math.clamp(biome.Temperature + rand:NextNumber() * 0.05, 0, 1)) ^ 2
			+ (humidity - math.clamp(biome.Humidity + rand:NextNumber() * 0.05, 0, 1)) ^ 2
			+ (altitude - math.clamp(biome.Altitude + rand:NextNumber() * 0.05, 0, 1)) ^ 2

		if distance < resultDistance then
			neighbourBiome = resultBiome
			neighbourDistance = resultDistance
			resultBiome = biome
			resultDistance = distance
		end
	end

	local factors = {
		Temperature = temperature,
		Humidity = humidity,
		Altitude = altitude,
	}

	local neighbour = {
		Biome = neighbourBiome,
		Distance = neighbourDistance - resultDistance,
	}

	self._cache:Set(position, {
		Biome = resultBiome,
		Neighbour = neighbour,
		Factors = factors,
	})

	return resultBiome, neighbour, factors
end

function Biomes:GetHeight(pos, noise)
	local currentBiome, neighbour, factors = Biomes:GetBiome(pos, noise)

	local noiseHeight = currentBiome:GetHeight(pos, noise, factors)
	local neighbourDistance = 1 / math.max(1, neighbour.Distance)

	local totalHeight, totalWeight = 0, 0
	for _, biome in pairs({ currentBiome, neighbour.Biome }) do
		-- Get influence between this biome and thhe neighbour
		local influence = biome:GetInfluence(biome, neighbourDistance, factors)
		local weight = if influence < 0.01
			then 0
			else (influence - math.abs(noiseHeight - biome.MinAltitude)) / influence

		totalWeight += weight
		local height = if biome == currentBiome then noiseHeight else biome:GetHeight(pos, noise, factors)

		totalHeight += height * weight
	end

	return math.clamp(totalHeight / totalWeight, 0, 1)

	-- -- Calculate height for actual biome
	-- local noiseHeight = desiredBiome:GetHeight(pos, noise, factors)

	-- local totalHeight, totalWeight = 0, 0
	-- local weights = table.create(#self._biomes)

	-- for i, biome in pairs(self._biomes) do
	-- 	-- Calculate height for other biome, if it was at pos
	-- 	local height = biome:GetHeight(pos, noise, factors)

	-- 	-- Calculate the weight of this biome
	-- 	local influence = biome:GetInfluence(desiredBiome, factors)
	-- 	local weight = if influence < 0.01
	-- 		then 0
	-- 		else (influence - math.abs(noiseHeight - biome.MinAltitude)) / influence
	-- 	weights[i] = math.max(0, weight)
	-- 	totalWeight += weights[i]

	-- 	-- Apply the height influence of this biome
	-- 	totalHeight += height * weights[i]
	-- end

	-- return math.clamp(totalHeight / totalWeight, 0, 1)
end

function Biomes:GetColor(pos, noise)
	local desiredBiome, factors = Biomes:GetBiome(pos, noise)
	return desiredBiome:GetColor(pos, noise, factors)
end

return Biomes

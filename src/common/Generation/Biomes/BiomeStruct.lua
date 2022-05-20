local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Modules = ReplicatedStorage.Common.Modules
local Noise = require(Modules.Noise)

local Biome = {}
Biome.__index = Biome

type BiomeOptions = {
	Name: string,
	Conditions: {
		Temperature: number,
		Humidity: number,
		Altitude: number,
		MinAltitude: number?,
	},
}

type BiomeFactors = {
	Temperature: number,
	Humidity: number,
	Altitude: number,
}

function Biome.new(options: BiomeOptions)
	assert(options.Name and type(options.Name) == "string", "Biome must have a Name")

	local cond = options.Conditions
	assert(cond.Temperature and type(cond.Temperature), "Biome must have a Temperature condition in range [0, 1]")
	assert(cond.Humidity and type(cond.Humidity), "Biome must have a Humidity condition in range [0, 1]")
	assert(cond.Altitude and type(cond.Altitude), "Biome must have a Altitude condition in range [0, 1]")

	local self = {
		Name = options.Name,
		Temperature = math.clamp(cond.Temperature, 0, 1),
		Humidity = math.clamp(cond.Humidity, 0, 1),
		Altitude = math.clamp(cond.Altitude, 0, 1),
		MinAltitude = math.clamp(cond.MinAltitude or 0, 0, 1),
	}

	return setmetatable(self, Biome)
end

function Biome:GetInfluence(biome: Biome, neighbourDistance: number, factors: BiomeFactors): number
	return 0.5
end

function Biome:GetHeight(position: Vector2, noise: Noise.Perlin, factors: BiomeFactors): number
	return 0
end

function Biome:GetColor(position: Vector2, noise: Noise.Perlin, factors: BiomeFactors): Color3
	return Color3.new()
end

export type Biome = typeof(Biome.new())

return Biome

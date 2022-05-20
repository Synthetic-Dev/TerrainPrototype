local Struct = require(script.Parent.Parent.BiomeStruct)

local Ocean = require(script.Parent.Ocean)

local Biome = Struct.new({
	Name = "Mountains",
	Conditions = {
		Temperature = 0.2,
		Humidity = 0.7,
		Altitude = 1,
	},
})

function Biome:GetHeight(position, noise, factors)
	local scaled = position / 250
	local mountain = noise(scaled.X, scaled.Y) --noise:WarpedNoise(1.5, scaled.X, scaled.Y)
	local bias = 2
	local elevation = mountain
		* (
			if factors.Altitude < 0.5
				then math.pow(factors.Altitude * 2, bias) / 2
				else 1 - (math.pow((1 - factors.Altitude) * 2, bias)) / 2
		)
	return elevation
end

function Biome:GetInfluence(biome, neighbourDistance, factors)
	if biome == Ocean then
		return 0
	end
	return 0.2 * factors.Altitude
end

function Biome:GetColor()
	return Color3.new(0.439215, 0.439215, 0.439215)
end

return Biome

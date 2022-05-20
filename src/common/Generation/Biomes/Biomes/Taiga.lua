local Struct = require(script.Parent.Parent.BiomeStruct)

local Ocean = require(script.Parent.Ocean)

local Biome = Struct.new({
	Name = "Taiga",
	Conditions = {
		Temperature = 0.1,
		Humidity = 0.3,
		Altitude = 0.55,
	},
})

function Biome:GetHeight(position, noise, factors)
	local small = position / 190
	local rolling = position / 500
	local elevation = noise(small.X, small.Y) * noise(rolling.X, rolling.Y)
	return factors.Altitude * elevation
end

function Biome:GetInfluence(biome, neighbourDistance)
	if biome == Ocean then
		return 0
	end
	return 0.5 * neighbourDistance
end

function Biome:GetColor()
	return Color3.new(0.913725, 0.835294, 0.792156)
end

return Biome

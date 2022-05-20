local Struct = require(script.Parent.Parent.BiomeStruct)

local Ocean = require(script.Parent.Ocean)

local Biome = Struct.new({
	Name = "Tundra",
	Conditions = {
		Temperature = 0.05,
		Humidity = 0.4,
		Altitude = 0.1,
	},
})

function Biome:GetHeight(position, noise, factors)
	local small = position / 300
	local rolling = position / 670
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
	return Color3.new(0.639215, 0.941176, 0.913725)
end

return Biome

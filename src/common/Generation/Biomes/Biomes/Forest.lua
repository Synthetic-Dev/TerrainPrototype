local Struct = require(script.Parent.Parent.BiomeStruct)

local Ocean = require(script.Parent.Ocean)

local Biome = Struct.new({
	Name = "Forest",
	Conditions = {
		Temperature = 0.45,
		Humidity = 0.5,
		Altitude = 0.6,
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
	return Color3.new(0.509803, 0.745098, 0.419607)
end

return Biome

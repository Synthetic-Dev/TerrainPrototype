local Struct = require(script.Parent.Parent.BiomeStruct)

local Biome = Struct.new({
	Name = "Ocean",
	Conditions = {
		Temperature = 0.3,
		Humidity = 0.2,
		Altitude = 0,
	},
})

function Biome:GetHeight(position, noise, factors)
	return 0
end

function Biome:GetInfluence(biome)
	return 1
end

function Biome:GetColor()
	return Color3.new(0.282352, 0.490196, 0.8)
end

return Biome

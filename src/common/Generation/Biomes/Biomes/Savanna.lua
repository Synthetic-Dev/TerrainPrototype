local Struct = require(script.Parent.Parent.BiomeStruct)

local Ocean = require(script.Parent.Ocean)

local Biome = Struct.new({
	Name = "Savanna",
	Conditions = {
		Temperature = 0.7,
		Humidity = 0.12,
		Altitude = 0.4,
	},
})

function Biome:GetHeight(position, noise, factors)
	local scaled = position / 1234
	return factors.Altitude * noise(scaled.X, scaled.Y)
end

function Biome:GetInfluence(biome, neighbourDistance)
	if biome == Ocean then
		return 0
	end
	return 0.5 * neighbourDistance
end

function Biome:GetColor()
	return Color3.new(0.792156, 0.764705, 0.376470)
end

return Biome

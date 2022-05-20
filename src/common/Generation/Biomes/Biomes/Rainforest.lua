local Struct = require(script.Parent.Parent.BiomeStruct)

local Ocean = require(script.Parent.Ocean)

local Biome = Struct.new({
	Name = "Rainforest",
	Conditions = {
		Temperature = 0.75,
		Humidity = 0.8,
		Altitude = 0.25,
	},
})

function Biome:GetHeight(position, noise, factors)
	local scaled = position / 400
	return factors.Altitude * noise(scaled.X, scaled.Y)
end

function Biome:GetInfluence(biome, neighbourDistance)
	if biome == Ocean then
		return 0
	end
	return 0.5 * neighbourDistance
end

function Biome:GetColor()
	return Color3.new(0.196078, 0.713725, 0.176470)
end

return Biome

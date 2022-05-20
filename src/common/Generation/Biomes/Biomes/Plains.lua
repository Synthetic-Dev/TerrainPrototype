local Struct = require(script.Parent.Parent.BiomeStruct)

local Ocean = require(script.Parent.Ocean)

local Biome = Struct.new({
	Name = "Plains",
	Conditions = {
		Temperature = 0.4,
		Humidity = 0.45,
		Altitude = 0.1,
	},
})

function Biome:GetHeight(position, noise, factors)
	local scaled = position / 300
	return factors.Altitude * noise(scaled.X, scaled.Y)
end

function Biome:GetInfluence(biome, neighbourDistance)
	if biome == Ocean then
		return 0
	end
	return 0.5 * neighbourDistance
end

function Biome:GetColor()
	return Color3.new(0.623529, 0.972549, 0.341176)
end

return Biome

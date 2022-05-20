local function MapAlphaToRange(alpha, range)
	return alpha * (range.Max - range.Min) + range.Min
end

local Noise = {}

local Perlin = {}
Perlin.__index = Perlin
Perlin.__call = function(self, ...)
	return self:Noise(...)
end
Noise.Perlin = Perlin

function Perlin.new(seed: number, range: NumberRange)
	range = range or NumberRange.new(0, 1)
	return setmetatable({
		_seed = seed / 1e5,
		_range = range,
	}, Perlin)
end

function Perlin:Noise(x, y, range)
	local noise = math.noise(x, y, self._seed)
	local alpha = math.clamp(noise + 0.5, 0, 1)
	return MapAlphaToRange(alpha, range or self._range)
end

function Perlin:WarpedNoise(strength, x, y, range)
	local dx = strength * self(x + 123, if y then y + 456 else nil)
	local dy = strength * self(x - 789, if y then y - 456 else nil)
	return self(x + dx, if y then y + dy else nil, range)
end

export type Perlin = typeof(Perlin.new())

local Voronoi = {}
Voronoi.__index = Voronoi
Noise.Voronoi = Voronoi

function Voronoi.new(seed: number, jitter: number)
	return setmetatable({
		_seed = seed,
		_jitter = jitter,
	}, Voronoi)
end

function Voronoi:Square() end

return Noise

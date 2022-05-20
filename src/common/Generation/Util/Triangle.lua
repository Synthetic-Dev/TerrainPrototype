local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Common = ReplicatedStorage.Common
local Assets = Common.Assets
local INSTANCE = Assets.Triangle
do
	INSTANCE.Anchored = true
	INSTANCE.CanTouch = false
	INSTANCE.CastShadow = false
end

local instancePool = {}

local Triangle = {}
Triangle.__index = Triangle

function Triangle.new(vA, vB, vC, parent)
	local model = Instance.new("Model")
	model.Name = "Tri"

	local t1 = table.remove(instancePool, 1) or INSTANCE:Clone()
	t1.Parent = model

	local t2 = table.remove(instancePool, 1) or INSTANCE:Clone()
	t2.Parent = model

	local self = setmetatable({
		Instance = model,
		_instances = { t1, t2 },
		_vertices = { vA, vB, vC },
	}, Triangle)

	self:Update()

	model.Parent = parent
	return self
end

function Triangle:SetVertices(vA, vB, vC)
	self._vertices = { vA, vB, vC }
	self:Update()
end

function Triangle:Update()
	-- Code taken from EgoMoose's 3d triangles article and modified
	-- See https://github.com/EgoMoose/Articles/blob/master/3d%20triangles/3D%20triangles.md

	local a = self._vertices[1].Position + self._vertices[1].Chunk.WorldPosition
	local b = self._vertices[2].Position + self._vertices[2].Chunk.WorldPosition
	local c = self._vertices[3].Position + self._vertices[3].Chunk.WorldPosition

	local color
	if self._vertices[1].Color then
		local aH, aS, aV = 0, 0, 0
		for _, vertex in pairs(self._vertices) do
			local h, s, v = Color3.toHSV(vertex.Color)
			aH += h
			aS += s
			aV += v
		end
		color = Color3.fromHSV(aH / 3, aS / 3, aV / 3)
	end

	local ab, ac, bc = b - a, c - a, c - b
	local abd, acd, bcd = ab:Dot(ab), ac:Dot(ac), bc:Dot(bc)

	if abd > acd and abd > bcd then
		c, a = a, c
	elseif acd > bcd and acd > abd then
		a, b = b, a
	end

	ab, ac, bc = b - a, c - a, c - b

	local right = ac:Cross(ab).Unit
	local up = bc:Cross(right).Unit
	local back = bc.Unit

	self.Gradient = math.max(
		math.abs(ab.Unit:Dot(Vector3.new(0, 1, 0))),
		math.abs(ac.Unit:Dot(Vector3.new(0, 1, 0))),
		math.abs(bc.Unit:Dot(Vector3.new(0, 1, 0)))
	)

	local epsilon = 0.01 -- * gradient
	local height = math.abs(ab:Dot(up)) + epsilon

	if not color then
		color = Color3.fromHSV(0, 0, 1 - self.Gradient)
	end

	self._instances[1].Size = Vector3.new(0, height, math.abs(ab:Dot(back)) + epsilon)
	self._instances[1].CFrame = CFrame.fromMatrix((a + b) * 0.5, -right, up, back):Orthonormalize()
	self._instances[1].Color = color

	self._instances[2].Size = Vector3.new(0, height, math.abs(ac:Dot(back)) + epsilon)
	self._instances[2].CFrame = CFrame.fromMatrix((a + c) * 0.5, right, up, -back):Orthonormalize()
	self._instances[2].Color = color
end

function Triangle:Destroy()
	table.insert(instancePool, self._instances[1])
	table.insert(instancePool, self._instances[2])

	table.clear(self)
	setmetatable(self, nil)
end

return Triangle

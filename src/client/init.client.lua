local Players = game:GetService("Players")
local ContentProvider = game:GetService("ContentProvider")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Packages = ReplicatedStorage.Packages

local Knit = require(Packages.Knit)

repeat
	task.wait(1)
until ContentProvider.RequestQueueSize == 0

local LocalPlayer = Players.LocalPlayer

Knit.AddControllers(script.Controllers)

Knit.Start({
	ServicePromises = false,
})
	:andThen(function()
		for _, component in pairs(script.Components:GetChildren()) do
			require(component)
		end
	end)
	:catch(function(err)
		LocalPlayer:Kick()
		error("Error loading Knit client", err)
	end)

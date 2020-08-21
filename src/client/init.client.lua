--[[
    Main control script for the client. Controls user input (i.e. the mouse).
]]

-- Game Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

-- Game Structure
local src = ReplicatedStorage:WaitForChild("Source")

-- Load the game modules
local Swap = require(src:WaitForChild("Swap"))
local Recolor = require(src:WaitForChild("Recolor"))
local Input = require(src:WaitForChild("Input"))

-- When the player mouses over a part, we want to recolor that part
RunService.RenderStepped:Connect(function()
    Recolor.SetTarget(Input.GetMouseTarget())
end)

-- When the player clicks on a part, add it to the list of parts we want to swap
Input.Events.MouseClicked:Connect(function(target)
    if not target then return end
    Swap.AddPart(target)
end)
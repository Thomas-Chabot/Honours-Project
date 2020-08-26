--[[
    Main control script for the client. Controls user input (i.e. the mouse).
]]

-- Game Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CollectionService = game:GetService("CollectionService")
local RunService = game:GetService("RunService")

-- Game Structure
local src = ReplicatedStorage:WaitForChild("Source")

-- Load the game modules
local Swap = require(src:WaitForChild("Swap"))
local Recolor = require(src:WaitForChild("Recolor"))
local Input = require(src:WaitForChild("Input"))
require(src:WaitForChild("CameraMode"))
require(src:WaitForChild("Tags"))
require(src:WaitForChild("Barriers"))

-- Globals
local raycastParams = RaycastParams.new()
raycastParams.FilterDescendantsInstances = CollectionService:GetTagged("CanSwap")
raycastParams.FilterType = Enum.RaycastFilterType.Whitelist

-- When the player mouses over a part, we want to recolor that part
RunService.RenderStepped:Connect(function()
    local targetData = Input.GetTargetData()
    local raycastResult = workspace:Raycast(targetData.Origin, targetData.Direction, raycastParams)
    Recolor.SetTarget(raycastResult and raycastResult.Instance)
end)

-- When the player clicks on a part, add it to the list of parts we want to swap
Input.Events.MouseClicked:Connect(function()
    local targetData = Input.GetTargetData()
    local raycastResult = workspace:Raycast(targetData.Origin, targetData.Direction, raycastParams)
    local target = raycastResult and raycastResult.Instance

    if not target then return end
    Swap.AddPart(target)
end)

Swap.Events.SwapStarted:Connect(function()
    Recolor.Disable()
end)
Swap.Events.SwapCompleted:Connect(function()
    Recolor.Enable()
end)

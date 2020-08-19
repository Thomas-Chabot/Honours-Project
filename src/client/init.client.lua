--[[
    Main control script for the client. Controls user input (i.e. the mouse).
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local src = ReplicatedStorage:WaitForChild("Source")
local Swap = require(src:WaitForChild("Swap"))
local Recolor = require(src:WaitForChild("Recolor"))

local player = game.Players.LocalPlayer
local mouse = player:GetMouse()

-- When the player mouses over a part, we want to recolor that part
RunService.RenderStepped:Connect(function()
    Recolor.SetTarget(mouse.Target)
end)

-- When the player clicks on a part, add it to the list of parts we want to swap
mouse.Button1Down:Connect(function()
    if not mouse.Target then return end
    Swap.AddPart(mouse.Target)
end)
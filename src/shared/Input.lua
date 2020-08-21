--[[
    The main Input module. This module returns a list of events
    that will fire when the player performs certain actions.
]]

local Input = { }

-- Services
local ContextActionService = game:GetService("ContextActionService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Game Structure
local Util = ReplicatedStorage:WaitForChild("Util")

-- Dependencies
local Signal = require(Util:WaitForChild("Signal"))

-- global variables
local player = game.Players.LocalPlayer
local mouse = player:GetMouse()

-- Input Events
Input.Events = {
    MouseClicked = Signal.new() -- Fires on mouse click
}

-- Retrieves what the player is currently pointing at
function Input.GetMouseTarget()
    return mouse.Target
end

-- Event Connections
-- Triggers the MouseClicked event
mouse.Button1Down:Connect(function()
    Input.Events.MouseClicked:Fire(mouse.Target)
end)

return Input

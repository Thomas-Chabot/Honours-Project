--[[
    The main Input module. This module returns a list of events
    that will fire when the player performs certain actions.
]]

local Input = { }

-- Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ContextActionService = game:GetService("ContextActionService")
local UserInputService = game:GetService("UserInputService")

-- Game Structure
local Util = ReplicatedStorage:WaitForChild("Util")

-- Dependencies
local Signal = require(Util:WaitForChild("Signal"))

-- global variables
local player = game.Players.LocalPlayer
local mouse = player:GetMouse()
local camera = workspace.CurrentCamera

-- Input Events
Input.Events = {
    MouseClicked = Signal.new(), -- Fires on mouse click. Passes in a Ray to where the player clicked
    CameraModeSwitchRequested = Signal.new() -- Fires when the player requests to switch camera mode
}

-- Converts a Vector2 Position vector into a Ray
local function getRayFromPositionVector(position)
	local unitRay = camera:ViewportPointToRay(position.X, position.Y)
	return {
        Origin = unitRay.Origin, 
        Direction = unitRay.Direction * 100
    }
end

-- ContextActionService handlers
-- Handles the request for switching camera mode
local function swapCameraMode(_, inputState)
    if inputState ~= Enum.UserInputState.Begin then return end
    Input.Events.CameraModeSwitchRequested:Fire()  
end

-- Retrieves what the player is currently pointing at
function Input.GetMouseTarget()
    return mouse.Target
end
function Input.GetTargetData()
    return getRayFromPositionVector(UserInputService:GetMouseLocation())
end

-- Event Connections
-- Triggers the MouseClicked event
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        Input.Events.MouseClicked:Fire(getRayFromPositionVector(input.Position))
    end
end)
UserInputService.TouchTapInWorld:Connect(function(position, gameProcessed)
    if gameProcessed then return end
    Input.Events.MouseClicked:Fire(getRayFromPositionVector(position))
end)

-- CameraMode swap action
ContextActionService:BindAction("CameraMode", swapCameraMode, true, Enum.KeyCode.LeftControl, Enum.KeyCode.ButtonR2)

return Input

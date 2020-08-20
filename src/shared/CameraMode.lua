local CameraMode = { }

-- Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Game Structure
local Util = ReplicatedStorage:WaitForChild("Util")
local Source = ReplicatedStorage:WaitForChild("Source")

-- Dependencies
local Signal = require(Util:WaitForChild("Signal"))
local Input = require(Source:WaitForChild("Input"))

-- Events
CameraMode.Events = {
    CameraModeChanged = Signal.new()
}

-- Constants
local Modes = {
    "PlayerView",
    "Overhead"
}

-- Global Variables
local currentMode = 1

-- Swaps the camera mode
local function swapCameraMode()
    currentMode = (currentMode % #Modes) + 1
    CameraMode.Events.CameraModeChanged:Fire(Modes[currentMode])
end

-- Event Connections
Input.Events.CameraModeSwitchRequested:Connect(swapCameraMode)
CameraMode.Events.CameraModeSwitchRequested:Connect(function(mode)
    print("The camera is now in ", mode)
end)

return CameraMode
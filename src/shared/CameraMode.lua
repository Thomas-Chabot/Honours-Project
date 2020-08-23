local CameraMode = { }

-- Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Game Structure
local Util = ReplicatedStorage:WaitForChild("Util")
local Source = ReplicatedStorage:WaitForChild("Source")

-- Dependencies
local Signal = require(Util:WaitForChild("Signal"))
local Input = require(Source:WaitForChild("Input"))
local Swap = require(Source:WaitForChild("Swap"))

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
    if Swap.IsSwapping() then
        print("Player tried to swap camera modes, but failed because currently swapping parts")
        return
    end
    
    currentMode = (currentMode % #Modes) + 1
    CameraMode.Events.CameraModeChanged:Fire(Modes[currentMode])
end

-- Get the current camera mode
function CameraMode.GetMode()
    return Modes[currentMode]
end

-- Event Connections
Input.Events.CameraModeSwitchRequested:Connect(swapCameraMode)
CameraMode.Events.CameraModeChanged:Connect(function(mode)
    print("The camera is now in ", mode)
end)

return CameraMode
local CameraMode = { }

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Network = ReplicatedStorage:WaitForChild("Network")

local Modes = {
    "PlayerView",
    "Overhead"
}
local currentMode = 1

local cameraModeChangedEvt = Network:WaitForChild("CameraModeChanged")

function CameraMode.Swap()
    currentMode = (currentMode % #Modes) + 1
    cameraModeChangedEvt:Fire(Modes[currentMode])
end

cameraModeChangedEvt.Event:Connect(function(mode)
    print("The camera is now in ", mode)
end)

return CameraMode
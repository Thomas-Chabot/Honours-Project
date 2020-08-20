local CameraMode = { }

local Modes = {
    "PlayerView",
    "Overhead"
}
local currentMode = 1

function CameraMode.Swap()
    currentMode = (currentMode % #Modes) + 1
    print("Now in mode ", Modes[currentMode])
end

return CameraMode
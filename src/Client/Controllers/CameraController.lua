-- Camera Controller
-- Username
-- September 5, 2020



local CameraController = {}

local RunService = game:GetService("RunService")
local ContextActionService = game:GetService("ContextActionService")

local CameraMode
local Maid

-- Retrieves the active camera mode
function CameraController:GetCameraMode()
    return CameraMode:GetActiveView()
end

-- Called when all controllers have been initialized
function CameraController:Start()
    -- Update camera
    Maid:GiveTask(RunService.RenderStepped:Connect(function()
        CameraMode:Update()
    end))

    -- Swap camera modes
    ContextActionService:BindAction("SwapCameraMode", function(_, inputState)
        self:_checkSwapCameraMode(inputState)
    end, true, Enum.KeyCode.LeftControl, Enum.KeyCode.ButtonR2)
end

-- Called to initialize the module
function CameraController:Init()
    self:RegisterEvent("CameraModeChanged")

    CameraMode = self.Modules.CameraBridge
    Maid = self.Shared.Maid.new()
end

-- Cleanup
function CameraController:Destroy()
    Maid:DoCleaning()
end

-- Handler for swapping camera mode. Only fires if InputState is End
function CameraController:_checkSwapCameraMode(inputState)
    if inputState ~= Enum.UserInputState.End then return end
    CameraMode:Swap()
end

return CameraController
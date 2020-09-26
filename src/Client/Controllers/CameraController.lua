-- Camera Controller
-- Username
-- September 5, 2020



local CameraController = {}

local ContextActionService = game:GetService("ContextActionService")

local CameraMode
local DungeonMasterController

-- Retrieves the active camera mode
function CameraController:GetCameraMode()
    return CameraMode:GetActiveView()
end

-- Called when all controllers have been initialized
function CameraController:Start()
    CameraMode = self.Modules.CameraBridge

    -- Swap camera modes
    ContextActionService:BindAction("SwapCameraMode", function(_, inputState)
        self:_checkSwapCameraMode(inputState)
    end, true, Enum.KeyCode.LeftControl, Enum.KeyCode.ButtonR2)
end

-- Called to initialize the module
function CameraController:Init()
    self:RegisterEvent("CameraModeChanged")
    DungeonMasterController = self.Controllers.DungeonMasterController
end

-- Cleanup
function CameraController:Destroy()
    CameraMode:Destroy()
end

-- Handler for swapping camera mode. Only fires if InputState is End
function CameraController:_checkSwapCameraMode(inputState)
    if inputState ~= Enum.UserInputState.End then return end
    if not DungeonMasterController:IsDungeonMaster() then return end

    CameraMode:Swap()
    self:FireEvent("CameraModeChanged")
end

return CameraController
-- Camera Bridge
-- Username
-- September 5, 2020



local CameraBridge = {}

local CameraViews
local ActiveView = 1

function CameraBridge:Init()
    CameraViews = {
        self.Modules.CameraModes.PlayerView,
        self.Modules.CameraModes.OverheadView
    }
end

-- Returns the active view mode (name)
function CameraBridge:GetActiveView()
    return self:_getCamera().Name
end

-- Updates the camera
function CameraBridge:Update()
    self:_getCamera():Update()
end

function CameraBridge:OnPointerAction(...)
    self:_getCamera():OnPointerAction(...)
end

-- Swaps the active view mode
function CameraBridge:Swap()
    self:_moveToNextCamera()
    self:_getCamera():Apply()
end

-- Private - Returns the active camera mode
function CameraBridge:_getCamera()
    return CameraViews[ActiveView]
end
-- Private - Pushes forward to the next camera mode
function CameraBridge:_moveToNextCamera()
    ActiveView = (ActiveView % #CameraViews) + 1
end


return CameraBridge
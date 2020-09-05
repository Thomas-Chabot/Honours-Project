-- Overhead View
-- Username
-- September 5, 2020



local OverheadView = {}
OverheadView.__index = OverheadView
OverheadView.Name = "Overhead"

local cameraPosition
local speed = 0.75

local player
local camera
local controls

local Zoom

-- Called when the module is ready for set up
function OverheadView:Start()
    cameraPosition = Vector2.new(0,0)

    player = self:_getPlayer()
    camera = self:_getCamera()
    controls = self:_getControls()
end

-- Initializes the module.
function OverheadView:Init()
    Zoom = self.Modules.Zoom
    
    local CameraView = self.Modules.CameraModes.CameraView
    OverheadView = setmetatable(OverheadView, {
        __index = CameraView
    })
end

-- Applies the changes needed for the player to be in Overhead view
function OverheadView:Apply()
    player.CameraMode = Enum.CameraMode.Classic
    camera.CameraType = Enum.CameraType.Scriptable
    --camera.CameraSubject = workspace.PrimaryPart

    controls:Disable()

    cameraPosition = Vector2.new(camera.CFrame.X, camera.CFrame.Z)
end

-- Updates the overhead camera CFrame
function OverheadView:Update()
    local moveVector = controls:GetMoveVector()

    camera.CFrame = CFrame.new(Vector3.new(cameraPosition.X, Zoom:GetNext(), cameraPosition.Y), Vector3.new(cameraPosition.X,0,cameraPosition.Y))
    cameraPosition += Vector2.new(-moveVector.Z * speed, moveVector.X * speed)
end

-- Zoom in/out
function OverheadView:OnPointerAction(wheel, pan, pinch)
    Zoom:OnPointerAction(wheel, pan, pinch)
end

return OverheadView
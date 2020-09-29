-- Overhead View
-- Username
-- September 5, 2020



local OverheadView = {}
OverheadView.__index = OverheadView
OverheadView.Name = "Overhead"

local cameraPosition
local speed = 1

local player
local camera
local controls

local CameraView
local Zoom
local Maid, maid

local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

-- Called when the module is ready for set up
function OverheadView:Start()
    CameraView.Start(self)

    player = self:_getPlayer()
    camera = self:_getCamera()
    controls = self:_getControls()

    cameraPosition = Vector2.new(0,0)
end

-- Initializes the module
function OverheadView:Init() 
    Zoom = self.Modules.Zoom
    Maid = self.Shared.Maid
    
    CameraView = self.Modules.CameraModes.CameraView
    OverheadView = setmetatable(OverheadView, {
        __index = CameraView
    })
end

-- Applies the changes needed for the player to be in Overhead view
function OverheadView:Activate()
    player.CameraMode = Enum.CameraMode.Classic
    camera.CameraSubject = workspace.PrimaryPart or workspace:FindFirstChildWhichIsA("BasePart")
    camera.CameraType = Enum.CameraType.Scriptable

    -- Disable player movement
    controls:Disable()

    -- Set up the initial position for the camera
    cameraPosition = Vector2.new(camera.CFrame.X, camera.CFrame.Z)

    -- Clean up all event connections that already exist
    self:Cleanup()

    -- Set up a maid to store our events
    maid = Maid.new()

    -- Zoom in/out
    maid:GiveTask(UserInputService.PointerAction:Connect(function(wheel, pan, pinch, processed)
        if processed then return end
        self:OnPointerAction(wheel, pan, pinch)
    end))

    -- Update camera positioning
    maid:GiveTask(RunService.RenderStepped:Connect(function()
        self:Update()
    end))
end

-- Deactivates the Overhead View so that it won't listen for events.
function OverheadView:Deactivate()
    self:Cleanup()
end

-- Updates the overhead camera CFrame
function OverheadView:Update()
    local moveVector = controls:GetMoveVector()

    camera.CFrame = CFrame.new(Vector3.new(cameraPosition.X, Zoom:GetNext(), cameraPosition.Y), Vector3.new(cameraPosition.X,0,cameraPosition.Y))
    cameraPosition += Vector2.new(-moveVector.Z * speed, moveVector.X * speed)
end

-- Cleans up all events & resets the active maid.
function OverheadView:Cleanup()
    if not maid then return end
    
    maid:DoCleaning()
    maid = nil
end

-- Zoom in/out
function OverheadView:OnPointerAction(wheel, pan, pinch)
    Zoom:OnPointerAction(wheel, pan, pinch)
end

return OverheadView
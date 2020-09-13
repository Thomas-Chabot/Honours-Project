-- Player View
-- Username
-- September 5, 2020



local PlayerView = {}
PlayerView.__index = PlayerView
PlayerView.Name = "PlayerView"

local player
local controls
local camera

local CameraView

-- Called when the module is ready to be started
function PlayerView:Start()
    CameraView.Start(self)

    player = self:_getPlayer()
    camera = self:_getCamera()
    controls = self:_getControls()
end

-- Initializees the module
function PlayerView:Init()
    CameraView = self.Modules.CameraModes.CameraView
    PlayerView = setmetatable(PlayerView, {
        __index = CameraView
    })
end

-- Applies the changes for the player to return to first person view
function PlayerView:Activate()
    camera.CameraType = Enum.CameraType.Custom
    player.CameraMode = Enum.CameraMode.LockFirstPerson
    camera.CameraSubject = player.Character and player.Character:FindFirstChildOfClass("Humanoid")

    controls:Enable()
end

-- Deactivate the Player View camera
function PlayerView:Deactivate()

end

return PlayerView
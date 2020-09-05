-- Player View
-- Username
-- September 5, 2020



local PlayerView = {}
PlayerView.__index = PlayerView
PlayerView.Name = "PlayerView"

local player
local controls
local camera

-- Called when the module is ready to be started
function PlayerView:Start()
    player = self:_getPlayer()
    camera = self:_getCamera()
    controls = self:_getControls()
end

-- Initializees the module
function PlayerView:Init()
    local CameraView = self.Modules.CameraModes.CameraView
    PlayerView = setmetatable(PlayerView, {
        __index = CameraView
    })
end

-- Applies the changes for the player to return to first person view
function PlayerView:Apply()
    camera.CameraType = Enum.CameraType.Custom
    player.CameraMode = Enum.CameraMode.LockFirstPerson
    camera.CameraSubject = player.Character and player.Character:FindFirstChildOfClass("Humanoid")

    controls:Enable()
end

function PlayerView:Update()
    -- No work for it to do in the PlayerView, works by Roblox's own camera script
end

return PlayerView
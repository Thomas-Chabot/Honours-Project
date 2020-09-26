-- Camera View
-- Username
-- September 5, 2020

--[[
    This class works as an abstract / base class for camera views.
    It implements a few helper functions & provides the template functions that
     every camera view must implement.
]]


local CameraView = {}
CameraView.__index = CameraView
CameraView.Name = "CameraView"

local player
local controls
local camera

-- Initializes local variables
function CameraView:Start()
    -- player
    player = game.Players.LocalPlayer
    
    -- camera
    camera = workspace.CurrentCamera

    -- controls module
    do
        local playerModule = require(player.PlayerScripts:WaitForChild("PlayerModule"))
        controls = playerModule:GetControls()
    end

end

-- To be called when the camera view becomes active.
-- Updates game settings so that the camera can be used. 
function CameraView:Activate()
    error("Method Not Implemented")
end

-- Called to deactivate the camera.
-- Performs cleaning that needs to be done once the camera is no longer active.
function CameraView:Deactivate()
    error("Method Not Implemented")
end

-- Returns the local player.
function CameraView:_getPlayer()
    return player
end

-- Returns the camera.
function CameraView:_getCamera()
    return camera
end

-- Returns the player controls module.
function CameraView:_getControls()
    return controls
end

return CameraView
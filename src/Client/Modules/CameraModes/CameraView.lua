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
function CameraView:Init()
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
function CameraView:Apply()
    error("Method Not Implemented")
end

-- Called on every render when the camera is active.
function CameraView:Update()
    error("Method Not Implemented")
end

-- Called with the PointerAction event.
-- Should be implemented for any camera module that overrides the camera for zooming.
function CameraView:OnPointerAction(wheel, pan, pinch)
    
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
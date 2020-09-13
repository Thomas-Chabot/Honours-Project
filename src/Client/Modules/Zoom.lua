-- Zoom Module
-- Username
-- September 5, 2020

--[[
    This module controls the zooming in and out of the overhead camera.
    When the player runs a PointerAction (i.e. mouse wheel up, mouse wheel down, pinch, etc.),
     the zoom target will update and this will return a number every frame for the Y axis of the Camera.
]]

local Zoom = {}

local UserGameSettings = UserSettings():GetService("UserGameSettings")

local Spring
local StartingZoom = 75

-- Constants
local SPRING_SPEED = 20
local PAN_SENSITIVITY = 20
local MOUSE_SENSITIVITY = Vector2.new( 0.002 * math.pi, 0.0015 * math.pi )
local ZOOM_SENSITIVITY_CURVATURE = 0.5
local FFlagUserFixZoomInZoomOutDiscrepancy 
local player = game.Players.LocalPlayer

do
    local success, result = pcall(function()
        return UserSettings():IsUserFeatureEnabled("UserFixZoomInZoomOutDiscrepancy")
    end)
    FFlagUserFixZoomInZoomOutDiscrepancy = success and result
end

-- Calls to initialize the module.
function Zoom:Init()
    Spring = self.Shared.Spring.new(StartingZoom)
    Spring.Target = StartingZoom
    Spring.Speed = SPRING_SPEED
end

-- Retrieves the current zoom value.
function Zoom:GetTarget()
    return Spring.Target
end

-- Returns a zoom value that we can use for the next frame.
function Zoom:GetNext()
    -- Will do some logic here
    return Spring.Position
end

-- Handles zooming in and out.
-- Code copied from Roblox's own default camera script. 
function Zoom:OnPointerAction(wheel, pan, pinch)
    if pan.Magnitude > 0 then
        local inversionVector = Vector2.new(1, UserGameSettings:GetCameraYInvertValue())
        local rotateDelta = PAN_SENSITIVITY*pan * MOUSE_SENSITIVITY * inversionVector
        self.rotateInput = self.rotateInput + rotateDelta
    end

    local zoomDelta = -(wheel + pinch)
    local zoom = Spring.Target
    
    if math.abs(zoomDelta) > 0 then
        local newZoom
        if FFlagUserFixZoomInZoomOutDiscrepancy then
            if (zoomDelta > 0) then
                newZoom = zoom + zoomDelta*(1 + zoom*ZOOM_SENSITIVITY_CURVATURE)
            else
                newZoom = (zoom + zoomDelta) / (1 - zoomDelta*ZOOM_SENSITIVITY_CURVATURE)
            end
        else
            newZoom = zoom + zoomDelta*(1 + zoom*ZOOM_SENSITIVITY_CURVATURE)
        end

        Spring.Target = math.clamp(newZoom, player.CameraMinZoomDistance, player.CameraMaxZoomDistance)
    end
end

return Zoom
-- Camera Controller
-- Username
-- August 30, 2020

--[[
    Controls the Camera. The camera has two modes:
        PlayerView - When the player is in first person view
        Overhead - When the player is in overhead view.
]]

local CameraController = {}

local RunService = game:GetService("RunService")
local ContextActionService = game:GetService("ContextActionService")
local UserInputService = game:GetService("UserInputService")
local UserGameSettings = UserSettings():GetService("UserGameSettings")

-- Camera mode data
local CameraModes = {
    {
        ModeName = "PlayerView",
        CameraType = Enum.CameraType.Custom,
        CameraMode = Enum.CameraMode.LockFirstPerson,
    },
    {
        ModeName = "Overhead",
        CameraType = Enum.CameraType.Scriptable,
        CameraMode = Enum.CameraMode.Classic
    }
}

-- Global Variables
local zoom = 75
local speed = 0.75
local currentMode = 1
local camera
local player
local controls
local target
local cameraPosition
local maid

-- Zoom Constants (taken from the BaseCamera code provided by Roblox)
local PAN_SENSITIVITY = 20
local MOUSE_SENSITIVITY = Vector2.new( 0.002 * math.pi, 0.0015 * math.pi )
local ZOOM_SENSITIVITY_CURVATURE = 0.5
local FFlagUserFixZoomInZoomOutDiscrepancy do
    local success, result = pcall(function()
        return UserSettings():IsUserFeatureEnabled("UserFixZoomInZoomOutDiscrepancy")
    end)
    FFlagUserFixZoomInZoomOutDiscrepancy = success and result
end

-- Retrieves humanoid for the active player
local function GetHumanoid()
    return player.Character and player.Character:FindFirstChild("Humanoid")
end

-- Starts up the controller
function CameraController:Start()
    -- Global Variable setup
    camera = workspace.CurrentCamera
    player = game.Players.LocalPlayer
    target = workspace.PrimaryPart
    maid = self.Shared.Maid.new()

    -- Controls Module
    local playerModule = require(player.PlayerScripts:WaitForChild("PlayerModule"))
    controls = playerModule:GetControls()

    -- Event connections
    -- Update camera position every frame
    maid:GiveTask(RunService.RenderStepped:Connect(function() self:Update() end))

    -- Swap between camera modes
    ContextActionService:BindAction("SwapCameraMode", function(_, inputState)
        if inputState ~= Enum.UserInputState.Begin then return end
        self:ChangeMode()
    end, true, Enum.KeyCode.LeftControl, Enum.KeyCode.ButtonR2)
    maid:GiveTask(function() ContextActionService:UnbindAction("SwapCameraMode") end)

    -- Camera zoom
    maid:GiveTask(UserInputService.PointerAction:Connect(function(wheel, pan, pinch, processed)
        self:OnPointerAction(wheel, pan, pinch, processed)
    end))
end

-- Called when the controller initializes
function CameraController:Init()
    self:RegisterEvent("CameraModeChanged")
end

-- Cleanup
function CameraController:Destroy()
    maid:DoCleaning()
end

-- Retrieves the name of the current mode (Overhead or PlayerView)
function CameraController:GetMode()
    return self:GetModeData().ModeName
end
-- Retrieves full data for the current mode
function CameraController:GetModeData()
    return CameraModes[currentMode]
end

-- Changes the active camera mode
function CameraController:ChangeMode()
    currentMode = (currentMode % #CameraModes) + 1
    self:Apply()
    self:FireEvent("CameraModeChanged", self:GetMode())
end

-- Applies a new Camera Mode
function CameraController:Apply()
    local data = self:GetModeData()
    player.CameraMode = data.CameraMode
    camera.CameraType = data.CameraType
    camera.CameraSubject = (data.CameraSubject == "Player") and GetHumanoid() or target

    if self:GetMode() == "Overhead" then
        local cf = camera.CFrame
        cameraPosition = Vector2.new(cf.X, cf.Z)

        controls:Disable()
    else
        controls:Enable()
    end
end

-- Updates Camera position when in overhead view
function CameraController:Update()
    -- Only needs to apply any changes if the camera is in Overhead view
    if self:GetMode() ~= "Overhead" then
        return
    end

    local moveVector = controls:GetMoveVector()
    camera.CFrame = CFrame.new(Vector3.new(cameraPosition.X, zoom, cameraPosition.Y), Vector3.new(cameraPosition.X,0,cameraPosition.Y))
    
    cameraPosition += Vector2.new(-moveVector.Z * speed, moveVector.X * speed)
end

-- Taken from the Roblox BaseCamera module. Controls the zoom level.
function CameraController:OnPointerAction(wheel, pan, pinch, processed)
    if processed or self:GetMode() ~= "Overhead" then
        return
    end

    if pan.Magnitude > 0 then
        local inversionVector = Vector2.new(1, UserGameSettings:GetCameraYInvertValue())
        local rotateDelta = self:InputTranslationToCameraAngleChange(PAN_SENSITIVITY*pan, MOUSE_SENSITIVITY)*inversionVector
        self.rotateInput = self.rotateInput + rotateDelta
    end

    local zoomDelta = -(wheel + pinch)

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

        zoom = math.clamp(newZoom, player.CameraMinZoomDistance, player.CameraMaxZoomDistance)
    end
end

return CameraController
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

-- Dependencies
local Input

-- Global Variables
local speed = 0.75
local currentMode = 1
local camera
local player
local controls
local target
local cameraPosition

local function GetHumanoid()
    return player.Character and player.Character:FindFirstChild("Humanoid")
end

function CameraController:Start()
    -- Global Variable setup
    camera = workspace.CurrentCamera
    player = game.Players.LocalPlayer
    target = workspace.PrimaryPart

    -- Controls Module
    local playerModule = require(player.PlayerScripts:WaitForChild("PlayerModule"))
    controls = playerModule:GetControls()

    -- Event connections
    -- Update camera position every frame
    RunService.RenderStepped:Connect(function() self:Update() end)

    -- Swap between camera modes
    ContextActionService:BindAction("CameraModes", function(_, inputState)
        if inputState ~= Enum.UserInputState.Begin then return end
        self:ChangeMode()
    end, true, Enum.KeyCode.LeftControl, Enum.KeyCode.ButtonR2)
end


function CameraController:Init()
    self:RegisterEvent("CameraModeChanged")
    Input = self.Controllers.UserInput
end

function CameraController:GetMode()
    return self:GetModeData().ModeName
end
function CameraController:GetModeData()
    return CameraModes[currentMode]
end

function CameraController:ChangeMode()
    currentMode = (currentMode % #CameraModes) + 1
    self:Apply()
    self:FireEvent("CameraModeChanged", self:GetMode())
end

function CameraController:Apply()
    local data = self:GetModeData()
    player.CameraMode = data.CameraMode
    camera.CameraType = data.CameraType
    camera.CameraSubject = (data.CameraSubject == "Player") and GetHumanoid() or target

    if self:GetMode() == "Overhead" then
        local cf = camera.CFrame
        cameraPosition = Vector3.new(cf.X, 75, cf.Z)

        controls:Disable()
    else
        controls:Enable()
    end
end

function CameraController:Update()
    -- Only needs to apply any changes if the camera is in Overhead view
    if self:GetMode() ~= "Overhead" then
        return
    end

    local moveVector = controls:GetMoveVector()
    camera.CFrame = CFrame.new(cameraPosition,Vector3.new(cameraPosition.X,0,cameraPosition.Z))
    
    cameraPosition += Vector3.new(-moveVector.Z * speed, 0, moveVector.X * speed)
end

return CameraController
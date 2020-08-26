local Barriers = { }

-- Game Services
local CollectionService = game:GetService("CollectionService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Game Structure
local Source = ReplicatedStorage:WaitForChild("Source")

-- Dependencies
local CameraMode = require(Source:WaitForChild("CameraMode"))

-- Constants
local BarrierTag = "Barrier"

local function setCollidable(objects, canCollide)
    for _,obj in pairs(objects) do
        obj.CanCollide = canCollide
    end
end

local function onCameraModeChanged(mode)
    if mode == "Overhead" then
        setCollidable(CollectionService:GetTagged(BarrierTag), false)
    else
        setCollidable(CollectionService:GetTagged(BarrierTag), true)
    end
end

-- Event Connections
CameraMode.Events.CameraModeChanged:Connect(onCameraModeChanged)

-- Update the tag when the game starts
onCameraModeChanged(CameraMode.GetMode())

return Barriers
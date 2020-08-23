--[[
    This script controls adding & removing tags from objects.
]]
local Tags = { }

-- Game Services
local CollectionService = game:GetService("CollectionService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Game Structure
local Source = ReplicatedStorage:WaitForChild("Source")

-- Dependencies
local CameraMode = require(Source:WaitForChild("CameraMode"))

-- Constants
local SwappableTag = "Swappable"
local CanSwapTag = "CanSwap"

-- Sets whether objects have a given tag.
-- Either adds or removes the tag to/from the collection.
-- @tparam objects Array of BasePart The list of objects that we want to toggle the tag on
-- @tparam tag string The tag to add/remove
-- @tparam hasTag bool Whether to add or remove the tag
local function setTag(objects, tag, hasTag)
    for _,object in pairs(objects) do
        if hasTag then
            CollectionService:AddTag(object, tag)
        else
            CollectionService:RemoveTag(object, tag)
        end
    end
end

-- Handler for the camera mode changing
-- When the camera goes into the Overhead view, objects can be swapped around
-- @tparam newMode String The camera mode that we changed into
local function onCameraModeChanged(newMode)
    -- When we go into Overhead view, we can swap around objects
    if newMode == "Overhead" then
        setTag(CollectionService:GetTagged(CanSwapTag), SwappableTag, true)
    else
        setTag(CollectionService:GetTagged(CanSwapTag), SwappableTag, false)
    end
end

-- Event Connections
CameraMode.Events.CameraModeChanged:Connect(onCameraModeChanged)

-- Update the tag when the game starts
onCameraModeChanged(CameraMode.GetMode())

return Tags
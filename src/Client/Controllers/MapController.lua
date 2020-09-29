-- Map Controller
-- Username
-- August 29, 2020

--[[
    This controls the client side of the map.
    This gets data from the MapService and builds out the map.
]]



local MapController = {}
local SwappableParts = { }

local CollectionService = game:GetService("CollectionService")
local CameraController

local function toggleTag(parts, tag, isActive)
    for _,part in pairs(parts) do
        if isActive then
            CollectionService:AddTag(part, tag) 
        else
            CollectionService:RemoveTag(part, tag)
        end
    end
end

function MapController:Start()

    self:Build()
    CameraController:ConnectEvent("CameraModeChanged", function()
        self:OnViewModeChanged()
    end)
end


function MapController:Init()
    CameraController = self.Controllers.CameraController
end

function MapController:Build()
    repeat
        wait()
    until self.Services.MapService
    local data = self.Services.MapService:GetLayout()
    for rowIndex, row in ipairs(data) do
        for colIndex, element in ipairs(row) do
            local obj = element.Type:Clone()
            obj.Name = element.Id
            obj.Position = Vector3.new((rowIndex - 1) * 24, 0, (colIndex - 1) * 24)
            obj.Anchored = true
            obj.Parent = workspace

            table.insert(SwappableParts, obj)
        end
    end
end

function MapController:OnViewModeChanged()
    local viewMode = CameraController:GetCameraMode()
    toggleTag(SwappableParts, "Swappable", viewMode == "Overhead")
end


return MapController
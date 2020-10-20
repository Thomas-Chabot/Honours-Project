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
local DungeonSettings
local Room
local Path

local Rooms
local SwappablesFolder

local function toggleTag(tag, isActive)
    for _,part in pairs(SwappablesFolder:GetChildren()) do
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
    DungeonSettings = self.Shared.DungeonSettings
    Room = self.Modules.Dungeon.Room
    Path = self.Modules.Dungeon.Path
end

function MapController:Build() 
    Rooms = { }

    repeat
        wait()
    until self.Services.MapService

    local folder = Instance.new("Folder")
    folder.Name = "Swappables"
    folder.Parent = workspace

    SwappablesFolder = folder

    local data = self.Services.MapService:GetLayout()

    -- Step 1) Set up the surrounding space to build out of
    local region = Region3.new(Vector3.new(-256, 0, -256), Vector3.new(256, DungeonSettings.WallHeight, 256)):ExpandToGrid(4)
    workspace.Terrain:FillRegion(region, 4, DungeonSettings.WallMaterial)

    -- Step 2) Set up data for the rooms
    for _,roomData in pairs(data.Rooms) do
        Rooms[roomData.Id] = Room.new(roomData)
    end

    -- Step 3) Connect & Build paths
    for _,pathData in pairs(data.Paths) do
        local r1 = Rooms[pathData[1]]
        local r2 = Rooms[pathData[2]]

        local path = Path.Between(r1, r2)
        path:Build()
    end

    -- Step 4) Build the rooms
    for _,room in pairs(Rooms) do
        room:Build()
    end
end

function MapController:OnViewModeChanged()
    local viewMode = CameraController:GetCameraMode()
    toggleTag("Swappable", viewMode == "Overhead")
end


return MapController
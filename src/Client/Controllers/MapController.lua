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

local CameraController, SwapController
local DungeonSettings
local Room
local Path
local Swap
local Maid

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
    Swap.Swapped:Connect(function(p1, p2)
        self:SwapRooms(p1, p2)
    end)
end


function MapController:Init()
    CameraController = self.Controllers.CameraController
    SwapController = self.Controllers.SwapController
    DungeonSettings = self.Shared.DungeonSettings
    Room = self.Modules.Dungeon.Room
    Path = self.Modules.Dungeon.Path
    Swap = self.Controllers.SwapController
    Maid = self.Shared.Maid.new()
end

function MapController:Rebuild()
    self:Clear()
    self:Build()
end

function MapController:Build()
    Rooms = { }

    repeat
        wait()
    until self.Services.MapService

    local folder = Instance.new("Folder")
    folder.Name = "Swappables"
    folder.Parent = workspace
    Maid:GiveTask(folder)

    SwappablesFolder = folder

    local data = self.Services.MapService:GetLayout()

    -- Step 1) Set up the surrounding space to build out of
    local region = Region3.new(Vector3.new(-256, 0, -256), Vector3.new(256, DungeonSettings.WallHeight, 256)):ExpandToGrid(4)
    workspace.Terrain:FillRegion(region, 4, DungeonSettings.WallMaterial)

    -- Step 2) Set up data for the rooms
    for _,roomData in pairs(data.Rooms) do
        local room = Room.new(roomData)
        Maid:GiveTask(room)

        Rooms[roomData.Id] = room
    end

    -- Step 3) Connect & Build paths
    for _,pathData in pairs(data.Paths) do
        local r1 = Rooms[pathData[1]]
        local r2 = Rooms[pathData[2]]

        local path = Path.Between(r1, r2)
        path:Build()

        r1:AddPath(path)
        r2:AddPath(path)

        Maid:GiveTask(path)
    end

    -- Step 4) Build the rooms
    for _,room in pairs(Rooms) do
        room:Build()
    end

    -- Step 5) Reload players
    self.Services.MapService:ReloadPlayers()

    -- Step 6) Set up the swap controller
    SwapController:Refresh()
end

function MapController:Clear()
    Maid:DoCleaning()
    Maid = self.Shared.Maid.new()
end

function MapController:OnViewModeChanged()
    local viewMode = CameraController:GetCameraMode()
    toggleTag("Swappable", viewMode == "Overhead")
end

-- Swaps two rooms.
function MapController:SwapRooms(swap1, swap2)
	local room1 = Rooms[swap1.Name]
    local room2 = Rooms[swap2.Name]
    assert(room1 ~= nil and room2 ~= nil, "Either room1 or room2 could not be found: Room 1 = " .. swap1.Name .. " | Room 2 = " .. swap2.Name)
    
	room1:SwapWith(room2)
end


return MapController
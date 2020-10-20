--[[
    This controls one room of the dungeon.
    Dungeon rooms clear out terrain of a given size at a given position.
    Every room has a RoomType and this determines the type of room that gets placed.
]]
local DungeonSettings = require(script.Parent.DungeonSettings)

local Room = { }
Room.__index = Room

function Room.new(data)
    local self = setmetatable({
        _position = data.Position,
        _size = data.Size,
        _roomType = data.RoomType,

        _regions = { }
    }, Room)
    self:Update()

    return self
end

function Room:Update()
    local min = self:GetPosition() - self:GetSize()/2 - Vector3.new(4,0,4)
    local max = self:GetPosition() + self:GetSize()/2 + Vector3.new(4,0,4)
    
    local region = Region3.new(min, max):ExpandToGrid(4)
    local air = Region3.new(min, max + Vector3.new(0, DungeonSettings.WallHeight, 0)):ExpandToGrid(4)

    self._regions = {
        Floor = region,
        Air = air
    }
end

function Room:Build()
    workspace.Terrain:FillRegion(self._regions.Air, 4, Enum.Material.Air)
    workspace.Terrain:FillRegion(self._regions.Floor, 4, DungeonSettings.FloorMaterial)

    -- set up the part here
end

function Room:Unload()
    workspace.Terrain:FillRegion(self._regions.Air, 4, DungeonSettings.WallMaterial)
end

return Room
--[[
    This controls a Path. Paths are built between two rooms and clear terrain connecting the rooms.
    Path logic is:
        1. Build a region connecting the X of Room1 to X of Room2
        2. Go from (Room2.X, Room1.Y) to Room2
    Each is generated as terrain
]]
local DungeonSettings = require(script.Parent.DungeonSettings)
local Path = { }
Path.__index = Path

function Path.Between(room1, room2)
    -- Take the room with the smaller X coordinate as the first room;
    -- This helps to make sure that ordering doesn't matter for setting up paths
    if (room1:GetPosition().X < room2:GetPosition().X) then
        return Path.Between(room2, room1)
    end


    local self = setmetatable({
        _rooms = {room1, room2},
        _regions = { }
    }, Path)
    self:Update()

    return self
end

function Path:Update()
    local p1 = self._rooms[1]:GetPosition()
    local p2 = self._rooms[2]:GetPosition()

    local s1 = self._rooms[1]:GetSize()
    local s2 = self._rooms[2]:GetSize()

    local midpoint = Vector3.new(p2.X, p1.Y, p1.Z)

    -- Multiplier for the Z axis
    -- Determines if we need to add or remove from Z to hook the path into the room's edge
    local multiplier = (p1.Z > p2.Z) and 1 or -1

    self._regions = {
        self:_createRegion(p1 + Vector3.new(-s1.X/2, 0, 0), midpoint),
        self:_createRegion(midpoint + Vector3.new(0, 0, DungeonSettings.PathSize.Z/2 * multiplier), p2 + Vector3.new(0, 0, s2.Z/2 * multiplier))
    }
end

function Path:Build()
    local terrain = workspace.Terrain
    for _,region in pairs(self._regions) do
        terrain:FillRegion(region.Air, 4, Enum.Material.Air)
        terrain:FillRegion(region.Floor, 4, DungeonSettings.FloorMaterial)
    end
end

function Path:Unload()
    for _,region in pairs(self._regions) do
        workspace.Terrain:FillRegion(region.Air, 4, Enum.Material.Sand)
    end
end

function Path:_createRegion(from, to)
    -- Adding & Removing 5 from each axis to add in additional space for the terrain
	local min = Vector3.new(math.min(from.X, to.X) - 5, -2, math.min(from.Z, to.Z) - 5)
    local max = Vector3.new(math.max(from.X, to.X, min.X + 4) + 5, 2, math.max(from.Z, to.Z, min.Z + 4) + 5)
    
    return {
        Floor = Region3.new(min, max):ExpandToGrid(4),
        Air = Region3.new(min, max + Vector3.new(0, DungeonSettings.WallHeight, 0)):ExpandToGrid(4)
    }
end

return Path
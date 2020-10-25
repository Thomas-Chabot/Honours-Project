--[[
    This controls a Path. Paths are built between two rooms and clear terrain connecting the rooms.
    Path logic is:
        1. Build a region connecting the X of Room1 to X of Room2
        2. Go from (Room2.X, Room1.Y) to Room2
    Each is generated as terrain
]]
local DungeonSettings
local Path = { }
Path.__index = Path

function Path.Between(room1, room2)
    local self = setmetatable({
        _rooms = {room1, room2},
        _regions = { }
    }, Path)
    self:Update()

    return self
end

function Path:Init()
    DungeonSettings = self.Shared.DungeonSettings
end

-- Checks if the path is bounded to the given room. Takes a Room object.
function Path:IsInRoom(room)
    for _,r in pairs(self._rooms) do
        if r == room then
            return true
        end
    end
    return false
end

-- Changes a room on the path. Replaces the instance of the room "from"
--  with the new room "to". Both should be Room instances.
function Path:ChangeRoom(from, to)
    local didChange = false
    for index,room in pairs(self._rooms) do
        if room == from then
            self._rooms[index] = to
            didChange = true
        end
    end

    if didChange then
        self:Update()
    end
end

-- Updates the region data for the path.
function Path:Update()
    -- Make sure that we don't leave any paths lying around after the change
    self:Unload()

    -- Verify that the rooms are in the correct order
    self:_fixRooms()

    -- Calculate the region data
    local p1 = self._rooms[1]:GetPosition()
    local p2 = self._rooms[2]:GetPosition()

    local s1 = self._rooms[1]:GetSize()
    local s2 = self._rooms[2]:GetSize()

    local midpoint = Vector3.new(p2.X, p1.Y, p1.Z)

    -- Multiplier for the Z axis
    -- Determines if we need to add or remove from Z to hook the path into the room's edge
    local multiplier = (p1.Z > p2.Z) and 1 or -1

    -- Note: There's some issues here with the values, so I'm adding some constants (-6, +4) to try to fix that;
    --  might need to look into it again later on
    self._regions = {
        self:_createRegion(p1 + Vector3.new(-s1.X/2 - 6, 0, -DungeonSettings.PathSize.Z/2), midpoint + Vector3.new(0, 0, DungeonSettings.PathSize.Z/2)),
        self:_createRegion(midpoint + Vector3.new(-DungeonSettings.PathSize.X/2, 0, 0), p2 + Vector3.new(DungeonSettings.PathSize.X/2, 0, s2.Z/2 * multiplier + 4*multiplier))
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

-- Fixes rooms so that the room with the lower X coordinate is last.
-- This helps to verify that paths will remain in the same position across swaps.
function Path:_fixRooms()
    local room1 = self._rooms[1]
    local room2 = self._rooms[2]

    -- If room1 has a lower X coordinate than room2, we swap the two around
    if (room1:GetPosition().X < room2:GetPosition().X) then
        self._rooms = {room2, room1}
    end
end

function Path:_createRegion(from, to)
    -- Adding & Removing 5 from each axis to add in additional space for the terrain
	local min = Vector3.new(math.min(from.X, to.X), -2, math.min(from.Z, to.Z))
    local max = Vector3.new(math.max(from.X, to.X, min.X + 4), 2, math.max(from.Z, to.Z, min.Z + 4))
    
    return {
        Floor = Region3.new(min, max):ExpandToGrid(4),
        Air = Region3.new(min, max + Vector3.new(0, DungeonSettings.WallHeight, 0)):ExpandToGrid(4)
    }
end

return Path
--[[
    This controls one room of the dungeon.
    Dungeon rooms clear out terrain of a given size at a given position.
    Every room has a RoomType and this determines the type of room that gets placed.
]]
local DungeonSettings
local SpawnService

local Room = { }
Room.__index = Room

function Room.new(data)
    local self = setmetatable({
        Id = data.Id,
        
        _position = data.Position,
        _size = data.Size,
        _roomType = DungeonSettings.RoomTypes[data.RoomType],

        _regions = { },
        _part = nil,

        _paths = { }
    }, Room)
    self:Update()

    return self
end

function Room:Init()
    DungeonSettings = self.Shared.DungeonSettings
    SpawnService = self.Services.SpawnService
end

function Room:GetPosition()
    return self._position
end
function Room:GetSize()
    return self._size
end

function Room:AddPath(path)
    table.insert(self._paths, path)
end

function Room:SwapWith(otherRoom)
    -- Clear up the two rooms
    self:Unload()
    otherRoom:Unload()

    -- Swap the positions of each room
    local myPosition = self:GetPosition()
    local otherPosition = otherRoom:GetPosition()

    self._position = otherPosition
    otherRoom._position = myPosition

    -- Update the Region3 data
    self:Update()
    otherRoom:Update()

    -- Update the paths & associate with their new rooms
    self:_changePathsTo(otherRoom)
    otherRoom:_changePathsTo(self)

    local paths = self._paths
    self._paths = otherRoom._paths
    otherRoom._paths = paths

    -- Rebuild the paths
    local roomsToRebuild = { }
    self:_rebuildPaths(roomsToRebuild)
    otherRoom:_rebuildPaths(roomsToRebuild)

    local rebuilt = {
        [self] = true,
        [otherRoom] = true
    }
    for _,room in pairs(roomsToRebuild) do
        if rebuilt[room] then
            continue
        end

        rebuilt[room] = true
        room:Build()
    end

    -- Rebuild the rooms
    self:Build()
    otherRoom:Build()
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
    local material = self._roomType.Material or DungeonSettings.FloorMaterial

    workspace.Terrain:FillRegion(self._regions.Air, 4, Enum.Material.Air)
    workspace.Terrain:FillRegion(self._regions.Floor, 4, material)

    if self._roomType.CanSwap or self._roomType.EffectType or self._roomType.IsSpawn then
        if self._part then
            return
        end

        -- If the room can be swapped, then add a part to control it
        local floor = self._regions.Floor
        local p = Instance.new("Part")
        p.Name = self.Id
        p.Position = Vector3.new(floor.CFrame.X, floor.CFrame.Y + floor.Size.Y/2 + 2, floor.CFrame.Z)
        p.Size = Vector3.new(floor.Size.X, 1, floor.Size.Z)
        p.CanCollide = false
        p.Anchored = true
        p.Transparency = 1
        p.Parent = self._roomType.CanSwap and workspace:WaitForChild("Swappables") or workspace

        if self._roomType.EffectType then
            p.Touched:Connect(function(hit) self:_onTouch(hit) end)
        end
        if self._roomType.IsSpawn then
            SpawnService:SetSpawnLocation(p.Position, true)
        end

        -- If it has a decal, give it the decal
        local decalId = self._roomType.PartDecal
        if decalId then
            local d = Instance.new("Decal")
            d.Face = Enum.NormalId.Top
            d.Transparency = 1
            d.Name = "SwapDecal"
            d.Texture = "rbxassetid://" .. decalId
            d.Parent = p
        end

        self._part = p
    end
end

function Room:Unload()
    workspace.Terrain:FillRegion(self._regions.Air, 4, DungeonSettings.WallMaterial)
end

-- Updates the path associated to this room to being associated with another room.
function Room:_changePathsTo(otherRoom)
    for _,path in pairs(self._paths) do
        -- If the path is already hooked into the room, then don't update anything
        if path:IsInRoom(otherRoom) then
            path:Update()
            continue
        end

        -- Otherwise, change out our room for the other room
        path:ChangeRoom(self, otherRoom)
    end
end

-- Rebuilds all paths connected to this room
function Room:_rebuildPaths(connectedRooms)
    for _,path in pairs(self._paths) do
        table.insert(connectedRooms, path:GetOtherRoom(self))
        path:Build()
    end
end

function Room:_onTouch(hit)
    if self._debounce then return end
    self._debounce = true

    local character = hit and hit.Parent
    local human = character and character:FindFirstChild("Humanoid")
    if human then
        local effect = DungeonSettings.Effects[self._roomType.EffectType]
        assert(effect, "Could not find the effect for " .. tostring(self._roomType.EffectType))

        effect(character)
    end

    wait()
    self._debounce = false
end

return Room
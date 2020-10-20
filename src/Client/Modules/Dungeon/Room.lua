--[[
    This controls one room of the dungeon.
    Dungeon rooms clear out terrain of a given size at a given position.
    Every room has a RoomType and this determines the type of room that gets placed.
]]
local DungeonSettings

local Room = { }
Room.__index = Room

function Room.new(data)
    local self = setmetatable({
        Id = data.Id,
        
        _position = data.Position,
        _size = data.Size,
        _roomType = data.RoomType,

        _regions = { }
    }, Room)
    self:Update()

    return self
end

function Room:Init()
    DungeonSettings = self.Shared.DungeonSettings
end

function Room:GetPosition()
    return self._position
end
function Room:GetSize()
    return self._size
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

    if self._roomType.CanSwap or self._roomType.EffectType then
        -- If the room can be swapped, then add a part to control it
        local p = Instance.new("Part")
        p.CFrame = self._regions.Floor.CFrame + Vector3.new(0,2,0)
        p.Size = self._regions.Floor.Size + Vector3.new(0, 2, 0)
        p.CanCollide = false
        p.Anchored = true
        p.Transparency = 1
        p.Parent = self._roomType.CanSwap and workspace:WaitForChild("Swappables") or workspace

        if self._roomType.EffectType then
            p.Touched:Connect(function(hit) self:_onTouch(hit) end)
        end
    end
end

function Room:Unload()
    workspace.Terrain:FillRegion(self._regions.Air, 4, DungeonSettings.WallMaterial)
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
--[[
    This controls settings for the dungeon.
]]

return {
    FloorMaterial = Enum.Material.Sand,
    WallMaterial = Enum.Material.Sand,

    WallHeight = 30,
    PathSize = Vector3.new(10, 1, 10),

    RoomTypes = {
        Start = {
            Material = nil, -- sets it to use the default
            EffectType = nil,
            CanSwap = false,
            IsSpawn = true
        },
        Goal = {
            Material = nil, -- sets it to use the default
            EffectType = "Goal",
            CanSwap = false,
            Material = Enum.Material.Grass
        },
        Trap = {
            Material = Enum.Material.CrackedLava,
            EffectType = "Trap",
            CanSwap = true,
            PartDecal = 5853527849
        },
        Safe = {
            Material = nil, -- sets it to use the default
            EffectType = nil,
            CanSwap = true,
            PartDecal = 5853574492
        }
    },

    Effects = {
        Trap = function(char) char.Humanoid:TakeDamage(100) end,
        Goal = function(char) print(char, " Has reached the goal") end
    }
}
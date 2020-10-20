--[[
    This controls settings for the dungeon.
]]

return {
    FloorMaterial = Enum.Material.Sand,
    WallMaterial = Enum.Material.Sand,

    WallHeight = 30,
    PathSize = Vector3.new(30, 1, 30),

    RoomTypes = {
        Start = {
            Material = nil, -- sets it to use the default
            EffectType = nil,
            CanSwap = false
        },
        Goal = {
            Material = nil, -- sets it to use the default
            EffectType = "Goal",
            CanSwap = false
        },
        Trap = {
            Material = Enum.Material.CrackedLava,
            EffectType = "Trap",
            CanSwap = true
        },
        Safe = {
            Material = nil, -- sets it to use the default
            EffectType = nil,
            CanSwap = true
        }
    },

    Effects = {
        Trap = function(char) char.Humanoid:TakeDamage(100) end,
        Goal = function(char) print(char, " Has reached the goal") end
    }
}
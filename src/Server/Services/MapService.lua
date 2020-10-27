-- Map Service
-- Username
-- August 29, 2020

--[[
    This controls the game layout.
]]


local MapService = {Client = {}}
print("MapService required")

local MapLoader

function MapService:Start()

end


function MapService:Init()
    MapLoader = self.Modules.MapLoader

    self:CacheClientMethod("GetLayout")
    self:RegisterClientEvent("SwapParts")
end

-- Reloads all players
function MapService:ReloadPlayers()
    for _,p in pairs(game.Players:GetPlayers()) do
        p:LoadCharacter()
    end
end

-- Swaps around two positions on the grid.
function MapService.Client:Swap(part1, part2)
    if part1 == part2 then
        return false
    end
    self:FireAllClients("SwapParts", part1, part2)
end

-- Returns the game layout.
function MapService.Client:GetLayout()
    --[[return {
        Rooms = {
            {
                Id = "Start",
                Position = Vector3.new(-17.5, 0.5, 17.5),
                Size = Vector3.new(30, 1, 30),
                RoomType = DungeonSettings.RoomTypes.Start
            },
            {
                Id = "A",
                Position = Vector3.new(23, 0.5, 69),
                Size = Vector3.new(10, 1, 10),
                RoomType = DungeonSettings.RoomTypes.Trap
            },
            {
                Id = "B",
                Position = Vector3.new(54, 0.5, -4),
                Size = Vector3.new(30, 1, 30),
                RoomType = DungeonSettings.RoomTypes.Safe
            },
            {
                Id = "Goal",
                Position = Vector3.new(78, 0.5, 104),
                Size = Vector3.new(30, 1, 30),
                RoomType = DungeonSettings.RoomTypes.Goal
            }
        },
        Paths = {
            {"A", "Goal"},
            {"A", "B"},
            {"Start", "A"}
        }
    }]]

    return MapLoader.LoadLevel(1)
end

-- Reload players
function MapService.Client:ReloadPlayers()
    self.Server:ReloadPlayers()
end

return MapService
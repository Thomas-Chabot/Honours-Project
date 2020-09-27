-- Map Service
-- Username
-- August 29, 2020

--[[
    This controls the game layout.
]]


local MapService = {Client = {}}
print("MapService required")

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CheckerboardPieces

function MapService:Start()
    local Objects = ReplicatedStorage:WaitForChild("Objects")
    CheckerboardPieces = {
        Objects:WaitForChild("BlackChecker"),
        Objects:WaitForChild("RedChecker")
    }
end


function MapService:Init()
    self:CacheClientMethod("GetLayout")
    self:RegisterClientEvent("SwapParts")
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
    local layout = { }
    for row = 1,20 do
        layout[row] = { }
        for col = 1,20 do
            local id = "Checker_" .. row .. "_" .. col
            local checkerType = ((row + col) % 2) + 1
            layout[row][col] = {
                Id = id,
                Type = CheckerboardPieces[checkerType]
            }
        end
    end

    return layout
end


return MapService
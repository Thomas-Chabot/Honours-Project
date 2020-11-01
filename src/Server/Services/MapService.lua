-- Map Service
-- Username
-- August 29, 2020

--[[
    This controls the game layout.
]]


local MapService = {Client = {}}
print("MapService required")

local MapLoader
local CurrentLevel

function MapService:Start()
    CurrentLevel = 1
end


function MapService:Init()
    MapLoader = self.Modules.MapLoader
    self:RegisterClientEvent("SwapParts")
end

-- Reloads all players
function MapService:ReloadPlayers()
    for _,p in pairs(game.Players:GetPlayers()) do
        p:LoadCharacter()
    end
end

function MapService:PlayerReachedGoal(player)
    local goalData = MapLoader.GetGoal(CurrentLevel)
    local playerRoot = player.Character and player.Character.PrimaryPart
    if not playerRoot then
        return false
    end

    -- Use a Region3 to detect if the player is standing over the goal 
    local goalPosition = goalData.Position
    local goalSize = goalData.Size
    local min = goalPosition - goalSize/2 - Vector3.new(8,8,8)
    local max = goalPosition + goalSize/2 + Vector3.new(8,8,8)

    local region = Region3.new(Vector3.new(min.X, min.Y, min.Z), Vector3.new(max.X, max.Y + 50, max.Z)):ExpandToGrid(4)
    local results = workspace:FindPartsInRegion3WithWhiteList(region, {playerRoot})
    
    return #results > 0
end

-- Responds to when a player reaches the goal.
-- Verifies that the goal has been reached and moves them to the next level.
function MapService:OnGoalReached(player)
    if not self:PlayerReachedGoal(player) then
        return false
    end

    print("SERVER: The player has reached the goal.")
    CurrentLevel = CurrentLevel + 1
    return true
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
    print("Loading level ", CurrentLevel)
    return MapLoader.LoadLevel(CurrentLevel)
end

-- Reload players
function MapService.Client:ReloadPlayers()
    self.Server:ReloadPlayers()
end

-- Advance to the next level
function MapService.Client:GoalReached(player)
    return self.Server:OnGoalReached(player)
end

return MapService
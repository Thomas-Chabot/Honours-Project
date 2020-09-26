-- Dungeon Master Service
-- Username
-- September 13, 2020

--[[
    This is the server-side code for the dungeon master.
    Every game has one dungeon master, and this is the player
     who can control the layout of the dungeon.
]]


local DungeonMasterService = {Client = {}}
local dungeonMaster

local Players = game:GetService("Players")

-- Starts up the service
function DungeonMasterService:Start()
    if #Players:GetPlayers() == 0 then
        Players.PlayerAdded:Wait()
    end

    dungeonMaster = Players:GetPlayers()[1]
end

-- Initializes the service
function DungeonMasterService:Init()
	self:RegisterClientEvent("DungeonMasterUpdated")
end

-- Retrieves the player who is the dungeon master.
function DungeonMasterService.Client:GetDungeonMaster()
    return dungeonMaster
end

-- Updates the active dungeon master.
function DungeonMasterService:Update(player)
    dungeonMaster = player
    self:FireAllClients("DungeonMasterUpdated", player)
end

return DungeonMasterService
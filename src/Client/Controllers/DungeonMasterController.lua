-- Dungeon Master Controller
-- Username
-- September 13, 2020

--[[
    This script controls the dungeon master.
    A game only has a single dungeon master,
     and this is the player who is allowed to manipulate the dungeons.
    
    It returns a method, IsDungeonMaster(), which can be used to determine
     if the player is the dungeon master. It returns in O(1) constant time.
]]


local DungeonMasterController = {}

local currentDungeonMaster
local player

-- Starts up the controller
function DungeonMasterController:Start()
    player = game.Players.LocalPlayer

    local dungeonMasterService = self.Services.DungeonMasterService

    currentDungeonMaster = dungeonMasterService:GetDungeonMaster()
    dungeonMasterService.DungeonMasterUpdated:Connect(function(...)
        self:OnUpdated(...)
    end)
end

-- Initializes the controller
function DungeonMasterController:Init()
    self:RegisterEvent("DungeonMasterUpdated")
end

-- Retrieves whether the player is the current dungeon master.
-- Returns T/F, runs in O(1).
function DungeonMasterController:IsDungeonMaster()
    return player == currentDungeonMaster
end

-- Reacts to dungeon master updates
function DungeonMasterController:OnUpdated(newDungeonMaster)
    currentDungeonMaster = newDungeonMaster
end

return DungeonMasterController
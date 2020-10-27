-- Spawn Service
-- Username
-- October 27, 2020



local SpawnService = {Client = {}}

local playerPositions = { }

function SpawnService:Start()
	
end


function SpawnService:Init()
    game.Players.PlayerAdded:Connect(function(player)
        self:OnPlayerAdded(player)
    end)
end

function SpawnService:UpdatePosition(player, location)
    playerPositions[player] = location
end

function SpawnService:OnPlayerAdded(player)
    player.CharacterAdded:Connect(function()
        self:OnPlayerRespawned(player)
    end)
end
function SpawnService:OnPlayerRespawned(player)
    if not playerPositions[player] then return end
    
    wait()
    player.Character:MoveTo(playerPositions[player])
end

function SpawnService.Client:SetSpawnLocation(player, location, doInstantUpdate)
    self.Server:UpdatePosition(player, location)
    if doInstantUpdate and player.Character then
        self.Server:OnPlayerRespawned(player)
    end
end

return SpawnService
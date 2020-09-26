-- Swap Service
-- Username
-- September 21, 2020



local SwapService = {Client = {}}


function SwapService:Start()
	
end


function SwapService:Init()
	self:RegisterClientEvent("Swapped")
end

function SwapService.Client:Swap(player, part1, part2)
    print("Swapping ", part1, " and ", part2)
    if not self.Server.Services.DungeonMasterService:IsDungeonMaster(player) then
        return false, "You are not the dungeon master."
    end

    print("Swapped")
    self.Server:FireAllClients("Swapped", part1, part2)
    return true
end

return SwapService
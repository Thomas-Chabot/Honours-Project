-- Server Swap Module
-- Username
-- September 21, 2020

--[[
    This module controls swapping when it is fired from the server.
    It listens for events firing from SwapService, then performs the swap.
    This is only active when the player is not the dungeon master.
]]


local ServerSwapModule = {}

local SwapService, SwapControls, Maid
local maid

function ServerSwapModule:Start()

end
function ServerSwapModule:Init()
    Maid = self.Shared.Maid
    SwapControls = self.Modules.SwapInternal.SwapControls
    SwapService = self.Services.SwapService
end

-- Activates the module. Adds event listeners for the server.
function ServerSwapModule:Activate()
    maid = Maid.new()
    maid:GiveTask(SwapService.Swapped:Connect(function(part1, part2)
        local p1 = workspace:FindFirstChild(part1)
        local p2 = workspace:FindFirstChild(part2)

        SwapControls.Swap(p1, p2)
        print(part1, part2, " swapped")
    end))
end

-- Deactives the module. Cleans up all events.
function ServerSwapModule:Deactivate()
    if not maid then
        return
    end

    maid:DoCleaning()
    maid = nil
end

return ServerSwapModule
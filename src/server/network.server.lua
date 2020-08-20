--[[
    Serves as a placeholder for now. Gives network ownership of all "Swappable" parts
    to the player.
]]

local CollectionService = game:GetService("CollectionService")
function giveOwnership(instance, player)
    instance:SetNetworkOwner(player)
end

local player = game.Players.PlayerAdded:Wait()
for _,obj in pairs(CollectionService:GetTagged("Swappable")) do
    giveOwnership(obj, player)
end
CollectionService:GetInstanceAddedSignal("Swappable"):Connect(function(instance)
    giveOwnership(instance, player)
end)
CollectionService:GetInstanceRemovedSignal("Swappable"):Connect(function(instance)
    giveOwnership(instance, nil)
end)
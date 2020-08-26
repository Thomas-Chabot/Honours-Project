--[[
    Serves as a placeholder for now. Gives network ownership of all "Swappable" parts
    to the player.
]]

local CollectionService = game:GetService("CollectionService")
function giveOwnership(instance, player)
    pcall(function() 
        instance:SetNetworkOwner(player) 
    end)
end

local player = game.Players.PlayerAdded:Wait()
for _,obj in pairs(CollectionService:GetTagged("CanSwap")) do
    giveOwnership(obj, player)
end
CollectionService:GetInstanceAddedSignal("CanSwap"):Connect(function(instance)
    giveOwnership(instance, player)
end)
CollectionService:GetInstanceRemovedSignal("CanSwap"):Connect(function(instance)
    giveOwnership(instance, nil)
end)
for _,part in pairs(workspace:GetDescendants()) do
    if part:IsA("BasePart") and not part.Anchored then
        print(part.Name)
        giveOwnership(part, player)
    end
end
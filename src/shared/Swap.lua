--[[
    Controls the Swap animation. When the player has selected two parts to swap,
     the two parts will swap places.
]]

local Swap = { }
local currentParts = { }

local CollectionService = game:GetService("CollectionService")
local SwappableTag = "Swappable"

local WorldHeight = 7

local function waitForReachedTarget(part, target)
    local result = Instance.new("BindableEvent")
    spawn(function()
        repeat
            wait(0.1)
        until (part.Position - target).magnitude < 0.5

        result:Fire()
    end)

    return result.Event
end
local function float(part, waitForResult)
    local bodyPosition = Instance.new("BodyPosition")
    local bodyGyro = Instance.new("BodyGyro")

    local force = part:GetMass() * 500
    bodyPosition.MaxForce = Vector3.new(force, force, force)
    bodyGyro.MaxTorque = Vector3.new(9e9, 9e9, 9e9)

    bodyGyro.CFrame = part.CFrame
    bodyPosition.Position = part.Position + Vector3.new(0, WorldHeight, 0)
    
    part.CanCollide = false
    bodyGyro.Parent = part
    bodyPosition.Parent = part

    -- Note: Because this will spawn up a background thread,
    --  only wait on the part to reach if we need to; otherwise just exit silently
    if waitForResult then
        return waitForReachedTarget(part, bodyPosition.Position)
    end
end
local function swapPositions(part1, part2)
   local bp1 = part1:FindFirstChildOfClass("BodyPosition")
   local bp2 = part2:FindFirstChildOfClass("BodyPosition")
   
   bp1.Position = Vector3.new(part2.Position.X, part1.Position.Y, part2.Position.Z)
   bp2.Position = Vector3.new(part1.Position.X, part2.Position.Y, part1.Position.Z)

   return waitForReachedTarget(part2, bp2.Position)
end
local function fall(part, waitForResult)
    local bp = part:FindFirstChildOfClass("BodyPosition")
    bp.Position = bp.Position - Vector3.new(0, WorldHeight, 0)

    if waitForResult then
        return waitForReachedTarget(part, bp.Position)
    end
end
function Swap.AddPart(part)
    if not CollectionService:HasTag(part, SwappableTag) or #currentParts >= 2 then
        return
    end

    -- Add the item to our swap table
    local currentPos = table.find(currentParts, part)
    if currentPos then
        table.remove(currentParts, currentPos)
    else
        table.insert(currentParts, part)
    end
    print("Added ", part)

    -- If we have two, then we want to perform the swap
    if #currentParts == 2 then
        -- Float the part
        float(part, true):Wait()
        swapPositions(currentParts[1], currentParts[2]):Wait()
        fall(currentParts[1], false)
        fall(currentParts[2], true):Wait()

        currentParts[1].CanCollide = true
        currentParts[2].CanCollide = true
        currentParts[1]:FindFirstChildOfClass("BodyPosition"):Destroy()
        currentParts[2]:FindFirstChildOfClass("BodyPosition"):Destroy()

        currentParts = { }
    elseif currentPos then
        fall(part, true):Wait()
        part.CanCollide = true
        part:FindFirstChildOfClass("BodyPosition"):Destroy()
    else
        float(part, false)
    end
end

return Swap
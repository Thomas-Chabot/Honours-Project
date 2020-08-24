--[[
    Controls the Swap animation. When the player has selected two parts to swap,
     the two parts will swap places.
]]

local Swap = { }
local currentParts = { }

-- Game Services
local CollectionService = game:GetService("CollectionService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Game Structure
local Util = ReplicatedStorage:WaitForChild("Util")
local Source = ReplicatedStorage:WaitForChild("Source")

-- Dependencies
local Promise = require(Util:WaitForChild("Promise"))
local Signal = require(Util:WaitForChild("Signal"))
local BodyPosition = require(Source:WaitForChild("BodyPosition"))

-- Constants
local SwappableTag = "Swappable"
local WorldHeight = 7

-- Events
Swap.Events = {
    SwapStarted = Signal.new(),
    SwapCompleted = Signal.new()
}

-- Animations
-- Animates a drop. The drop method drops a part back to the ground.
-- @tparam part BasePart A part to drop.
-- @treturns Promise A promise that resolves once the part has reached the ground.
local function animateDrop(part)
    local bodyPosition = BodyPosition.GetOrCreate(part)
    local currentPosition = bodyPosition.Position
    local startPosition = bodyPosition:GetDefaultPosition()

    return bodyPosition:MoveTo(Vector3.new(currentPosition.X, startPosition.Y, currentPosition.Z))
end

-- Animates a swap. This takes two parts and swaps the positions of each,
--  such that part1 will be where part2 was, and part2 will be where part1 was.
-- @tparam part1 BasePart The first part to swap with
-- @tparam part2 BasePart The second part to swap with
-- @treturns Promise A Promise that will resolve once both parts have reached their targets.
local function animateSwap(part1, part2)
    local bp1 = BodyPosition.GetOrCreate(part1)
    local bp2 = BodyPosition.GetOrCreate(part2)

    local pos1 = bp1.Position
    local pos2 = bp2.Position

    return Promise.all({
        bp1:MoveTo(Vector3.new(pos2.X, pos1.Y, pos2.Z)),
        bp2:MoveTo(Vector3.new(pos1.X, pos2.Y, pos1.Z))
    })
end

-- Animates a float. The float method brings a part into the air.
-- @tparam part BasePart The part that we want to raise into the air
-- @tresult Promise A Promise that will resolve once the part reaches the target (i.e. is floating)
local function animateFloat(part)
    local bodyPosition = BodyPosition.GetOrCreate(part)
    return bodyPosition:MoveTo(bodyPosition:GetDefaultPosition() + Vector3.new(0,WorldHeight,0))
end

-- Connects the part to adjoining parts so that everything will move together.
-- This currently connects it only to Player objects, but we may want to change that.
-- @tparam part BasePart The part we want to connect it in with
local function connectParts(part)
    local min = part.Position - part.Size/2
    local max = part.Position + part.Size/2
    local region = Region3.new(Vector3.new(min.X, part.Position.Y - 20, min.Z), Vector3.new(max.X, part.Position.Y + 20, max.Z))
    local connected = workspace:FindPartsInRegion3(region, part)

    for _,connectedPart in pairs(connected) do
        if not connectedPart.Parent or connectedPart.Locked then 
            continue
        end

        local humanoid = connectedPart.Parent:FindFirstChild("Humanoid")
        local primary = humanoid and connectedPart.Parent.PrimaryPart
        local target = humanoid and primary or connectedPart
        if target:FindFirstChild("Connected") then
            continue
        end

        if humanoid then
            local weld = Instance.new("WeldConstraint")
            weld.Part0 = part
            weld.Part1 = target
            weld.Parent = part
        end

        local val = Instance.new("BoolValue")
        val.Name = "Connected"
        val.Parent = target

        local canCollide = Instance.new("BoolValue")
        canCollide.Name = "CanCollide"
        canCollide.Value = target.CanCollide
        canCollide.Parent = target

        local anchored = Instance.new("BoolValue")
        anchored.Name = "Anchored"
        anchored.Value = target.Anchored
        anchored.Parent = target

        target.CanCollide = false
        target.Anchored = false
    end
end

-- Removes all WeldConstraints connected to the part.
-- @tparam part BasePart The part that we want to remove connections from
local function removeConnections(part)
    for _,weld in pairs(part:GetChildren()) do
        if weld:IsA("WeldConstraint") then
            local p = weld.Part1
            if p and p:FindFirstChild("Connected") then
                local canCollide = p:FindFirstChild("CanCollide")
                local anchored = p:FindFirstChild("Anchored")

                p.CanCollide = canCollide.Value
                p.Anchored = anchored.Value

                p.Connected:Destroy()
                canCollide:Destroy()
                anchored:Destroy()
            end

            if p.Parent and p.Parent:FindFirstChild("Humanoid") then
                weld:Destroy()
            end
        end
    end
end

-- Removes a part. This performs all cleanup related to the removal of the part.
-- @tparam part BasePart The part we want to clean up
local function removePart(part)
    local partIndex = table.find(currentParts, part)

    -- cleans up the changes made to the part.
    -- runs as a function so that we can variably call it once other things are done
    local function performCleanup()
        -- Remove the BodyPosition
        local bodyPos = BodyPosition.Get(part)
        if bodyPos then
            bodyPos:Destroy()
        end

        -- Remove connections
        removeConnections(part)
    end

    -- If the part is in the air, remove it
    if partIndex then
        -- Drop it to the ground
        animateDrop(part):andThen(function()
            part.CanCollide = true

            -- Clean up
            performCleanup()
        end)

        -- Remove it from our list of swapping parts
        table.remove(currentParts, partIndex)
    else
        -- Clean up, since we don't need to animate anything
        performCleanup()
    end
end

-- Adds a Part into the list of parts that we're swapping with.
-- If the part is already added into the list, it will instead be removed.
-- This also animates the part movement, either bringing it into the air or dropping it to the ground.
-- @tparam part BasePart The Part that we want to add into our swapping list
function Swap.AddPart(part)
    -- If this part can't be swapped, or if we're already running a swap operation, exit out
    if not CollectionService:HasTag(part, SwappableTag) or #currentParts >= 2 then
        return
    end

    -- Check if the part already exists within our swapping table
    local currentPos = table.find(currentParts, part)

    -- If it's already in the table: Remove it;
    -- Otherwise add it
    if currentPos then
        table.remove(currentParts, currentPos)
    else
        table.insert(currentParts, part)
        connectParts(part)
    end

    -- Turn off collisions for the part -- this prevents it from getting stuck on anything
    part.CanCollide = false

    -- If we have two, then we want to perform the swap
    if #currentParts == 2 then
        -- Fire the SwapStarted event
        Swap.Events.SwapStarted:Fire()

        -- Float the part
        animateFloat(part)
            :andThen(function()
                -- Swap the first part & the second part
                return animateSwap(currentParts[1], currentParts[2])
            end)
            :andThen(function()
                -- Drop both parts back to the ground
                return Promise.all({
                    animateDrop(currentParts[1]),
                    animateDrop(currentParts[2])
                })
            end):andThen(function()
                -- Reset everything
                -- Both parts should now turn collisions back on
                currentParts[1].CanCollide = true
                currentParts[2].CanCollide = true

                removeConnections(currentParts[1])
                removeConnections(currentParts[2])

                -- Remove the BodyPositions from each part
                BodyPosition.Get(currentParts[1]):Destroy()
                BodyPosition.Get(currentParts[2]):Destroy()

                -- Reset the list of swapping parts
                currentParts = { }

                -- Fire the SwapCompleted event
                Swap.Events.SwapCompleted:Fire()
            end)
    elseif currentPos then
        -- If it's already in our list, drop it back to the ground
        animateDrop(part):andThen(function()
            part.CanCollide = true
            removeConnections(part)
        end)
    else
        -- Otherwise we're adding it into our list, so bring it into the air
        animateFloat(part)
    end
end

-- Checks if parts are currently being swapped.
-- @treturn bool True if a swap is currently being run.
function Swap.IsSwapping()
    return #currentParts >= 1
end

-- When a part is removed from the Swappable list, clean it up
CollectionService:GetInstanceRemovedSignal(SwappableTag):Connect(function(part)
    if Swap.IsSwapping() then return end
    removePart(part)
end)

return Swap
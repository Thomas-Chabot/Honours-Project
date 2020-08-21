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

-- Removes a part. This performs all cleanup related to the removal of the part.
-- @tparam part BasePart The part we want to clean up
local function removePart(part)
    local partIndex = table.find(currentParts, part)

    -- cleans up the BodyPosition object.
    -- runs as a function so that we can variably call it once other things are done
    local function cleanupBodyPosition()
        local bodyPos = BodyPosition.Get(part)
        if bodyPos then
            bodyPos:Destroy()
        end
    end


    -- If the part is in the air, remove it
    if partIndex then
        -- Drop it to the ground
        animateDrop(part):andThen(function()
            part.CanCollide = true

            -- Clean up the BodyPosition
            cleanupBodyPosition()
        end)

        -- Remove it from our list of swapping parts
        table.remove(currentParts, partIndex)
    else
        -- Clean up the BodyPosition, since we don't need to animate anything
        cleanupBodyPosition()
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
        end)
    else
        -- Otherwise we're adding it into our list, so bring it into the air
        animateFloat(part)
    end
end

-- Checks if parts are currently being swapped.
-- @treturn bool True if a swap is currently being run.
function Swap.IsSwapping()
    return #currentParts >= 2
end

-- When a part is removed from the Swappable list, clean it up
CollectionService:GetInstanceRemovedSignal(SwappableTag):Connect(function(part)
    if Swap.IsSwapping() then return end
    removePart(part)
end)

return Swap
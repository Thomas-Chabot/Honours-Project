local BodyPosition = { }
BodyPosition.__index = BodyPosition

-- Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Util = ReplicatedStorage:WaitForChild("Util")

-- Dependencies
local Promise = require(Util:WaitForChild("Promise"))

-- Constants
local ForceMultiplier = 500
local Instances = { }

-- Sets up a BodyPosition for the given part.
-- Assigns it a MaxForce according to its mass * ForceMultiplier, sets it to its current position,
-- then returns the new body position.
-- @tparam part BasePart The part we want to assign the BodyPosition to
-- @treturn BodyPosition The new BodyPosition instance that we created
local function setupBodyPosition(part)
    local bodyPosition = part:FindFirstChildOfClass("BodyPosition") or Instance.new("BodyPosition")
    local mass = part:GetMass()

    bodyPosition.MaxForce = Vector3.new(mass, mass, mass) * ForceMultiplier
    bodyPosition.Position = part.Position
    bodyPosition.Parent = part

    return bodyPosition
end

-- Constructor
-- Creates a BodyPosition for the given part
function BodyPosition.new(part)
    local bodyPosition = setupBodyPosition(part)
    local self = setmetatable({
        Position = part.Position,

        _part = part,
        _defaultPosition = part.Position,
        _bodyPosition = bodyPosition,

        _currentPromise = nil,
    }, BodyPosition)

    Instances[part] = self
    return self
end

-- Getter. Returns a BodyPosition attached to a Part if one already exists.
-- If one does not exist, returns nil.
function BodyPosition.Get(part)
    return Instances[part]
end

-- Getter. Finds a BodyPosition attached to a Part,
-- or creates a new one if one does not already exist.
function BodyPosition.GetOrCreate(part)
    if Instances[part] then
        return Instances[part]
    end

    return BodyPosition.new(part)
end

-- Returns the default position for the part.
-- This is the position the part was in when the BodyPosition was created.
function BodyPosition:GetDefaultPosition()
    return self._defaultPosition
end

-- Moves the BodyPosition to a destination.
function BodyPosition:MoveTo(position)
    -- If we're already waiting on a movement to complete, cancel that
    if self._currentPromise ~= nil then
        self._currentPromise:cancel()
    end

    -- Set up a new promise that'll return a result when the movement completes
    local promise = Promise.new(function(resolve, _, onCancel)
        local part = self._part
        self._bodyPosition.Position = position
        self.Position = position

        -- Hook up a variable to listen for it to cancel
        local cancelled = false
        onCancel(function()
            cancelled = true
        end)

        -- Wait until we reach the target
        repeat
            wait(0.1)
        until cancelled or (part.Position - position).magnitude < 0.5

        -- Clean up the current promise, if we don't have a new one
        if not cancelled then
            self._currentPromise = nil
        end

        -- Exit out
        resolve()
    end)

    -- Store our current promise, and return that to the caller
    -- so they can wait for the movement to complete
    self._currentPromise = promise
    return promise
end

-- Cleans up the BodyPosition object & all associated instances.
function BodyPosition:Destroy()
    self._bodyPosition:Destroy()
    Instances[self._part] = nil
end

return BodyPosition
local AlignPosition = { }
AlignPosition.__index = AlignPosition

-- Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Util = ReplicatedStorage:WaitForChild("Util")

-- Dependencies
local Promise = require(Util:WaitForChild("Promise"))

-- Constants
local Instances = { }

-- Sets up a BodyPosition for the given part.
-- Assigns it a MaxForce according to its mass * ForceMultiplier, sets it to its current position,
-- then returns the new body position.
-- @tparam part BasePart The part we want to assign the BodyPosition to
-- @treturn BodyPosition The new BodyPosition instance that we created
local function setupBodyPosition(part)
    local mass = part:GetMass()
    local alignPosition = part:FindFirstChildOfClass("AlignPosition") or Instance.new("AlignPosition")

    local targetPart = Instance.new("Part")
    targetPart.CanCollide = false
    targetPart.Anchored = true
    targetPart.Locked = true
    targetPart.Transparency = 1
    targetPart.Position = part.Position
    targetPart.Parent = workspace

    local attachment0 = Instance.new("Attachment")
    attachment0.Parent = part

    local attachment1 = Instance.new("Attachment")
    attachment1.Parent = targetPart

    alignPosition.Attachment0 = attachment0
    alignPosition.Attachment1 = attachment1
    alignPosition.RigidityEnabled = false
    alignPosition.MaxForce = 9e9
    alignPosition.MaxVelocity = 30
    alignPosition.Responsiveness = 10

    alignPosition.Parent = part

    part.Anchored = false

    return alignPosition
end

-- Constructor
-- Creates a BodyPosition for the given part
function AlignPosition.new(part)
    local alignPosition = setupBodyPosition(part)
    local self = setmetatable({
        Position = part.Position,

        _part = part,
        _defaultPosition = part.Position,
        _alignPosition = alignPosition,

        _currentPromise = nil,
    }, AlignPosition)

    Instances[part] = self
    return self
end

-- Getter. Returns a BodyPosition attached to a Part if one already exists.
-- If one does not exist, returns nil.
function AlignPosition.Get(part)
    return Instances[part]
end

-- Getter. Finds a BodyPosition attached to a Part,
-- or creates a new one if one does not already exist.
function AlignPosition.GetOrCreate(part)
    if Instances[part] then
        return Instances[part]
    end

    return AlignPosition.new(part)
end

-- Returns the default position for the part.
-- This is the position the part was in when the BodyPosition was created.
function AlignPosition:GetDefaultPosition()
    return self._defaultPosition
end

-- Moves the BodyPosition to a destination.
function AlignPosition:MoveTo(position)
    -- If we're already waiting on a movement to complete, cancel that
    if self._currentPromise ~= nil then
        self._currentPromise:cancel()
    end

    -- Set up a new promise that'll return a result when the movement completes
    local promise = Promise.new(function(resolve, _, onCancel)
        local part = self._part
        -- set position
        self._alignPosition.Attachment1.Parent.Position = position

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
function AlignPosition:Destroy()
    self._part.Anchored = true

    self._alignPosition.Attachment0:Destroy()
    self._alignPosition.Attachment1.Parent:Destroy()
    self._alignPosition.Attachment1:Destroy()
    self._alignPosition:Destroy()

    Instances[self._part] = nil
end

return AlignPosition
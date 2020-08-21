--[[
    This script controls colouring the mouse's target as a way of
    signaling that the part can be clicked on.
]]
local Recolor = { }

-- Game Services
local CollectionService = game:GetService("CollectionService")

-- Constants
local TargetColor = BrickColor.Blue()
local ColorableTag = "Swappable"

-- Global Variables
local currentTarget = { }
local isEnabled = true

-- Resets an existing target. This will change it back to how it was
-- before it was colored.
local function ResetTarget()
    if not currentTarget.Target then return end
    
    local target = currentTarget.Target
    target.BrickColor = currentTarget.Color

    if target:IsA("UnionOperation") then
        target.UsePartColor = currentTarget.UsesPartColor
    end

    currentTarget.Target = nil
end

-- Sets the Target for recoloring.
-- If we have an existing target, it'll be reset to its original colour;
-- The new target will be recoloured according to our settings.
function Recolor.SetTarget(target)
    -- If the system is disabled, don't do anything
    if not isEnabled then return end

    -- reset the target if we're now moving to a different one
    if target ~= currentTarget.Target then
        ResetTarget()
    end

    -- exit conditions: no target OR same target OR target is not colorable
    if not target or target == currentTarget.Target or not CollectionService:HasTag(target, ColorableTag) then
        return
    end

    -- store the part data
    local usesPartColor = target:IsA("UnionOperation") and target.UsePartColor or false
    currentTarget = {
        Target = target,
        Color = target.BrickColor,
        UsesPartColor = usesPartColor
    }

    -- change color
    target.BrickColor = TargetColor

    -- if it's a union, we want to make sure it becomes colored
    if target:IsA("UnionOperation") then
        target.UsePartColor = true
    end
end

-- Enables the Recolor system, allowing objects to be colored/highlighted.
function Recolor.Enable()
    isEnabled = true
end

-- Disables the Recolor system.
-- Any active coloring will be removed & parts will not be highlighted.
function Recolor.Disable()
    isEnabled = false
    ResetTarget()
end

-- Hook in events

-- When an object loses the "Swappable" tag, we want to make sure it's not colored
CollectionService:GetInstanceRemovedSignal(ColorableTag):Connect(function(instance)
    if currentTarget.Target == instance then
        ResetTarget()
    end
end)

-- Return the SetTarget method
return Recolor
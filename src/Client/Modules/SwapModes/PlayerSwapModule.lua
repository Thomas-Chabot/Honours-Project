-- Player Swap
-- Username
-- September 21, 2020

--[[
    This swap module controls swapping when the player is the dungeon master,
     and is able to make swaps themselves.
    In this case, swaps are made based on user input - dragging, etc.
]]


local PlayerSwapModule = {}

local CollectionService = game:GetService("CollectionService")
local RunService = game:GetService("RunService")

local Maid, Input, Mouse, Recolor, SwapService, SwapControls, DungeonSettings
local maid

local BasePart, ClonedPart

local RaycastData
local SwappableObjectsFolder

-- Retrieves a part that the mouse is currently sitting over, if one exists.
local function GetTarget()
    local targetData = Mouse:Raycast(RaycastData)
    local targ = targetData and targetData.Instance
    if not targ or not CollectionService:HasTag(targ, "Swappable") then
        return nil 
    end

    return targ
end

-- Makes a clone of a part. Returns the cloned part
local function Clone(part)
    local clone = part:Clone()
    clone.CanCollide = false
    clone.Name = part.Name .. "Clone"
    clone.Parent = workspace

    return clone
end

-- Starts up the module -- set up some constants
function PlayerSwapModule:Start()
    SwappableObjectsFolder = workspace:WaitForChild("Swappables")

    RaycastData = RaycastParams.new()
    RaycastData.FilterType = Enum.RaycastFilterType.Whitelist
    RaycastData.FilterDescendantsInstances = {SwappableObjectsFolder}
end

-- Loads dependencies
function PlayerSwapModule:Init()
    Maid = self.Shared.Maid
    Input = self.Controllers.UserInput
    Recolor = self.Modules.Recolor
    SwapControls = self.Modules.SwapInternal.SwapControls
    SwapService = self.Services.SwapService
    DungeonSettings = self.Shared.DungeonSettings

    self.Swapped = self.Shared.Signal.new()
end

-- Activates the player swap module, hooks up events
function PlayerSwapModule:Activate()
    Mouse = Input:Get("Mouse")
    maid = Maid.new()
    maid:GiveTask(Mouse.LeftDown:Connect(function()
        self:Pickup(GetTarget())
    end))
    maid:GiveTask(Mouse.LeftUp:Connect(function()
        self:Release()
    end))
    maid:GiveTask(RunService.RenderStepped:Connect(function()
        self:Update()
    end))
    maid:GiveTask(function()
        self:Cleanup()
    end)
end

-- Deactivates the player swap module, runs cleanup
function PlayerSwapModule:Deactivate()
    if maid then
        maid:DoCleaning()
        maid = nil 
    end
end

-- Updates the game with every frame - colors & clonedpart position
function PlayerSwapModule:Update()
    -- If we have a cloned part, move it around
    if ClonedPart then
        local ray = Mouse:GetRay(1)
        local targetHeight = DungeonSettings.WallHeight + 4

        -- Determines the position to set the part so that it follows the mouse & sticks at a given height
        ClonedPart.Position = ray.Origin + ray.Direction.unit * ((ray.Origin.Y - targetHeight)/math.abs(ray.Direction.unit.Y))
    end
    
    -- Update color of the part that the mouse is sitting over
    Recolor.SetTarget(GetTarget())
end

-- Picks up a part so that a player can move it around.
function PlayerSwapModule:Pickup(part)
    -- Don't do anything if we have no part
    if not part then
        return
    end

    -- If we're already moving a part, run cleanup & swap
    if ClonedPart then
        self:Cleanup()
    end

    -- Set up the swap movement
    BasePart = part
    ClonedPart = Clone(part)

    --BasePart.Transparency = 0.7
    BasePart.Material = Enum.Material.ForceField
    local decal = ClonedPart:FindFirstChildOfClass("Decal") 
    if decal then
        ClonedPart.Transparency = Recolor.GetTransparency()
        decal.Transparency = 0.2
    else
        ClonedPart.Transparency = 0.2
    end
    ClonedPart.BrickColor = Recolor.GetColor()
end

-- Releases a part, swapping it if the player is over another part.
function PlayerSwapModule:Release()
    -- Do nothing if we're not already running a swap
    if not ClonedPart then return end

    -- Clean up the cloned part
    ClonedPart:Destroy()

    -- Check if we're releasing over another part - if we are we want to swap
    local releasedOver = GetTarget()
    if BasePart and releasedOver and BasePart ~= releasedOver then
        -- Do the swap
        SwapControls.Swap(BasePart, releasedOver)
        
        local basePart = BasePart
        self:Cleanup()

        -- Feed the swap through to the server
        -- If the server returns false, it means the movement is invalid & has to be reversed
        self.Swapped:Fire(basePart, releasedOver)
        local valid = SwapService:Swap(basePart.Name, releasedOver.Name)
        if not valid then
            -- Swap the BasePart and releasedOver parts back -- reversing the swap
            SwapControls.Swap(basePart, releasedOver)

            -- TODO: Would want to report an error here
        end
    end
end

-- Cleans up parts data & resets active parts
function PlayerSwapModule:Cleanup()
    -- If we have a base part, reset transparency & do data cleanup
    if BasePart then
        --BasePart.Transparency = 0
        BasePart.Material = Enum.Material.Plastic
        BasePart = nil
    end
    
    -- Remove the clone if we have one
    if ClonedPart then
        ClonedPart:Destroy()
    end
end



return PlayerSwapModule
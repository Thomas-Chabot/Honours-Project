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

local Maid, Input, Mouse, Recolor, SwapService, SwapControls
local maid

local BasePart, ClonedPart

local RaycastData
local IgnoredObjectsFolder

local function GetTarget()
    local targetData = Mouse:Raycast(RaycastData)
    local targ = targetData and targetData.Instance
    if not targ or not CollectionService:HasTag(targ, "Swappable") then
        return nil 
    end

    return targ
end

local function Clone(part)
    local clone = part:Clone()
    clone.Name = part.Name .. "Clone"
    clone.Parent = IgnoredObjectsFolder

    return clone
end

function PlayerSwapModule:Start()    
    IgnoredObjectsFolder = Instance.new("Folder")
    IgnoredObjectsFolder.Parent = workspace

    RaycastData = RaycastParams.new()
    RaycastData.FilterType = Enum.RaycastFilterType.Blacklist
    RaycastData.FilterDescendantsInstances = {IgnoredObjectsFolder}
end

function PlayerSwapModule:Init()
    Maid = self.Shared.Maid
    Input = self.Controllers.UserInput
    Recolor = self.Modules.Recolor
    SwapControls = self.Modules.SwapInternal.SwapControls
    SwapService = self.Services.SwapService
end

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
end

function PlayerSwapModule:Deactivate()
    if maid then
        maid:DoCleaning()
        maid = nil 
    end
end


function PlayerSwapModule:Update()
    if ClonedPart then
        local ray = Mouse:GetRay(1)
        ClonedPart.Position = ray.Origin + ray.Direction.unit * 75
    end
    
    Recolor.SetTarget(GetTarget())
end

function PlayerSwapModule:Pickup(part)
    if ClonedPart then
        self:Release()
    end

    BasePart = part
    ClonedPart = Clone(part)

    BasePart.Transparency = 0.7
    ClonedPart.Transparency = 0.2
    ClonedPart.BrickColor = Recolor.GetColor()
end
function PlayerSwapModule:Release()
    if not ClonedPart then return end
    ClonedPart:Destroy()

    local releasedOver = GetTarget()
    if BasePart and releasedOver then
        SwapControls.Swap(BasePart, releasedOver)
        
        local valid = SwapService:Swap(BasePart.Name, releasedOver.Name)
        if not valid then
            SwapControls.Swap(BasePart, releasedOver)
        end
    end

    if BasePart then
        BasePart.Transparency = 0
        BasePart = nil
    end
end



return PlayerSwapModule
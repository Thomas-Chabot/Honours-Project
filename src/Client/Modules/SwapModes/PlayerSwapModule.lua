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

local Maid, Input, Mouse, Recolor, SwapService
local maid
local TargetPart

local RaycastData
local IgnoredObjectsFolder

local StartPosition

local function GetTarget()
    local targetData = Mouse:Raycast(RaycastData)
    local targ = targetData and targetData.Instance
    if not targ or not CollectionService:HasTag(targ, "Swappable") then
        return nil 
    end

    return targ
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
    if TargetPart then
        local ray = Mouse:GetRay(1)
        TargetPart.Position = ray.Origin + ray.Direction.unit * 75
    end
    
    Recolor.SetTarget(GetTarget())
end

function PlayerSwapModule:Pickup(part)
    if TargetPart then
        self:Release()
    end

    StartPosition = part.Position
    TargetPart = part
    part.Transparency = 0.2
    part.Parent = IgnoredObjectsFolder
end
function PlayerSwapModule:Release()
    if not TargetPart then return end
    
    local releasedOver = GetTarget()
    if releasedOver then
        TargetPart.Position = releasedOver.Position
        releasedOver.Position = StartPosition
    else
        TargetPart.Position = StartPosition
    end
    TargetPart.Transparency = 0 
    TargetPart.Parent = workspace

    local p = TargetPart
    TargetPart = nil

    local valid = SwapService:Swap(p.Name, releasedOver.Name)
    if not valid then
        self:Reverse(p, releasedOver)
    end
end
function PlayerSwapModule:Reverse(p1, p2)
    local p = p1.Position
    p1.Position = p2.Position
    p2.Position = p
end



return PlayerSwapModule
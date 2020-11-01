-- Swap Controller
-- Username
-- August 30, 2020

--[[
    This controls the swapping of two parts.
    When a player mouses over a part, that part becomes selected,
    and can be dragged around.
]]

--[[
local SwapController = {}

local CollectionService = game:GetService("CollectionService")

local Input
local Recolor
local Mouse

local Camera
local TargetPart
local StartPosition

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

function SwapController:Start()
    IgnoredObjectsFolder = Instance.new("Folder")
    IgnoredObjectsFolder.Parent = workspace

    RaycastData = RaycastParams.new()
    RaycastData.FilterType = Enum.RaycastFilterType.Blacklist
    RaycastData.FilterDescendantsInstances = {IgnoredObjectsFolder}

    Mouse = Input:Get("Mouse")
    Mouse.LeftDown:Connect(function()
        self:Pickup(GetTarget())
    end)
    Mouse.LeftUp:Connect(function()
        self:Release()
    end)

    game:GetService("RunService").RenderStepped:Connect(function()
        self:Update()
    end)

    Camera = workspace.CurrentCamera
end


function SwapController:Init()
    Input = self.Controllers.UserInput
    Recolor = self.Modules.Recolor
end

function SwapController:IsSwapping()
    return TargetPart ~= nil
end

function SwapController:Update()
    if TargetPart then
        local ray = Mouse:GetRay(1)
        TargetPart.Position = ray.Origin + ray.Direction.unit * 75
    end
    
    Recolor.SetTarget(GetTarget())
end

function SwapController:Pickup(part)
    if TargetPart then
        self:Release()
    end

    StartPosition = part.Position
    TargetPart = part
    part.Transparency = 0.2
    part.Parent = IgnoredObjectsFolder
end
function SwapController:Release()
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

    local valid = self.Services.SwapService:Swap(p.Name, releasedOver.Name)
    if not valid then
        self:Reverse(p, releasedOver)
    end
end
function SwapController:Reverse(p1, p2)
    local p = p1.Position
    p1.Position = p2.Position
    p2.Position = p
end

return SwapController
]]

local SwapController = { }
local swapModule

function SwapController:Start()
    if self.Controllers.DungeonMasterController:IsDungeonMaster() then
        swapModule = self.Modules.SwapModes.PlayerSwapModule
    else
        swapModule = self.Modules.SwapModes.ServerSwapModule
    end
    swapModule:Activate()

    -- Listen for swap event
    swapModule.Swapped:Connect(function(part1, part2)
        self.Swapped:Fire(part1, part2)
    end)
end

function SwapController:Init()
    self.Swapped = self.Shared.Signal.new()
end

function SwapController:Refresh()
    swapModule:Refresh()
end

return SwapController
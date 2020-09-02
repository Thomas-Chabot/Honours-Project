-- Swap Controller
-- Username
-- August 30, 2020

--[[
    This controls the swapping of two parts.
    When a player mouses over a part, that part becomes selected,
    and can be dragged around.
]]


local SwapController = {}

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
    return targetData and targetData.Instance
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
    local releasedOver = GetTarget()
    if releasedOver then
        TargetPart.Position = releasedOver.Position
        releasedOver.Position = StartPosition
    else
        TargetPart.Position = StartPosition
    end
    TargetPart.Transparency = 0 
    TargetPart.Parent = workspace
    TargetPart = nil
end


return SwapController
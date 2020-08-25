local BodyGyro = { }
BodyGyro.__index = BodyGyro

local Instances = { }
local function setupBodyGyro(part)
    local bodyGyro = Instance.new("BodyGyro")
    bodyGyro.MaxTorque = Vector3.new(9e9,9e9,9e9)
    bodyGyro.CFrame = part.CFrame
    bodyGyro.Parent = part

    return bodyGyro
end
function BodyGyro.Create(part)
    local self = setmetatable({
        _part = part,
        _bodyGyro = setupBodyGyro(part)
    }, BodyGyro)

    if Instances[self] then
        -- should store both but because it's a prototype we'll just send a warning here
        warn("Creating a second copy of BodyGyro is not advised")
    end
    
    Instances[part] = self
    return self
end
function BodyGyro.Get(part)
    return Instances[part]
end
function BodyGyro.GetOrCreate(part)
    local existing = Instances[part]
    if existing then
        return existing
    end

    return BodyGyro.Create(part)
end

function BodyGyro:Destroy()
    self._bodyGyro:Destroy()
    Instances[self._part] = nil
end

return BodyGyro
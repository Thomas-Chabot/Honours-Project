-- Map Controller
-- Username
-- August 29, 2020

--[[
    This controls the client side of the map.
    This gets data from the MapService and builds out the map.
]]



local MapController = {}
local CheckerboardPieces = { }
local ReplicatedStorage = game:GetService("ReplicatedStorage")

function MapController:Start()
    local Objects = ReplicatedStorage:WaitForChild("Objects")
    CheckerboardPieces = {
        Objects:WaitForChild("BlackChecker"),
        Objects:WaitForChild("RedChecker")
    }

	self:Build()
end


function MapController:Init()

end

function MapController:Build()
    repeat
        wait()
    until self.Services.MapService
    local data = self.Services.MapService:GetLayout()
    for rowIndex, row in ipairs(data) do
        for colIndex, element in ipairs(row) do
            local obj = CheckerboardPieces[element]:Clone()
            obj.Position = Vector3.new((rowIndex - 1) * 20, 0, (colIndex - 1) * 20)
            obj.Anchored = true
            obj.Parent = workspace
        end
    end
end


return MapController
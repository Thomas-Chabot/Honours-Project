local player = game.Players.LocalPlayer

local function getConnectedParts(part)
    local results = { }

    local min = part.Position - part.Size/2
    local max = part.Position + part.Size/2
    local region = Region3.new(Vector3.new(min.X, part.Position.Y - 20, min.Z), Vector3.new(max.X, part.Position.Y + 20, max.Z))
    local connected = workspace:FindPartsInRegion3(region, part)

    for _,connectedPart in pairs(connected) do
        if not connectedPart.Parent or connectedPart.Locked then 
            continue
        end

        local humanoid = connectedPart.Parent:FindFirstChild("Humanoid")
        local primary = humanoid and connectedPart.Parent.PrimaryPart
        local target = humanoid and primary
        print(target and target.Parent)

        if target then
            table.insert(results, target)
        end
    end

    return results
end

local function moveTo(part, position, moved)
    local connections = getConnectedParts(part)
    for _,p in pairs(connections) do
        if moved[p] then
            continue
        end

        moved[p] = true
        p.CFrame = CFrame.new(p.Position - part.Position + position)
    end

    part.Position = position
end

local function swapParts(part1, part2)
    local moved = { }
    local p = part1.Position
    moveTo(part1, part2.Position, moved)
    moveTo(part2, p, moved)
end

return {
    Swap = swapParts
}
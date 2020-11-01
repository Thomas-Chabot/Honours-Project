local function getConnectedPlayers(part, matched)
    local results = { }

    local min = part.Position - part.Size/2
    local max = part.Position + part.Size/2
    local region = Region3.new(Vector3.new(min.X, part.Position.Y - part.Size.Y/2, min.Z), Vector3.new(max.X, part.Position.Y + part.Size.Y/2 + 100, max.Z))
    local connected = workspace:FindPartsInRegion3(region, part, math.huge)

    for _,connectedPart in pairs(connected) do
        if not connectedPart.Parent then 
            continue
        end

        local char = connectedPart.Parent
        local humanoid = char:FindFirstChild("Humanoid")
        if humanoid and not matched[char] then
            matched[char] = true
            table.insert(results, char)
        end
    end

    return results
end

local function moveTo(part, position, connectedPlayers)
    for _,player in pairs(connectedPlayers) do
        local primaryPart = player and player.PrimaryPart
        if not primaryPart then
            continue
        end

        local target = game.Players:GetPlayerFromCharacter(player) and
                        part.Position + Vector3.new(0, 5, 0) or -- If it's a player, move to the center of the part they're standing on
                        primaryPart.Position - part.Position + position -- Otherwise, we want them to move with the part
                        
        primaryPart.CFrame = CFrame.new(target)
    end
    part.Position = position
end

local function swapParts(part1, part2)
    local matched = { }
    local players = {
        Part1 = getConnectedPlayers(part1, matched),
        Part2 = getConnectedPlayers(part2, matched)
    }

    local part1Pos = part1.Position
    moveTo(part1, part2.Position, players.Part1)
    moveTo(part2, part1Pos, players.Part2)
end

return {
    Swap = swapParts
}
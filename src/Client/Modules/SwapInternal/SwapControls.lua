local function moveTo(part, position)
    part.Position = position
end

local function swapParts(part1, part2)
    local p = part1.Position
    moveTo(part1, part2.Position)
    moveTo(part2, p)
end

return {
    MoveTo = moveTo,
    Swap = swapParts
}
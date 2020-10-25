--[[
    This module loads in map data from ServerStorage.
]]
local maps = game.ServerStorage.Objects.Maps
local levels = {
    maps["Level-2"]
}

local colorRoomMap = {
	[BrickColor.Gray().Name] = "Safe",
	[BrickColor.Red().Name] = "Trap",
	[BrickColor.Blue().Name] = "Start",
	[BrickColor.Green().Name] = "Goal"
}

local function getConnectingRooms(path)
	return {
		path.Room1.Value,
		path.Room2.Value
	}
end

local function getRooms(level)
	local rooms = { }
	for _,room in ipairs(level.Rooms:GetChildren()) do
		local roomType = colorRoomMap[room.BrickColor.Name]
		assert(roomType, "Could not match the color " .. tostring(room.BrickColor) .. " to a room type")
		
		table.insert(rooms, {
			Id = room.Name,
			Position = room.Position,
			Size = room.Size,
			RoomType = roomType
		})
	end
	
	return rooms
end

local function getPaths(level)
	local paths = { }
	for _,path in pairs(level.Paths:GetChildren()) do
		local connections = getConnectingRooms(path)
		assert(#connections == 2, "Could not find exactly 2 connections from path " .. path.Name .. ": Received " .. tostring(#connections) .. " connections")
		
		table.insert(paths, connections)
	end
	return paths
end

local function loadMapData(map)
    return {
        Rooms = getRooms(map),
        Paths = getPaths(map)
    }
end

local loadMap = function (level)
    assert(levels[level], "Could not find a level map for the level " .. tostring(level))
    return loadMapData(levels[level])
end

return {
    LoadLevel = loadMap
}
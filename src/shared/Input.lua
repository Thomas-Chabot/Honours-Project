local Input = { }

local ContextActionService = game:GetService("ContextActionService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Util = ReplicatedStorage:WaitForChild("Util")
local Signal = require(Util:WaitForChild("Signal"))

local player = game.Players.LocalPlayer
local mouse = player:GetMouse()

Input.Events = {
    MouseClicked = Signal.new()
}

function Input.GetMouseTarget()
    return mouse.Target
end

mouse.Button1Down:Connect(function()
    Input.Events.MouseClicked:Fire(mouse.Target)
end)

return Input

local cam = workspace.CurrentCamera
local player = game.Players.LocalPlayer

local UserInputService = game:GetService("UserInputService")
local Camera = require(game.ReplicatedStorage.Source.CameraMode)

local X = 0
local Z = 0
local Y = 75
local Speed = 0.5

Camera.Events.CameraModeChanged:Connect(function(mode)
	if mode == "Overhead" then
		player.CameraMode = Enum.CameraMode.Classic
		cam.CameraSubject = workspace.PrimaryPart
		cam.CameraType = Enum.CameraType.Scriptable
	else
		cam.CameraSubject = player.Character.Humanoid
		cam.CameraType = Enum.CameraType.Custom
		player.CameraMode = Enum.CameraMode.LockFirstPerson
	end
end)

game:GetService("RunService").RenderStepped:Connect(function()
	if Camera:GetMode() == "Overhead" then
		cam.CFrame = CFrame.new(Vector3.new(X,Y,Z),Vector3.new(X,0,Z))
		
		if UserInputService:IsKeyDown(Enum.KeyCode.W) then
			X += Speed
		end
		if UserInputService:IsKeyDown(Enum.KeyCode.S) then
			X -= Speed
		end
		if UserInputService:IsKeyDown(Enum.KeyCode.A) then
			Z -= Speed
		end
		if UserInputService:IsKeyDown(Enum.KeyCode.D) then
			Z += Speed
		end
	end
end)
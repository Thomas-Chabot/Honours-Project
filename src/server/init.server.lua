print("Hello world, from server!")
game.Players.PlayerAdded:Connect(function(newPlayer)
    print(newPlayer.Name)
end)
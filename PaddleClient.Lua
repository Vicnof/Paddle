local PlayerId = game.Players.LocalPlayer.UserId

game.ReplicatedStorage:GetAttributeChangedSignal(PlayerId):Connect(function()
	game.ReplicatedStorage.Pong:FireServer(game.ReplicatedStorage:GetAttribute(PlayerId))
	-- we don't use a remote because they fire too slowly, see full post in SCC/CW for details
	-- we instead change an attribute on the server, detect it, and then fire, which matches the replication rate from the server to the client, back to the server
end)

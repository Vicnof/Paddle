local PingChecks = {} -- in the format [Player.UserId] = {WaitingOnClientResponse, TimeSent, Signature}

game.ReplicatedStorage.Pong.OnServerEvent:Connect(function(Player, Signature)
	if PingChecks[Player.UserId][3] and PingChecks[Player.UserId][3] == Signature then -- make sure they exist first
		local Time = tostring(workspace:GetServerTimeNow() - PingChecks[Player.UserId][2]) * 1000
		local Decimal = string.find(Time, "%.")
		Player.leaderstats.Ping.Value = string.sub(Time, 1, Decimal + 2).."ms"
		PingChecks[Player.UserId][1] = false
	end
end)

local function HandleDroppedRequest(Player, OldSignature)
	if PingChecks[Player.UserId][3] == OldSignature then
		PingChecks[Player.UserId] = {false, nil, nil}
		Player.leaderstats.Ping.Value = "1,000ms+"
	end
end

while true do
	for _, Player in pairs(game.Players:GetPlayers()) do
		PingChecks[Player.UserId] = PingChecks[Player.UserId] or {false, nil, nil} -- initalize them if they don't exist yet

		if PingChecks[Player.UserId][1] == false then
			local Signature = tostring(Random.new():NextInteger(1, 2^30)) -- prevent exploiters from artifically lowering ping, they can't guess what the server will generate
			local TimeSent = workspace:GetServerTimeNow()

			game.ReplicatedStorage:SetAttribute(tostring(Player.UserId), Signature)
			PingChecks[Player.UserId] = {true, TimeSent, Signature}

			task.delay(1, HandleDroppedRequest, Player, Signature) -- handles re-joins + straight-up dropped remotes
		end
	end
	task.wait(0.25) -- change to your liking
end

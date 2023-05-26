# Paddle: Better Ping Calculation
⸻
## Background
A small but rather substantial oversight I've noticed with most ping-checking systems is not accounting for the queue system Roblox uses to queue up client/server replication. For example, if you call `FireClient()` twice in consecutive frames, the client *won't* receive one event, then a frame later the second. Rather, they're joined up in a queue and the client will receive both invocations at the same time.

The best source I've found for this is this post on the DevForum regarding network rates: https://devforum.roblox.com/t/are-there-any-replication-methods-that-are-faster-than-the-standard-20-hz-remotes/168634/9, but as the linked documentation seems to have been deleted, I can't speak to the exact rates authoritatively.

Regardless, this introduces a problem: checking ping by simply firing remotes from the server, to the client, and back to the server can introduce artificial delays of anywhere from 30ms-50ms, a large discrepancy considering the ping-reliant nature of sword fighting.

The best way to calculate ping is probably calling `Player:GetNetworkPing()`, but as that updates slowly (once every 1-2 seconds), I've created an open-source ping measurement system, I'm calling it Paddle (yk getting ping, ponging it back) that accounts for network queuing. To be clear, there's no perfect way to measure ping, as even something that seems to update constantly like player positions is actually updated at sub-60 FPS rates, and so you're forced to decide *what kind of ping* you want to measure.

Paddle measures the total time it takes for a changed property to replicate from the server to the client, and then for the server to receive an update from the player. A more apt analogy would be the total time it takes for a player's sword to move on the server, you to see the movement, and for the server to receive your reaction.
## More Info
- By having the property we replicate be a randomly server-sided generated number, and by forcing the client to respond with this number before we can measure ping, we can prevent exploiters from firing the remote early and faking a lower ping. They can still, however, choose to delay their reaction and fake a higher ping, but that's less useful for them.

- Paddle gracefully handles players leaving/re-joining, mid-game username changes, and dropped remotes.

- Paddle has an error of ±7ms due to the limits of the network queue. Although the bulk of Paddle uses `RecieveRate` which operates at the fastest network rate of 1/60th of a second, this still introduces some delay. There is also delay between the server updating the leaderstat and that updated leaderstat replicating to other clients.
## Paddle Setup:
- You must have already made a leaderstat named "Ping". It must be a StringValue.
- You must have a RemoteEvent in ReplicatedStorage named "Pong".
- Create `PaddleServer.lua` as a Script under ServerScriptService
- Create `PaddleClient.lua` as a LocalScript under StarterPlayer.StarterPlayerScripts

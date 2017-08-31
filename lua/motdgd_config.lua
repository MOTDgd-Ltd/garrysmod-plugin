MOTDgd = MOTDgd or {}

MOTDgd.UserID = 0   						-- Your /motd/?user=X, where X is your user ID as specified on the MOTDgd Portal
MOTDgd.Forced = true						-- Force players to wait [MOTDgd.WaitTime] seconds before they can close the MOTD window. true = enabled, false = disabled
MOTDgd.WaitTime = 10						-- How long to force the advertisement for, will do anything only if Forced is enabled, recommended is 10 (seconds)
MOTDgd.SkipRanks = {"admin", "superadmin"}			-- If players is one of these ranks, then the advert will not show up for them, useful for donators or admins, add more like this: {"admin", "superadmin", "donator", "someotherrank"} Supports: ULX, evolve, moderator and Ass
MOTDgd.AdCooldownTime = 300					-- This dictates the cooldown time between adverts showing, set to 0 to disable. This is in seconds.

--[[
You shouldn't have these ones both enabled at the same time, because they happen very close to each other:
	OnPlayerSpawn and OnPlayerDeath
--]]

MOTDgd.OnPlayerSpawn = false -- Should it show the ad every time a player spawns?
	MOTDgd.OnPlayerSpawnForced = false
	MOTDgd.OnPlayerSpawnWaitTime = 0 -- Time in seconds to force the advertisement for

MOTDgd.OnPlayerDeath = true -- This is run when a player dies
	MOTDgd.OnPlayerDeathForced = true
	MOTDgd.OnPlayerDeathWaitTime = 5 -- Time in seconds to force the advertisement for

MOTDgd.OnTTTEndRound = false -- This is run when a round ends in TTT
	MOTDgd.OnTTTEndRoundForced = false
	MOTDgd.OnTTTEndRoundWaitTime = 0 -- Time in seconds to force the advertisement for

MOTDgd.ShowOnJoin = true -- Show an advert immediately as soon as a player finishes joining?
	
if SERVER then return end
-- Clientside Configuration

MOTDgd.FrameSizeW = ScrW() * 0.95
MOTDgd.FrameSizeH = ScrH() * 0.95

MOTDgd.BGColor = Color(22,22,22,250)
MOTDgd.TopTextColor = Color(100,100,100,255)

MOTDgd.CloseBtnColor = Color(33,33,33,254)
MOTDgd.CloseBtnTextColor = Color(180,180,180,254)

MOTDgd.DisabledCloseBtnColor = Color(100,100,100,255)
MOTDgd.DisabledCloseBtnTextColor = Color(180,180,180,255)

MOTDgd.Font = "Franklin Gothic"
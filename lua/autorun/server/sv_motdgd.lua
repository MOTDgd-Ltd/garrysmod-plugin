MOTDgd = MOTDgd or {}
MOTDgd.Version = "2.07"

util.AddNetworkString("MOTDgdShow")
util.AddNetworkString("MOTDgdUpdate")

include("motdgd_config.lua")
AddCSLuaFile("motdgd_config.lua")

if SERVER then
	MOTDgd.CvarPluginVersion = CreateConVar("sm_motdgd_version", "2.07-gm", FCVAR_NOTIFY + FCVAR_DONTRECORD, "MOTDgd LUA Plugin Version")
end

function MOTDgd.GetServerInfo()
	local HostIP = GetConVarString("hostip")
	MOTDgd.Port = GetConVarString("hostport")

	HostIP = tonumber( HostIP )

	local IP = {}
	IP[1] = bit.rshift(bit.band(HostIP, 0xFF000000), 24)
	IP[2] = bit.rshift(bit.band(HostIP, 0x00FF0000), 16)
	IP[3] = bit.rshift(bit.band(HostIP, 0x0000FF00), 8)
	IP[4] = bit.band(HostIP, 0x000000FF)

	MOTDgd.IP = table.concat(IP, ".")
end

function MOTDgd.Show(ply, Forced, WaitTime, isAdRetry)
	if !ply.MOTDgdCached then
		net.Start( "MOTDgdUpdate" )
			net.WriteDouble( MOTDgd.UserID )
			net.WriteString( MOTDgd.IP )
			net.WriteDouble( MOTDgd.Port )
			net.WriteString( MOTDgd.Version )
			net.WriteDouble( WaitTime )
			net.WriteBit( Forced )
			net.WriteString( ply:SteamID() )
		net.Send( ply )
		ply.MOTDgdCached = true
	else
		net.Start("MOTDgdShow")
			net.WriteBit( Forced )
		net.Send( ply )
	end
end

hook.Add("OnGamemodeLoaded", "MOTDgdOnGamemodeLoadedHook", function()
	MOTDgd.GetServerInfo()
end)

hook.Add("PlayerInitialSpawn", "MOTDgdPlayerInitialSpawnHook", function(ply)
	ply.MOTDgdSkipNextSpawn = true
	if MOTDgd.ShowOnJoin then
		MOTDgd.Show(ply, MOTDgd.Forced, MOTDgd.WaitTime, false)
	end
end)

hook.Add("PlayerSpawn", "MOTDgdPlayerSpawnHook", function(ply)
	if MOTDgd.OnPlayerSpawn then
		if !ply.MOTDgdSkipNextSpawn then
			MOTDgd.Show( ply, MOTDgd.OnPlayerSpawnForced, MOTDgd.OnPlayerSpawnWaitTime, false )
		else
			ply.MOTDgdSkipNextSpawn = false
		end
	end
end)

hook.Add("PlayerDeath", "MOTDgdPlayerDeathHook", function(ply)
	if MOTDgd.OnPlayerDeath then
		MOTDgd.Show( ply, MOTDgd.OnPlayerDeathForced, MOTDgd.OnPlayerDeathWaitTime, false )
	end
end)

hook.Add("TTTEndRound", "MOTDgdTTTEndRoundHook", function(ply)
	if MOTDgd.OnTTTEndRound then
		for k, v in pairs( player.GetAll() ) do
			MOTDgd.Show( v, MOTDgd.OnTTTEndRoundForced, MOTDgd.OnTTTEndRoundWaitTime, false )
		end
	end
end)
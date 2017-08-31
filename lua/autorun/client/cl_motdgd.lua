MOTDgd = MOTDgd or {}
MOTDgd.Frame = nil
MOTDgd.HTML = nil
MOTDgd.CloseBtn = nil
MOTDgd.CloseBtnWaitTime = 0
MOTDgd.Initialized = false
MOTDgd.LastAdShown = -1
MOTDgd.PendingAd = false
MOTDgd.PendingAdAttempts = 0
MOTDgd.WaitTime = 0

include("motdgd_config.lua")

surface.CreateFont( "MOTDgdFont22", { font = MOTDgd.Font, size = 22, antialias = true, weight = 550 })
surface.CreateFont( "MOTDgdFont33", { font = MOTDgd.Font, size = 33, antialias = true, weight = 550 })

function MOTDgd.GetIfSkip()
	local ply = LocalPlayer()
	local CurrentRank = ply:GetUserGroup()
		
	if table.HasValue(MOTDgd.SkipRanks, CurrentRank) then
		print("[MOTDgd] Refusing to show Advert - SkipRanks check passed!")
		return true
	else
		return false
	end
end

function MOTDgd.Show( ply, toForce, toWaitTime, isAdRetry ) -- Yeah, let's add support if this is being called shared shall we?
	if !isAdRetry and MOTDgd.PendingAd then
		print("[MOTDgd] An advert was attempted to be displayed while another is currently pending or shown!")
		return
	end
	
	MOTDgd.PendingAd = true
	
	if !MOTDgd.Initialized then
		if MOTDgd.PendingAdAttempts < 4 then
			print("[MOTDgd] An advert was attempted to be displayed too early! Retrying in a few seconds...")
			MOTDgd.PendingAdAttempts = MOTDgd.PendingAdAttempts + 1;
			timer.Simple(4, function() MOTDgd.Show(ply, toForce, toWaitTime, true) end)
		else
			print("[MOTDgd] An advert was attempted to be displayed too early! All re-attempts failed, abandoning MOTDgd.Show(...)!")
			MOTDgd.PendingAdAttempts = 0
		end
		
		return
	end
	
	if MOTDgd.LastAdShown >= 0 then
		if (MOTDgd.LastAdShown + MOTDgd.AdCooldownTime) > CurTime() then
			print("[MOTDgd] Not showing advert - cooldown in effect! [" .. (MOTDgd.LastAdShown + MOTDgd.AdCooldownTime) .. " > " .. CurTime() .. "]")
			MOTDgd.PendingAd = false
			MOTDgd.PendingAdAttempts = 0
			return
		end
	end

	MOTDgd.Forced = toForce or MOTDgd.Forced
	MOTDgd.WaitTime = toWaitTime or MOTDgd.WaitTime

	if !MOTDgd.UserID then 
		if MOTDgd.PendingAdAttempts < 4 then
			print("[MOTDgd] Not received information yet, retrying in a few seconds...")
			MOTDgd.PendingAdAttempts = MOTDgd.PendingAdAttempts + 1;
			timer.Simple(4, function() MOTDgd.Show(ply, toForce, toWaitTime, true) end)
		else
			print("[MOTDgd] Not received information yet, abandoning MOTDgd.Show(...)!")
			MOTDgd.PendingAdAttempts = 0
		end
		
		return 
	end

	if MOTDgd.GetIfSkip() then
		MOTDgd.PendingAd = false
		MOTDgd.PendingAdAttempts = 0
		return
	end
	
	MOTDgd.PendingAdAttempts = 0
	
	MOTDgd.LastAdShown = CurTime()

	local ForcedNum = Either(MOTDgd.Forced, 1, 0)

	-- Popup The Frame
	MOTDgd.Frame:MakePopup()
	MOTDgd.Frame:SetVisible(true)
	
	MOTDgd.HTML:OpenURL("http://motdgd.com/motd/?user=" .. MOTDgd.UserID .. "&fv=" .. ForcedNum .. "&ip=" .. MOTDgd.IP .. "&pt=" .. MOTDgd.Port .. "&gm=garrysmod&st=" .. MOTDgd.SteamID .. "&v=" .. MOTDgd.Version .. "&sec=" .. MOTDgd.WaitTime)

	MOTDgd.CloseBtnWaitTime = MOTDgd.WaitTime

	if MOTDgd.Forced then
		MOTDgd.CloseBtn.Disabled = true
		timer.Create("MOTGgdTimer", 1, MOTDgd.CloseBtnWaitTime, function()
			MOTDgd.CloseBtnWaitTime = MOTDgd.CloseBtnWaitTime - 1
			if MOTDgd.CloseBtnWaitTime <= 0 then
				if IsValid(MOTDgd.CloseBtn) then
					MOTDgd.CloseBtn.Disabled = false
				end
			end
		end)
	end
	
	
	print( "[MOTDgd] An advertisement was displayed!" ) 
end

function MOTDgd:Update( uid, ip, port, ver, wt, force, sid )
	print("[MOTDgd] Internal information was successfully received!")
	
	MOTDgd.UserID = uid
	MOTDgd.IP = ip
	MOTDgd.Port = port
	MOTDgd.Version = ver
	MOTDgd.WaitTime = wt
	MOTDgd.Forced = force
	MOTDgd.SteamID = sid
	
	MOTDgd.Show()
end

net.Receive("MOTDgdUpdate", function()	
	MOTDgd:Update( net.ReadDouble(), net.ReadString(), net.ReadDouble(), net.ReadString(), net.ReadDouble(), net.ReadBit() == 1, net.ReadString() )
end)

net.Receive("MOTDgdShow", function()
	MOTDgd.Forced = net.ReadBit() == 1

	MOTDgd.Show( )
end)

hook.Add("InitPostEntity", "MOTDgdInitHook", function()
	MOTDgd.InitializeWidgets()
end)

function MOTDgd.InitializeWidgets()
	-- Initialize Frame
	MOTDgd.Frame = MOTDgd.Frame or vgui.Create("DFrame")
	MOTDgd.Frame:SetSize(MOTDgd.FrameSizeW, MOTDgd.FrameSizeH)
	MOTDgd.Frame:SetTitle("")
	MOTDgd.Frame:ShowCloseButton(false)
	MOTDgd.Frame:SetDraggable(false)
	MOTDgd.Frame:Center()
	
	-- On Paint Event
	MOTDgd.Frame.Paint = function(self)
		surface.SetDrawColor(MOTDgd.BGColor)
		surface.DrawRect(0, 25, self:GetWide(), self:GetTall() )
		draw.SimpleText("MOTDgd.com Advertisement", "MOTDgdFont22", self:GetWide() / 2, 10, MOTDgd.TopTextColor, 1, 1)
	end
	
	-- Initialize HTML Widget
	MOTDgd.HTML = MOTDgd.HTML or vgui.Create("DHTML", MOTDgd.Frame)
	MOTDgd.HTML:SetSize(MOTDgd.Frame:GetWide(), MOTDgd.Frame:GetTall() - 75)
	MOTDgd.HTML:SetPos(0, 25)

	-- Initialize Close Button
	MOTDgd.CloseBtn = MOTDgd.CloseBtn or vgui.Create("DButton", MOTDgd.Frame)
	MOTDgd.CloseBtn:SetSize(MOTDgd.Frame:GetWide(), 50)
	MOTDgd.CloseBtn:SetText("")
	MOTDgd.CloseBtn:SetPos(0, MOTDgd.Frame:GetTall() - 50)
	MOTDgd.CloseBtn.TextColor = MOTDgd.CloseBtnTextColor
	MOTDgd.CloseBtn.Color = MOTDgd.CloseBtnColor
	MOTDgd.CloseBtn.HoverOver = 150
	MOTDgd.CloseBtn.Disabled = false
	
	-- Hide Everything When the button is pressed
	MOTDgd.CloseBtn.DoClick = function(self)
		if !self.Disabled then
			
			MOTDgd.Frame:SetVisible(false); -- Hide The Frame
			MOTDgd.PendingAd = false
			MOTDgd.PendingAdAttempts = 0
			
			-- Stop the video when the player presses Hide
			-- MOTDgd.HTML:OpenURL("about:blank");
		end
	end
	
	-- Button On Paint Event
	MOTDgd.CloseBtn.Paint = function(self)
		if self.Color.a == self.HoverOver then
		elseif self.Color.a > self.HoverOver then
			self.Color.a = self.Color.a - 2
			self.TextColor.a = self.Color.a
		elseif self.Color.a < self.HoverOver then
			self.Color.a = self.Color.a + 2
			self.TextColor.a = self.Color.a
		end

		if self.Disabled then
			surface.SetDrawColor(MOTDgd.DisabledCloseBtnColor)
			surface.DrawRect(0, 0, self:GetWide(), self:GetTall() )
			draw.SimpleText("Hide in " .. MOTDgd.CloseBtnWaitTime .. " second(s)", "MOTDgdFont33", self:GetWide() / 2, self:GetTall() / 2, MOTDgd.DisabledCloseBtnTextColor, 1, 1)
		else
			surface.SetDrawColor(self.Color)
			surface.DrawRect(0, 0, self:GetWide(), self:GetTall() )
			draw.SimpleText("Hide", "MOTDgdFont33", self:GetWide() / 2, self:GetTall() / 2, self.TextColor, 1, 1)
		end
	end
	
	-- Called when the mosue entered the button
	MOTDgd.CloseBtn.OnCursorEntered = function(self)
		self.HoverOver = 250
	end
	-- Called when the mouse left the button
	MOTDgd.CloseBtn.OnCursorExited = function(self)
		self.HoverOver = 140
	end
	
	MOTDgd.Frame:SetVisible(false)
	
	-- Set this so we know we have everything initialized
	MOTDgd.Initialized = true
	
	print("[MOTDgd] Initialized advertisements system!")
end
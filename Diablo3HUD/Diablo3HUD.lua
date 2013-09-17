Diablo3HUD = {
	tAnchor = {},
	tArtwork = {
		["imgCircleBg"] = {10, 9},	-- yellow, green
		["aniCircle"] = {
			"ui/Image/Common/SprintYellowPower1.UITex",
			"ui/Image/Common/SprintGreenPower1.UITex"
		},
		["aniWater"] = {
			"ui/Image/Common/SprintYellowPower2.UITex",
			"ui/Image/Common/SprintGreenPower2.UITex"
		},
		["imgHighLight"] = {18, 17},
	},
	bMerge = false,
}

RegisterCustomData("Diablo3HUD.tAnchor")
RegisterCustomData("Diablo3HUD.bMerge")
local tCustomModeName = {"Ѫ��", "����", "Ѫ����"}

function Diablo3HUD.OnFrameCreate()
	this:RegisterEvent("UI_SCALED")
	this:RegisterEvent("CUSTOM_DATA_LOADED")
	this:RegisterEvent("ON_ENTER_CUSTOM_UI_MODE")
	this:RegisterEvent("ON_LEAVE_CUSTOM_UI_MODE")
	this:RegisterEvent("PLAYER_STATE_UPDATE")
	Diablo3HUD.UpdateAnchor(this)
	for i = 1, 3, 1 do
		if this.index and this.index == i then
			UpdateCustomModeWindow(this, tCustomModeName[i])
			Diablo3HUD.Init(this, i)
		end
	end
end

function Diablo3HUD.OnFrameDragEnd()
	this:CorrectPos()
	Diablo3HUD.tAnchor[this.index] = GetFrameAnchor(this)
end

function Diablo3HUD.UpdateAnchor(frame)
	local anchor = Diablo3HUD.tAnchor[frame.index]
	if anchor then
		frame:SetPoint(anchor.s, 0, 0, anchor.r, anchor.x, anchor.y)
	else
		if frame.index == 3 then
			frame:SetAbsPos(500, 500)
		else
			frame:SetAbsPos(500 + (frame.index - 1) * 180, 500)
		end
	end
	frame:CorrectPos()
end


function Diablo3HUD.OnEvent(event)
	if event == "UI_SCALED" or (event == "CUSTOM_DATA_LOADED" and arg0 == "Role") then
		Diablo3HUD.UpdateAnchor(this)
	elseif event == "ON_ENTER_CUSTOM_UI_MODE" or event == "ON_LEAVE_CUSTOM_UI_MODE" then
		UpdateCustomModeWindow(this)
	elseif event == "PLAYER_STATE_UPDATE" then
		if arg0 == UI_GetClientPlayerID() then
			Diablo3HUD.UpdateHFData(this)
		end
	end
end

function Diablo3HUD.Init(frame, index)
	if index == 3 then
		local handle = frame:Lookup("", "")
		for k, v in ipairs({"Left", "Right"}) do
			local hCircle = handle:Lookup("Handle_" .. v):Lookup("Handle_" .. v .. "Circle")
			local hWater = hCircle:Lookup("Handle_" .. v .. "Water")
			local aniCircle = hCircle:Lookup("Animate_" .. v .. "Circle")
			local aniWater = hWater:Lookup("Animate_" .. v .. "Water")

			aniCircle:SetAnimateType(7)
			aniCircle:SetAlpha(200)
			aniWater:Hide()
		end
	else
		local handle = frame:Lookup("", "")
		local imgCircleBg = handle:Lookup("Image_CircleBg")
		local hCircle = handle:Lookup("Handle_Circle")
		local imgHighLight = hCircle:Lookup("Image_HighLight")
		local hWater = hCircle:Lookup("Handle_Water")
		local aniCircle = hCircle:Lookup("Animate_Circle")
		local aniWater = hWater:Lookup("Animate_Water")

		local tArtwork = Diablo3HUD.tArtwork

		imgCircleBg:SetFrame(tArtwork["imgCircleBg"][index])
		imgHighLight:SetFrame(tArtwork["imgHighLight"][index])

		aniCircle:SetAnimate(tArtwork["aniCircle"][index], 0, -1)
		aniWater:SetAnimate(tArtwork["aniWater"][index], 0, -1)

		aniCircle:SetAnimateType(7)
		aniCircle:SetAlpha(200)

		aniWater:Hide()
	end
end

function Diablo3HUD.UpdateHFData(frame)
	local player = GetClientPlayer()
	local dwForceID = player.dwForceID
	if frame.index == 1 then	--Ѫ��
		if player.nMaxLife > 0 then
			local fHealth = player.nCurrentLife / player.nMaxLife
			local szPer = string.format("%d%%", fHealth * 100)
			local szVal = string.format("%d/%d", player.nCurrentLife, player.nMaxLife)
			Diablo3HUD.UpdateCircle(frame, fHealth, szPer, szVal)
		end
	elseif frame.index == 2 then	--����
		if dwForceID == 7 then	--����
			if player.nMaxEnergy > 0 then
				local fPer = player.nCurrentEnergy / player.nMaxEnergy
				local szPer = string.format("%d%%", fPer * 100)
				local szVal = string.format("%d/%d", player.nCurrentEnergy, player.nMaxEnergy)
				Diablo3HUD.UpdateCircle(frame, fPer, szPer, szVal)
			end
		elseif dwForceID == 8 then	--�ؽ�
			if player.nMaxRage > 0 then
				local fRage = player.nCurrentRage / player.nMaxRage
				local szPer = string.format("%d%%", fRage * 100)
				local szVal = string.format("%d/%d", player.nCurrentRage, player.nMaxRage)
				Diablo3HUD.UpdateCircle(frame, fRage, szPer, szVal)
			end
		elseif dwForceID == 10 then	--����
			local fPer = math.max(player.nCurrentSunEnergy / player.nMaxSunEnergy, player.nCurrentMoonEnergy / player.nMaxMoonEnergy)
			local szValS = string.format("�� %d/%d", player.nCurrentSunEnergy / 100, player.nMaxSunEnergy / 100)
			local szValM = string.format("�� %d/%d", player.nCurrentMoonEnergy / 100, player.nMaxMoonEnergy / 100)
			if player.nSunPowerValue == 1 then
				szValS, fPer = "����", 1
			elseif player.nMoonPowerValue == 1 then
				szValM, fPer = "����", 1
			end
			Diablo3HUD.UpdateCircle(frame, fPer, szValS, szValM)
		else
			if player.nMaxMana > 0 and player.nMaxMana ~= 1 then
				local fMana = player.nCurrentMana / player.nMaxMana
				local szPer = string.format("%d%%", fMana * 100)
				local szVal = string.format("%d/%d", player.nCurrentMana, player.nMaxMana)
				Diablo3HUD.UpdateCircle(frame, fMana, szPer, szVal)
			end
		end
	elseif frame.index == 3 then
		if player.nMaxLife > 0 then
			local fHealth = player.nCurrentLife / player.nMaxLife
			local szPer = string.format("%d%%", fHealth * 100)
			Diablo3HUD.UpdateMergeCircle(frame, fHealth, szPer, "Left")
		end

		if dwForceID == 7 then	--����
			if player.nMaxEnergy > 0 then
				local fPer = player.nCurrentEnergy / player.nMaxEnergy
				local szPer = string.format("%d", fPer * 100)
				Diablo3HUD.UpdateMergeCircle(frame, fPer, szPer, "Right")
			end
		elseif dwForceID == 8 then	--�ؽ�
			if player.nMaxRage > 0 then
				local fRage = player.nCurrentRage / player.nMaxRage
				local szPer = string.format("%d", fRage * 100)
				Diablo3HUD.UpdateMergeCircle(frame, fRage, szPer, "Right")
			end
		elseif dwForceID == 10 then	--����
			local fPerS, fPerM = player.nCurrentSunEnergy / player.nMaxSunEnergy, player.nCurrentMoonEnergy / player.nMaxMoonEnergy
			local fPer = math.max(fPerS, fPerM)
			local szPer = nil
			if fPerM > fPerS then
				szPer = string.format("�� %d", fPerM * 100)
			else
				szPer = string.format("�� %d", fPerS * 100)
			end
			if player.nSunPowerValue == 1 then
				szPer, fPer = "����", 1
			elseif player.nMoonPowerValue == 1 then
				szPer, fPer = "����", 1
			end
			Diablo3HUD.UpdateMergeCircle(frame, fPer, szPer, "Right")
		else
			if player.nMaxMana > 0 and player.nMaxMana ~= 1 then
				local fMana = player.nCurrentMana / player.nMaxMana
				local szPer = string.format("%d%%", fMana * 100)
				Diablo3HUD.UpdateMergeCircle(frame, fMana, szPer, "Right")
			end
		end
	end
end

function Diablo3HUD.UpdateCircle(frame, fp, szPer, szVal)
	local handle = frame:Lookup("", "")
	local imgCircleBg = handle:Lookup("Image_CircleBg")
	local hCircle = handle:Lookup("Handle_Circle")
	local imgHighLight = hCircle:Lookup("Image_HighLight")
	local hWater = hCircle:Lookup("Handle_Water")
	local aniCircle = hCircle:Lookup("Animate_Circle")
	local aniWater = hWater:Lookup("Animate_Water")
	local hPer = hCircle:Lookup("Text_Per")
	local hValue = hCircle:Lookup("Text_Value")

	local cW, cH = aniCircle:GetSize()
	local cX, cY = aniCircle:GetRelPos()
	local wW, wH = hWater:GetSize()
	local wX, wY = hWater:GetRelPos()
	local h = wH * fp
	local a = (h + (wY - cY)) / cH
	aniCircle:SetPercentage(a)
	local b = cH * a
	local c = cH - b - (wY - cY)
	local d = aniWater:GetRelPos()
	local e, f = aniWater:GetSize()
	aniWater:SetRelPos(d, c - f / 2)
	hWater:FormatAllItemPos()
	if fp == 1 then
		aniWater:Hide()
	else
		aniWater:Show()
	end
	hPer:SetText(szPer)
	hValue:SetText(szVal)
end

function Diablo3HUD.UpdateMergeCircle(frame, fp, szPer, szPos)
	local handle = frame:Lookup("", "")
	local hCircle = handle:Lookup("Handle_" .. szPos):Lookup("Handle_" .. szPos .. "Circle")
	local hWater = hCircle:Lookup("Handle_" .. szPos .. "Water")
	local aniCircle = hCircle:Lookup("Animate_" .. szPos .. "Circle")
	local aniWater = hWater:Lookup("Animate_" .. szPos .. "Water")
	local hPer = hCircle:Lookup("Text_" .. szPos .. "Per")

	local cW, cH = aniCircle:GetSize()
	local cX, cY = aniCircle:GetRelPos()
	local wW, wH = hWater:GetSize()
	local wX, wY = hWater:GetRelPos()
	local h = wH * fp
	local a = (h + (wY - cY)) / cH

	aniCircle:SetPercentage(a)
	if szPos == "Left" then
		local b = cH * a
		local c = cH - b - (wY - cY)
		local d = aniWater:GetRelPos()
		local e, f = aniWater:GetSize()
		aniWater:SetRelPos(d, c - f / 2)
		hWater:FormatAllItemPos()
	elseif szPos == "Right" then
		local b = cH * a
		local c = cH - b - (wY - cY)
		local d = cX + wH
		local e, f = aniWater:GetSize()
		aniWater:SetRelPos(d, c - f / 2)
		hWater:FormatAllItemPos()
	end
	if fp == 1 then
		aniWater:Hide()
	else
		aniWater:Show()
	end
	hPer:SetText(szPer)
end

function Diablo3HUD.GetMenu()
	local menu = {
		szOption = "Diablo3HUD",
		{
			szOption = "�ϲ�Ѫ��˫��",
			bCheck = true,
			bChecked = Diablo3HUD.bMerge,
			fnAction = function()
				Diablo3HUD.bMerge = not Diablo3HUD.bMerge
				Diablo3HUD.TogglePanel(Diablo3HUD.bMerge)
			end,
		}
	}
	return menu
end

function Diablo3HUD.TogglePanel(bMerge)
	--˫�����
	for index = 1, 2, 1 do
		local frame = Station.Lookup("Normal/Diablo3HUD" .. index)
		if not bMerge then
			if not frame then
				frame = Wnd.OpenWindow("Interface\\Diablo3HUD\\Diablo3HUD.ini", "Diablo3HUD" .. index)
				frame.index = index
				frame.OnFrameDragEnd = Diablo3HUD.OnFrameDragEnd
				frame.OnEvent = Diablo3HUD.OnEvent
				local _this = this
				this = frame
				Diablo3HUD.OnFrameCreate()
				this = _this
			end
		elseif frame then
			Wnd.CloseWindow("Diablo3HUD" .. index)
		end
	end
	--�������
	local frame = Station.Lookup("Normal/Diablo3HUDMerge")
	if bMerge then
		if not frame then
			frame = Wnd.OpenWindow("Interface\\Diablo3HUD\\Diablo3HUDMerge.ini", "Diablo3HUDMerge")
			frame.index = 3
			frame.OnFrameDragEnd = Diablo3HUD.OnFrameDragEnd
			frame.OnEvent = Diablo3HUD.OnEvent
			local _this = this
			this = frame
			Diablo3HUD.OnFrameCreate()
			this = _this
		end
	elseif frame then
		Wnd.CloseWindow("Diablo3HUDMerge")
	end
end

RegisterEvent("LOGIN_GAME", function()
 	local tMenu = {
 		function()
 			return {Diablo3HUD.GetMenu()}
 		end,
 	}
 	Player_AppendAddonMenu(tMenu)
	Diablo3HUD.TogglePanel(Diablo3HUD.bMerge)
end)



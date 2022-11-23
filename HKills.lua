

hkills = {};

local HKFrame = CreateFrame("Frame", nil, UIParent );
HKFrame.Backdrop = CreateFrame("Frame", "HKFrameBackdrop", HKFrame , BackdropTemplateMixin and "BackdropTemplate" );

local menuFrame = CreateFrame("Frame", "HKills1", UIParent, "UIDropDownMenuTemplate")

local menu = {
    { text = "HKills for Dragonflight 10.0.2", isTitle = true},
    { text = "Сбросить счетчик почетных побед", func = function() HKFrame:resetCounter(); end },
	
    { text = "Показ HKM (Килов в минуту)", hasArrow = true,
        menuList = {
            { text = "Отобразить", func = function() hkills["isShowHKS"] = 1; HKFrame:updateStats(); end },
			{ text = "Скрыть", func = function() hkills["isShowHKS"] = 0; HKFrame:updateStats(); end }
        } 
    },	

    { text = "Общее количество килов", hasArrow = true,
        menuList = {
            { text = "Отобразить", func = function() hkills["isShowAllHK"] = 1; HKFrame:updateStats(); end },
			{ text = "Скрыть", func = function() hkills["isShowAllHK"] = 0; HKFrame:updateStats(); end }
        } 
    },	
	
    { text = "Обновить (пересчитать) данные", func = function() HKFrame:updateStats(); end },
	{ text = "Скрыть (/hkills show для отображения)", func = function() HKFrame:Hide(); end },
    { text = "Об аддоне", func = function() HKillsAbout(); end }
}


HKFrame:SetFrameStrata("BACKGROUND");
HKFrame:SetWidth(185) ;
HKFrame:SetHeight(85);
HKFrame:SetPoint("CENTER", "UIParent");
HKFrame.text = HKFrame.Backdrop:CreateFontString ( nil, "OVERLAY", "GameFontNormalLarge" );
HKFrame.text:SetTextColor(1, 0.2, 0.3);
HKFrame.text:SetWidth(185);
HKFrame.text:SetHeight(85);
HKFrame.text:SetPoint("CENTER", HKFrame, "CENTER");
HKFrame.Backdrop:SetAllPoints();
HKFrame.Backdrop.backdropInfo = {
	bgFile = "Interface\\ChatFrame\\ChatFrameBackground",
	edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
	tile = true;
	edgeSize = 18,
	insets = {left = 4, right = 4, top = 4, bottom = 4},
};
HKFrame.Backdrop:ApplyBackdrop()
HKFrame.Backdrop:SetBackdropColor(0.05, 0.05, 0.05);
HKFrame.Backdrop:SetBackdropBorderColor(0,0,0,0.8);

			
HKFrame:RegisterEvent("PLAYER_PVP_KILLS_CHANGED");
HKFrame:RegisterEvent("PLAYER_TARGET_CHANGED");
HKFrame:SetScript("OnDragStart", HKFrame.StartMoving);
HKFrame:SetScript("OnDragStop", function()
									HKFrame:StopMovingOrSizing();
									hkills["point"], _, hkills["relativePoint"], hkills["xpos"], hkills["ypos"] = HKFrame:GetPoint();

								end);

								
HKFrame:SetScript("OnMouseDown", function (self, button)
									if button == "RightButton" then
										EasyMenu(menu, menuFrame, "cursor", 0 , 0, "MENU", 1);
									end;
								 end);								 


HKFrame:SetMovable(true);
HKFrame:EnableMouse(true);
HKFrame:RegisterForDrag("LeftButton");

HKFrame:SetScript("OnEvent", function(self,event,...)
	if event == "PLAYER_PVP_KILLS_CHANGED" then
		if hkills["startHKpos"] == 0 then
			hkills["startHKpos"] = GetPVPLifetimeStats()
		end;
		
		if GetPVPLifetimeStats() - hkills["startHKpos"] == 1 then -- установка таймера с первым килом
			hkills["startTime"] = time() - 1;
		end;	
		
		HKFrame:updateStats();
	end;
	

end)

-- устанавливаем параметры фрейма после полной загрузки аддона
local DummyFrame = CreateFrame("Frame");
DummyFrame:RegisterEvent("ADDON_LOADED");
DummyFrame:SetScript("OnEvent", function(self,event,arg1)
	if arg1 == "HKills" then
	
		
		if not hkills["point"] then
			hkills["point"] = "CENTER";
		end;
		if not hkills["relativePoint"] then
			hkills["relativePoint"] = "CENTER";
		end;
		if not hkills["xpos"] then
			hkills["xpos"] = 0;
		end;
		if not hkills["ypos"] then
			hkills["ypos"] = 0;
		end;
		HKFrame:SetPoint(hkills["point"], "UIParent", hkills["relativePoint"], hkills.xpos, hkills.ypos);
		if not hkills["startHKpos"] then
			hkills["startHKpos"] = 0;
		end;
		
		if not hkills["startTime"] then
			hkills["startTime"] = 0;
		end;
		
		if not hkills["isShowHKS"] then
			hkills["isShowHKS"] = 1;
		end;
		
		if not hkills["isShowAllHK"] then
			hkills["isShowAllHK"] = 1;
		end;
		
		HKFrame:updateStats();

		HKFrame:Show();
	end;
end)

SLASH_HKILLS1 = "/hkills"
SlashCmdList["HKILLS"] = function(msg, _)

	if strupper(msg) == "SHOW" then
		HKFrame:Show();
	end;

	if strupper(msg) == "?" then
		HKillsAbout();
	end;
	
	if strupper(msg) == "RC" then
		HKFrame:resetCounter();
	end;
	
	if strupper(msg) == "RESETPOSITION" then
		hkills["point"] = "CENTER";
		hkills["relativePoint"] = "CENTER";
		hkills["xpos"] = 0;
		hkills["ypos"] = 0;
		DEFAULT_CHAT_FRAME:AddMessage("HKILLS: Для сброса местоположения фрейма счетчика сделайте /reload ");
	end;
end;

function HKFrame.resetCounter()
	hkills["startHKpos"] = GetPVPLifetimeStats();
	hkills["startTime"] = time() - 1;
	if hkills["startHKpos"] == 0 then
		DEFAULT_CHAT_FRAME:AddMessage("HKILLS: Счетчик почетных побед НЕ обнулен, попробуйте еще раз!");
	else
		DEFAULT_CHAT_FRAME:AddMessage("HKILLS: Счетчик почетных побед обнулен!");
	end;
	HKFrame:updateStats();
end;

function HKFrame.updateStats()
	if hkills["startHKpos"] == 0 then 
		hkills["startHKpos"] = GetPVPLifetimeStats();
		hkills["startTime"] = time() - 1;
	end;
	if GetPVPLifetimeStats() == 0 then
		HKFrame.text:SetText("Обновите данные".."\n(меню по правому клику)");
		return;
	end;
	
	if hkills["isShowHKS"] == 1 then
		HKSstring = "\nHK в минуту: "..HKSround((GetPVPLifetimeStats() - hkills["startHKpos"]) / ((time() - hkills["startTime"])/60), 2).."\n("..GetPVPLifetimeStats() - hkills["startHKpos"].." килов за "..HKSround((time() - hkills["startTime"])/60, 0).." минут)";
	else
		HKSstring = " ";
	end;	
	
	if hkills["isShowAllHK"] == 1 then
		AllHKstring = "\nВсего HK: "..GetPVPLifetimeStats();
	else
		AllHKstring = " ";
	end;
	
	HKFrame.text:SetText("Счетчик HK: "..GetPVPLifetimeStats() - hkills["startHKpos"]..HKSstring..AllHKstring);
end;

function HKSround(num, idp)
	local mult = 10^(idp or 0)
	return math.floor(num * mult + 0.5) / mult;
end;

function HKillsAbout()
	DEFAULT_CHAT_FRAME:AddMessage("HKILLS: 10.0.2 100002 rebuild for Dragonflight");
	DEFAULT_CHAT_FRAME:AddMessage("HKILLS: Аддон создан для участников сообщества |cFFC41F3B Эшелон |r https://discord.gg/fwZzkTp http://echelon-community.com/ ");
	DEFAULT_CHAT_FRAME:AddMessage("HKILLS: Автор Бузилко@CC");
end;

---------------------------------------------------------------------------------------
--local function OnDragStart()
--	if opt.frame_draggable then
	--	HKFrame:StartMoving()
--	end
--end

--local function OnDragStop()
	------HKFrame:StopMovingOrSizing()
	----opt.frame_position_x = HKFrame:GetLeft()
	--opt.frame_position_y = opt.frame_grow_upwards and HKFrame:GetBottom() or HKFrame:GetTop()
--end

-- Fontstring sizes
--local function AdjustFontstringSize(self)
	--local text = self:GetText()
	--self:SetHeight(self:GetStringHeight())
	--self:SetText(text)
--end

-- Colors
--local function Darken(mult, ...)
	--local r, g, b, a = ...
	--if type(r) == 'table' then
	--	r, g, b, a = unpack(r)
	--end
	--return r * mult, g * mult, b * mult, a or 1
--end

--local function GetColor(self, key, mult)
	--local skin, raw, default, t = self.skin, rawget(self.opt, key), defaults.profile[key]
	--assert(default, "No default color specified for key " .. key)
	-- Use options if different from defaults
	--if raw and (raw[1] ~= default[1] or raw[2] ~= default[2] or raw[3] ~= default[3] or raw[4] ~= default[4]) then
		--t = raw
	-- Use skin if options are defaults
	--elseif skin[key] then
	--	t = skin[key]
	-- Use defaults
	--else
		--t = default
	--end
	-- Darken
	--if mult then
		--return Darken(mult, t)
	--end
	--return unpack(t)
--end
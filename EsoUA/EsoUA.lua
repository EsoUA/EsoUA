local EsoUA = {}
EsoUA.Flags = { "en", "ua", "ru"}
EsoUA.Version = "1.3"
EsoUA.API = 101046
EsoUA.Name = "EsoUA"
EsoUA.DropdownParameters = {
	["ua"] = "Українська",
	["uaen"] = "Українська+Англійська",
	["enua"] = "Англійська+Українська",
	["en"] = "Англійська",
}
EsoUA.StringsBackup = {
	["SI_ABILITY_NAME_AND_RANK"] = GetString(SI_ABILITY_NAME_AND_RANK),
	["SI_ABILITY_TOOLTIP_NAME"] = GetString(SI_ABILITY_TOOLTIP_NAME),
	["SI_ITEM_FORMAT_STR_ENCHANT_HEADER_NAMED"] = GetString(SI_ITEM_FORMAT_STR_ENCHANT_HEADER_NAMED),
	["SI_ITEM_FORMAT_STR_ITEM_TRAIT_HEADER"] = GetString(SI_ITEM_FORMAT_STR_ITEM_TRAIT_HEADER),
	["SI_ITEM_FORMAT_STR_ITEM_TRAIT_WITH_ICON_HEADER"] = GetString(SI_ITEM_FORMAT_STR_ITEM_TRAIT_WITH_ICON_HEADER),
	["SI_ITEM_FORMAT_STR_SET_NAME"] = GetString(SI_ITEM_FORMAT_STR_SET_NAME),
	["SI_TOOLTIP_ITEM_NAME"] = GetString(SI_TOOLTIP_ITEM_NAME),
	["SI_ITEM_FORMAT_STR_SET_NAME_NO_COUNT"] = GetString(SI_ITEM_FORMAT_STR_SET_NAME_NO_COUNT),
}

EsoUA.Defaults = {
	Anchor = { BOTTOMRIGHT, BOTTOMRIGHT, 0, 7 },
	-- Misc
	ShowNPC = "ua",
	ShowLocations = "ua",
	ShowCraft = "ua",
	-- Abilities
	ShowAbilitiesMenu = "ua",
	ShowAbilitiesTooltip = "ua",
	-- Champion
	ShowChampionTooltip = "ua",
	-- Items
	ShowItemsNamesTooltip = "ua",
	ShowItemsEnchantsTooltip = "ua",
	ShowItemsTraitsTooltip = "ua",
	ShowItemsSetsTooltip = "ua",
	IsUpdateNeeded = true,
	-- Collections
	EnglishSearch = true,
	ShowCollectionsSetsMenu = "ua",
	--ShowTributeCards = "ua",
	Data = {
		ApiVersion = 0,
		AddonVersion = "",
		Abilities = {},
		Items = {},
		Sets = {},
		SetsNames = {},
		Traits = {},
		Potions = {},
		Locations = {},
		CraftAbilities = {},
		Parts = {},
		Prefixes = {},
		Affixes = {},
		EnchantPrefixes = {},
		--TributeCards = {},
	}
}
EsoUA.DefaultsCharacter = {
	IsFirstLaunch = true
}
EsoUA.Settings = EsoUA.Defaults
EsoUA.SettingsCharacter = EsoUA.DefaultsCharacter

function EsoUA_Change(lang)
	if GetCVar("language.2") ~= lang then
		SetCVar("language.2", lang)
	else
		ZO_Alert(UI_ALERT_CATEGORY_ERROR, SOUNDS.NEGATIVE_CLICK, "Ця мова вже увімкнута")
	end
end

function EsoUA:RefreshUI()
	local flagControl
	local count = 0
	local flagTexture
	for _, flagCode in pairs(self.Flags) do
		flagTexture = "EsoUA/textures/"..flagCode..".dds"
		flagControl = GetControl("EsoUA_FlagControl_"..tostring(flagCode))
		if flagControl == nil then
			flagControl = CreateControlFromVirtual("EsoUA_FlagControl_", EsoUAUI, "EsoUA_FlagControl", tostring(flagCode))
			GetControl("EsoUA_FlagControl_"..flagCode.."Texture"):SetTexture(flagTexture)
			if self:GetLanguage() ~= flagCode then
				flagControl:SetAlpha(0.3)
				if flagControl:GetHandler("OnMouseDown") == nil then flagControl:SetHandler("OnMouseDown", function() EsoUA_Change(flagCode) end) end
			end
		end
		flagControl:ClearAnchors()
		flagControl:SetAnchor(LEFT, EsoUAUI, LEFT, 14 +count*34, 0)
		count = count + 1
	end
	EsoUAUI:SetDimensions(25 +count*34, 50)
	EsoUAUI:SetMouseEnabled(true)
end

function EsoUA:GetLanguage()
	local lang = GetCVar("language.2")
	
	if lang == "ua" or lang == "de" or lang == "fr" or lang == "es" or lang == "ru" then return lang end
	return "en"
end

function EsoUA:StartupMessage()
	if self.Settings.IsUpdateNeeded and self:IsDBOld() then
		self:ShowMsgBox("Потрібно оновити мовну базу", "\n\n\n\nГра почне перемикати мови (текст на екрані змінюється з українського на англійський). Це нормально. Не закривай гру. Процес може зайняти від секунд до 10 хвилин залежно від потужності комп'ютера.", 1)
	end
	
	if self:IsDBOld() and not self.Settings.IsUpdateNeeded then
		d("Мовний файл EsoUA застарів. Його потрібно оновитии в налаштуваннях: ESC -> Настройки -> Дополнения (или Модификации) -> EsoUA або командою /esoua")
	end
	
	self:Check()
	
	EVENT_MANAGER:UnregisterForEvent("EsoUA_StartupMessage", EVENT_PLAYER_ACTIVATED)
end

function EsoUA:MapNameStyle()		
	if self.Settings.ShowLocations == "uaen" or self.Settings.ShowLocations == "enua" then
		ZO_WorldMapCornerTitle:SetFont("ZoFontWinH3")
	else
		ZO_WorldMapCornerTitle:SetFont("ZoFontWinH1")
	end
	
	local scrollData = ZO_ScrollList_GetDataList(ZO_WorldMapLocationsList)
    ZO_ClearNumericallyIndexedTable(scrollData)
	WORLD_MAP_LOCATIONS_DATA:RefreshLocationList()
	WORLD_MAP_LOCATIONS:BuildLocationList()
end

function EsoUA:OnInit(eventCode, addOnName)	
	if zo_strlower(addOnName) ~= zo_strlower(self.Name) then return end
	EVENT_MANAGER:UnregisterForEvent("EsoUA_OnAddOnLoaded", EVENT_ADD_ON_LOADED)
	
	self.Settings = ZO_SavedVars:NewAccountWide("EsOUAVariables", 1, nil, self.Defaults)
	self.SettingsCharacter = ZO_SavedVars:New("EsOUAVariables", 1, nil, self.DefaultsCharacter)
	
	if self.SettingsCharacter.IsFirstLaunch == true then
		SetSetting(SETTING_TYPE_SUBTITLES, SUBTITLE_SETTING_ENABLED_FOR_NPCS, "true")
		SetSetting(SETTING_TYPE_SUBTITLES, SUBTITLE_SETTING_ENABLED_FOR_VIDEOS, "true")
		self.SettingsCharacter.IsFirstLaunch = false
	end
	
	for _, flagCode in pairs(self.Flags) do
		ZO_CreateStringId("SI_BINDING_NAME_"..string.upper(flagCode), string.upper(flagCode))
	end

	self:RefreshUI()
	
	EsoUAUI:ClearAnchors()
	EsoUAUI:SetAnchor(self.Settings.Anchor[1], GuiRoot, self.Settings.Anchor[2], self.Settings.Anchor[3], self.Settings.Anchor[4])
	
	self.LAM = ESOUA_SETTINGS:New(self)
	
	ZO_CreateStringId("SI_BINDING_NAME_ESOUA_EN", "English")
	ZO_CreateStringId("SI_BINDING_NAME_ESOUA_RU", "Українська")
	
	if self:GetLanguage() == "ua" then
		EsoUA_init()
	end
	
	function ZO_GameMenu_OnShow(control)
		if control.OnShow then
			control.OnShow(control.gameMenu)
			EsoUAUI:SetHidden(hidden)
		end
	end
	
	function ZO_GameMenu_OnHide(control)
		if control.OnHide then
			control.OnHide(control.gameMenu)
			EsoUAUI:SetHidden(not hidden)
		end
	end
end

function EsoUA:IsDBOld()
	local rsv = self.Settings.Data
	if not rsv.ApiVersion or not rsv.AddonVersion or (rsv.ApiVersion ~= GetAPIVersion()) or (rsv.AddonVersion ~= self.Version) then
		return true
	else
		return false
	end
end

function EsoUA:CloseMsgBox()
	ZO_Dialogs_ReleaseDialog("EsoUADialog", false)
end

function EsoUA:ShowMsgBox(title, msg, typ)

	local callback = {}

	callback = {
		[1] = 
		{
			keybind = "DIALOG_PRIMARY",
			text = "Оновити мовну базу",
			callback =
				function ()
					EsoUA_Dump()
				end,
            clickSound = SOUNDS.DIALOG_ACCEPT,
		},
		[2] =
		{
			keybind = "DIALOG_NEGATIVE",
            text = "Отмена", 
			callback =
				function ()
					self.Settings.IsUpdateNeeded = false
				end,
            clickSound = SOUNDS.DIALOG_DECLINE,
		},
	}
	
	local confirmDialog = 
	{
		canQueue = true,
		onlyQueueOnce = true,
		gamepadInfo = { dialogType = GAMEPAD_DIALOGS.BASIC },
		title = { text = title },
		mainText = { text = msg },
		buttons = callback
	}
	
	ZO_Dialogs_RegisterCustomDialog("EsoUADialog", confirmDialog)
	self:CloseMsgBox()
	
	--if IsInGamepadPreferredMode() then
	--	zo_callLater(function()
	--		ZO_Dialogs_ShowGamepadDialog("EsoUADialog")
	--	end, 500)
	--else
		ZO_Dialogs_ShowDialog("EsoUADialog")
	--end
end

function EsoUA_init()
	
	if not EsoUA:IsDBOld() then
		
		if EsoUA.Settings.ShowLocations ~= "ua" and EsoUA_doubleNamesLocations then
			LFGDoubleNames(EsoUA)
			EsoUA_doubleNamesLocations(EsoUA)
		end
		
		if EsoUA.Settings.ShowNPC ~= "ua" and EsoUA_doubleNamesNPC then
			EsoUA_doubleNamesNPC(EsoUA)
		end
		
		if EsoUA.Settings.ShowCraft ~= "ua" and EsoUA_doubleNamesBoth then
			EsoUA_doubleNamesBoth(EsoUA)
		end
		
		if (EsoUA.Settings.ShowAbilitiesMenu ~= "ua" or EsoUA.Settings.ShowAbilitiesTooltip ~= "ua") and EsoUA_doubleNamesAbilities then
			EsoUA_doubleNamesAbilities(EsoUA)
		end
		
		if (EsoUA.Settings.ShowChampionMenu ~= "ua" or EsoUA.Settings.ShowChampionTooltip ~= "ua") and EsoUA_doubleNamesChampion then
			EsoUA_doubleNamesChampion(EsoUA)
		end
		
		if (EsoUA.Settings.ShowItemsNamesTooltip ~= "ua" or EsoUA.Settings.ShowItemsEnchantsTooltip ~= "ua" or EsoUA.Settings.ShowItemsTraitsTooltip ~= "ua" or EsoUA.Settings.ShowItemsSetsTooltip ~= "ua") and EsoUA_doubleNamesItems then
			EsoUA_doubleNamesItems(EsoUA)
		end
		
		if (EsoUA.Settings.EnglishSearch or EsoUA.Settings.ShowCollectionsSetsMenu ~= "ua") and EsoUA_doubleNamesCollections then
			EsoUA_doubleNamesCollections(EsoUA)
			ITEM_SET_COLLECTIONS_DATA_MANAGER:SortTopLevelCategories()
			ITEM_SET_COLLECTIONS_DATA_MANAGER:FireCallbacks("CollectionsUpdated")
		end
	end
end

function EsoUA_SaveAnchor()
	local isValidAnchor, point, relativeTo, relativePoint, offsetX, offsetY = EsoUAUI:GetAnchor()
	if isValidAnchor then
		EsoUA.Settings.Anchor = { point, relativePoint, offsetX, offsetY }
	end
end

function EsoUA:MagicReplace(str, what, with)
    what = zo_strgsub(what, "[%(%)%.%+%-%*%?%[%]%^%$%%]", "%%%1")
    with = zo_strgsub(with, "[%%]", "%%%%")
    return zo_strgsub(str, what, with)
end

function EsoUA:DumpUA()
	local rsv = EsoUA.Settings.Data
	
	for i = 1, 300000 do

		local hasSet, setName = GetItemLinkSetInfo(string.format("|H1:item:%d:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h", i)) 
		
		if hasSet then
			rsv.SetsNames[ZO_CachedStrFormat("<<z:1>>", setName)] = i
		end
	end
	
	for i = 1, #ruesoLinks do
		rsv.Potions[zo_strlower(GetItemLinkName(string.format("|H1:item:%s:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h", ruesoLinks[i])))] = ruesoLinks[i]
	end
	
	for i = 1, #ruesoParts do
		rsv.Parts[ZO_CachedStrFormat("<<z:1>>", GetItemLinkName(string.format("|H1:item:%d:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h", ruesoParts[i])))] = ruesoParts[i]
	end
	
	for i = 1, #ruesoEnchantPrefixes do
		rsv.EnchantPrefixes[EsoUA:MagicReplace(zo_strlower(GetItemLinkName(string.format("|H1:item:%s:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h", ruesoEnchantPrefixes[i]))), " " .. GetItemLinkName("|H1:item:5364:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h"), "")] = ruesoEnchantPrefixes[i]
	end
	
	for i = 1, #ruesoPrefixes do
		local str = EsoUA:MagicReplace(ZO_CachedStrFormat("<<z:1>>", GetItemLinkName(string.format("|H1:item:%s:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h", ruesoPrefixes[i]))), " " .. ZO_CachedStrFormat("<<z:1>>", GetItemLinkName("|H1:item:" .. string.match(ruesoPrefixes[i], "^(%d+):") .. ":0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h")), "")
		rsv.Prefixes[str:sub(1, #str - 4)] = ruesoPrefixes[i]
	end
	
	for i = 1, #ruesoAffixes do
		rsv.Affixes[EsoUA:MagicReplace(ZO_CachedStrFormat("<<z:1>>", GetItemLinkName(string.format("|H1:item:43533:0:0:%d:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h", ruesoAffixes[i]))), ZO_CachedStrFormat("<<z:1>>", GetItemLinkName("|H1:item:43533:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h")) .. " ", "")] = ruesoAffixes[i]
	end
	
	-- Locations
	
	local backupLocations = EsoUA.Settings.ShowLocations
	EsoUA.Settings.ShowLocations = "ua"
	
	local zonesCount = GetNumZones()
	for i = 1, zonesCount do
		local locationName = ZO_CachedStrFormat("<<z:1>>", GetZoneNameByIndex(i))
		if locationName then
			rsv.Locations[locationName] = string.format("zone:%d:0", i)
		end
		
		local POIsCount = GetNumPOIs(i)
		for j = 1, POIsCount do
			local locationName = ZO_CachedStrFormat("<<z:1>>", GetPOIInfo(i, j))
			if locationName then
				rsv.Locations[locationName] = string.format("poi:%d:%d", i, j)
			end
		end
	end
	
	local fastTravelNodesCount = GetNumFastTravelNodes()
	for i = 1, fastTravelNodesCount do
		local _, locationName = GetFastTravelNodeInfo(i)
		if locationName then
			rsv.Locations[ZO_CachedStrFormat("<<z:1>>", locationName)] = string.format("ft:%d:0", i)
		end
	end
	
	for i = 1, 1000 do
		local locationName = ZO_CachedStrFormat("<<z:1>>", GetKeepName(i))
		if locationName then
			rsv.Locations[locationName] = string.format("keep:%d:0", i)
		end
	end
	
	EsoUA.Settings.ShowLocations = backupLocations
	
	EsoUA.Settings["enDump"] = true
	SetCVar("language.2", "en")
end

function EsoUA:DumpEn()
	local rsv = EsoUA.Settings.Data
	
	-- Items
	
	for i = 1, 300000 do
		local itemName = GetItemLinkName(string.format("|H1:item:%d:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h", i))
		
		if itemName and itemName ~= "" and not string.match(itemName, "_") then
			rsv.Items[i] = ZO_CachedStrFormat(SI_TOOLTIP_ITEM_NAME, itemName)
		end

		local hasSet, setName, _, _, _, setId = GetItemLinkSetInfo(string.format("|H1:item:%d:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h", i))
		
		if hasSet then
			rsv.Sets[setId] = setName
		end

		--[[local _, enchantHeader = GetItemLinkEnchantInfo("|H1:item:" .. i .. ":0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h")
		local enchantId = GetItemLinkFinalEnchantId("|H1:item:" .. i .. ":0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h")

		if enchantHeader and enchantHeader ~= "" and enchantHeader ~= "Enchantment" then
			rsv.Enchants[enchantId] = EsoUA:MagicReplace(enchantHeader, " Enchantment", "")
		end]]
	end
	
	-- Tribute Cards
	
	--[[for i = 1, 1000 do
		local cardName = GetTributeCardName(i)
		
		if cardName and cardName ~= "" then
			rsv.TributeCards[i] = ZO_CachedStrFormat(SI_TOOLTIP_ITEM_NAME, cardName)
		end
	end]]
	
	-- Set Names
	
	for index,value in pairs(rsv.SetsNames) do
		local hasSet, setName = GetItemLinkSetInfo(string.format("|H1:item:%d:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h", value))
		rsv.SetsNames[index] = ZO_CachedStrFormat(SI_TOOLTIP_ITEM_NAME, setName)
	end
	
	-- Alchemy
	
	for index,value in pairs(rsv.Potions) do
		rsv.Potions[index] = ZO_CachedStrFormat(SI_TOOLTIP_ITEM_NAME, GetItemLinkName(string.format("|H1:item:%s:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h", value)))
	end
	
	-- Item Parts
	
	for index,value in pairs(rsv.Parts) do
		rsv.Parts[index] = ZO_CachedStrFormat(SI_TOOLTIP_ITEM_NAME, GetItemLinkName(string.format("|H1:item:%d:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h", value)))
	end
	
	-- Enchantment Prefixes
	
	for index,value in pairs(rsv.EnchantPrefixes) do
		rsv.EnchantPrefixes[index] = ZO_CachedStrFormat(SI_TOOLTIP_ITEM_NAME, EsoUA:MagicReplace(GetItemLinkName(string.format("|H1:item:%s:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h", value)), " " .. GetItemLinkName("|H1:item:5364:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h"), ""))
	end
	
	-- Item Prefixes
	
	for index,value in pairs(rsv.Prefixes) do
		rsv.Prefixes[index] = EsoUA:MagicReplace(ZO_CachedStrFormat(SI_TOOLTIP_ITEM_NAME, GetItemLinkName(string.format("|H1:item:%s:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h", value))), " " .. ZO_CachedStrFormat(SI_TOOLTIP_ITEM_NAME, GetItemLinkName("|H1:item:" .. string.match(value, "^(%d+):") .. ":0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h")), "")
	end
	
	-- Item Affixes
	
	for index,value in pairs(rsv.Affixes) do
		rsv.Affixes[index] = EsoUA:MagicReplace(ZO_CachedStrFormat(SI_TOOLTIP_ITEM_NAME, GetItemLinkName(string.format("|H1:item:43533:0:0:%d:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h", value))), ZO_CachedStrFormat(SI_TOOLTIP_ITEM_NAME, GetItemLinkName("|H1:item:43533:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h")) .. " ", "")
	end
	
	-- Locations
	
	for index,value in pairs(rsv.Locations) do
		local locType, locId, locSubId = string.match(value, "^(.*):(%d+):(%d+)$")
		
		if locType and locId and locSubId then
			if locType == "zone" then
				rsv.Locations[index] = ZO_CachedStrFormat(SI_ZONE_NAME, GetZoneNameByIndex(locId))
			elseif locType == "poi" then
				rsv.Locations[index] = ZO_CachedStrFormat(SI_ZONE_NAME, GetPOIInfo(locId, locSubId))
			elseif locType == "keep" then
				rsv.Locations[index] = ZO_CachedStrFormat(SI_ZONE_NAME, GetKeepName(locId))
			elseif locType == "ft" then
				local _, locationName = GetFastTravelNodeInfo(locId)
				rsv.Locations[index] = ZO_CachedStrFormat(SI_ZONE_NAME, locationName)
			end
		end
	end
	
	-- Traits
	
	for i = 1, 100 do
		local traitName = GetString("SI_ITEMTRAITTYPE", i)
		
		if traitName and traitName ~= "" then
			rsv.Traits[i] = traitName
		end
	end
	
	-- Abilities
	
	local numSkillTypes = GetNumSkillTypes()
	
	for i = 1, numSkillTypes do
		local numSkillLines = GetNumSkillLines(i)
		
		for j = 1, numSkillLines do
			local numSkillAbilities = GetNumSkillAbilities(i, j)
			
			for k = 1, numSkillAbilities do
				
				local _, _, _, passive = GetSkillAbilityInfo(i, j, k)
				
				if passive then
					for l = 1,GetNumPassiveSkillRanks(i, j, k) do
						local currentMorphId = GetSpecificSkillAbilityInfo(i, j, k, 0, l)
						rsv.Abilities[currentMorphId] = GetAbilityName(currentMorphId)
					end
				else
					local currentMorphId = GetSpecificSkillAbilityInfo(i, j, k, 0, 1)
					rsv.Abilities[currentMorphId] = GetAbilityName(currentMorphId)
					
					local currentMorphId = GetSpecificSkillAbilityInfo(i, j, k, 1, 1)
					rsv.Abilities[currentMorphId] = GetAbilityName(currentMorphId)
					
					local currentMorphId = GetSpecificSkillAbilityInfo(i, j, k, 2, 1)
					rsv.Abilities[currentMorphId] = GetAbilityName(currentMorphId)
				end
			end
		end
	end
	
	for key,value in pairs(ruesoCompanionAbilities) do
		rsv.Abilities[key] = GetAbilityName(key)
	end

	for i = 1, GetNumChampionDisciplines() do
		for j = 1, GetNumChampionDisciplineSkills(i) do
			rsv.Abilities[GetChampionAbilityId(GetChampionSkillId(i, j))] = GetChampionSkillName(GetChampionSkillId(i, j))
		end
	end
	
	EsoUA.Settings["enDump"] = nil
	EsoUA.Settings["success"] = true
	
	rsv.ApiVersion = GetAPIVersion()
	rsv.AddonVersion = EsoUA.Version
	EsoUA.Settings.IsUpdateNeeded = true,
	
	SetCVar("language.2", "ua")
end

function EsoUA:Check()

	local rsv = EsoUA.Settings

	if GetCVar("language.2") == "en" and rsv["enDump"] ~= nil then
		EsoUA:DumpEn()
	end
	
	if GetCVar("language.2") == "ua" and rsv["ruDump"] ~= nil then
		rsv["ruDump"] = nil
		EsoUA:DumpUA()
	end
	
	if rsv["success"] ~= nil then
		rsv["success"] = nil
	end
end

function EsoUA:IsAddonRunning(addonName)
    local manager = GetAddOnManager()
    for i = 1, manager:GetNumAddOns() do
        local name, _, _, _, _, state = manager:GetAddOnInfo(i)
        if name == addonName and state == ADDON_STATE_ENABLED then
            return true
        end
    end
    return false
end

function EsoUA_Dump()
	local rsd = EsoUA.Settings.Data
	rsd.Sets = {}
	rsd.SetsNames = {}
	rsd.Potions = {}
	rsd.Traits = {}
	rsd.Abilities = {}
	rsd.Items = {}
	rsd.Parts = {}
	rsd.Prefixes = {}
	rsd.Affixes = {}
	rsd.EnchantPrefixes = {}
	rsd.Locations = EsoUA_getLocations()
	rsd.CraftAbilities = EsoUA_getCraftAbilities()
	
	if GetCVar("language.2") == "ua" then
		EsoUA:DumpUA()
	else
		EsoUA.Settings["ruDump"] = true
		SetCVar("language.2", "ua")
	end
end

--[[ function EsoUA_Dump_Dev()
	local rsd = EsoUA.Settings.Data
	
	if not rsd.Companions then
		rsd.Companions = {}
	end
	
	local numSkillTypes = GetNumSkillTypes()
	
	for i = 1, numSkillTypes do
		local numSkillLines = GetNumCompanionSkillLines(i)
		
		for j = 1, numSkillLines do
			local skillLineId = GetCompanionSkillLineId(i, j)
			local numSkillAbilities = GetNumAbilitiesInCompanionSkillLine(skillLineId)
			
			for k = 1, numSkillAbilities do
				local currentAbilityId = GetCompanionAbilityId(skillLineId, k)
				rsd.Companions[currentAbilityId] = GetAbilityName(currentAbilityId)
			end
		end
	end
end ]]

EVENT_MANAGER:RegisterForEvent("EsoUA_OnAddOnLoaded", EVENT_ADD_ON_LOADED, function(_event, _name) EsoUA:OnInit(_event, _name) end)
EVENT_MANAGER:RegisterForEvent("EsoUA_StartupMessage", EVENT_PLAYER_ACTIVATED, function(...) EsoUA:StartupMessage() end)

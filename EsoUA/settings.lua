local EsoUASettings = ZO_Object:Subclass()
ESOUA_SETTINGS = EsoUASettings

function EsoUASettings:New(...)
    local settings = ZO_Object.New(self)
    settings:Initialize(...)
    return settings
end

function EsoUASettings:Initialize(EsoUA)
	self.LAM = LibAddonMenu2
	self:InitSettings(EsoUA)
end

function EsoUASettings:InitSettings(EsoUA)

    local panelData = {
		type = "panel",
		name = EsoUA.Name,
		displayName = EsoUA.Name,
		author = "ESO.pp.UA",
		version = EsoUA.Version,
		slashCommand = "/esoua",
		registerForRefresh = true,
		registerForDefaults = true,
		website = "https://eso.pp.ua/"
	}
	
	self.LAM:RegisterAddonPanel(panelData.name, panelData)
	
	local optionsTable = {}
	
	table.insert(optionsTable, {
		type = "header",
		name = "Оновлення мовної бази",
		width = "full",	--or "half" (optional)
	})
	
	table.insert(optionsTable, {
		type = "button",
		name = "Оновити базу",
		tooltip = "Робить індексацію мовного файлу після оновлення гри чи аддону",
		func = EsoUA_Dump,
	})

	table.insert(optionsTable, {
		type = "header",
		name = "Оригінальні назви (різне)",
		width = "full",	--or "half" (optional)
	})
	
	
	
	table.insert(optionsTable, {
		type = "dropdown",
		name = "Назви локацій",
		warning = (function()
			if EsoUA:IsDBOld() then
				return "Потрібне оновлення мовної бази."
			else
				return false
			end
		end),
		disabled = function() return EsoUA:IsDBOld() end,
		tooltip = "Дозволяє налаштувати мову відображення назв локацій.",
		choices = {EsoUA.DropdownParameters["ua"], EsoUA.DropdownParameters["uaen"], EsoUA.DropdownParameters["enua"], EsoUA.DropdownParameters["en"]},
		choicesValues = {"ua", "uaen", "enua", "en"},			
		getFunc = function() return EsoUA.Settings.ShowLocations end,
		setFunc = (function(value)
			EsoUA.Settings.ShowLocations = value
			
			if value ~= "ua" and EsoUA_doubleNamesLocations then
				EsoUA_doubleNamesLocations(EsoUA)
			end
			
			FRIENDS_LIST_MANAGER:BuildMasterList()
			FRIENDS_LIST_MANAGER:OnSocialDataLoaded()
			GUILD_ROSTER_MANAGER:BuildMasterList()
			GUILD_ROSTER_MANAGER:OnGuildDataLoaded()
			
			LFGDoubleNames(EsoUA)
			
			CADWELLS_ALMANAC:RefreshList()
			CALLBACK_MANAGER:FireCallbacks("OnWorldMapChanged")
			EsoUA:MapNameStyle()
		end),
		width = "full",
	})
	
	table.insert(optionsTable, {
		type = "dropdown",
		name = "Назви наборів у ремісничих верстатах",
		warning = (function()
			if EsoUA:IsDBOld() then
				return "Потрібне оновлення мовної бази."
			else
				return false
			end
		end),
		disabled = function() return EsoUA:IsDBOld() end,
		tooltip = "Дозволяє налаштувати мову відображення назв наборів під час наведення на ремісничі верстати.",
		choices = {EsoUA.DropdownParameters["ua"], EsoUA.DropdownParameters["uaen"], EsoUA.DropdownParameters["enua"], EsoUA.DropdownParameters["en"]},
		choicesValues = {"ua", "uaen", "enua", "en"},
		getFunc = function() return EsoUA.Settings.ShowCraft end,
		setFunc = (function(value)
			EsoUA.Settings.ShowCraft = value
			
			if value ~= "ua" and EsoUA_doubleNamesBoth then
				EsoUA_doubleNamesBoth(EsoUA)
			end
		end),
		width = "full",
	})
	
	table.insert(optionsTable, {
		type = "header",
		name = "Оригінальні назви (здібності)",
		width = "full",	--or "half" (optional)
	})
	
	table.insert(optionsTable, {
		type = "dropdown",
		name = "Здібності (меню)",
		warning = (function()
			if EsoUA:IsDBOld() then
				return "Потрібне оновлення бази."
			else
				return false
			end
		end),
		disabled = function() return EsoUA:IsDBOld() end,
		choices = {EsoUA.DropdownParameters["ua"], EsoUA.DropdownParameters["en"]},
		choicesValues = {"ua", "en"},
		tooltip = "Дозволяє налаштувати мову відображення назв здібностей у відповідному розділі.",
		getFunc = function() return EsoUA.Settings.ShowAbilitiesMenu end,
		setFunc = (function(value)
			EsoUA.Settings.ShowAbilitiesMenu = value
			
			if value ~= "ua" and EsoUA_doubleNamesAbilities then
				EsoUA_doubleNamesAbilities(EsoUA)
			end
			
			SKILLS_WINDOW:RebuildSkillLineList()
			COMPANION_SKILLS_DATA_MANAGER:RebuildSkillsData()
		end),
	})
	
	table.insert(optionsTable, {
		type = "dropdown",
		name = "Здібності (випливаючі вікна)",
		warning = (function()
			if EsoUA:IsDBOld() then
				return "Потрібне оновлення бази."
			else
				return false
			end
		end),
		disabled = function() return EsoUA:IsDBOld() end,
		choices = {EsoUA.DropdownParameters["ua"], EsoUA.DropdownParameters["uaen"], EsoUA.DropdownParameters["enua"], EsoUA.DropdownParameters["en"]},
		choicesValues = {"ua", "uaen", "enua", "en"},
		tooltip = "Дозволяє налаштувати мову відображення назв здібностей у спливаючих вікнах.",
		getFunc = function() return EsoUA.Settings.ShowAbilitiesTooltip end,
		setFunc = (function(value)
			EsoUA.Settings.ShowAbilitiesTooltip = value
			
			if value ~= "ua" and EsoUA_doubleNamesAbilities then
				EsoUA_doubleNamesAbilities(EsoUA)
			end
		end),
	})
	
	table.insert(optionsTable, {
		type = "dropdown",
		name = "Система героя",
		warning = (function()
			if EsoUA:IsDBOld() then
				return "Потрібне оновлення бази."
			else
				return false
			end
		end),
		disabled = function() return EsoUA:IsDBOld() end,
		choices = {EsoUA.DropdownParameters["ua"], EsoUA.DropdownParameters["uaen"], EsoUA.DropdownParameters["enua"], EsoUA.DropdownParameters["en"]},
		choicesValues = {"ua", "uaen", "enua", "en"},
		tooltip = "Дозволяє налаштувати мову відображення назв здібностей у розділі системи героя.",
		getFunc = function() return EsoUA.Settings.ShowChampionTooltip end,
		setFunc = (function(value)
			EsoUA.Settings.ShowChampionTooltip = value
			
			if value ~= "ua" and EsoUA_doubleNamesChampion then
				EsoUA_doubleNamesChampion(EsoUA)
			end
		end),
	})
	
	table.insert(optionsTable, {
		type = "header",
		name = "Оригінальні назви (предмети)",
		width = "full",	--or "half" (optional)
	})
	
	table.insert(optionsTable, {
		type = "dropdown",
		name = "Предмети (випливаючі вікна)",
		warning = (function()
			if EsoUA:IsDBOld() then
				return "Потрібне оновлення бази."
			else
				return false
			end
		end),
		disabled = function() return EsoUA:IsDBOld() end,
		choices = {EsoUA.DropdownParameters["ua"], EsoUA.DropdownParameters["uaen"], EsoUA.DropdownParameters["enua"], EsoUA.DropdownParameters["en"]},
		choicesValues = {"ua", "uaen", "enua", "en"},
		tooltip = "Дозволяє налаштувати мову відображення назв предметів у спливаючих вікнах.",
		getFunc = function() return EsoUA.Settings.ShowItemsNamesTooltip end,
		setFunc = (function(value)
			EsoUA.Settings.ShowItemsNamesTooltip = value
			
			if value ~= "ua" and EsoUA_doubleNamesItems then
				EsoUA_doubleNamesItems(EsoUA)
			end
		end),
	})
	
	table.insert(optionsTable, {
		type = "dropdown",
		name = "Зачарування (випливаючі вікна)",
		warning = (function()
			if EsoUA:IsDBOld() then
				return "Потрібне оновлення бази."
			else
				return false
			end
		end),
		disabled = function() return EsoUA:IsDBOld() end,
		choices = {EsoUA.DropdownParameters["ua"], EsoUA.DropdownParameters["uaen"], EsoUA.DropdownParameters["enua"], EsoUA.DropdownParameters["en"]},
		choicesValues = {"ua", "uaen", "enua", "en"},
		tooltip = "Дозволяє налаштувати мову відображення назв чарів у спливаючих вікнах.",
		getFunc = function() return EsoUA.Settings.ShowItemsEnchantsTooltip end,
		setFunc = (function(value)
			EsoUA.Settings.ShowItemsEnchantsTooltip = value
			
			if value ~= "ua" and EsoUA_doubleNamesItems then
				EsoUA_doubleNamesItems(EsoUA)
			end
		end),
	})
	
	table.insert(optionsTable, {
		type = "dropdown",
		name = "Особливості (випливаючі вікна)",
		warning = (function()
			if EsoUA:IsDBOld() then
				return "Потрібне оновлення мовної бази."
			else
				return false
			end
		end),
		disabled = function() return EsoUA:IsDBOld() end,
		choices = {EsoUA.DropdownParameters["ua"], EsoUA.DropdownParameters["uaen"], EsoUA.DropdownParameters["enua"], EsoUA.DropdownParameters["en"]},
		choicesValues = {"ua", "uaen", "enua", "en"},
		tooltip = "Дозволяє налаштувати мову відображення назв особливостей у спливаючих вікнах.",
		getFunc = function() return EsoUA.Settings.ShowItemsTraitsTooltip end,
		setFunc = (function(value)
			EsoUA.Settings.ShowItemsTraitsTooltip = value
			
			if value ~= "ua" and EsoUA_doubleNamesItems then
				EsoUA_doubleNamesItems(EsoUA)
			end
		end),
	})
	
	table.insert(optionsTable, {
		type = "dropdown",
		name = "Набори (випливаючі вікна)",
		warning = (function()
			if EsoUA:IsDBOld() then
				return "Потрібне оновлення мовної бази."
			else
				return false
			end
		end),
		disabled = function() return EsoUA:IsDBOld() end,
		choices = {EsoUA.DropdownParameters["ua"], EsoUA.DropdownParameters["uaen"], EsoUA.DropdownParameters["enua"], EsoUA.DropdownParameters["en"]},
		choicesValues = {"ua", "uaen", "enua", "en"},
		tooltip = "Дозволяє налаштувати мову відображення назв наборів у спливаючих вікнах.",
		getFunc = function() return EsoUA.Settings.ShowItemsSetsTooltip end,
		setFunc = (function(value)
			EsoUA.Settings.ShowItemsSetsTooltip = value
			
			if value ~= "ua" and EsoUA_doubleNamesItems then
				EsoUA_doubleNamesItems(EsoUA)
			end
		end),
	})
	
	table.insert(optionsTable, {
		type = "header",
		name = "Оригінальні назви (колекція наборів)",
		width = "full",	--or "half" (optional)
	})
	
	table.insert(optionsTable, {
		type = "checkbox",
		name = "Двомовний пошук",
		warning = (function()
			if EsoUA:IsDBOld() then
				return "Потрібне оновлення мовної бази."
			else
				return false
			end
		end),
		disabled = function() return EsoUA:IsDBOld() end,
		tooltip = "Дозволяє використовувати англійську назву наборів під час пошуку в меню колекцій.",
		getFunc = function() return EsoUA.Settings.EnglishSearch end,
		setFunc = (function(value)
			EsoUA.Settings.EnglishSearch = value
			
			if value and EsoUA_doubleNamesCollections then
				EsoUA_doubleNamesCollections(EsoUA)
			end
		end),
	})
	
	table.insert(optionsTable, {
		type = "dropdown",
		name = "Набори (меню)",
		warning = (function()
			if EsoUA:IsDBOld() then
				return "Потрібне оновлення мовної бази."
			else
				return false
			end
		end),
		disabled = function() return EsoUA:IsDBOld() end,
		choices = {EsoUA.DropdownParameters["ua"], EsoUA.DropdownParameters["uaen"], EsoUA.DropdownParameters["enua"], EsoUA.DropdownParameters["en"]},
		choicesValues = {"ua", "uaen", "enua", "en"},
		tooltip = "Дозволяє налаштувати мову відображення назв наборів у меню колекцій.",
		getFunc = function() return EsoUA.Settings.ShowCollectionsSetsMenu end,
		setFunc = (function(value)
			EsoUA.Settings.ShowCollectionsSetsMenu = value
			
			if value ~= "ua" and EsoUA_doubleNamesCollections then
				EsoUA_doubleNamesCollections(EsoUA)
			end
			ITEM_SET_COLLECTIONS_DATA_MANAGER:SortTopLevelCategories()
			ITEM_SET_COLLECTIONS_DATA_MANAGER:FireCallbacks("CollectionsUpdated")
		end),
	})
		
	self.LAM:RegisterOptionControls(panelData.name, optionsTable)
end
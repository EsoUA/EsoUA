local EsoUA_Lite = {}
EsoUA_Lite.name  = "EsoUA Lite"
EsoUA_Lite.version = "1.0"
EsoUA_Lite.langString = nil
EsoUA_Lite.positionning = false
EsoUA_Lite.Flags = { "en", "ua" }

EsoUA_Lite.defaults = {
	Enable	= true,
	anchor	= {BOTTOMRIGHT, BOTTOMRIGHT, 0, 7},
	Flags = {
		["en"]	= true,
		["ua"]	= true,
	}
}
EsoUA_Lite.settings = EsoUA_Lite.defaults

local confirmDialog = {
    title = { text = zo_iconFormat("EsoUA_Lite/images/".."es.dds", 24, 24).." EsoUA Lite "..zo_iconFormat("EsoUA_Lite/images/".."es.dds", 24, 24)},
    mainText = { text = "Українізатор «EsoUA Lite»\n\nПри натисканні ESC в нижньому куті мають з'являтись два прапорці (англійська, українська).\n\nКлацніть на потрібний щоб перемкнути мову\n\n"},
    buttons = {
        { text = SI_DIALOG_ACCEPT, callback = functionToCall},
    }
}
ZO_Dialogs_RegisterCustomDialog("ADDON_DIALOG", confirmDialog )

if GetCVar("IgnorePatcherLanguageSetting") == "0" then
	ZO_Dialogs_ShowDialog("ADDON_DIALOG")
end

function EsoUA_Lite_ChangeLanguage(lang)
	if lang ~= GetCVar("language.2") then
	  if lang == "en" then
		SetCVar("IgnorePatcherLanguageSetting", 0)
	  else
		SetCVar("IgnorePatcherLanguageSetting", 1)
	  end
	  SetCVar("language.2", lang)
	end
  end


function EsoUA_Lite:RefreshUI()
	local flagControl
	local count = 0
	local flagTexture
	for _, flagCode in pairs(EsoUA_Lite.Flags) do
		flagTexture = "EsoUA_Lite/images/"..flagCode..".dds"
		flagControl = GetControl("EsoUA_Lite_FlagControl_"..tostring(flagCode))
		if flagControl == nil then
			flagControl = CreateControlFromVirtual("EsoUA_Lite_FlagControl_", EsoUA_LiteUI, "EsoUA_Lite_FlagControl", tostring(flagCode))
			if flagControl:GetHandler("OnMouseDown") == nil then flagControl:SetHandler("OnMouseDown", function() EsoUA_Lite_ChangeLanguage(flagCode) end) end
			GetControl("EsoUA_Lite_FlagControl_"..flagCode.."Texture"):SetTexture(flagTexture)
		end
		if EsoUA_Lite.settings.Flags[flagCode] then
			flagControl:ClearAnchors()
			flagControl:SetAnchor(LEFT, EsoUA_LiteUI, LEFT, 14 +count*34, 0)
			count = count +1
		end
		flagControl:SetMouseEnabled(true)
		flagControl:SetHidden(not EsoUA_Lite.settings.Flags[flagCode])
	end
	EsoUA_LiteUI:SetDimensions(25 +count*34, 50)
	EsoUA_LiteUI:SetMouseEnabled(true)

end

function EsoUA_Lite_Selected()
	local isValidAnchor, point, relativeTo, relativePoint, offsetX, offsetY = EsoUA_LiteUI:GetSelected()
	if isValidAnchor then
		EsoUA_Lite.settings.anchor = { point, relativePoint, offsetX, offsetY }
	end
end

function EsoUA_Lite:OnInit(eventCode, addOnName)
	EsoUA_Lite.langString = GetCVar("language.2")
	EsoUA_Lite.settings = ZO_SavedVars:NewAccountWide("EsoUA_Lite_settings", 1, nil, EsoUA_Lite.defaults)

	for _, flagCode in pairs(EsoUA_Lite.Flags) do
		ZO_CreateStringId("SI_BINDING_NAME_"..string.upper(flagCode), string.upper(flagCode))
	end

	EsoUA_Lite:RefreshUI()
	EsoUA_LiteUI:ClearAnchors()
	EsoUA_LiteUI:SetAnchor(EsoUA_Lite.settings.anchor[1], GuiRoot, EsoUA_Lite.settings.anchor[2], EsoUA_Lite.settings.anchor[3], EsoUA_Lite.settings.anchor[4])
	EsoUA_Lite:registerEvents(true)

	EVENT_MANAGER:UnregisterForEvent(EsoUA_Lite.name, EVENT_ADD_ON_LOADED)
end

function EsoUA_Lite:registerEvents(state)
	if state then
		EVENT_MANAGER:RegisterForEvent(EsoUA_Lite.name, EVENT_RETICLE_HIDDEN_UPDATE, function(eventCode, hidden) if EsoUA_Lite.settings.Enable then EsoUA_LiteUI:SetHidden(not hidden) end end)
	else
		EVENT_MANAGER:UnregisterForEvent(EsoUA_Lite.name, EVENT_RETICLE_HIDDEN_UPDATE)
	end
end

EVENT_MANAGER:RegisterForEvent(EsoUA_Lite.name, EVENT_ADD_ON_LOADED , function(_event, _name) EsoUA_Lite:OnInit(_event, _name) end)
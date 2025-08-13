function EsoUA_doubleNamesLocations(EsoUA)

	local rsd = EsoUA.Settings.Data
	
	-- Third-party Compatibility
	-- AwesomeGuildStore
	local AGSform1 = "|ca99e83"
	local AGSform2 = "|r"
	
	if EsoUA:IsAddonRunning("AwesomeGuildStore") then
		if AwesomeGuildStore.class.StoreLocationHelper then
			ZO_PreHook(AwesomeGuildStore.class.StoreLocationHelper, "CollectStoresOnCurrentMap", function()
				AGSform1 = ""
				AGSform2 = ""
			end)
			ZO_PreHook(AwesomeGuildStore.class.StoreLocationHelper, "UpdateKioskAndStore", function()
				AGSform1 = ""
				AGSform2 = ""
			end)
			ZO_PostHook(AwesomeGuildStore.class.StoreLocationHelper, "CollectStoresOnCurrentMap", function()
				AGSform1 = "|ca99e83"
				AGSform2 = "|r"
			end)
			ZO_PostHook(AwesomeGuildStore.class.StoreLocationHelper, "UpdateKioskAndStore", function()
				AGSform1 = "|ca99e83"
				AGSform2 = "|r"
			end)
		end
	end
	
	-- EasyTravel
	if EsoUA:IsAddonRunning("EasyTravel") then
		local ShowLocationsBackup
		
		if EasyTravel.PlayerList and EasyTravel.PlayerList.Rebuild then
			ZO_PreHook(EasyTravel.PlayerList, "Rebuild", function()
				ShowLocationsBackup = EsoUA.Settings.ShowLocations
				EsoUA.Settings.ShowLocations = "ua"
			end)
			
			ZO_PostHook(EasyTravel.PlayerList, "Rebuild", function()
				EsoUA.Settings.ShowLocations = ShowLocationsBackup
			end)
		end
		
		if EasyTravel.class and EasyTravel.class.PlayerList and EasyTravel.class.PlayerList.Rebuild then
			ZO_PreHook(EasyTravel.class.PlayerList, "Rebuild", function()
				ShowLocationsBackup = EsoUA.Settings.ShowLocations
				EsoUA.Settings.ShowLocations = "ua"
			end)
			
			ZO_PostHook(EasyTravel.class.PlayerList, "Rebuild", function()
				EsoUA.Settings.ShowLocations = ShowLocationsBackup
			end)
		end
	end

	-- Unboxer
	if EsoUA:IsAddonRunning("Unboxer") then
		local ShowLocationsBackup
		
		if Unboxer.classes.rules.rewards.Solo then
			ZO_PreHook(Unboxer.classes.rules.rewards.Solo, "GetDlcs", function()
				ShowLocationsBackup = EsoUA.Settings.ShowLocations
				EsoUA.Settings.ShowLocations = "ua"
			end)
			
			ZO_PostHook(Unboxer.classes.rules.rewards.Solo, "GetDlcs", function()
				EsoUA.Settings.ShowLocations = ShowLocationsBackup
			end)
		end
	end
	-- Third-party Compatibility
	
	local GetMapLocationTooltipHeaderOld = GetMapLocationTooltipHeader
	
	function GetMapLocationTooltipHeader(...)
		local headerText = ZO_CachedStrFormat(SI_ZONE_NAME, GetMapLocationTooltipHeaderOld(...))
		
		if (headerText == nil or EsoUA.Settings.ShowLocations == "ua") then
			return headerText
		end
		
		newLocName = rsd.Locations[ZO_CachedStrFormat("<<z:1>>", headerText)]
		
		if newLocName ~= nil then
			if EsoUA.Settings.ShowLocations == "uaen" then
				headerText = headerText .. "\n" .. AGSform1 .. newLocName .. AGSform2
			elseif EsoUA.Settings.ShowLocations == "enua" then
				headerText = newLocName .. "\n" .. AGSform1 .. headerText .. AGSform2
			else
				headerText = newLocName
			end
		end
		
		return headerText
	end
	
	local GetPOIInfoOld = GetPOIInfo
	
	function GetPOIInfo(...)
		local poiName, _, poiStartDesc, poiFinishedDesc = GetPOIInfoOld(...)
		
		if (poiName == nil or EsoUA.Settings.ShowLocations == "ua") then
			return ZO_CachedStrFormat(SI_ZONE_NAME, poiName), _, poiStartDesc, poiFinishedDesc
		end
		
		newLocName = rsd.Locations[ZO_CachedStrFormat("<<z:1>>", poiName)]
			
		if newLocName ~= nil then
			if (EsoUA.Settings.ShowLocations == "uaen") then
				poiName = ZO_CachedStrFormat(SI_ZONE_NAME, poiName) .. " (" .. newLocName .. ")"
			elseif (EsoUA.Settings.ShowLocations == "enua") then
				poiName = newLocName .. " (" .. zo_strformat("<<1>>", poiName) .. ")"
			else
				poiName = newLocName
			end
		end
		
		return poiName, _, poiStartDesc, poiFinishedDesc
	end
	
	local GetMapMouseoverInfoOld = GetMapMouseoverInfo
	
	function GetMapMouseoverInfo(...)
		local locationName, textureFile, widthN, heightN, locXN, locYN = GetMapMouseoverInfoOld(...)
		
		if (locationName == nil or EsoUA.Settings.ShowLocations == "ua") then
			return ZO_CachedStrFormat(SI_ZONE_NAME, locationName), textureFile, widthN, heightN, locXN, locYN
		end
		
		newLocName = rsd.Locations[ZO_CachedStrFormat("<<z:1>>", locationName)]
			
		if newLocName ~= nil then
			if (EsoUA.Settings.ShowLocations == "uaen") then
				locationName = ZO_CachedStrFormat(SI_ZONE_NAME, locationName) .. "\n" .. newLocName
			elseif (EsoUA.Settings.ShowLocations == "enua") then
				locationName = newLocName .. "\n" .. ZO_CachedStrFormat(SI_ZONE_NAME, locationName)
			else
				locationName = newLocName
			end
		end
		
		return locationName, textureFile, widthN, heightN, locXN, locYN
	end
	
	local GetMapNameOld = GetMapName
	
	function GetMapName(...)
		local zoneName = GetMapNameOld(...)
		
		if (zoneName == nil or EsoUA.Settings.ShowLocations == "ua") then
			return zoneName
		end
		
		newLocName = rsd.Locations[ZO_CachedStrFormat("<<z:1>>", zoneName)]
			
		if newLocName ~= nil then
			if (EsoUA.Settings.ShowLocations == "uaen") then
				zoneName = ZO_CachedStrFormat(SI_ZONE_NAME, zoneName) .. "\n" .. newLocName
			elseif (EsoUA.Settings.ShowLocations == "enua") then
				zoneName = newLocName .. "\n" .. ZO_CachedStrFormat(SI_ZONE_NAME, zoneName)
			else
				zoneName = newLocName
			end
		end
		
		return zoneName
	end
	
	local GetFastTravelNodeInfoOld = GetFastTravelNodeInfo
	
	function GetFastTravelNodeInfo(...)
		local known, name, normalizedX, normalizedY, icon, glowIcon, poiType, isLocatedInCurrentMap, linkedCollectibleIsLocked = GetFastTravelNodeInfoOld(...)
		
		if (name == nil or EsoUA.Settings.ShowLocations == "ua") then
			return known, name, normalizedX, normalizedY, icon, glowIcon, poiType, isLocatedInCurrentMap, linkedCollectibleIsLocked
		end
		
		newLocName = rsd.Locations[ZO_CachedStrFormat("<<z:1>>", name)]
			
		if newLocName ~= nil then
			if (EsoUA.Settings.ShowLocations == "uaen") then
				name = name .. " (" .. newLocName .. ")"
			elseif (EsoUA.Settings.ShowLocations == "enua") then
				name = newLocName .. " (" .. name .. ")"
			else
				name = newLocName
			end
		end
		
		return known, name, normalizedX, normalizedY, icon, glowIcon, poiType, isLocatedInCurrentMap, linkedCollectibleIsLocked
	end
	
	local GetKeepNameOld = GetKeepName
	
	function GetKeepName(...)
		local name = ZO_CachedStrFormat(SI_ZONE_NAME, GetKeepNameOld(...))
		
		if (name == nil or EsoUA.Settings.ShowLocations == "ua") then
			return name
		end
		
		newLocName = rsd.Locations[ZO_CachedStrFormat("<<z:1>>", name)]
			
		if newLocName ~= nil then
			if (EsoUA.Settings.ShowLocations == "uaen") then
				name = name .. " (" .. newLocName .. ")"
			elseif (EsoUA.Settings.ShowLocations == "enua") then
				name = newLocName .. " (" .. name .. ")"
			else
				name = newLocName
			end
		end
		
		return name
	end
	
	local GetMapInfoOld = GetMapInfoByIndex
	
	function GetMapInfoByIndex(...)
		local mapName, mapType, mapContentType, zoneId, description = GetMapInfoOld(...)
		
		if (mapName == nil or EsoUA.Settings.ShowLocations == "ua") then
			return mapName, mapType, mapContentType, zoneId, description
		end
		
		newLocName = rsd.Locations[ZO_CachedStrFormat("<<z:1>>", mapName)]
			
		if newLocName ~= nil then
			if (EsoUA.Settings.ShowLocations == "uaen") then
				mapName = mapName .. " (" .. newLocName .. ")"
			elseif (EsoUA.Settings.ShowLocations == "enua") then
				mapName = newLocName .. " (" .. mapName .. ")"
			else
				mapName = newLocName
			end
		end
		
		return mapName, mapType, mapContentType, zoneId, description
	end
	
	local GetFriendCharacterInfoOld = GetFriendCharacterInfo
	
	local function GetFriendCharacterInfoNew(...)
		local hasCharacter, characterName, zone, class, alliance, level, championPoints, zoneId, consoleId = GetFriendCharacterInfoOld(...)
		
		if (zone == nil or EsoUA.Settings.ShowLocations == "ua") then
			return hasCharacter, characterName, zone, class, alliance, level, championPoints, zoneId, consoleId
		end
		
		zone = ZO_CachedStrFormat(SI_ZONE_NAME, zone)
		
		newLocName = rsd.Locations[ZO_CachedStrFormat("<<z:1>>", zone)]
			
		if newLocName ~= nil then
			if (EsoUA.Settings.ShowLocations == "uaen") then
				zone = zone .. " (" .. newLocName .. ")"
			elseif (EsoUA.Settings.ShowLocations == "enua") then
				zone = newLocName .. " (" .. zone .. ")"
			else
				zone = newLocName
			end
		end
		
		return hasCharacter, characterName, zone, class, alliance, level, championPoints, zoneId, consoleId
	end
	
	ZO_PreHook(FRIENDS_LIST_MANAGER, "BuildMasterList", function()
		GetFriendCharacterInfo = GetFriendCharacterInfoNew
	end)
	
	ZO_PostHook(FRIENDS_LIST_MANAGER, "BuildMasterList", function()
		GetFriendCharacterInfo = GetFriendCharacterInfoOld
	end)
	
	FRIENDS_LIST_MANAGER:BuildMasterList()
	
	ZO_PostHook(FRIENDS_LIST_MANAGER, "OnFriendCharacterZoneChanged", function(tooltip, displayName, characterName, zoneName)
		local data = tooltip:FindDataByDisplayName(displayName)
		
		if data then
			local oldLocation = data.formattedZone
			local newLocName = rsd.Locations[ZO_CachedStrFormat("<<z:1>>", oldLocation)]
			
			if newLocName ~= nil then
				if (EsoUA.Settings.ShowLocations == "uaen") then
					data.formattedZone = oldLocation .. " (" .. newLocName .. ")"
				elseif (EsoUA.Settings.ShowLocations == "enua") then
					data.formattedZone = newLocName .. " (" .. oldLocation .. ")"
				else
					data.formattedZone = newLocName
				end
				
				tooltip:RefreshSort()
			end
		end
	end)
	
	local GetZoneNameByIndexOld = GetZoneNameByIndex
	
	function GetZoneNameByIndex(...)
		local zone = GetZoneNameByIndexOld(...)
		
		if (zone == nil or EsoUA.Settings.ShowLocations == "ua") then
			return zone
		end
		
		zone = ZO_CachedStrFormat(SI_ZONE_NAME, zone)
		
		newLocName = rsd.Locations[ZO_CachedStrFormat("<<z:1>>", zone)]
			
		if newLocName ~= nil then
			if (EsoUA.Settings.ShowLocations == "uaen") then
				zone = zone .. " (" .. newLocName .. ")"
			elseif (EsoUA.Settings.ShowLocations == "enua") then
				zone = newLocName .. " (" .. zone .. ")"
			else
				zone = newLocName
			end
		end
		
		return zone
	end
	
	local GetActivityInfoOld = GetActivityInfo
	
	function GetActivityInfo(...)
		local name, levelMin, levelMax, championPointsMin, championPointsMax, groupType, minGroupSize, description, sortOrder = GetActivityInfoOld(...)
		
		if (name == nil or EsoUA.Settings.ShowLocations == "ua") then
			return name, levelMin, levelMax, championPointsMin, championPointsMax, groupType, minGroupSize, description, sortOrder
		end
		
		name = ZO_CachedStrFormat(SI_ZONE_NAME, name)
		
		newLocName = rsd.Locations[ZO_CachedStrFormat("<<z:1>>", name)]
			
		if newLocName ~= nil then
			if (EsoUA.Settings.ShowLocations == "uaen") then
				name = name .. " (" .. newLocName .. ")"
			elseif (EsoUA.Settings.ShowLocations == "enua") then
				name = newLocName .. " (" .. name .. ")"
			else
				name = newLocName
			end
		end
		
		return name, levelMin, levelMax, championPointsMin, championPointsMax, groupType, minGroupSize, description, sortOrder
	end
	
	local GetGuildMemberCharacterInfoOld = GetGuildMemberCharacterInfo
	
	local function GetGuildMemberCharacterInfoNew(...)
		local hasCharacter, rawCharacterName, zone, class, alliance, level, championPoints, zoneId, consoleId = GetGuildMemberCharacterInfoOld(...)
		
		if (zone == nil or EsoUA.Settings.ShowLocations == "ua") then
			return hasCharacter, rawCharacterName, zone, class, alliance, level, championPoints, zoneId, consoleId
		end
		
		zone = ZO_CachedStrFormat(SI_ZONE_NAME, zone)
		
		newLocName = rsd.Locations[ZO_CachedStrFormat("<<z:1>>", zone)]
			
		if newLocName ~= nil then
			if (EsoUA.Settings.ShowLocations == "uaen") then
				zone = zone .. " (" .. newLocName .. ")"
			elseif (EsoUA.Settings.ShowLocations == "enua") then
				zone = newLocName .. " (" .. zone .. ")"
			else
				zone = newLocName
			end
		end
		
		return hasCharacter, rawCharacterName, zone, class, alliance, level, championPoints, zoneId, consoleId
	end
	
	ZO_PreHook(GUILD_ROSTER_MANAGER, "BuildMasterList", function()
		GetGuildMemberCharacterInfo = GetGuildMemberCharacterInfoNew
	end)
	
	ZO_PostHook(GUILD_ROSTER_MANAGER, "BuildMasterList", function()
		GetGuildMemberCharacterInfo = GetGuildMemberCharacterInfoOld
	end)
	
	GUILD_ROSTER_MANAGER:BuildMasterList()
	
	ZO_PostHook(GUILD_ROSTER_MANAGER, "OnGuildMemberPlayerStatusChanged", function(tooltip, displayName, oldStatus, newStatus)
		local data = tooltip:FindDataByDisplayName(displayName)
		local isOnline = (newStatus ~= PLAYER_STATUS_OFFLINE)
		
		if data and isOnline then
			local oldLocation = data.formattedZone
			local newLocName = rsd.Locations[ZO_CachedStrFormat("<<z:1>>", oldLocation)]
			
			if newLocName ~= nil then
				if (EsoUA.Settings.ShowLocations == "uaen") then
					data.formattedZone = oldLocation .. " (" .. newLocName .. ")"
				elseif (EsoUA.Settings.ShowLocations == "enua") then
					data.formattedZone = newLocName .. " (" .. oldLocation .. ")"
				else
					data.formattedZone = newLocName
				end
				
				tooltip:RefreshFilters()
			end
		end
	end)

	ZO_PostHook(GUILD_ROSTER_MANAGER, "OnGuildMemberCharacterZoneChanged", function(tooltip, displayName, characterName, zone)
		local data = tooltip:FindDataByDisplayName(displayName)
		
		if data then
			local oldLocation = data.formattedZone
			local newLocName = rsd.Locations[ZO_CachedStrFormat("<<z:1>>", oldLocation)]
			
			if newLocName ~= nil then
				if (EsoUA.Settings.ShowLocations == "uaen") then
					data.formattedZone = oldLocation .. " (" .. newLocName .. ")"
				elseif (EsoUA.Settings.ShowLocations == "enua") then
					data.formattedZone = newLocName .. " (" .. oldLocation .. ")"
				else
					data.formattedZone = newLocName
				end
				
				tooltip:RefreshSort()
			end
		end
	end)
	
	local GetCadwellZoneInfoOld = GetCadwellZoneInfo
	
	function GetCadwellZoneInfo(...)
		local zone, zoneDescription, zoneOrder = GetCadwellZoneInfoOld(...)
		
		if (zone == nil or EsoUA.Settings.ShowLocations == "ua") then
			return zone, zoneDescription, zoneOrder
		end
		
		newLocName = rsd.Locations[ZO_CachedStrFormat("<<z:1>>", zone)]
			
		if newLocName ~= nil then
			if (EsoUA.Settings.ShowLocations == "uaen") then
				zone = zone .. " (" .. newLocName .. ")"
			elseif (EsoUA.Settings.ShowLocations == "enua") then
				zone = newLocName .. " (" .. zone .. ")"
			else
				zone = newLocName
			end
		end
		
		return zone, zoneDescription, zoneOrder
	end
	
	CADWELLS_ALMANAC:RefreshList()
	EsoUA:MapNameStyle()
	
	local ZO_AlertText_GetHandlersOld = ZO_AlertText_GetHandlers
	
	function ZO_AlertText_GetHandlers()
		local ALERT = UI_ALERT_CATEGORY_ALERT
		local handlers = ZO_AlertText_GetHandlersOld()
		
		handlers[EVENT_ZONE_CHANGED] = function(zoneName, subzoneName)
			if(subzoneName ~= "") then
				if (EsoUA.Settings.ShowLocations ~= "ua") then
					newLocName = rsd.Locations[ZO_CachedStrFormat("<<z:1>>", subzoneName)]
			
					if newLocName ~= nil then
						if (EsoUA.Settings.ShowLocations == "uaen") then
							subzoneName = subzoneName .. "\n|ca99e83" .. newLocName .. "|r"
						elseif (EsoUA.Settings.ShowLocations == "enua") then
							subzoneName = newLocName .. "\n|ca99e83" .. ZO_CachedStrFormat(SI_ZONE_NAME, subzoneName) .. "|r"
						else
							subzoneName = newLocName
						end
					end
				end
				
				return ALERT, ZO_CachedStrFormat(SI_ALERTTEXT_LOCATION_FORMAT, subzoneName)
			elseif(zoneName ~= "") then
				if (EsoUA.Settings.ShowLocations ~= "ua") then
					newLocName = rsd.Locations[ZO_CachedStrFormat("<<z:1>>", zoneName)]
			
					if newLocName ~= nil then
						if (EsoUA.Settings.ShowLocations == "uaen") then
							zoneName = zoneName .. "\n|ca99e83" .. newLocName .. "|r"
						elseif (EsoUA.Settings.ShowLocations == "enua") then
							zoneName = newLocName .. "\n|ca99e83" .. ZO_CachedStrFormat(SI_ZONE_NAME, zoneName) .. "|r"
						else
							zoneName = newLocName
						end
					end
				end
				
				return ALERT, ZO_CachedStrFormat(SI_ALERTTEXT_LOCATION_FORMAT, zoneName)
			end
		end
		
		return handlers
	end
	
	LFGDoubleNames(EsoUA)
	
	EsoUA_doubleNamesLocations = nil
end

function LFGDoubleNames(EsoUA)
	local rsd = EsoUA.Settings.Data
	local locs2 = ZO_ACTIVITY_FINDER_ROOT_MANAGER.sortedLocationsData[2] -- Normal Dungeons
	local locs3 = ZO_ACTIVITY_FINDER_ROOT_MANAGER.sortedLocationsData[3] -- Vet Dungeons
	
	for i = 1, #locs2 do	   
	   newLocationName = rsd.Locations[ZO_CachedStrFormat("<<z:1>>", locs2[i]["rawName"])]
	   
	   if newLocationName ~= nil then
			if (EsoUA.Settings.ShowLocations == "ua") then
				locs2[i]["nameKeyboard"] = ZO_CachedStrFormat(SI_ZONE_NAME, locs2[i]["rawName"])
				locs2[i]["nameGamepad"] = ZO_CachedStrFormat(SI_ZONE_NAME, locs2[i]["rawName"])
			else
				locs2[i]["nameKeyboard"] = ZO_CachedStrFormat(SI_ZONE_NAME, locs2[i]["rawName"] .. " (" .. newLocationName .. ")")
				locs2[i]["nameGamepad"] = ZO_CachedStrFormat(SI_ZONE_NAME, locs2[i]["rawName"] .. " (" .. newLocationName .. ")")
			end
		end
	end
	
	for i = 1, #locs3 do	   
	   newLocationName = rsd.Locations[ZO_CachedStrFormat("<<z:1>>", locs3[i]["rawName"])]
	   
	   if newLocationName ~= nil then
			if (EsoUA.Settings.ShowLocations == "ua") then
				if string.find(locs3[i]["nameKeyboard"], "target_veteranRank_icon") then
					locs3[i]["nameKeyboard"] = "|t100%:100%:EsoUI/Art/UnitFrames/target_veteranRank_icon.dds|t " .. ZO_CachedStrFormat(SI_ZONE_NAME, locs3[i]["rawName"])
				end
				if string.find(locs3[i]["nameGamepad"], "^Ветеранское подземелье") then
					locs3[i]["nameGamepad"] = "Ветеранское подземелье " .. locs3[i]["rawName"]
				end
			else
				if string.find(locs3[i]["nameKeyboard"], "target_veteranRank_icon") then
					locs3[i]["nameKeyboard"] = "|t100%:100%:EsoUI/Art/UnitFrames/target_veteranRank_icon.dds|t " .. ZO_CachedStrFormat(SI_ZONE_NAME, locs3[i]["rawName"] .. " (" .. newLocationName .. ")")
				end
				if string.find(locs3[i]["nameGamepad"], "^Ветеранское подземелье") then
					locs3[i]["nameGamepad"] = "Ветеранское подземелье " .. locs3[i]["rawName"] .. " (" .. newLocationName .. ")"
				end
			end
		end
	end
end
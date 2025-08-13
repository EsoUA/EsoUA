function EsoUA_doubleNamesBoth(EsoUA)
	local GetGameCameraInteractableActionInfoOld = GetGameCameraInteractableActionInfo
	local prevInteractNpcEn = ""
	local prevInteractNpcRu = ""
	
	function GetGameCameraInteractableActionInfo(...)		
		local action, interactableName, interactionBlocked, isOwned, additionalInteractInfo, context, contextLink, isCriminalInteract = GetGameCameraInteractableActionInfoOld()
		local newNpcName, temp1, temp2, interactionType, settingType
		
		if action == GetString(SI_GAMECAMERAACTIONTYPE2) or action == GetString(SI_GAMECAMERAACTIONTYPE21) or action == GetString(SI_GAMECAMERAACTIONTYPE1) or action == GetString(SI_GAMECAMERAACTIONTYPE7) then
			interactionType = "npc"
			settingType = EsoUA.Settings.ShowNPC
		elseif action == GetString(SI_GAMECAMERAACTIONTYPE5) then
			interactionType = "craft"
			settingType = EsoUA.Settings.ShowCraft
		end
		
		if not settingType or settingType == "ua" or interactableName == nil then
			return action, interactableName, interactionBlocked, isOwned, additionalInteractInfo, context, contextLink, isCriminalInteract
		end
		
		if interactionType == "npc" then
			if interactableName == prevInteractNpcRu then
				newNpcName = prevInteractNpcEn
			else
				newNpcName = npcNames[zo_strlower(interactableName)]
				
				if newNpcName == nil then
					return action, interactableName, interactionBlocked, isOwned, additionalInteractInfo, context, contextLink, isCriminalInteract
				end
					
				if interactableName ~= nil then
					prevInteractNpcEn = newNpcName
					prevInteractNpcRu = interactableName
				end
			end
			
			if newNpcName ~= interactableName then
				if settingType == "uaen" then
					interactableName = ZO_CachedStrFormat(SI_ZONE_NAME, interactableName) .. "\n" .. newNpcName
				elseif (settingType == "enua") then
					interactableName = newNpcName .. "\n" .. ZO_CachedStrFormat(SI_ZONE_NAME, interactableName)
				else
					interactableName = newNpcName
				end
			end
		elseif interactionType == "craft" then
			local ruName = string.match(interactableName, "%((.*)%)$")
			
			if interactableName == prevInteractNpcRu then
				newNpcName = prevInteractNpcEn
			else				
				if ruName and EsoUA.Settings.Data.SetsNames[zo_strlower(ruName)] then
					newNpcName = EsoUA.Settings.Data.SetsNames[zo_strlower(ruName)] -- EsoUA:MagicReplace(interactableName, ruName, EsoUA.Settings.Data.SetsNames[zo_strlower(ruName)])
				end
				
				if newNpcName == nil then
					return action, interactableName, interactionBlocked, isOwned, additionalInteractInfo, context, contextLink, isCriminalInteract
				end
					
				if interactableName ~= nil then
					prevInteractNpcEn = newNpcName
					prevInteractNpcRu = interactableName
				end
			end
			
			if newNpcName ~= interactableName and ruName then
				local firstPart = string.match(interactableName, "^(.*) %(")
				
				if settingType == "uaen" then
					interactableName = string.format("%s (%s — %s)", firstPart, ruName, EsoUA.Settings.Data.SetsNames[zo_strlower(ruName)])
				elseif (settingType == "enua") then
					interactableName = string.format("%s (%s — %s)", firstPart, EsoUA.Settings.Data.SetsNames[zo_strlower(ruName)], ruName)
				else
					interactableName = string.format("%s (%s)", firstPart, EsoUA.Settings.Data.SetsNames[zo_strlower(ruName)])
				end
			end
		end
		
		return action, interactableName, interactionBlocked, isOwned, additionalInteractInfo, context, contextLink, isCriminalInteract
	end
	
	EsoUA_doubleNamesBoth = nil
end
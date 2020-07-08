local doorState = {}


RegisterServerEvent('esx_doorlock:updateState')
AddEventHandler('esx_doorlock:updateState', function(doorIndex, state)
	local player = source;
	if roleTracker[player] ~= nil then 
		local roleListt = roleTracker[player];
		for i = 1, #roleListt do 
			if type(doorIndex) == 'number' and type(state) == 'boolean' and Config.DoorList[doorIndex] 
				and isAuthorized(roleListt[i], Config.DoorList[doorIndex]) then
				doorState[doorIndex] = state
				TriggerClientEvent('esx_doorlock:setDoorState', -1, doorIndex, state)
				return;
			end
		end
	end
end)

RegisterNetEvent('esx_doorlock:getDoorState')
AddEventHandler('esx_doorlock:getDoorState', function()
	TriggerClientEvent('esx_doorlock:returnDoorState', -1, doorState);
end)

RegisterNetEvent('Doorlock:CheckPermsDoor')
AddEventHandler('Doorlock:CheckPermsDoor', function(doorV, state)
	local player = source;
	if roleTracker[player] ~= nil then 
		local roleListt = roleTracker[player];
		for i = 1, #roleListt do 
			if type(doorV) == 'number' and Config.DoorList[doorV] 
				and isAuthorized(roleListt[i], Config.DoorList[doorV]) then
				doorState[doorV] = state;
				TriggerClientEvent('esx_doorlock:setDoorState', -1, doorV, state)
				return;
			end
		end
	end
end)

AddEventHandler('playerDropped', function (reason) 
  -- Clear their lists 
  local src = source;
  roleTracker[src] = nil;
end)

RegisterNetEvent('Doorlock:CheckPerms')
AddEventHandler('Doorlock:CheckPerms', function()
	local src = source;
	for k, v in ipairs(GetPlayerIdentifiers(src)) do
        if string.sub(v, 1, string.len("discord:")) == "discord:" then
            identifierDiscord = v
        end
    end
	-- TriggerClientEvent("FaxDisVeh:CheckPermission:Return", src, true, false)
    if identifierDiscord then
		local roles = exports.discord_perms:GetRoles(src)
		if not (roles == false) then
			for roleName, roleID in pairs(Config.Roles) do
				for i = 1, #roles do
					if tostring(roles[i]) == tostring(roleID) then
						-- Return the index back to the Client script
						if roleTracker[src] ~= nil then 
							-- They have a list, add to it 
							table.insert(roleTracker[src], roleName);
							print("Added " .. GetPlayerName(src) .. " to doorlock-group '" .. roleName .. "'")
						else 
							-- No list, make one 
							local roless = {};
							table.insert(roless, roleName);
							roleTracker[src] = roless;
							print("Added " .. GetPlayerName(src) .. " to doorlock-group '" .. roleName .. "'")
						end
					end
				end
			end
		else
			print(GetPlayerName(src) .. " did not receive door permissions because roles == false")
		end
    elseif identifierDiscord == nil then
		print("identifierDiscord == nil")
    end
end)
roleTracker = {}
function isAuthorized(role, doorObject)
	for k, rolee in pairs(doorObject.authorizedRoles) do
		if rolee == role then
			return true
		end
	end

	return false
end

--[[
	Author: FileEX
	For: Royal-MTA
]]

addEvent('syncTable', true);
addEventHandler('syncTable', root, function(i)
	for k,v in pairs(Element.getAllByType('player')) do
		if isPlayerTeam(v, 2, 3) then
			triggerClientEvent(v, 'syncTableClient', v, i);
		end
	end
end);

function insertReport(plr,_, who, ...)
	if not who or not ... then
		plr:outputChatB('Użycie /report <nick> <powod>',255,255,255);
	return end;

	if not Player(who) then
		plr:outputChat('Graczo takim nicku nie istnieje.',255,255,255);
	return end;

	local reason = table.concat({...}, " ");

	--local t = getRealTime().timestamp;
	local t = os.time();

	for k,v in pairs(Element.getAllByType('player')) do
		if isPlayerTeam(v, 2,3) then -- mod or admin (default 1 is support)
			triggerLatentClientEvent(v, 'reSyncTableClient', v, plr, who, reason, t);
		end
	end
	plr:outputChat('Wysłano zgłoszenie.',255,255,255);
end

for k,v in pairs(commands) do
	addCommandHandler(v, insertReport);
end
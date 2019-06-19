--[[
	Author: FileEX
	For: Royal-MTA
]]

addEvent('syncTable', true);
addEventHandler('syncTable', root, function(i)
	for k,v in pairs(Element.getAllByType('player')) do
		if isPlayerTeam(v, unpack(levels)) then
			triggerClientEvent(v, 'syncTableClient', v, i);
		end
	end
end);

function insertReport(plr,_, who, ...)
	if not who or not ... then
		exports.rm_noti:createAlert(plr, 'info', 'Użyj: /report <nazwa/id> <powód>');
	return end;
	local who = exports.rm_core:findPlayer(plr, who);
	if not who then
		exports.rm_noti:createAlert(plr, 'error', 'Nie znaleziono podanego gracza.');
	return end;

	local reason = table.concat({...}, " ");

	--local t = getRealTime().timestamp;
	local t = os.time();

	for k,v in pairs(Element.getAllByType('player')) do
		if isPlayerTeam(v, unpack(levels)) then -- mod or admin (default 1 is support)
			triggerLatentClientEvent(v, 'reSyncTableClient', v, plr, who, reason, t);
		end
	end
	exports.rm_noti:createAlert(plr, 'success', 'Pomyślnie wysłano zgłoszenie na '..getPlayerName(who):gsub("#%x%x%x%x%x%x",''))
end

for k,v in pairs(commands) do
	addCommandHandler(v, insertReport);
end
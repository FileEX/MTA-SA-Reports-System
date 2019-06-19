--[[
	Author: FileEX
	For: Royal-MTA
]]

reports = {};
setmetatable(reports, {__call = function(o, ...) return o:constructor(...) end, __index = reports});

local screenX, screenY = guiGetScreenSize();

local constY = 5 / 800 * screenY;

local screen = {guiGetScreenSize()};

function sx( value )
    local result = ( value / 1680 ) * screen[1]

    return result
end

function sy( value )
    local result = ( value / 1050 ) * screen[2]
	
    return result
end

local renderData = {
	iconX = 385 / 800 * screenY,
	iconY = 5 / 800 * screenY,
	iconW = 40 / 800 * screenY,
	iconH = 25 / 800 * screenY,
	notifX = 38 / 800 * screenY,
	notifY = 20 / 800 * screenY,
	notifW = 22 / 800 * screenY,
	notifH = 22 / 800 * screenY,
	notifS = 0.7 / 800 * screenY,
	notifOX = 8 / 800 * screenY,
	notifOY = 4 / 800 * screenY,

	-- menu
	menuX = sx(1242),
	menuY = sy(239),
	menuW = sx(428),
	menuH = sy(480),


	itemX = sx(1248),
	itemY = sy(306),
	itemOY = sy(33),
	itemW = sx(417),
	itemH = sy(31),

	textOskX = sx(1248),
	textOskY = sy(282),
	textOskW = sx(1331),
	textOskH = sy(302),

	textOsk2X = sx(1365),
	textOsk2Y = sy(282),
	textOsk2W = sx(1448),
	textOsk2H = sy(302),

	textPoX = sx(1534),
	textPoY = sy(282),
	textPoW = sx(1617),
	textPoH = sy(302),

	

	textX = 600 / 800 * screenY,
	textY = (screenY / 2) - 310 / 800 * screenY,
	textS = 1.5 / 800 * screenY,

	-- buttons

	btnLX = sx(1255),
	btnDX = sx(1397),
	btnCX = sx(1539),

	btnY = sy(711),
	btnW = sx(118),
	btnH = sy(35),

	renderTextX = sx(1266),
	renderTextY = sy(298),
	renderTextW = sx(1638),
	renderTextH = sy(667),

	lookTextS = 1.45 / 800 * screenY,

	btnTextS = 1.35 / 800 * screenY,

	-- useful
	us = 2 / 800 * screenY,
};

function reports:constructor()
	self.__init = function()
		self.reportsTable = {};
		self.newReports = 0;
		self.pressed = false;
		self.panelOpened = false;
		self.textures = {
			icon = DxTexture('i/icon.png','argb',false,'clamp'),
			notif = DxTexture('i/notif.png','argb',false,'clamp');
		};
		self.fonts = {
			[1] = exports.rm_gui:fonts_getFont(12, 'regular'),
			[2] = exports.rm_gui:fonts_getFont(10, 'regular'),
		};
		self.rows = 12;
		self.scroll = 0;
		self.tick = 0;
		self.selected = 0;
		self.reader = false;
		self.bgS = false;
	end

	self.render = function() self:drawInterface(self); end;
	self.click = function(b,s) self:onClick(b,s,self); end;
	self.move = function(_,_,ax,ay) self:onMove(_,_,ax,ay,self); end;
	self.scrollF = function(k) self:onScroll(k,self); end;

	self.__init();
	return self;
end

function reports:destructor()
	self.textures.icon:destroy();
	self.textures.notif:destroy();
	_G['self'] = nil;
	collectgarbage('collect');
	removeEventHandler('onClientCursorMove', root, self.move);
end

function reports:drawInterface()
	dxDrawImage(renderData.iconX, renderData.iconY, renderData.iconW, renderData.iconH, self.textures.icon, 0, 0, 0, 0xFFFFFFFF, false);
	if self.newReports > 0 then
		dxDrawImage(renderData.iconX + renderData.notifX, renderData.iconY - renderData.notifY, renderData.notifW, renderData.notifH, self.textures.notif, 0, 0, 0, 0xFFFFFFFF, false);
		dxDrawText(self.newReports, renderData.iconX + renderData.notifX + renderData.notifOX, renderData.iconY - renderData.notifY + renderData.notifOY, renderData.notifW, renderData.notifH, 0xFFFFFFFF, renderData.notifS, 'default-bold');
	end

	if self.tick > 0 then
		renderData.iconY = interpolateBetween(self.newReports > 0 and constY or constY + 19 / 800 * screenY, 0, 0, self.newReports > 0 and constY + 19 / 800 * screenY or constY, 0, 0, (getTickCount() - self.tick) / 500, 'Linear');
		if (getTickCount() - self.tick) / 500 > 1 then
			self.tick = 0;
		end
	end

	if self.panelOpened then
		-- bg
		exports.rm_gui:dxCreateWindow(renderData.menuX, renderData.menuY, renderData.menuW, renderData.menuH, 'Raporty na graczy', 'left');
		
        dxDrawText("Oskarżający", renderData.textOskX, renderData.textOskY, renderData.textOskW, renderData.textOskH, 0xFFD4D4D4, 1.00, self.fonts[1], 'center', 'center');
        dxDrawText("Oskarżony", renderData.textOsk2X, renderData.textOsk2Y, renderData.textOsk2W, renderData.textOsk2H, 0xFFD4D4D4, 1.00, self.fonts[1], 'center', 'center');
        dxDrawText("Powód", renderData.textPoX, renderData.textPoY, renderData.textPoW, renderData.textPoH, 0xFFD4D4D4, 1.00, self.fonts[1], 'center', 'center');
		
		if isMouseInPosition(renderData.btnLX, renderData.btnY, renderData.btnW, renderData.btnH) then
			dxDrawRectangle(renderData.btnLX, renderData.btnY, renderData.btnW, renderData.btnH, 0xFF464646, false);
		else
			dxDrawRectangle(renderData.btnLX, renderData.btnY, renderData.btnW, renderData.btnH, 0xFF404040, false);
		end

		if isMouseInPosition(renderData.btnDX, renderData.btnY, renderData.btnW, renderData.btnH) then
			dxDrawRectangle(renderData.btnDX, renderData.btnY, renderData.btnW, renderData.btnH, 0xFF464646, false);
		else
			dxDrawRectangle(renderData.btnDX, renderData.btnY, renderData.btnW, renderData.btnH, 0xFF404040, false);
		end

		if isMouseInPosition(renderData.btnCX, renderData.btnY, renderData.btnW, renderData.btnH) then
			dxDrawRectangle(renderData.btnCX, renderData.btnY, renderData.btnW, renderData.btnH, 0xFF464646, false);
		else
			dxDrawRectangle(renderData.btnCX, renderData.btnY, renderData.btnW, renderData.btnH, 0xFF404040, false);
		end

		dxDrawText('Zobacz', renderData.btnLX, renderData.btnY, renderData.btnLX + renderData.btnW, renderData.btnY + renderData.btnH, 0xFFD4D4D4, 1, self.fonts[1], 'center', 'center');
		dxDrawText('Usuń', renderData.btnDX, renderData.btnY, renderData.btnDX + renderData.btnW, renderData.btnY + renderData.btnH, 0xFFD4D4D4, 1, self.fonts[1], 'center', 'center');
		dxDrawText('Zamknij', renderData.btnCX, renderData.btnY, renderData.btnCX + renderData.btnW, renderData.btnY + renderData.btnH, 0xFFD4D4D4, 1, self.fonts[1], 'center', 'center');

		for i = self.scroll + 1,self.scroll + self.rows do
			if self.reportsTable[i] then
				dxDrawRectangle(renderData.itemX, renderData.itemY - (28 - (i - self.scroll) * renderData.itemOY), renderData.itemW, renderData.itemH, (not isMouseInPosition(renderData.itemX, renderData.itemY - (28 - (i - self.scroll) * renderData.itemOY), renderData.itemW, renderData.itemH) and (not self.reportsTable[i].selected and 0xFF373737 or 0xFF404040) or 0xFF404040), false);
				
				dxDrawText(self.reportsTable[i].a, renderData.itemX + renderData.us + 5 / 800 * screenY, renderData.itemY - (24 - (i - self.scroll) * renderData.itemOY) + renderData.us, renderData.menuW, renderData.itemH, 0xFFFFFFFF, renderData.itemS, self.fonts[2]);
				dxDrawText(self.reportsTable[i].b, renderData.itemX + 98 / 800 * screenY, renderData.itemY - (24 - (i - self.scroll) * renderData.itemOY) + renderData.us, renderData.menuW, renderData.itemH, 0xFFFFFFFF, renderData.itemS, self.fonts[2]);
				dxDrawText(self.reportsTable[i].rsD, renderData.itemX + 220 / 800 * screenY, renderData.itemY - (24 - (i - self.scroll) * renderData.itemOY) + renderData.us, renderData.menuW, renderData.itemH, 0xFFFFFFFF, renderData.itemS, self.fonts[2]);
			end
		end
	end

	if self.reader then
		-- bg
		exports.rm_gui:dxCreateWindow(renderData.menuX, renderData.menuY, renderData.menuW, renderData.menuH, 'Raport: '..self.selected, 'left')
		dxDrawText('Zgłaszający: '..self.reportsTable[self.selected].a..'\n\nOskarżony: '..self.reportsTable[self.selected].b..'\n\nData: '..self.reportsTable[self.selected].time..'\n\nTreść: '..self.reportsTable[self.selected].rs, renderData.renderTextX, renderData.renderTextY, renderData.renderTextW, renderData.renderTextH, 0xFFD4D4D4, 1.00, self.fonts[1], "center", "top")

		if isMouseInPosition(renderData.btnDX, renderData.btnY, renderData.btnW, renderData.btnH) then
			dxDrawRectangle(renderData.btnDX, renderData.btnY, renderData.btnW, renderData.btnH, 0xFF464646, false);
		else
			dxDrawRectangle(renderData.btnDX, renderData.btnY, renderData.btnW, renderData.btnH, 0xFF404040, false);
		end
		dxDrawText('Wstecz', renderData.btnDX, renderData.btnY, renderData.btnDX + renderData.btnW, renderData.btnY + renderData.btnH, 0xFFD4D4D4, 1, self.fonts[1], 'center', 'center');
	end

	-- small anti bug
	if not getKeyState('mouse1') and self.pressed then
		self.pressed = false;
		removeEventHandler('onClientCursorMove', root, self.move);
	end
end

function reports:onClick(btn,state)
	if btn == 'left' then
		if isMouseInPosition(renderData.iconX, renderData.iconY, renderData.iconW, renderData.iconH) then
			self.pressed = state == 'down' or false;
			_G[self.pressed and 'addEventHandler' or 'removeEventHandler']('onClientCursorMove', root, self.move);
			if state == 'up' and not self.pressed and not self.reader then
				self.panelOpened = not self.panelOpened;
				_G[self.panelOpened and 'addEventHandler' or 'removeEventHandler']('onClientKey', root, self.scrollF);
				if not self.panelOpened and self.newReports > 0 then self.newReports = 0; self.tick = getTickCount(); end;
			end
		end

		if ((self.panelOpened and not self.reader) or (not self.panelOpened and self.reader)) and state == 'down' then

			if isMouseInPosition(renderData.btnCX, renderData.btnY, renderData.btnW, renderData.btnH) then
				self.panelOpened = false;
				removeEventHandler('onClientKey',root,self.scrollF);
				if self.newReports > 0 then
					self.newReports = 0;
					self.tick = getTickCount();
				end
			elseif isMouseInPosition(renderData.btnDX, renderData.btnY, renderData.btnW, renderData.btnH) and self.selected > 0 then
				if not self.reader then
					if self.reportsTable[self.selected] then
						triggerServerEvent('syncTable', root, self.selected);
					end
				else
					self.panelOpened,self.reader = true, false;
				end
			elseif isMouseInPosition(renderData.btnLX, renderData.btnY, renderData.btnW, renderData.btnH) and self.selected > 0 then
				if self.reportsTable[self.selected] then
					self.panelOpened,self.reader = false, true;
				end
			end

			for i = self.scroll + 1,self.scroll + self.rows do
				if self.reportsTable[i] then
					if not self.reader then
						self.reportsTable[i].selected = false;
						self.selected = 0;
					end
					if isMouseInPosition(renderData.itemX, renderData.itemY - (28 - (i - self.scroll) * renderData.itemOY), renderData.menuW, renderData.itemH) then
						self.reportsTable[i].selected = not self.reportsTable[i].selected;
						self.selected = i;
						break;
					end
				end
			end

		end

	end
end

function reports:onMove(_,_,ax,ay)
	renderData.iconX, renderData.iconY = ax, ay;
	constY = renderData.iconY;
end

function reports:onScroll(k)
	if k == 'mouse_wheel_up' then
		self.scroll = self.scroll - 1 >= 0 and self.scroll - 1 or 0;
	elseif k == 'mouse_wheel_down' then
		self.scroll = self.scroll + 1 <= #self.reportsTable and self.scroll + 1 or #self.reportsTable;
	end
end

function reports:newReport(plr, target, reason, tm)
	table.insert(self.reportsTable, {i = #self.reportsTable + 1, a = plr.name, b = target.name, rs = reason, rsD = reason:sub(1,25)..'...', selected = false, time = tm});
		
	if (isElement(self.bgS)) then
		self.bgS:destroy();
	end
	self.bgS = Sound('s/n.wav', false, false);

	if self.newReports <= 0 then
		self.tick = getTickCount();
	end
	self.newReports = self.newReports + 1;
end

function reports:removeRaport(i)
	table.remove(self.reportsTable, i);
	self.newReports = self.newReports > 0 and self.newReports - 1 or self.newReports;
	if self.newReports == 0 then
		self.tick = getTickCount();
	end

	exports.rm_noti:createAlert('info', 'Zgłoszenie zostało usunięte.');
end

addEvent('syncTableClient', true);
addEventHandler('syncTableClient', localPlayer, function(i)
	reports:removeRaport(i);
end);

addEvent('reSyncTableClient', true);
addEventHandler('reSyncTableClient', localPlayer, function(plr, who, reason, t)
	local t = os.date('%Y-%m-%d %H:%M', t);
	reports:newReport(plr, who, reason, t);
end);
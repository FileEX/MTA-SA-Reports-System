--[[
	Author: FileEX
	For: Royal-MTA
]]

reports = {};
setmetatable(reports, {__call = function(o, ...) return o:constructor(...) end, __index = reports});

local screenX, screenY = guiGetScreenSize();

local constY = 5 / 800 * screenY;

local renderData = {
	iconX = 385 / 800 * screenY,
	iconY = 5 / 800 * screenY,
	iconW = 40 / 800 * screenY,
	iconH = 25 / 800 * screenY,
	notifX = 40 / 800 * screenY,
	notifY = 20 / 800 * screenY,
	notifW = 22 / 800 * screenY,
	notifH = 22 / 800 * screenY,
	notifS = 0.7 / 800 * screenY,
	notifOX = 6 / 800 * screenY,
	notifOY = 4 / 800 * screenY,

	-- menu
	menuX = 350 / 800 * screenY,
	menuY = (screenY / 2) - 330 / 800 * screenY,
	menuW = 590 / 800 * screenY,
	menuH = 590 / 800 * screenY,

	itemX = 350 / 800 * screenY,
	itemY = screenY / 2 - 320 / 800 * screenY,
	itemOY = 40 / 800 * screenY,
	itemH = 30 / 800 * screenY,
	itemS = 1.3 / 800 * screenY,

	textX = 600 / 800 * screenY,
	textY = (screenY / 2) - 310 / 800 * screenY,
	textS = 1.5 / 800 * screenY,

	-- buttons
	btnLX = 365 / 800 * screenY,
	btnDX = 555 / 800 * screenY,
	btnCX = 745 / 800 * screenY,

	btnY = 570 / 800 * screenY,
	btnW = 170 / 800 * screenY,
	btnH = 56 / 800 * screenY,

	readerTextX = 370 / 800 * screenY,
	readerTextY = screenY / 2 - 230 / 800 * screenY,

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
		self.rows = 10;
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
		dxDrawRectangle(renderData.menuX, renderData.menuY, renderData.menuW, renderData.menuH, 0xFF232323, false);
		dxDrawText('RAPORTY', renderData.textX, renderData.textY, 100, 100, 0xFFFFFFFF, renderData.textS, 'default');
		dxDrawRectangle(renderData.btnLX, renderData.btnY, renderData.btnW, renderData.btnH, 0xFF9736E2, false);
		dxDrawText('Zobacz', renderData.btnLX, renderData.btnY, renderData.btnLX + renderData.btnW, renderData.btnY + renderData.btnH, 0xFFFFFFFF, renderData.btnTextS, 'default', 'center', 'center');
		dxDrawRectangle(renderData.btnDX, renderData.btnY, renderData.btnW, renderData.btnH, 0xFF9736E2, false);
		dxDrawText('Usuń', renderData.btnDX, renderData.btnY, renderData.btnDX + renderData.btnW, renderData.btnY + renderData.btnH, 0xFFFFFFFF, renderData.btnTextS, 'default', 'center', 'center');
		dxDrawRectangle(renderData.btnCX, renderData.btnY, renderData.btnW, renderData.btnH, 0xFF9736E2, false);
		dxDrawText('Zamknij', renderData.btnCX, renderData.btnY, renderData.btnCX + renderData.btnW, renderData.btnY + renderData.btnH, 0xFFFFFFFF, renderData.btnTextS, 'default', 'center', 'center');

		for i = self.scroll + 1,self.scroll + self.rows do
			if self.reportsTable[i] then
				dxDrawRectangle(renderData.itemX, renderData.itemY - (-10 - (i - self.scroll) * renderData.itemOY), renderData.menuW, renderData.itemH, (not isMouseInPosition(renderData.itemX, renderData.itemY - (-10 - (i - self.scroll) * renderData.itemOY), renderData.menuW, renderData.itemH) and (not self.reportsTable[i].selected and 0xFF1E1E1E or 0xFF5E5E5E) or 0xFF5E5E5E), false);
				dxDrawText(self.reportsTable[i].a, renderData.itemX + renderData.us, renderData.itemY - (-10 - (i - self.scroll) * renderData.itemOY) + renderData.us, renderData.menuW, renderData.itemH, 0xFFFFFFFF, renderData.itemS, 'default-bold');
				dxDrawText(self.reportsTable[i].b, renderData.itemX + 150 / 800 * screenY, renderData.itemY - (-10 - (i - self.scroll) * renderData.itemOY) + renderData.us, renderData.menuW, renderData.itemH, 0xFFFFFFFF, renderData.itemS, 'default-bold');
				dxDrawText(self.reportsTable[i].rsD, renderData.itemX + 350 / 800 * screenY, renderData.itemY - (-10 - (i - self.scroll) * renderData.itemOY) + renderData.us, renderData.menuW, renderData.itemH, 0xFFFFFFFF, renderData.itemS, 'default-bold');
			end
		end
	end

	if self.reader then
		-- bg
		dxDrawRectangle(renderData.menuX, renderData.menuY, renderData.menuW, renderData.menuH, 0xFF232323, false);
		dxDrawText('RAPORT '..self.selected, renderData.textX, renderData.textY, 100, 100, 0xFFFFFFFF, renderData.textS, 'default');

		dxDrawText('Zgłaszający: '..self.reportsTable[self.selected].a..'\n\nOskarżony: '..self.reportsTable[self.selected].b..'\n\nData: '..self.reportsTable[self.selected].time..'\n\nTreść: '..self.reportsTable[self.selected].rs, renderData.readerTextX, renderData.readerTextY, renderData.readerTextX + renderData.menuW - (renderData.us * 12), renderData.readerTextY + renderData.menuH, 0xFFFFFFFF, renderData.lookTextS, 'default-bold', 'left', 'top', false, true);

		dxDrawRectangle(renderData.btnDX, renderData.btnY, renderData.btnW, renderData.btnH, 0xFF9736E2, false);
		dxDrawText('Wstecz', renderData.btnDX, renderData.btnY, renderData.btnDX + renderData.btnW, renderData.btnY + renderData.btnH, 0xFFFFFFFF, renderData.btnTextS, 'default', 'center', 'center');
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
					if isMouseInPosition(renderData.itemX, renderData.itemY - (-10 - (i - self.scroll) * renderData.itemOY), renderData.menuW, renderData.itemH) then
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
	table.insert(self.reportsTable, {i = #self.reportsTable + 1, a = plr.name, b = target, rs = reason, rsD = reason:sub(1,25)..'...', selected = false, time = tm});
		
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

	outputChatBox('Usunięto zgłoszenie.');
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
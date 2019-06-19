--[[
	Author: FileEX
	For: Royal-MTA
]]

local rClass;

function setReportsVisible(b)
	if b then
		if not rClass then
			rClass = reports();
			addEventHandler('onClientRender', root, rClass.render);
			addEventHandler('onClientClick', root, rClass.click);
		end
	else
		if rClass then
			removeEventHandler('onClientRender', root, rClass.render);
			removeEventHandler('onClientClick', root, rClass.click);
			rClass:destructor();
			rClass = nil;
		end
	end
end
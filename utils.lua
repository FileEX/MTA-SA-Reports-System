function isMouseInPosition ( x, y, width, height )
	if ( not isCursorShowing( ) ) then
		return false
	end
    local sx, sy = guiGetScreenSize ( )
    local cx, cy = getCursorPosition ( )
    local cx, cy = ( cx * sx ), ( cy * sy )
    if ( cx >= x and cx <= x + width ) and ( cy >= y and cy <= y + height ) then
        return true
    else
        return false
    end
end

function isPlayerTeam(...)
    if select(1, ...).type == 'player' then
        local p,q = select(1, ...), #{...};
        local r;
        for i = 1,q do
            r = p:getData(rankLevel) == i;
            if r then break; end;
        end
        return r;
    end
    return false;
end
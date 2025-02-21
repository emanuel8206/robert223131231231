p = { }

addEventHandler("onPlayerLogin", root, function()
         local userID = exports.players:getUserID(source)
			local s = exports.sql:query_assoc("SELECT * FROM characters WHERE userID = "..userID)
			if s and s[1] then 
				setElementData(source, "sed", tonumber(s[1].sed))
				setElementData(source, "hambre", tonumber(s[1].hambre))
				--outputDebugString("se le asigno "..s[1].sed.." de sed al usuario numero "..userID)
			else
				outputDebugString("Error al obtener el valor de sed para el usuario numero "..userID)
			end
end)

function hambre_sed()
	for key, value in ipairs( getElementsByType( "player" ) ) do
		if exports.players:isLoggedIn(value) and not getElementData(value, "ajail") and not getElementData(value, "tjail") then
		--	if getElementData(value, "sed") and getElementData(value, "sed") <= 0 then
			--	if (getElementHealth(value)-5) >= 2 then
			--		setElementHealth(value, getElementHealth(value)-5)
			----	end
			--end

            local sed = getElementData(value, "sed") or 100
			setElementData(value, "sed", math.max(0, sed - math.random(2, 8)))

            local hambre = getElementData(value, "hambre") or 100
			setElementData(value, "hambre", math.max(0, hambre - math.random(2, 10)))
		end
    end
end

function hs_salud()
    for key, value in ipairs( getElementsByType( "player" ) ) do
		local onduty = exports.players:getOption( value, "staffduty" )
		if exports.players:isLoggedIn(value) and not getElementData(value, "ajail") and not getElementData(value, "tjail") and onduty ~= true then
			outputDebugString("a")
            if getElementData(value, "hambre") and getElementData(value, "hambre") == 0 then
				setElementHealth(value, getElementHealth(value)-15)

            elseif getElementData(value, "hambre") and getElementData(value, "hambre") <= 10 then
				setElementHealth(value, getElementHealth(value)-10)

            elseif getElementData(value, "hambre") and getElementData(value, "hambre") <= 15 then
				setElementHealth(value, getElementHealth(value)-5)
            end

            if getElementData(value, "sed") and getElementData(value, "sed") == 0 then
				setElementHealth(value, getElementHealth(value)-15)

            elseif getElementData(value, "sed") and getElementData(value, "sed") <= 10 then
				setElementHealth(value, getElementHealth(value)-10)

            elseif getElementData(value, "sed") and getElementData(value, "sed") <= 15 then
				setElementHealth(value, getElementHealth(value)-5)
            end
		end       
    end
end

setTimer(hs_salud, 180000, 0)
setTimer(hambre_sed, 210000, 0) 
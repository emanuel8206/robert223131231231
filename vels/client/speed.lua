

color = tocolor(50,205,50) ----цвет спидометра 
color2 = tocolor(255,255,255,255) ---- цвет тахометра


-----------------------
local sX, sY = guiGetScreenSize()
local screenWidth, screenHeight = sX, sY - 20 -- положение спидометра
local smothedRotation = 0
local maskShader
local tShader
local circleTexturesSpeed = {}
local circleTexturesTaxometr = {}


local SPEEDO_FONT = dxCreateFont("assets/SPEED_0.ttf", 17)
local RPM_FONT = dxCreateFont("assets/SPEED_0.ttf", 15)
local REG = dxCreateFont("assets/RR.ttf", 8)
local REG_CRUISE = dxCreateFont("assets/RR.ttf", 7)

addEventHandler( "onClientResourceStart", resourceRoot, function()

	maskShader = dxCreateShader("assets/mask3d.fx")
	local maskTexture = dxCreateTexture("assets/s_mask.png")
	dxSetShaderValue(maskShader, "sMaskTexture", maskTexture) 
	dxSetShaderValue(maskShader, "gUVRotCenter", 0.5, 0.5)
	for i = 1, 3 do
		circleTexturesSpeed[i] = dxCreateTexture("assets/s_circle"..tostring(i)..".png")
	end
	
	tShader = dxCreateShader("assets/mask3d.fx")
	local tTexture = dxCreateTexture("assets/t_mask.png")
	dxSetShaderValue(tShader, "sMaskTexture", tTexture) 
	dxSetShaderValue(tShader, "gUVRotCenter", 0.5, 0.5)

	for i = 1, 2 do
		circleTexturesTaxometr[i] = dxCreateTexture("assets/t_circle"..tostring(i)..".png")
	end

	fShader = dxCreateShader("assets/mask3d.fx")
	local fTexture = dxCreateTexture("assets/c_fuel.png")
	dxSetShaderValue(fShader, "sMaskTexture", fTexture) 
	dxSetShaderValue(fShader, "gUVRotCenter", 0.5, 0.5)

		circleTexturesFuel = dxCreateTexture("assets/f_circle.png")
	
	
end)


local function drawSpeedometr()

	local veh = getPedOccupiedVehicle(localPlayer) 
   if not veh or getVehicleOccupant ( veh ) ~= localPlayer then return true end
	local vehicleSpeed = getVehicleSpeed()
	local fuel = getElementData(getPedOccupiedVehicle ( localPlayer ), "fuel" ) or 0
	local rot = math.floor(((175/12800)* getVehicleRPM(getPedOccupiedVehicle(getLocalPlayer()))) + 0.5)
	if (smothedRotation < rot) then smothedRotation = smothedRotation + 2.5 end
	if (smothedRotation > rot) then smothedRotation = smothedRotation - 2.5 end
	
	dxDrawImage(screenWidth-200, screenHeight-200, 162, 162, "assets/s_speedo.png")

	dxDrawImage(screenWidth-300, screenHeight-155, 122, 122, "assets/s_tahometer.png")
	
	if vehicleSpeed < 243 then
		dxDrawImage(screenWidth-200, screenHeight-200, 160, 160, "assets/needle_s.png", vehicleSpeed - 3, 0.0, 0.0, tocolor(255,255,255,255), false)
	else
		dxDrawImage(screenWidth-200, screenHeight-200, 160, 160, "assets/needle_s.png", 240, 0.0, 0.0, tocolor(255,255,255,255), false)
	end
	
	dxDrawImage(screenWidth-295, screenHeight-150, 115, 115, "assets/needle_t.png", smothedRotation - 5, 0.0, 0.0, tocolor(255,255,255,255), false)
	
    	if vehicleSpeed < 90 then
		dxSetShaderValue(maskShader, "sPicTexture", circleTexturesSpeed[1])
		dxSetShaderValue(maskShader, "gUVRotAngle", 0 - (vehicleSpeed/57) - 0.2)
	elseif vehicleSpeed > 90 and vehicleSpeed < 170 then
		dxSetShaderValue(maskShader, "sPicTexture", circleTexturesSpeed[2])
		dxSetShaderValue(maskShader, "gUVRotAngle", 0 - (vehicleSpeed/57) - 4.9)
	elseif vehicleSpeed > 170 then
		dxSetShaderValue(maskShader, "sPicTexture", circleTexturesSpeed[3])
		dxSetShaderValue(maskShader, "gUVRotAngle", 0 - (vehicleSpeed/57) - 3.3)
	end
		
		
	dxDrawImage(screenWidth-200, screenHeight-200, 162, 162, maskShader, 0, 0, 0, color)
	
	if (0 - (smothedRotation/57)) > - 1 then
		dxSetShaderValue(tShader, "sPicTexture", circleTexturesSpeed[1])
		dxSetShaderValue(tShader, "gUVRotAngle", 0 - (smothedRotation/57) + 0.35)
	elseif (0 - (smothedRotation/57)) > - 4.4 then
		dxSetShaderValue(tShader, "sPicTexture", circleTexturesSpeed[2])
		dxSetShaderValue(tShader, "gUVRotAngle", 0 - (smothedRotation/57) - 4.5)
	end
	dxDrawImage(screenWidth-300, screenHeight-155, 122, 122, tShader, 0, 0, 0, color2)
	----------------------------------------
	if vehicleSpeed > 50 then
		dxSetShaderValue(fShader, "sPicTexture", circleTexturesFuel)
		dxSetShaderValue(fShader, "gUVRotAngle", 0 + (vehicleSpeed/157) - 4.35)
	elseif vehicleSpeed < 50 then
		dxSetShaderValue(fShader, "sPicTexture", circleTexturesFuel)
		dxSetShaderValue(fShader, "gUVRotAngle", 0 - (vehicleSpeed/157) - 1.5)
	end 
	----------------------
	local speedx, speedy, speedz = getElementVelocity ( veh )
       local actualspeed = (speedx^2 + speedy^2 + speedz^2)^(0.5)
       local speed = math.floor(actualspeed * 180)
	dxDrawSpeedText(speed, screenWidth, screenHeight-105, screenWidth-240, 300, tocolor ( 255,255,255 ), 1, SPEEDO_FONT, "center")
	dxDrawSpeedText( "км/h", screenWidth-133, screenHeight-82, 240, 300, tocolor ( 255,255,255 ), 1, REG)

	dxDrawSpeedText(string.sub(getVehicleRPM(veh), 1, 1), screenWidth, screenHeight-80, screenWidth-430, 300, tocolor ( 255,255,255 ), 1, RPM_FONT, "center")
	dxDrawSpeedText( "RPM", screenWidth-226, screenHeight-53, 240, 300, tocolor ( 255,255,255 ), 1, REG)

	if not (getVehicleEngineState(veh)) then
		dxDrawImage(screenWidth-185, screenHeight-45, 26, 26, "assets/engine_off.png")
	else
		dxDrawImage(screenWidth-185, screenHeight-45, 26, 26, "assets/engine_on.png")
	end
	
	if not isVehicleLocked ( veh ) then  
		dxDrawImage(screenWidth-125, screenHeight-45, 26, 26, "assets/door_open.png")
	else
		dxDrawImage(screenWidth-125, screenHeight-45, 26, 26, "assets/door_close.png")
	end
	
	if (getVehicleOverrideLights(veh) == 2) then
		dxDrawImage(screenWidth-95, screenHeight-45, 26, 26, "assets/lights_on.png")
	else
		dxDrawImage(screenWidth-95, screenHeight-45, 26, 26, "assets/lights_off.png")
	end

	if ccEnabled then 
		dxDrawImage(screenWidth-155, screenHeight-45, 26, 26, "assets/cc_on.png")
	else
		dxDrawImage(screenWidth-155, screenHeight-45, 26, 26, "assets/cc_off.png")
	end

	dxDrawImage(screenWidth-160, screenHeight-87, 26, 26, "assets/turnlight_l.png")
	dxDrawImage(screenWidth-107, screenHeight-87, 26, 26, "assets/turnlight_r.png")

	if getElementData(getPedOccupiedVehicle ( localPlayer ), "rightflash" ) then
		if ( getTickCount () % 1400 >= 600 ) then
			dxDrawImage(screenWidth-107, screenHeight-87, 26, 26, "assets/turnlight_r_a.png")
	    end
	end
   

	if getElementData(getPedOccupiedVehicle ( localPlayer ), "leftflash" ) then
		if ( getTickCount () % 1400 >= 600 ) then
			dxDrawImage(screenWidth-160, screenHeight-87, 26, 26, "assets/turnlight_l_a.png")
	    end
	end

	if getElementData(getPedOccupiedVehicle ( localPlayer ), "allflash" ) then
		if ( getTickCount () % 1400 >= 600 ) then
			dxDrawImage(screenWidth-160, screenHeight-87, 26, 26, "assets/turnlight_l_a.png")
			dxDrawImage(screenWidth-107, screenHeight-87, 26, 26, "assets/turnlight_r_a.png")
		end
	end

   
    if fuel >= 11 and fuel <= 100 then
	    dxDrawImage(screenWidth-35, screenHeight-60, 26, 26, "assets/fuel.png",0,0,0,tocolor(255,255,255))
    end 
	if fuel >= 1 and fuel <= 10 then
		alpha = 0
		if ( getTickCount () % 1500 >= 500 ) then
			dxDrawImage(screenWidth-35, screenHeight-60, 26, 26, "assets/fuel_empty.png",0,0,0,tocolor(255,255,255))
		end
    end 
	if fuel == 0 then
        --alpha = 0
		dxDrawImage(screenWidth-35, screenHeight-60, 26, 26, "assets/fuel_no.png",0,0,0,tocolor(255,255,255))
	end
	dxDrawCircle( screenWidth-(-320/5), screenHeight-120, 170, 165,tocolor (40,40,40,255),230,93,4.4)
	dxDrawCircle( screenWidth-(-320/5), screenHeight-120, 170, 165,color,230,math.floor(math.round(fuel)*0.93),4.4)
end
addEventHandler("onClientRender", root, drawSpeedometr)
addEventHandler("onClientVehicleEnter", root, function (thePlayer, seat)
	 if thePlayer == localPlayer and seat == 0 then
	addEventHandler("onClientRender", root, drawSpeedometr)
end
end)

addEventHandler("onClientVehicleStartExit", root, function(thePlayer, seat)
    if thePlayer == localPlayer and seat == 0 then
        removeEventHandler("onClientRender", root, drawSpeedometr)
    end
end)

addEventHandler("onClientElementDestroy", getRootElement(), function ()
	if getElementType(source) == "vehicle" and getPedOccupiedVehicle(getLocalPlayer()) == source then
		removeEventHandler("onClientRender", root, drawSpeedometr)
	end
end)

addEventHandler ( "onClientPlayerWasted", getLocalPlayer(), function()
	if not getPedOccupiedVehicle(source) then return end
	removeEventHandler("onClientRender", root, drawSpeedometr)
end)


function dxDrawSpeedText(text, x1, y1, x2, y2, color, size, font, pos)
	dxDrawText(text, x1 - 1, y1, x2 - 1, y2, tocolor(0, 0, 0, 150), size, font, pos or nil)
	dxDrawText(text, x1 + 1, y1, x2 + 1, y2, tocolor(0, 0, 0, 150), size, font, pos or nil)
	dxDrawText(text, x1, y1 - 1, x2, y2 - 1, tocolor(0, 0, 0, 150), size, font, pos or nil)
	dxDrawText(text, x1, y1 + 1, x2, y2 + 1, tocolor(0, 0, 0, 150), size, font, pos or nil)
	dxDrawText(text, x1, y1, x2, y2, color, size, font, pos or nil)
end

function getVehicleSpeed()
    if isPedInVehicle(getLocalPlayer()) then
	    local theVehicle = getPedOccupiedVehicle (getLocalPlayer())
        local vx, vy, vz = getElementVelocity (theVehicle)
        return math.sqrt(vx^2 + vy^2 + vz^2) * 165
    end
    return 0
end

function getElementSpeed(element)
	speedx, speedy, speedz = getElementVelocity (element)
	actualspeed = (speedx^2 + speedy^2 + speedz^2)^(0.5) 
	kmh = actualspeed * 180
	return math.round(kmh)
end

function math.round(number, decimals, method)
    decimals = decimals or 0
    local factor = 10 ^ decimals
    if (method == "ceil" or method == "floor") then return math[method](number * factor) / factor
    else return tonumber(("%."..decimals.."f"):format(number)) end
end

function getVehicleRPM(vehicle)
	local vehicleRPM = 0
    if (vehicle) then  
        if (getVehicleEngineState(vehicle) == true) then
            if getVehicleCurrentGear(vehicle) > 0 then   
				vehicleRPM = math.floor(((getElementSpeed(vehicle, "kmh")/getVehicleCurrentGear(vehicle))*180) + 0.5) 
				if getElementSpeed(vehicle, "kmh") == 0 then vehicleRPM  = math.random(1500, 1650) end
                if (vehicleRPM < 650) then
                    vehicleRPM = math.random(650, 750)
                elseif (vehicleRPM >= 9800) then
                    vehicleRPM = math.random(9800, 9900)
                end
            else
                vehicleRPM = math.floor((getElementSpeed(vehicle, "kmh")*80) + 0.5)
				if getElementSpeed(vehicle, "kmh") == 0 then vehicleRPM  = math.random(1500, 1650) end
                if (vehicleRPM < 650) then
                    vehicleRPM = math.random(650, 750)
                elseif (vehicleRPM >= 9800) then
                    vehicleRPM = math.random(9800, 9900)
                end
            end
        else
            vehicleRPM = 0
        end
        return tonumber(vehicleRPM)
    else
        return 0
    end
end

-------------------КРУИЗ------------------------
limit = true

allowedTypes = { "Automobile" }

function getElementSpeed(element,unit)
	if (unit == nil) then unit = 0 end
	if (isElement(element)) then
		local x,y,z = getElementVelocity(element)
		if (unit=="mph" or unit==1 or unit =='1') then
			return (x^2 + y^2 + z^2) ^ 0.5 * 100
		else
			return (x^2 + y^2 + z^2) ^ 0.5 * 180
		end
	else
		return false
	end
end

function setElementSpeed(element, unit, speed)
	if (unit == nil) then unit = 0 end
	if (speed == nil) then speed = 0 end
	speed = tonumber(speed)
	local acSpeed = getElementSpeed(element, unit)
	if (acSpeed~=false) then 
		local diff = speed/acSpeed
		local x,y,z = getElementVelocity(element)
		setElementVelocity(element,x*diff,y*diff,z*diff)
		return true
	else
		return false
	end
end

function in_array(e, t)
	for _,v in pairs(t) do
		if (v==e) then return true end
	end
	return false
end

function round2(num, idp)
  return tonumber(string.format("%." .. (idp or 0) .. "f", num))
end


function angle(vehicle)
	local vx,vy,vz = getElementVelocity(vehicle)
	local modV = math.sqrt(vx*vx + vy*vy)
	
	if not isVehicleOnGround(vehicle) then return 0,modV end
	
	local rx,ry,rz = getElementRotation(vehicle)
	local sn,cs = -math.sin(math.rad(rz)), math.cos(math.rad(rz))
	
	local cosX = (sn*vx + cs*vy)/modV
	return math.deg(math.acos(cosX))*0.5, modV
end

lp = getLocalPlayer()
ccEnabled = false

myveh = false
targetSpeed = 1
multiplier = 1

function cc()
	if (not isElement(myveh)) then
		removeEventHandler("onClientRender", getRootElement(), cc)
		ccEnabled=false
		return false
	end
	if getVehicleEngineState(myveh) == false then
		removeEventHandler("onClientRender", getRootElement(), cc)
		ccEnabled=false
		return false
	end
	local x,y = angle(myveh)
	if (x<15) then
		local speed = getElementSpeed(myveh)
		local targetSpeedTmp = speed + multiplier
		if (targetSpeedTmp > targetSpeed) then
			targetSpeedTmp = targetSpeed
		end
		if (targetSpeedTmp > 3) then
			setElementSpeed(myveh, "k", targetSpeedTmp)
		end
	end
end

bindKey("lshift", "up", function()
	local veh = getPedOccupiedVehicle(lp)
	if (veh) then
		if (lp==getVehicleOccupant(veh)) then
			myveh = veh
			if (ccEnabled) then
				removeEventHandler("onClientRender", getRootElement(), cc)
				ccEnabled=false
			else
				targetSpeed = getElementSpeed(veh)
				if targetSpeed > 4 then
					if (limit) then
						if in_array(getVehicleType(veh), allowedTypes) then
							targetSpeed = round2(targetSpeed)
							addEventHandler("onClientRender", getRootElement(), cc)
							ccEnabled=true				
						end
					else
						targetSpeed = round2(targetSpeed)
						addEventHandler("onClientRender", getRootElement(), cc)
						ccEnabled=true
					end
				end
			end
		end
	end
end)

bindKey("brake_reverse","down",function()
	if ccEnabled then
		removeEventHandler("onClientRender", getRootElement(), cc)
		ccEnabled=false
	end
end)

bindKey("handbrake","down",function()
	if ccEnabled then
		removeEventHandler("onClientRender", getRootElement(), cc)
		ccEnabled=false
	end
end)

addEventHandler("onClientPlayerVehicleExit", getLocalPlayer(), function(veh, seat)
	if (seat==0) then
		if (ccEnabled) then
			removeEventHandler("onClientRender", getRootElement(), cc)
			ccEnabled=false
		end
	end
end)
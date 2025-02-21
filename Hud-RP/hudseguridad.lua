local screenW, screenH = guiGetScreenSize()
local components = {"ammo", "area_name", "armour", "breath", "clock", "health", "money", "vehicle_name", "weapon", "radio", "wanted"}
local hudVisible = true  -- HUD visible por defecto
local customFont = dxCreateFont("bold.ttf", 10)
local customFont2 = dxCreateFont("righteous.ttf", 15)
local customFont4 = dxCreateFont("bold.ttf", 11)
local customFont5 = dxCreateFont("righteous.ttf", 13)
local circleSegments = 100
local lineThickness = screenW * 0.0013
local backgroundSize = screenW * 0.02
local iconSize = screenW * 0.014
local iconOffset = (backgroundSize - iconSize) / 2

function dxDrawCircle(posX, posY, radius, startAngle, stopAngle, color)
    startAngle = math.rad(startAngle)
    stopAngle = math.rad(stopAngle)
    local step = (stopAngle - startAngle) / circleSegments
    local sx, sy = posX + math.cos(startAngle) * radius, posY + math.sin(startAngle) * radius
    for i = 1, circleSegments do
        local angle = startAngle + step * i
        local ex, ey = posX + math.cos(angle) * radius, posY + math.sin(angle) * radius
        dxDrawLine(sx, sy, ex, ey, color, lineThickness)
        sx, sy = ex, ey
    end
end

function drawCustomHUD()
    local playerInterior = getElementInterior(localPlayer)
    local playerDimension = getElementDimension(localPlayer)
   

    if playerInterior == 6 and playerDimension == 1 then
        dxDrawImage(screenW * 0.4, screenH * 0.4, screenW * 0.2, screenH * 0.2, "images/your_image.png")
        return
    end

    if hudVisible then
        drawMoneyHUD()
        drawHealthHUD()
        drawArmorHUD()
        drawThirstHUD()
        drawHungerHUD()
        drawStaminaHUD()
        drawWeaponHUD()
    end
end

function drawMoneyHUD()
    local money = getPlayerMoney(localPlayer)
    local moneyText = formatMoney(money)
    local playerName = getPlayerName(localPlayer)
    local playerID = getElementData(localPlayer, "playerid")
    local playerNameWithID = string.format("[%d] %s", playerID, playerName)
    local moneyX = screenW * 0.870
    local moneyY = screenH * 0.06
    local rectangleSizeW = screenW * 0.11
    local rectangleSizeH = screenH * 0.025
    local playerNameX = moneyX
    local playerNameY = moneyY - screenH * 0.03

    local isStaffDuty = getElementData(localPlayer, "account:gmduty") or false
    local playerNameColor = isStaffDuty and tocolor(255, 0, 0, 255) or tocolor(255, 255, 255, 255)

    -- Calcula la longitud del texto del nombre del jugador
    local textWidth = dxGetTextWidth(playerNameWithID, 1, customFont2)
    
    -- Calcula la escala del texto basada en la longitud y el tamaño del rectángulo
    local scale = 0.9
    if textWidth > rectangleSizeW then
        scale = rectangleSizeW / textWidth
    end

    dxDrawImage(playerNameX, playerNameY, rectangleSizeW, rectangleSizeH, "images/rectangle.png", 0, 0, 0, tocolor(0, 0, 0 , 255))
    dxDrawText(playerNameWithID, playerNameX, playerNameY, playerNameX + rectangleSizeW, playerNameY + rectangleSizeH, playerNameColor, scale, customFont2, "center", "center")

    -- Dibuja el rectángulo del dinero
    dxDrawImage(moneyX, moneyY, rectangleSizeW, rectangleSizeH, "images/rectangle.png", 0, 0, 0, tocolor(0, 0, 0 , 255))
    
    -- Separa el símbolo $ del resto del texto
    local dollarSymbol = "$ "
    local dollarSymbolColor = tocolor(76, 187, 3, 255)
    local remainingMoneyText = string.sub(moneyText, 3)  -- Quita el símbolo "$ " del inicio

    -- Calcula la longitud del texto del dinero y del símbolo $
    local dollarSymbolWidth = dxGetTextWidth(dollarSymbol, 1, customFont5)
    local remainingMoneyTextWidth = dxGetTextWidth(remainingMoneyText, 1, customFont5)
    local totalTextWidth = dollarSymbolWidth + remainingMoneyTextWidth

    -- Calcula las posiciones para centrar el texto
    local textStartX = moneyX + (rectangleSizeW - totalTextWidth) / 2

    -- Dibuja el símbolo $ y el texto del dinero centrados
    dxDrawText(dollarSymbol, textStartX, moneyY, textStartX + dollarSymbolWidth, moneyY + rectangleSizeH, dollarSymbolColor, 1, customFont5, "left", "center")
    dxDrawText(remainingMoneyText, textStartX + dollarSymbolWidth, moneyY, textStartX + totalTextWidth, moneyY + rectangleSizeH, tocolor(255, 255, 255, 255), 1, customFont5, "left", "center")
end

function formatMoney(amount)
    local formatted = string.format("%d", amount)
    while true do  
        formatted, k = string.gsub(formatted, "^(-?%d+)(%d%d%d)", '%1,%2')
        if k == 0 then break end
    end
    return "$ " .. formatted
end

function drawStatHUD(statValue, posX, posY, iconPath, color, statTextColor)
    local percent = (statValue / 100) * 100
    local text = string.format("%.0f%%", percent)
    
    dxDrawImage(posX, posY, backgroundSize, backgroundSize, "images/circle.png", 0, 0, 0, tocolor(24, 24, 24, 200))
    dxDrawImage(posX + iconOffset, posY + iconOffset, iconSize, iconSize, iconPath, 0, 0, 0, color)
    
    local startAngle = -90
    local stopAngle = startAngle - (360 * (percent / 100))
    local circleRadius = backgroundSize / 2
    dxDrawCircle(posX + circleRadius, posY + circleRadius, circleRadius, startAngle, stopAngle, color)
    
    dxDrawText(text, posX, posY + backgroundSize + 5, posX + backgroundSize, posY + backgroundSize + 25, statTextColor, 0.8, customFont, "center", "top")
end

function drawHealthHUD()
    local health = getElementHealth(localPlayer)
    drawStatHUD(health, screenW * 0.87, screenH * 0.10, "images/corazon.png", tocolor(255, 0, 0, 193), tocolor(255, 0, 0, 255))
end

function drawThirstHUD()
    local thirst = getElementData(localPlayer, "sed") or 100
    drawStatHUD(thirst, screenW * 0.90, screenH * 0.10, "images/sed.png", tocolor(0, 162, 255, 255), tocolor(0, 162, 255, 255))
end

function drawHungerHUD()
    local hunger = getElementData(localPlayer, "hambre") or 100
    drawStatHUD(hunger, screenW * 0.93, screenH * 0.10, "images/hambre.png", tocolor(255, 165, 0, 255), tocolor(255, 165, 0, 255))
end

function drawArmorHUD()
    local armor = getPedArmor(localPlayer)
    if armor > 0 then
        drawStatHUD(armor, screenW * 0.84, screenH * 0.10, "images/armor.png", tocolor(165, 240, 141, 193), tocolor(165, 240, 141, 255))
    end
end

function drawStaminaHUD()
    local stamina = getElementData(localPlayer, "stamina") or 100
    drawStatHUD(stamina, screenW * 0.96, screenH * 0.10, "images/stamina.png", tocolor(233, 236, 177, 255), tocolor(233, 236, 177, 255))
end

function drawWeaponHUD()
    local weaponID = getPedWeapon(localPlayer)
    local tazerOn = getElementData(localPlayer, "tazerOn")

    if weaponID and weaponID ~= 0 then
        local weaponName = getWeaponNameFromID(weaponID)
        if weaponID == 24 and tazerOn then
            weaponName = "Tazer"
        end

        local ammoInClip = getPedAmmoInClip(localPlayer)
        local totalAmmo = getPedTotalAmmo(localPlayer)
        local reserveAmmo = totalAmmo - ammoInClip

        weaponText = string.format("%s ", weaponName)
        ammoText = string.format("(%d) ", ammoInClip)
        reserveAmmoText = string.format("%d", reserveAmmo)
    else
        weaponText = "Manos Vacias"
        ammoText = ""
        reserveAmmoText = ""
    end

    local weaponTextX = screenW * 0.927
    local weaponTextY = screenH * 0.165
    local textWidth = screenW * 0.1
    local textHeight = screenH * 0.025
    local outlineColor = tocolor(0, 0, 0, 255)
    local textColor = tocolor(255, 255, 255, 255)
    local reserveAmmoColor = tocolor(169, 169, 169, 255) -- Color gris
    local scaleFactor = math.min(screenW / 1920, screenH / 1080)
    local fontSize = 1 * scaleFactor
    local font = customFont4

    local function drawOutlinedText(text, x, y, color)
        dxDrawText(text, x - 1, y - 1, x + textWidth - 1, y + textHeight - 1, outlineColor, fontSize, font, "left", "top")
        dxDrawText(text, x + 1, y - 1, x + textWidth + 1, y + textHeight - 1, outlineColor, fontSize, font, "left", "top")
        dxDrawText(text, x - 1, y + 1, x + textWidth - 1, y + textHeight + 1, outlineColor, fontSize, font, "left", "top")
        dxDrawText(text, x + 1, y + 1, x + textWidth + 1, y + textHeight + 1, outlineColor, fontSize, font, "left", "top")
        dxDrawText(text, x, y, x + textWidth, y + textHeight, color, fontSize, font, "left", "top")
    end

    drawOutlinedText(weaponText, weaponTextX, weaponTextY, textColor)
    drawOutlinedText(ammoText, weaponTextX + dxGetTextWidth(weaponText, fontSize, font), weaponTextY, reserveAmmoColor)
    drawOutlinedText(reserveAmmoText, weaponTextX + dxGetTextWidth(weaponText .. ammoText, fontSize, font), weaponTextY, reserveAmmoColor)
end

addEventHandler("onClientRender", root, drawCustomHUD)

function ocultarHudDefault()
    for _, componente in ipairs(components) do
        setPlayerHudComponentVisible(componente, false)
    end
end

addEventHandler("onClientResourceStart", getResourceRootElement(getThisResource()), ocultarHudDefault)




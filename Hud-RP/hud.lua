local screenW, screenH = guiGetScreenSize()
if not screenW or not screenH then
    outputChatBox("Error: No se pudo obtener el tamaño de la pantalla.", 255, 0, 0, false)
    return
end

local components = {"ammo", "area_name", "armour", "breath", "clock", "health", "money", "vehicle_name", "weapon", "radio", "wanted"}
local hudVisible = true  -- HUD visible por defecto
local editing = false -- Modo de edición del HUD
local customFont = dxCreateFont("bold.ttf", 10)
local customFont2 = dxCreateFont("righteous.ttf", 15)
local customFont4 = dxCreateFont("bold.ttf", 11)
local customFont5 = dxCreateFont("righteous.ttf", 13)
local circleSegments = 100
local lineThickness = screenW * 0.0013
local backgroundSize = screenW * 0.02
local iconSize = screenW * 0.014
local iconOffset = (backgroundSize - iconSize) / 2

local draggedComponent = nil  -- Componente que está siendo arrastrado
local offsetX, offsetY = 0, 0  -- Desplazamiento relativo entre el mouse y el componente
local editableComponents = {}  -- Lista para almacenar los componentes editables

-- Posiciones iniciales del HUD (pueden ser personalizadas)
local hudPositions = {
    money = {x = screenW * 0.87, y = screenH * 0.06},
    health = {x = screenW * 0.87, y = screenH * 0.10},
    armour = {x = screenW * 0.84, y = screenH * 0.10},
    thirst = {x = screenW * 0.90, y = screenH * 0.10},
    hunger = {x = screenW * 0.93, y = screenH * 0.10},
    stamina = {x = screenW * 0.96, y = screenH * 0.10},
    weapon = {x = screenW * 0.927, y = screenH * 0.165},
}

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
    local moneyX = hudPositions.money.x
    local moneyY = hudPositions.money.y
    local rectangleSizeW = screenW * 0.11
    local rectangleSizeH = screenH * 0.025
    local playerNameX = moneyX
    local playerNameY = moneyY - screenH * 0.03

    dxDrawImage(playerNameX, playerNameY, rectangleSizeW, rectangleSizeH, "images/rectangle.png", 0, 0, 0, tocolor(0, 0, 0 , 255))
    dxDrawText(playerNameWithID, playerNameX, playerNameY, playerNameX + rectangleSizeW, playerNameY + rectangleSizeH, tocolor(255, 255, 255, 255), 0.9, customFont2, "center", "center")
    dxDrawImage(moneyX, moneyY, rectangleSizeW, rectangleSizeH, "images/rectangle.png", 0, 0, 0, tocolor(0, 0, 0 , 255))
    local dollarSymbol = "$ "
    local dollarSymbolColor = tocolor(76, 187, 3, 255)
    local remainingMoneyText = string.sub(moneyText, 3)
    local dollarSymbolWidth = dxGetTextWidth(dollarSymbol, 1, customFont5)
    local remainingMoneyTextWidth = dxGetTextWidth(remainingMoneyText, 1, customFont5)
    local totalTextWidth = dollarSymbolWidth + remainingMoneyTextWidth
    local textStartX = moneyX + (rectangleSizeW - totalTextWidth) / 2
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
    drawStatHUD(health, hudPositions.health.x, hudPositions.health.y, "images/corazon.png", tocolor(255, 0, 0, 193), tocolor(255, 0, 0, 255))
end

function drawThirstHUD()
    local thirst = getElementData(localPlayer, "sed") or 100
    drawStatHUD(thirst, hudPositions.thirst.x, hudPositions.thirst.y, "images/sed.png", tocolor(0, 162, 255, 255), tocolor(0, 162, 255, 255))
end

function drawHungerHUD()
    local hunger = getElementData(localPlayer, "hambre") or 100
    drawStatHUD(hunger, hudPositions.hunger.x, hudPositions.hunger.y, "images/hambre.png", tocolor(255, 165, 0, 255), tocolor(255, 165, 0, 255))
end

function drawArmorHUD()
    local armor = getPedArmor(localPlayer)
    if armor > 0 then
        drawStatHUD(armor, hudPositions.armour.x, hudPositions.armour.y, "images/armor.png", tocolor(165, 240, 141, 193), tocolor(165, 240, 141, 255))
    end
end

function drawStaminaHUD()
    local stamina = getElementData(localPlayer, "stamina") or 100
    drawStatHUD(stamina, hudPositions.stamina.x, hudPositions.stamina.y, "images/stamina.png", tocolor(233, 236, 177, 255), tocolor(233, 236, 177, 255))
end

function drawWeaponHUD()
    local weaponID = getPedWeapon(localPlayer)
    local tazerOn = getElementData(localPlayer, "tazerOn")

    local weaponText, ammoText, reserveAmmoText

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

    local weaponTextX = hudPositions.weapon.x
    local weaponTextY = hudPositions.weapon.y
    drawOutlinedText(weaponText, weaponTextX, weaponTextY, tocolor(255, 255, 255, 255))
    drawOutlinedText(ammoText, weaponTextX + dxGetTextWidth(weaponText, 1, customFont), weaponTextY, tocolor(169, 169, 169, 255))
    drawOutlinedText(reserveAmmoText, weaponTextX + dxGetTextWidth(weaponText .. ammoText, 1, customFont), weaponTextY, tocolor(169, 169, 169, 255))
end

function drawOutlinedText(text, x, y, color)
    local outlineColor = tocolor(0, 0, 0, 255)
    local textWidth = dxGetTextWidth(text, 1, customFont4)
    local textHeight = screenH * 0.025
    dxDrawText(text, x - 1, y - 1, x + textWidth - 1, y + textHeight - 1, outlineColor, 1, customFont4, "left", "top")
    dxDrawText(text, x + 1, y - 1, x + textWidth + 1, y + textHeight - 1, outlineColor, 1, customFont4, "left", "top")
    dxDrawText(text, x - 1, y + 1, x + textWidth - 1, y + textHeight + 1, outlineColor, 1, customFont4, "left", "top")
    dxDrawText(text, x + 1, y + 1, x + textWidth + 1, y + textHeight + 1, outlineColor, 1, customFont4, "left", "top")
    dxDrawText(text, x, y, x + textWidth, y + textHeight, color, 1, customFont4, "left", "top")
end

function toggleEditingMode()
    if editing then
        outputChatBox("#058300[US:RP] #ffffff Modo de edición desactivado.", 88, 131, 104, true)
    else
        outputChatBox("#058300[US:RP] #ffffff Modo de edición activado. Arrastra los componentes del HUD.", 88, 131, 104, true)
    end
    editing = not editing
end

addCommandHandler("edithud", toggleEditingMode)

function confirmChanges()
    if not editing then
        outputChatBox("#FF0000[US:RP] #ffffff Primero activa el modo de edición con /edithud.", 255, 0, 0, true)
        return
    end
    -- Guardar las nuevas posiciones aquí si es necesario.
    outputChatBox("#058300[US:RP] #ffffff Cambios confirmados.", 88, 131, 104, true)
    editing = false  -- Desactivar el modo de edición al confirmar
end


addCommandHandler("confirmar", confirmChanges)

addEventHandler("onClientClick", root, function(button, state, x, y)
    if editing then
        for component, position in pairs(hudPositions) do
            local compX, compY = position.x, position.y
            local compW, compH = screenW * 0.1, screenH * 0.025  -- Tamaño del rectángulo del componente (ajustar si es necesario)
            if x >= compX and x <= compX + compW and y >= compY and y <= compY + compH then
                draggedComponent = component
                offsetX = x - compX
                offsetY = y - compY
            end
        end
    end
end)

addEventHandler("onClientRender", root, function()
    if draggedComponent then
        local x, y = getCursorPosition()
        x = x * screenW - offsetX
        y = y * screenH - offsetY
        hudPositions[draggedComponent].x = x
        hudPositions[draggedComponent].y = y
    end

    -- Asegurarnos de que siempre se dibuje el HUD
    drawCustomHUD()
end)

addEventHandler("onClientClick", root, function(button, state, x, y)
    if state == "up" then
        draggedComponent = nil
    end
end)

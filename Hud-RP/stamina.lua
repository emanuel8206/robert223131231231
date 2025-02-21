local isSprinting = false

function manageStamina()
    local stamina = getElementData(localPlayer, "stamina") or 100
    local moveState = getPedMoveState(localPlayer)
    local isInVehicle = isPedInVehicle(localPlayer)
    local isStaffDuty = getElementData(localPlayer, "account:gmduty")

    if not isStaffDuty then
        if moveState == "sprint" then
            if stamina > 0 then
                setElementData(localPlayer, "stamina", stamina - 0.045)
                isSprinting = true
            else
                setControlState("sprint", false)
                toggleControl("sprint", false)
                isSprinting = false
            end
        elseif moveState == "jump" then
                setElementData(localPlayer, "stamina", stamina - 0.130)
                isSprinting = true
        elseif (moveState == "stand" or moveState == "crouch" or moveState == "walk" or moveState == "crawl" or isInVehicle) and stamina < 100 then
            
                setElementData(localPlayer, "stamina", stamina + 0.035)
            --end
            isSprinting = false
        end

        if stamina < 0 then
            setElementData(localPlayer, "stamina", 0)
        end

        if stamina > 100 then
            setElementData(localPlayer, "stamina", 100)
        end

        if stamina <= 21 then
            toggleControl("jump", false)
        else
            toggleControl("jump", true)
        end

        if stamina > 21 then
            toggleControl("sprint", true)
        end
    else
        toggleControl("jump", true)
        toggleControl("sprint", true)
    end
end

function onResourceStart()
    setElementData(localPlayer, "stamina", 100)
    toggleControl("sprint", true)
    toggleControl("jump", true)
end

addEventHandler("onClientRender", root, manageStamina)
addEventHandler("onClientResourceStart", resourceRoot, onResourceStart)
addEventHandler("onClientPlayerJump", localPlayer, handleJump)

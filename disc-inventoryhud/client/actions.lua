isHotKeyCoolDown = false
RegisterNUICallback('UseItem', function(data)
    if isWeapon(data.item.id) then
        currentWeaponSlot = data.slot
    end
    TriggerServerEvent('disc-inventoryhud:notifyImpendingRemoval', data.item, 1)
    TriggerServerEvent("esx:useItem", data.item.id)
    TriggerEvent('disc-inventoryhud:refreshInventory')
    data.item.msg = _U('used')
    data.item.qty = 1
    TriggerEvent('disc-inventoryhud:showItemUse', {
        data.item
    })
end)

local keys = {
    157, 158, 160, 164, 165
}

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(0)
        BlockWeaponWheelThisFrame()
        HideHudComponentThisFrame(19)
        HideHudComponentThisFrame(20)
        HideHudComponentThisFrame(17)
        DisableControlAction(0, 37, true) --Disable Tab
        EnableControlAction(0, 163, true)
        for k, v in pairs(keys) do
            if IsDisabledControlJustReleased(0, v) then
                UseItem(k)
            end
        end
        if IsDisabledControlJustReleased(0, 37) then
            ESX.TriggerServerCallback('disc-inventoryhud:GetItemsInSlotsDisplay', function(items)
                SendNUIMessage({
                    action = 'showActionBar',
                    items = items
                })
            end)
        end
    end
end)

function UseItem(slot)
    if isHotKeyCoolDown then
        return
    end
    Citizen.CreateThread(function()
        isHotKeyCoolDown = true
        Citizen.Wait(Config.HotKeyCooldown)
        isHotKeyCoolDown = false
    end)
    ESX.TriggerServerCallback('disc-inventoryhud:UseItemFromSlot', function(item)
        if item then
            if isWeapon(item.id) then
                currentWeaponSlot = slot
            end
            TriggerServerEvent('disc-inventoryhud:notifyImpendingRemoval', item, 1)
            TriggerServerEvent("esx:useItem", item.id)
            item.msg = _U('used')
            item.qty = 1
            TriggerEvent('disc-inventoryhud:showItemUse', {
                item,
            })
        end
    end
    , slot)
end

RegisterNetEvent('disc-inventoryhud:showItemUse')
AddEventHandler('disc-inventoryhud:showItemUse', function(items)
    local data = {}
    for k, v in pairs(items) do
        table.insert(data, {
            item = {
                label = v.label,
                itemId = v.id
            },
            qty = v.qty,
            message = v.msg
        })
    end
    SendNUIMessage({
        action = 'itemUsed',
        alerts = data
    })
end)

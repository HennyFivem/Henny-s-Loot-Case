RegisterNetEvent('henny_lootcase:client:useBox', function(data)
    SendNUIMessage({ action = 'open' })
    SetNuiFocus(true, true)
    TriggerServerEvent('henny_lootcase:server:openBox', Config.LootboxItemName)
end)

RegisterNetEvent('henny_lootcase:client:showResult', function(reward, allRewards)
    SendNUIMessage({
        action = 'result',
        winner = reward,
        reel = allRewards
    })
end)


RegisterNUICallback('animationFinished', function(data, cb)

    TriggerServerEvent('henny_lootcase:server:finalizeReward', data.winner)
    cb({})
end)

RegisterNUICallback('close', function(_, cb)
    SetNuiFocus(false, false)
    cb({})
end)
local Framework = exports['qb-core']:GetCoreObject()
local PendingRewards = {}

function LogDiscordInfo(title, message, source)
    if not Config.Webhook.Enabled or not Config.Webhook.URL or Config.Webhook.URL == "YOUR_WEBHOOK_URL_HERE" then return end
    local fields = {{ ["name"] = "Details", ["value"] = string.format("```%s```", message), ["inline"] = false }}
    if source then
        local playerName = GetPlayerName(source) or ("Player " .. source)
        table.insert(fields, 1, { ["name"] = "Player", ["value"] = string.format("```%s (ID: %s)```", playerName, source), ["inline"] = false })
    end
    local embed = {{ ["author"] = {["name"] = "Log Details"}, ["title"] = title, ["color"] = 4886754, ["fields"] = fields, ["footer"] = {["text"] = "henny_lootcase | " .. os.date("%Y-%m-%d %H:%M:%S")} }}

    PerformHttpRequest(Config.Webhook.URL, function(err, text, headers) end, 'POST', json.encode({username = Config.Webhook.BotName, avatar_url = Config.Webhook.BotAvatar, embeds=embed}), {['Content-Type']='application/json'})
end

function LogDiscordError(title, message, source)
    if not Config.Webhook.Enabled or not Config.Webhook.URL or Config.Webhook.URL == "YOUR_WEBHOOK_URL_HERE" then return end
    local fields = {{["name"]="Details",["value"]=string.format("```%s```",message),["inline"]=false}}
    if source then
        local playerName = GetPlayerName(source) or ("Player " .. source)
        local safeIdentifiers = {}
        for _, identifier in ipairs(GetPlayerIdentifiers(source)) do
            if not string.find(identifier, "ip:") then table.insert(safeIdentifiers, identifier) end
        end
        table.insert(fields,1,{["name"]="Player",["value"]=string.format("```%s (ID: %s)```",playerName,source),["inline"]=false})
        table.insert(fields,{["name"]="Identifiers",["value"]="```\n"..table.concat(safeIdentifiers,"\n").."```",["inline"]=false})
    end
    local embed = {{["author"]={["name"]="Alert Details"},["title"]=title,["color"]=15158332,["fields"]=fields,["footer"]={["text"]="henny_lootcase | "..os.date("%Y-%m-%d %H:%M:%S")}}}

    PerformHttpRequest(Config.Webhook.URL,function(err,text,headers)end,'POST',json.encode({username = Config.Webhook.BotName, avatar_url = Config.Webhook.BotAvatar, embeds=embed}),{['Content-Type']='application/json'})
end

function SendToDiscord(source, reward, adminSource)
    if not Config.Webhook.Enabled or not Config.Webhook.URL or Config.Webhook.URL == "YOUR_WEBHOOK_URL_HERE" then return end
    local playerName = GetPlayerName(source) or ("Player " .. source)
    local safeIdentifiers = {}
    for _, identifier in ipairs(GetPlayerIdentifiers(source)) do
        if not string.find(identifier, "ip:") then table.insert(safeIdentifiers, identifier) end
    end
    local colorMapping = {common=10197915,uncommon=3066993,rare=3447003,epic=10181046,legendary=15844367,Admin=15158332}
    local embedColor = colorMapping[reward.rarity] or 10197915
    local embed = {{["color"]=embedColor,["footer"]={["text"]="henny_lootcase | "..os.date("%Y-%m-%d %H:%M:%S")}}}
    if adminSource then
        local adminName = GetPlayerName(adminSource) or ("Admin " .. adminSource)
        embed[1].title = "Admin Gave Supply Case"
        embed[1].fields = {{["name"]="Admin",["value"]=string.format("```%s (ID: %s)```",adminName,adminSource),["inline"]=true},{["name"]="Target Player",["value"]=string.format("```%s (ID: %s)```",playerName,source),["inline"]=true},{["name"]="Target Identifiers",["value"]="```\n"..table.concat(safeIdentifiers,"\n").."```",["inline"]=false}}
    else
        embed[1].title = "Lootcase Reward Received"
        embed[1].fields = {{["name"]="Player",["value"]=string.format("```%s (ID: %s)```",playerName,source),["inline"]=false},{["name"]="Item Won",["value"]=string.format("```%s (%s)```",reward.label,reward.name),["inline"]=true},{["name"]="Rarity",["value"]=string.format("```%s```",reward.rarity:upper()),["inline"]=true},{["name"]="Identifiers",["value"]="```\n"..table.concat(safeIdentifiers,"\n").."```",["inline"]=false}}
    end

    PerformHttpRequest(Config.Webhook.URL,function(err,text,headers)end,'POST',json.encode({username = Config.Webhook.BotName, avatar_url = Config.Webhook.BotAvatar, embeds=embed}),{['Content-Type']='application/json'})
end

RegisterNetEvent('henny_lootcase:server:openBox', function(boxItemName)
    local src = source
    local player = Framework.Functions.GetPlayer(src)
    if not player then return end
    if player.Functions.GetItemByName(boxItemName).count > 0 then
        LogDiscordInfo("Case Opening Initiated", string.format("Player is using one '%s'.", boxItemName), src)
        player.Functions.RemoveItem(boxItemName, 1)
        local reward = CalculateReward()
        if not reward then
            local errorMessage = "Could not determine a reward. Check Config.RarityChances and ensure items exist for each rarity."
            print(('[henny_lootcase] ERROR: '..errorMessage))
            LogDiscordError("Configuration Error", errorMessage)
            reward = { name = 'water_bottle', label = 'Water', amount = 1, rarity = 'common', type = 'item' }
        end
        PendingRewards[src] = reward
        TriggerClientEvent('henny_lootcase:client:showResult', src, reward, Config.Rewards)
    else
        local errorMessage = string.format("Player tried to open %s without having the item.", boxItemName)
        print(('[henny_lootcase] EXPLOIT ATTEMPT: '..errorMessage))
        LogDiscordError("Potential Exploit Attempt", errorMessage, src)
    end
end)

RegisterNetEvent('henny_lootcase:server:finalizeReward', function(rewardDataFromClient)
    local src = source
    if not Framework.Functions.GetPlayer(src) then return end
    local pendingReward = PendingRewards[src]
    if pendingReward and pendingReward.name == rewardDataFromClient.name then
        GiveReward(src, pendingReward)
        PendingRewards[src] = nil
    else
        local errorMessage = "Player tried to finalize a reward without a pending reward, or with tampered data."
        print(('[henny_lootcase] EXPLOIT ATTEMPT: '..errorMessage))
        LogDiscordError("Potential Exploit Attempt", errorMessage, src)
    end
end)

function GiveReward(source, reward)
    local player = Framework.Functions.GetPlayer(source)
    if not player then return end
    if reward.type == 'item' then
        player.Functions.AddItem(reward.name, reward.amount)
    elseif reward.type == 'weapon' then
        player.Functions.AddWeapon(reward.name, 0)
    end
    print(('[henny_lootcase] Player %s received a %s item: %s'):format(player.PlayerData.citizenid, reward.rarity, reward.label))
    SendToDiscord(source, reward)
end

function CalculateReward()
    local roll = math.random(1, 100)
    local cumulativeChance = 0
    local winningRarity = 'common'
    for rarity, chance in pairs(Config.RarityChances) do
        cumulativeChance = cumulativeChance + chance
        if roll <= cumulativeChance then winningRarity = rarity; break; end
    end
    local potentialRewards = {}
    for _, item in ipairs(Config.Rewards) do
        if item.rarity == winningRarity then table.insert(potentialRewards, item); end
    end
    if #potentialRewards > 0 then
        local chosenReward = potentialRewards[math.random(1, #potentialRewards)]
        if not chosenReward.type then chosenReward.type = 'item' end
        return chosenReward
    else
        return nil
    end
end

RegisterCommand('givecase', function(source, args, rawCommand)
    if IsPlayerAceAllowed(source, 'group.admin') then
        local targetId = tonumber(args[1])
        local amount = tonumber(args[2]) or 1
        if not targetId then TriggerClientEvent('ox_lib:notify', source, { description = 'Usage: /givecase [Player ID] [Amount]', type = 'error' }) return end
        local targetPlayer = Framework.Functions.GetPlayer(targetId)
        if targetPlayer then
            targetPlayer.Functions.AddItem(Config.LootboxItemName, amount)
            TriggerClientEvent('ox_lib:notify', source, { description = ('Gave %s x%d.'):format(Config.LootboxItemName, amount), type = 'success' })
            local logData = { rarity = "Admin" }
            SendToDiscord(targetId, logData, source)
        else
            TriggerClientEvent('ox_lib:notify', source, { description = 'Player not found.', type = 'error' })
        end
    end
end, false)

CreateThread(function()
    Wait(2000)
    LogDiscordInfo("Resource Started", "henny_lootcase has been started successfully.")
end)
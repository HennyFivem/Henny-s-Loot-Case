# Henny's Loot Case

A modern, secure, and highly configurable loot case script for FiveM, built for the QBCore and ESX frameworks. This script provides a polished, premium-quality user experience, from smooth NUI animations to detailed Discord logging, all while being powered by a secure, server-authoritative backend.

## Features

  * **🎬 Smooth NUI Animations:** A clean and responsive interface for a satisfying opening experience, featuring a rolling reel, rarity-themed glows, and a dramatic reveal.
  * **🎲 5-Tier Rarity System:** Configure loot pools and chances based on tiers: **Common, Uncommon, Rare, Epic, and Legendary**.
  * **🔌 Deep `ox_inventory` Integration:** Automatically uses your item images from `ox_inventory` without any extra configuration. The loot case itself is a usable item that can be opened anywhere.
  * **🔐 Secure Server-Side Logic:** All critical actions are handled securely on the server. Features include a delayed reward system and a `PendingRewards` table to protect against exploits and spam attacks.
  * **📝 Comprehensive Discord Logging:** Get detailed, color-coded webhook logs for every case opening, reward received, admin action, potential exploit, and script error. The webhook name and avatar can be forced from the config.
  * **🔊 Custom Sound Support:** Easily add your own custom sound effects for the rolling and reward-reveal animations. The animation timing is easily adjustable to sync perfectly with your audio.
  * **🤖 Admin Commands:** Includes a `/givecase` command for administrators with its own dedicated Discord log.
  * **🌐 Framework Support:** Works with both `qb-core` and `es_extended`.

## Dependencies

  * [qb-core](https://github.com/qbcore-framework/qb-core) or [es\_extended](https://www.google.com/search?q=https://github.com/es-extended/es_extended)
  * [ox\_lib](https://github.com/overextended/ox_lib) (Required for notifications and general script functions)
  * [ox\_inventory](https://github.com/overextended/ox_inventory) (Required for the usable item and automatic image fetching)

## Installation

1.  Download or clone this repository into your `resources` directory.
2.  Rename the folder to `henny_lootcase`.
3.  Ensure all dependencies listed above are also installed and started.
4.  Add `ensure henny_lootcase` to your `server.cfg` file, after the dependencies.
5.  Configure the files as described below.

## Configuration

Configuration is split between the `config.lua` file and your `ox_inventory` item list.

### 1\. The Loot Case Item

First, you must add the case as a usable item in your `ox_inventory`. Go to your inventory's item list (e.g., `ox_inventory/data/items.lua`) and add the following:

```lua
['loot_case'] = {
    label = 'Loot Case',
    weight = 2000,
    client = {
        event = 'henny_lootcase:client:useBox',
    },
},
```

*You can change `loot_case` to anything, but make sure it matches the `Config.LootboxItemName` in `config.lua`.*

### 2\. The Main Config (`config.lua`)

This file controls the core logic of the script.

  * **`Config.Webhook`**:

      * `Enabled`: Set to `true` or `false` to toggle Discord logging.
      * `URL`: **Crucial\!** Paste your Discord webhook URL here. The script will not log if this is left as the default.
      * `BotName` & `BotAvatar`: Customize the look of your log messages. The script will force this name and avatar on every post.

  * **`Config.Framework`**:

      * Set to `'qb'` for QBCore or `'esx'` for ESX.

  * **`Config.RarityChances`**:

      * Define the percentage chance for each rarity tier.
      * **Important:** All rarity percentages in this table **must add up to 100**.

  * **`Config.Rewards`**:

      * This is your master loot table.
      * `name`: The spawn name of the item. This is also used to find the image in `ox_inventory` (e.g., `'water_bottle'` looks for `water_bottle.png`).
      * `label`: The display name shown in the UI.
      * `amount`: The quantity of the item to give.
      * `rarity`: The tier of the item. Must match a name from `RarityChances`.
      * `type`: (Optional) Set to `'weapon'` for weapons. If omitted, it defaults to `'item'`.

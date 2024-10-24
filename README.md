# FiveM Halloween Event Script 🎃

A Halloween-themed event script for FiveM servers that adds trick-or-treating, pumpkin collection mechanics with jumpscares, and a leaderboard system.

## Features 🦇

- **Trick or Treating**: 
  - Visit houses to trick or treat
  - Unique door-knocking animation and sound effects
  - Player-specific door tracking (each player can visit each door once per session)
  - Customizable rewards system

- **Pumpkin Collection with Jumpscares**: 
  - Find and collect pumpkins across the map
  - Pumpkins respawn after configurable time
  - Random jumpscare events while collecting
  - Particle effects on collection
  - Statistics tracking and leaderboard
  - Persistent stats saved to JSON

- **Jumpscare System**: 
  - Random zombie appearances
  - Custom fog effects
  - Scary sound effects
  - Chase sequences
  - Configurable spawn distance and duration

- **Reward System**: 
  - Different types of rewards (candy, rare items, special items)
  - Configurable chances and amounts
  - Easy to add new rewards

## Dependencies 📦

- ESX Framework
- FiveM Server Build 2802 or higher

## Installation 💿

1. Clone this repository into your server's `resources` directory
```bash
cd resources
git clone https://github.com/FourTwentyDev/halloween
```
2. Add `ensure fourtwenty_halloween` to your `server.cfg`
3. Configure the script using the `config.lua` file
4. Start/restart your server

## Configuration 🔧

### Main Configuration
```lua
Config = {
    Debug = false,
    RespawnTime = 10, -- Minutes until pumpkins respawn
    SearchRadius = 2.0, -- Interaction radius
    CollectKey = 38, -- Key to interact (Default: E)
    Locale = "en" -- Available: "en", "de"
}
```

### Jumpscare Configuration
```lua
local JumpscareConfig = {
    npcModel = "u_m_y_zombie_01",
    spawnDistance = 10.0,
    duration = 3000,
    fogDensity = 0.3,
    jumpscareChance = 0.1,
    runSpeed = 8.0
}
```

### Reward Configuration

You can configure any items in the rewards section. The items don't need to exist in your database - you can use your own items/rewards:

```lua
Config.Rewards = {
    pumpkins = {
        {item = "candy", amount = {1,5}, chance = 70},
        {item = "rare_candy", amount = {1,2}, chance = 20},
        {item = "halloween_mask", amount = {1,1}, chance = 10}
    },
    trickortreat = {
        {item = "candy", amount = {1,3}, chance = 60},
        {item = "halloween_toy", amount = {1,1}, chance = 30},
        {item = "cursed_item", amount = {1,1}, chance = 10}
    }
}
```

### Custom Notifications

You can customize the notification system by editing `custom_notify.lua`:

```lua
function Notify(xPlayer, message)
    TriggerClientEvent("esx:showNotification", xPlayer.source, message)
    -- Edit this to use your own notification system
end
```

## Commands 🎮

- `/pumpkinleader` - Shows the top 10 pumpkin collectors leaderboard

## Example Items (Optional) 📝

If you want to use our example items, add these to your `items` table in your database:

```sql
INSERT INTO `items` (`name`, `label`, `weight`) VALUES
    ('candy', 'Halloween Candy', 1),
    ('rare_candy', 'Rare Candy', 1),
    ('halloween_mask', 'Spooky Mask', 1),
    ('halloween_toy', 'Halloween Toy', 1),
    ('cursed_item', 'Cursed Item', 1);
```

## Localization 🌍

The script supports multiple languages. You can add your own language in the `locales` folder:

```lua
Locales['en'] = {
    ['press_trick_or_treat'] = 'Press ~y~E~w~ to Trick or Treat!',
    ['trick_or_treat_success'] = 'Trick or Treat! You received %sx %s!',
    ['press_collect_pumpkin'] = 'Press ~y~E~w~ to collect the pumpkin',
    ['pumpkin_collected'] = 'You found a pumpkin and received %sx %s!'
}
```

## Support 💡

For support, please:
1. Join our [Discord](https://discord.gg/fourtwenty)
2. Visit our website: [www.fourtwenty.dev](https://fourtwenty.dev)
3. Create an issue on GitHub

## License 📄

This project is licensed under the MIT License - see the [LICENSE.md](LICENSE.md) file for details.

---
Made with ❤️ by [FourTwentyDev](https://fourtwenty.dev)

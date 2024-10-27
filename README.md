# FourTwenty Fishing System 🎣

A comprehensive fishing system for FiveM ESX servers featuring dynamic pricing, leveling system, multiple fishing zones, and various types of fish and equipment.

## Features 🐟

- **Dynamic Fishing System**: 
  - Multiple fishing zones across the map
  - Realistic fishing animations
  - Auto-fishing with configurable cooldowns
  - Level-based progression system
  - XP-based rewards
  
- **Advanced Market System**: 
  - Real-time dynamic pricing
  - Configurable price fluctuations
  - Visual price trends (up/down indicators)
  - Modern selling interface
  - Multiple fish species with different values
  
- **Equipment System**: 
  - 3 types of fishing rods (upgradeable)
  - Level-based equipment restrictions
  - Catch rate bonuses per rod
  - XP multipliers based on equipment
  
- **Progression System**: 
  - Experience-based leveling
  - Persistent catch statistics
  - Individual progress tracking
  - Statistics command

## Dependencies 📦

- ESX Framework
- MySQL Async
- FiveM Server Build 2802 or higher

## Installation 💿

1. Clone this repository into your server's `resources` directory
```bash
cd resources
git clone https://github.com/FourTwentyDev/fishing
```
2. Import the included SQL file:
```sql
CREATE TABLE IF NOT EXISTS fourtwenty_fishing (
    identifier VARCHAR(50) PRIMARY KEY,
    level INT DEFAULT 1,
    xp INT DEFAULT 0
);

CREATE TABLE IF NOT EXISTS fourtwenty_fishing_catches (
    identifier VARCHAR(50),
    fish_name VARCHAR(50),
    fish_count INT DEFAULT 0,
    PRIMARY KEY (identifier, fish_name)
);
```
3. Add `ensure fourtwenty_fishing` to your `server.cfg`
4. Configure using `config.lua`
5. Start/restart your server

## Configuration Guide 🔧

### Core Settings
```lua
Config = {
    Locale = 'en',           -- Available: 'en', 'de'
    Debug = false           -- Enable debug logs and features
}
```

### Fishing Mechanics
```lua
Config.FishingSettings = {
    autoFishing = true,     -- Toggle automatic fishing after catch
    autoCooldown = 5000,    -- Time between auto-fishing attempts (ms)
    cancelKey = 177,        -- Key to stop fishing (BACKSPACE)
    startKey = 38,          -- Key to start fishing (E)
}
```

### Market System
```lua
Config.DynamicPricing = {
    enabled = true,         -- Enable/disable dynamic market
    updateInterval = 10000, -- Price update frequency (ms)
    priceFluctuation = {
        min = 0.7,         -- Minimum price (70% of base)
        max = 1.3          -- Maximum price (130% of base)
    },
    maxPriceChangePercent = 15  -- Max price change per update
}
```

### Customizable Elements

1. **Fishing Zones**:
   - Add/remove zones in `Config.FishingZones`
   - Customize zone size, location, and blip settings
   - Each zone needs:
     ```lua
     {
         name = "Zone Name",
         coords = vector3(x, y, z),
         radius = 50.0,
         blipColor = 26,
         blipAlpha = 64
     }
     ```

2. **Fishing Rods**:
   - Modify existing or add new rods in `Config.FishingRods`
   - Customizable properties:
     ```lua
     {
         name = "Rod Name",
         item = "item_name",
         catchChance = 0.6,      -- 0.0 to 1.0
         xpMultiplier = 1.0,     -- XP gain multiplier
         requiredLevel = 1       -- Level needed to use
     }
     ```

3. **Fish Types**:
   - Add/modify fish in `Config.Fish`
   - Configurable attributes:
     ```lua
     {
         name = "Fish Name",
         item = "item_name",
         price = 100,           -- Base price
         xp = 10,              -- XP awarded
         rarity = 3            -- 1 (common) to 5 (rare)
     }
     ```

## Required Items

Add these items to your ESX items table:

```sql
INSERT INTO `items` (`name`, `label`, `weight`) VALUES
    ('fishing_rod_wood', 'Wooden Fishing Rod', 1),
    ('fishing_rod_carbon', 'Carbon Fishing Rod', 1),
    ('fishing_rod_pro', 'Professional Fishing Rod', 1),
    ('fish_mackerel', 'Mackerel', 1),
    ('fish_bass', 'Bass', 1),
    ('fish_salmon', 'Salmon', 1),
    ('fish_tuna', 'Tuna', 1),
    ('fish_swordfish', 'Swordfish', 1),
    ('fish_shark', 'Shark', 1),
    ('fish_anchovy', 'Anchovy', 1),
    ('fish_lobster', 'Lobster', 1);
```

## Commands 🎮

- `/fishingstats` - Shows your fishing level, XP, and catch statistics

## Localization 🌍

Add or modify languages in the `locales` folder. Example:
```lua
Locales['en'] = {
    ['press_sell_fish'] = 'Press ~INPUT_CONTEXT~ to sell fish',
    ['fish_caught'] = 'You caught a %s!',
    ['level_up'] = 'Fishing level increased to %s!',
    ['fish_sold'] = 'You sold your fish for $%s'
}
```

## Support 💡

For support:
1. Join our [Discord](https://discord.gg/fourtwenty)
2. Visit [fourtwenty.dev](https://fourtwenty.dev)
3. Create an issue on GitHub

## License 📄

This project is licensed under the MIT License - see the [LICENSE.md](LICENSE.md) file for details.

---
Made with ❤️ by [FourTwentyDev](https://fourtwenty.dev)


This README now includes:
- Detailed setup instructions
- Complete SQL setup
- All configurable elements
- Required items for ESX
- Clear examples of customization options
- Explanation of the dynamic pricing system
- Command list
- Localization guide

Would you like me to expand any section further?

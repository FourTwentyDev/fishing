# FiveM Fishing Script 🎣

A comprehensive fishing system for FiveM servers featuring experience-based progression, multiple fishing zones, diverse equipment, and a persistent catch tracking system.

## Features 🐟

- **Advanced Fishing System**: 
  - Multiple fishing zones across the map
  - Experience-based progression system
  - Realistic fishing animations
  - Multiple fishing rod types
  - Custom map blips and markers
  - Custom NPC at selling point

- **Progression System**: 
  - Level-based fishing mechanics
  - Experience points from each catch
  - Three tiers of fishing rods
  - Player statistics tracking
  - Persistent progress saved to database

- **Fish Collection**: 
  - 8 different fish species
  - Various rarities and values
  - Custom catch chances
  - Inventory integration
  - Catch history tracking

- **Market System**: 
  - Dedicated fish market location
  - Professional fisherman NPC
  - Different prices for each fish type
  - Automatic earnings calculation
  - Visual market blip

## Dependencies 📦

- ESX Framework
- MySQL-Async
- FiveM Server Build 2802 or higher

## Installation 💿

1. Clone this repository into your server's `resources` directory
```bash
cd resources
git clone https://github.com/FourTwentyDev/fishing
```
2. Import the database tables:
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
4. Configure the script using the `config.lua` file

## Configuration 🔧

### Main Configuration
```lua
Config = {
    Locale = 'de',  -- Available: "en", "de"
}
```

### Fishing Zones Configuration
```lua
Config.FishingZones = {
    {
        name = "Strand Zone",
        coords = vector3(-1850.0, -1250.0, 8.0),
        radius = 50.0,
        blipColor = 26,
        blipAlpha = 64
    }
    -- Add more zones as needed
}
```

### Fishing Rod Configuration
```lua
Config.FishingRods = {
    {
        name = "Holzangel",
        item = "fishing_rod_wood",
        catchChance = 0.6,
        xpMultiplier = 1.0,
        requiredLevel = 1
    },
    {
        name = "Carbonangel",
        item = "fishing_rod_carbon",
        catchChance = 0.75,
        xpMultiplier = 1.5,
        requiredLevel = 5
    },
    {
        name = "Profiangel",
        item = "fishing_rod_pro",
        catchChance = 0.9,
        xpMultiplier = 2.0,
        requiredLevel = 10
    }
}
```

### Fish Configuration
```lua
Config.Fish = {
    {
        name = "Makrele",
        item = "fish_mackerel",
        price = 25,
        xp = 5,
        rarity = 1
    }
    -- Add more fish types as needed
}
```

## Example Items (Optional) 📝

Add these to your `items` table in your database:

```sql
INSERT INTO `items` (`name`, `label`, `weight`, `rare`, `can_remove`) VALUES 
    ('fishing_rod_wood', 'Wooden Fishing Rod', 1, 0, 1),
    ('fishing_rod_carbon', 'Carbon Fishing Rod', 1, 0, 1),
    ('fishing_rod_pro', 'Professional Fishing Rod', 1, 0, 1),
    ('fish_mackerel', 'Mackerel', 1, 0, 1),
    ('fish_bass', 'Bass', 1, 0, 1),
    ('fish_salmon', 'Salmon', 1, 0, 1),
    ('fish_tuna', 'Tuna', 1, 0, 1),
    ('fish_swordfish', 'Swordfish', 2, 0, 1),
    ('fish_shark', 'Shark', 3, 0, 1),
    ('fish_anchovy', 'Anchovy', 1, 0, 1),
    ('fish_lobster', 'Lobster', 1, 0, 1);
```

## Commands 🎮

- `/fishingstats` - Shows your fishing level, XP, and catch history

## Localization 🌍

The script supports multiple languages. You can add your own language in the `locales` folder:

```lua
Locales['en'] = {
    ['press_start_fishing'] = 'Press ~y~E~w~ to start fishing',
    ['fish_caught'] = 'You caught a %s!',
    ['press_sell_fish'] = 'Press ~y~E~w~ to sell your fish',
    ['fish_sold'] = 'You sold your fish for $%s',
    ['level_up'] = 'Fishing level increased to %s!'
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
Made with 🎣 by [FourTwentyDev](https://fourtwenty.dev)

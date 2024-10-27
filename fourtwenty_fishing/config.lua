-- Configuration file for FourTwenty Fishing System
-- https://fourtwenty.dev | https://github.com/FourTwentyDev

Config = {}
-- Set the language for the system (en = English)
Config.Locale = 'en'

Config.FishingSettings = {
    -- If true, player will automatically continue fishing after catching something
    autoFishing = true,
    -- Time in milliseconds (5000 = 5 seconds) between automatic fishing attempts
    autoCooldown = 5000,
    -- Key code for canceling fishing activity (177 = BACKSPACE)
    cancelKey = 177,
    -- Key code for starting to fish (38 = E)
    startKey = 38,
    -- Animation settings for when player is waiting between casts
    waitingAnimDict = "amb@world_human_stand_fishing@idle_a",
    waitingAnim = "idle_c",
}

Config.DynamicPricing = {
    -- Turn on/off the dynamic market price system
    enabled = true,
    -- How often prices update (in milliseconds, 10000 = 10 seconds)
    updateInterval = 10000,
    -- Price limits as percentage of base price
    priceFluctuation = {
        min = 0.7,  -- Prices won't go lower than 70% of base price
        max = 1.3   -- Prices won't go higher than 130% of base price
    },
    -- Maximum price change per update (15 = prices can change up to 15% each update)
    maxPriceChangePercent = 15
}

Config.FishingZones = {
    {
        -- Name shown on the map
        name = "Beach Zone",
        -- Location coordinates (x, y, z)
        coords = vector3(-1850.0, -1250.0, 8.0),
        -- How far from the point players can fish
        radius = 50.0,
        -- Color of the zone on the map (26 = blue)
        blipColor = 26,
        -- Transparency of zone on map (64 = semi-transparent)
        blipAlpha = 64,
    },
    {
        name = "Harbor Zone",
        coords = vector3(1340.0, 4225.0, 33.0),
        radius = 70.0,
        blipColor = 26,
        blipAlpha = 64,
    },
    {
        name = "Alamo Sea",
        coords = vector3(1301.0, 4233.0, 33.0),
        radius = 100.0,
        blipColor = 26,
        blipAlpha = 64,
    },
    -- Add more fishing zones here
}

Config.Blips = {
    -- Settings for the fish market icon on the map
    FishMarket = {
        sprite = 356,  -- Icon type
        color = 59,    -- Icon color
        scale = 0.8,   -- Size of icon
        display = 4,   -- How icon shows on map
    },
    -- Settings for fishing spot icons on the map
    FishingSpot = {
        sprite = 68,
        color = 26,
        scale = 0.8,
        display = 4,
    }
}

-- Location and settings for the fish seller NPC
Config.SellPoint = {
    -- Where players can sell their fish
    coords = vector3(902.6486, -2274.9658, 32.5476),
    -- Which direction NPC faces
    heading = 319.0,
    -- What the NPC looks like
    npcModel = "s_m_m_migrant_01"
}

-- Different types of fishing rods available
Config.FishingRods = {
    {
        name = "Wooden Rod",
        -- Item name in inventory
        item = "fishing_rod_wood",
        -- 60% chance to catch something
        catchChance = 0.6,
        -- Normal XP gain
        xpMultiplier = 1.0,
        -- Available from level 1
        requiredLevel = 1
    },
    {
        name = "Carbon Rod",
        item = "fishing_rod_carbon",
        -- 75% catch chance
        catchChance = 0.75,
        -- 50% more XP
        xpMultiplier = 1.5,
        -- Need level 5 to use
        requiredLevel = 5
    },
    {
        name = "Pro Rod",
        item = "fishing_rod_pro",
        -- 90% catch chance
        catchChance = 0.9,
        -- Double XP gain
        xpMultiplier = 2.0,
        -- Available from level 1 (for testing)
        requiredLevel = 10
    }
}

-- All fish types that can be caught
Config.Fish = {
    {
        name = "Mackerel",
        -- Item name in inventory
        item = "fish_mackerel",
        -- Base selling price
        price = 25,
        -- XP gained when caught
        xp = 5,
        -- How rare (1 = common, 5 = very rare)
        rarity = 1
    },
    {
        name = "Bass",
        item = "fish_bass",
        price = 40,
        xp = 8,
        rarity = 2
    },
    {
        name = "Salmon",
        item = "fish_salmon",
        price = 60,
        xp = 12,
        rarity = 2
    },
    {
        name = "Tuna",
        item = "fish_tuna",
        price = 100,
        xp = 15,
        rarity = 3
    },
    {
        name = "Swordfish",
        item = "fish_swordfish",
        price = 150,
        xp = 25,
        rarity = 4
    },
    {
        name = "Shark",
        item = "fish_shark",
        price = 300,
        xp = 50,
        rarity = 5
    },
    {
        name = "Anchovy",
        item = "fish_anchovy",
        price = 15,
        xp = 3,
        rarity = 1
    },
    {
        name = "Lobster",
        item = "fish_lobster",
        price = 120,
        xp = 20,
        rarity = 4
    }
}
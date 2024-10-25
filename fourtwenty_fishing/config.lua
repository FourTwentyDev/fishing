-- config.lua
Config = {}
Config.Locale = 'de'

Config.FishingZones = {
    {
        name = "Strand Zone",
        coords = vector3(-1850.0, -1250.0, 8.0),
        radius = 50.0,
        blipColor = 26, -- Blau
        blipAlpha = 64,
    },
    {
        name = "Hafen Zone",
        coords = vector3(1340.0, 4225.0, 33.0),
        radius = 70.0,
        blipColor = 26,
        blipAlpha = 64,
    },
    {
        name = "Alamo See",
        coords = vector3(1301.0, 4233.0, 33.0),
        radius = 100.0,
        blipColor = 26,
        blipAlpha = 64,
    },
    -- Füge weitere Zonen hinzu
}

Config.Blips = {
    FishMarket = {
        sprite = 356,
        color = 59,
        scale = 0.8,
        display = 4,
    },
    FishingSpot = {
        sprite = 68,
        color = 26,
        scale = 0.8,
        display = 4,
    }
}

Config.SellPoint = {
    coords = vector3(-1816.0, -1193.0, 13.0),
    npcModel = "s_m_m_fishingspc_01"
}

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

Config.Fish = {
    {
        name = "Makrele",
        item = "fish_mackerel",
        price = 25,
        xp = 5,
        rarity = 1
    },
    {
        name = "Barsch",
        item = "fish_bass",
        price = 40,
        xp = 8,
        rarity = 2
    },
    {
        name = "Lachs",
        item = "fish_salmon",
        price = 60,
        xp = 12,
        rarity = 2
    },
    {
        name = "Thunfisch",
        item = "fish_tuna",
        price = 100,
        xp = 15,
        rarity = 3
    },
    {
        name = "Schwertfisch",
        item = "fish_swordfish",
        price = 150,
        xp = 25,
        rarity = 4
    },
    {
        name = "Hai",
        item = "fish_shark",
        price = 300,
        xp = 50,
        rarity = 5
    },
    {
        name = "Sardelle",
        item = "fish_anchovy",
        price = 15,
        xp = 3,
        rarity = 1
    },
    {
        name = "Hummer",
        item = "fish_lobster",
        price = 120,
        xp = 20,
        rarity = 4
    }
}
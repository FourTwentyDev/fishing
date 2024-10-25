Locales = {
    ['en'] = {
        ['press_start_fishing'] = 'Press ~INPUT_CONTEXT~ to start fishing',
        ['press_sell_fish'] = 'Press ~INPUT_CONTEXT~ to sell fish',
        ['need_rod'] = 'You need a fishing rod!',
        ['level_too_low'] = 'You need to be level %s to use this rod!',
        ['fish_got_away'] = 'The fish got away!',
        ['fish_caught'] = 'You caught a %s!',
        ['fish_sold'] = 'You sold your fish for $%s',
        ['level_up'] = 'Fishing level up! You are now level %s',
        ['blip_fish_market'] = 'Fish Market',
        ['blip_fishing_spot'] = 'Fishing Spot',
    },
    ['de'] = {
        ['press_start_fishing'] = 'Drücke ~INPUT_CONTEXT~ zum Angeln',
        ['press_sell_fish'] = 'Drücke ~INPUT_CONTEXT~ zum Verkaufen',
        ['need_rod'] = 'Du brauchst eine Angelrute!',
        ['level_too_low'] = 'Du brauchst Level %s für diese Angelrute!',
        ['fish_got_away'] = 'Der Fisch ist entkommen!',
        ['fish_caught'] = 'Du hast einen %s gefangen!',
        ['fish_sold'] = 'Du hast deine Fische für $%s verkauft',
        ['level_up'] = 'Angel-Level aufgestiegen! Du bist jetzt Level %s',
        ['blip_fish_market'] = 'Fischmarktt',
        ['blip_fishing_spot'] = 'Angelplatz',
    }
}

function translate(str, ...)
    local lang = Config.Locale or 'de'
    if Locales[lang] and Locales[lang][str] then
        return string.format(Locales[lang][str], ...)
    end
    return 'Translation missing: ' .. str
end
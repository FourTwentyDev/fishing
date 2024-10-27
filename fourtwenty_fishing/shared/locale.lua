Locales = {
    ['en'] = {
        -- Existing translations
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
        ['press_start_auto_fishing'] = 'Press ~INPUT_CONTEXT~ to start fishing. ~INPUT_CELLPHONE_CANCEL~ to cancel.',
        ['fishing_stopped'] = 'Quit fishing.',
        ['press_to_cancel'] = 'Press ~INPUT_CELLPHONE_CANCEL~ to quit fishing',
        
        -- UI translations
        ['ui_fish_market'] = 'Fish Market',
        ['ui_next_price_change'] = 'Next price change in',
        ['ui_total_value'] = 'Total Value',
        ['ui_sell_all'] = 'Sell All Fish',
        ['ui_price'] = 'Price',
        ['ui_quantity'] = 'Quantity',
        ['ui_base_price'] = 'Base Price',
        ['ui_current_price'] = 'Current Price',
        ['ui_trend_up'] = 'Price trending up',
        ['ui_trend_down'] = 'Price trending down',
        ['ui_trend_stable'] = 'Price stable',
        ['ui_close'] = 'Close'
    },
    ['de'] = {
        -- Existing translations
        ['press_start_fishing'] = 'Drücke ~INPUT_CONTEXT~ zum Angeln',
        ['press_sell_fish'] = 'Drücke ~INPUT_CONTEXT~ zum Verkaufen',
        ['need_rod'] = 'Du brauchst eine Angelrute!',
        ['level_too_low'] = 'Du brauchst Level %s für diese Angelrute!',
        ['fish_got_away'] = 'Der Fisch ist entkommen!',
        ['fish_caught'] = 'Du hast einen %s gefangen!',
        ['fish_sold'] = 'Du hast deine Fische für $%s verkauft',
        ['level_up'] = 'Angel-Level aufgestiegen! Du bist jetzt Level %s',
        ['blip_fish_market'] = 'Fischmarkt',
        ['blip_fishing_spot'] = 'Angelplatz',
        ['press_start_auto_fishing'] = 'Drücke ~INPUT_CONTEXT~ um automatisch zu angeln. ~INPUT_CELLPHONE_CANCEL~ zum Abbrechen.',
        ['fishing_stopped'] = 'Angeln beendet.',
        ['press_to_cancel'] = 'Drücke ~INPUT_CELLPHONE_CANCEL~ um das Angeln zu beenden',
        
        -- UI translations
        ['ui_fish_market'] = 'Fischmarkt',
        ['ui_next_price_change'] = 'Nächste Preisänderung in',
        ['ui_total_value'] = 'Gesamtwert',
        ['ui_sell_all'] = 'Alle Fische verkaufen',
        ['ui_price'] = 'Preis',
        ['ui_quantity'] = 'Menge',
        ['ui_base_price'] = 'Grundpreis',
        ['ui_current_price'] = 'Aktueller Preis',
        ['ui_trend_up'] = 'Preis steigt',
        ['ui_trend_down'] = 'Preis fällt',
        ['ui_trend_stable'] = 'Preis stabil',
        ['ui_close'] = 'Schließen'
    }
}

function translate(str, ...)
    local lang = Config.Locale or 'de'
    if Locales[lang] and Locales[lang][str] then
        return string.format(Locales[lang][str], ...)
    end
    return 'Translation missing: ' .. str
end
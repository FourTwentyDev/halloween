Locales = {}

Locales['de'] = {
    -- Door/Trick or Treat interactions
    ['press_trick_or_treat'] = 'Drücke ~y~E~w~ für Süßes oder Saures!',
    ['trick_or_treat_success'] = 'Süßes oder Saures! Du hast %sx %s erhalten!',
    
    -- Pumpkin interactions
    ['press_collect_pumpkin'] = 'Drücke ~y~E~w~ um den Kürbis zu sammeln',
    ['pumpkin_collected'] = 'Du hast einen Kürbis gefunden und %sx %s erhalten!',
    
    -- Reward types
    ['reward_candy'] = 'Du hast Süßigkeiten bekommen! 🍬',
    ['reward_trick'] = 'Oh nein, ein Streich wurde dir gespielt! 👻',
    ['reward_special'] = 'Wow, ein besonderes Halloween-Geschenk! 🎃'
}

Locales['en'] = {
    -- Door/Trick or Treat interactions
    ['press_trick_or_treat'] = 'Press ~y~E~w~ to Trick or Treat!',
    ['trick_or_treat_success'] = 'Trick or Treat! You received %sx %s!',
    
    -- Pumpkin interactions
    ['press_collect_pumpkin'] = 'Press ~y~E~w~ to collect the pumpkin',
    ['pumpkin_collected'] = 'You found a pumpkin and received %sx %s!',
    
    -- Reward types
    ['reward_candy'] = 'You got candy! 🍬',
    ['reward_trick'] = 'Oh no, you got tricked! 👻',
    ['reward_special'] = 'Wow, a special Halloween gift! 🎃'
}

-- Function to translate text
function _(str, ...)
    local lang = Config.Locale or 'de'
    if Locales[lang] and Locales[lang][str] then
        return string.format(Locales[lang][str], ...)
    end
    return 'Translation missing: ' .. str
end
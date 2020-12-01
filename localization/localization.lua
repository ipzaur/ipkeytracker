local AddonName, Addon = ...

Addon.localization = {}

Addon.localization.ADDELEMENT = "Add element"

Addon.localization.BACKGROUND = "Background"
Addon.localization.BORDER     = "Border"
Addon.localization.BORDERLIST = "Select a border from the library"
Addon.localization.BRDERWIDTH = "Border width"

Addon.localization.CLEANDBBT  = "Clean database"
Addon.localization.CLEANDBTT  = "Clear the addon internal base with the percent of monsters.\n" ..
                                "Helps if the percent counter is buggy"
Addon.localization.CLOSE      = "Close"
Addon.localization.COLOR      = "Color"
Addon.localization.COLORDESCR = {
    TIMER = {
        [-1] = 'Timer color if the key deplited',
        [0]  = 'Timer color if time is within range for +1',
        [1]  = 'Timer color if time is within range for +2',
        [2]  = 'Timer color if time is within range for +3',
    },
    OBELISKS = {
        [-1] = 'Living Obelisk Color',
        [0]  = 'Closed obelisk color',
    },
}
Addon.localization.COPY       = "Copy"
Addon.localization.CORRUPTED = {
    [161124] = "Urg'roth, Breaker of Heroes (Tank breaker)",
    [161241] = "Voidweaver Mal'thir (Spider)",
    [161243] = "Samh'rek, Beckoner of Chaos (Fear)",
    [161244] = "Blood of the Corruptor (Blob)",
}

Addon.localization.DAMAGE     = "Damage"
Addon.localization.DECORELEMS = "Decorative elements"
Addon.localization.DEFAULT    = "Default"
Addon.localization.DEATHCOUNT = "Deaths"
Addon.localization.DEATHSHOW  = "Click for detail information"
Addon.localization.DEATHTIME  = "Time lost"
Addon.localization.DELETDECOR = "Delete decorative element"
Addon.localization.DIRECTION  = "Progress changing"
Addon.localization.DIRECTIONS = {
    asc  = "Ascending (0% -> 100%)",
    desc = "Descending (100% -> 0%)",
}
Addon.localization.DTHCAPTION = "Deaths history"

Addon.localization.ELEMENT    = {
    AFFIXES   = "Active affixes",
    BOSSES    = "Bosses",
    DEATHS    = "Deaths",
    DUNGENAME = "Dungeon name",
    LEVEL     = "Key level",
    OBELISKS  = "Obelisks",
    PLUSLEVEL = "Key upgrade",
    PLUSTIMER = "Time until the key upgrade is lowered",
    PROGRESS  = "Enemy killed",
    PROGNOSIS = "Percents after pull",
    TIMER     = "Key timer",
}
Addon.localization.ELEMACTION =  {
    SHOW = "Show element",
    HIDE = "Hide element",
    MOVE = "Move element",
}
Addon.localization.ELEMPOS    = "Element position"

Addon.localization.FONT       = "Font"
Addon.localization.FONTSIZE   = "Font size"

Addon.localization.HEIGHT     = "Height"
Addon.localization.HELP       = {
    AFFIXES    = "Active affixes",
    BOSSES     = "Bosses killed",
    DEATHTIMER = "Time wasted due to deaths",
    LEVEL      = "Active key Level",
    PLUSLEVEL  = "How key will upgrade with current time",
    PLUSTIMER  = "Time until the key upgrade is lowered",
    PROGNOSIS  = "Progress after kill pulled mobs",
    PROGRESS   = "Trash killed",
    TIMER      = "Time left",
}

Addon.localization.ICONSIZE   = "Icon size"

Addon.localization.JUSTIFYH   = "Horizontal text justify"

Addon.localization.LAYER      = "Layer"

Addon.localization.MAPBUT     = "LMB (click) - toggle options\n" ..
                                "LMB (drag) - move button"
Addon.localization.MAPBUTOPT  = "Show/Hide minimap button"
Addon.localization.MELEEATACK = "Melee attack"

Addon.localization.OPTIONS    = "Options"

Addon.localization.POINT      = "Point"
Addon.localization.PRECISEPOS = "Right click for precise positioning"
Addon.localization.PROGFORMAT = {
    percent = "Percent (100.00%)",
    forces  = "Forces (300)",
}
Addon.localization.PROGRESS   = "Progress format"

Addon.localization.RELPOINT   = "Relative point"

Addon.localization.SCALE      = "Scale"
Addon.localization.SEASONOPTS = "Season options"
Addon.localization.SOURCE     = "Source"
Addon.localization.STARTINFO  = "iP Mythic Timer loaded. Type /ipmt for options."

Addon.localization.TEXTURE    = "Texture"
Addon.localization.TEXTURELST = "Select a texture from the library"
Addon.localization.TXTRINDENT = "Texture indent"
Addon.localization.THEME      = "Theme"
Addon.localization.THEMEBUTNS = {
    DUPLICATE   = "Duplicate current theme",
    DELETE      = "Delete current theme",
    RESTORE     = 'Restore theme "' .. Addon.localization.DEFAULT .. '" and select it',
    OPENEDITOR  = "Open theme editor",
    CLOSEEDITOR = "Close theme editor",
}
Addon.localization.THEMEDITOR = "Edit theme"
Addon.localization.THEMENAME  = "Theme name"
Addon.localization.TIME       = "Time"
Addon.localization.TIMERCHCKP = "Timer checkpoints"

Addon.localization.UNKNOWN    = "Unknown"

Addon.localization.WAVEALERT  = "Alert every 20%"
Addon.localization.WIDTH      = "Width"
Addon.localization.WHODIED    = "Who died"

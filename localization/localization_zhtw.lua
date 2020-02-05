if GetLocale() ~= "zhTW" then return end

local AddonName, Addon = ...

Addon.localization.CLEANDBBT  = "清理数据库"
Addon.localization.CLEANDBTT  = "清除怪物内部百分比的插件内部基础.\n" ..
                                "帮助百分比计数器是否有错误"
Addon.localization.CLOSE      = "關閉"
Addon.localization.CUSTOMIZE  = "自定义框架"
Addon.localization.CCAPTION   = "主框架:\n" ..
                                "    LMB (拖动) - 移动\n" ..
                                "    RMB (拖动) - 调整\n" ..
                                "元素:\n" ..
                                "    LMB (拖动) - 移动\n" ..
                                "    RMB (请点击) - 字体大小\n" ..
                                "    MMB (请点击) - 切换可见性"
Addon.localization.DAMAGE     = "损伤"
Addon.localization.DEATHCOUNT = "死亡人数"
Addon.localization.DEATHSHOW  = "点击查看详细信息"
Addon.localization.DEATHTIME  = "浪费时间"
Addon.localization.DIRECTION  = "进度变化"
Addon.localization.DIRECTIONS = {
    [1] = "上升 (0% -> 100%)",
    [2] = "降序 (100% -> 0%)",
}
Addon.localization.DTHCAPTION = "死亡史"
Addon.localization.FONT       = "字形"
Addon.localization.FONTSIZE   = "字体大小"
Addon.localization.MAPBUT     = "LMB（单击）- 切换选项\n" ..
                                "LMB（拖动）- 移动按钮"
Addon.localization.MAPBUTOPT  = "显示/隐藏小地图按钮"
Addon.localization.MELEEATACK = "近战攻击"
Addon.localization.OPTIONS    = "選項"
Addon.localization.OPACITY    = "背景透明度"
Addon.localization.PROGFORMAT = {
    [1] = "百分 (100.00%)",
    [2] = "力 (300)",
}
Addon.localization.PROGRESS   = "进度格式"
Addon.localization.RESTORE    = "恢復"
Addon.localization.SCALE      = "縮放"
Addon.localization.SOURCE     = "资源"
Addon.localization.STARTINFO  = "iP Mythic Timer已載入。輸入 /ipmt 開啟選項。"
Addon.localization.TIME       = "时间"
Addon.localization.UNKNOWN    = "未知"
Addon.localization.WHODIED    = "谁死了"

Addon.localization.HELP = {
    LEVEL      = "活动密钥级别",
    PLUSLEVEL  = "密钥将如何随着当前时间升级",
    TIMER      = "剩下的时间",
    PLUSTIMER  = "是时候降级关键进度了",
    DEATHTIMER = "由于死亡而浪费时间",
    PROGRESS   = "垃圾被杀死",
    PROGNOSIS  = "杀死小怪后的进展",
    BOSSES     = "老板被杀",
    AFFIXES    = "主动词缀",
}
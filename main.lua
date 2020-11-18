local AddonName, Addon = ...

function Addon:ResetDungeon()
    IPMTDungeon = Addon:CopyObject(Addon.cleanDungeon)
end

function Addon:GetEnemyForces(npcID, progressFormat)
    local forces = nil

    if Addon.season.isActive and Addon.season.GetForces then
        forces = Addon.season:GetForces(npcID, IPMTDungeon.isTeeming)
    end

    if forces == nil then
        if IPMTDB and IPMTDB[npcID] and type(IPMTDB[npcID]) == 'table' and IPMTDB[npcID][IPMTDungeon.isTeeming] then
            forces = IPMTDB[npcID][IPMTDungeon.isTeeming]
        else
            forces = Addon:GetForcesFromMDT(npcID, true)
        end
    end

    if progressFormat == nil then
        progressFormat = IPMTOptions.progress
    end

    if forces and progressFormat == Addon.PROGRESS_FORMAT_PERCENT then
        forces = 100 / IPMTDungeon.trash.total * forces
        forces = Addon:Round(forces, 2)
    end
    return forces
end

local killInfo = {
    npcID        = 0,
    progress     = 0,
    progressTime = nil,
    diedTime     = nil,
}
local function ClearKillInfo()
    killInfo = {
        npcID        = 0,
        progress     = 0,
        progressTime = nil,
        diedTime     = nil,
    }
end

local function GrabMobInfo(npcID)
    killInfo.npcID = npcID
    killInfo.diedTime = GetTime()
    if killInfo.npcID and killInfo.diedTime and killInfo.progress and killInfo.progressTime then
        if abs(killInfo.progressTime - killInfo.diedTime) < 0.1 then
            if not IPMTDB then
                IPMTDB = {}
            end
            if IPMTDB[killInfo.npcID] == nil then
                IPMTDB[killInfo.npcID] = {}
            end
            if IPMTDB[killInfo.npcID][IPMTDungeon.isTeeming] == nil then
                IPMTDB[killInfo.npcID][IPMTDungeon.isTeeming] = killInfo.progress
            end
            ClearKillInfo()
        end
    end
end

function Addon:EnemyDied(npcGUID)
    local _, zero, server_id, instance_id, zone_uid, npcID, spawnID = strsplit("-", npcGUID)
    npcID = tonumber(npcID)
    local npcUID = spawnID .. "_" .. npcID
    if IPMTDungeon.prognosis[npcUID] then
        IPMTDungeon.prognosis[npcUID] = nil
    end
    if Addon:GetEnemyForces(npcID) == nil then
        GrabMobInfo(npcID)
    else
        ClearKillInfo()
    end

    if Addon.season.isActive and Addon.season.EnemyDied then
        Addon.season:EnemyDied(npcID)
    end
end

function Addon:CombatLogEvent()
    local timestamp, event, hideCaster, sourceGUID, sourceName, sourceFlags, sourceRaidFlags, destGUID, destName, destFlags, destRaidFlags, x12, x13, x14, x15 = CombatLogGetCurrentEventInfo()

    if event == "UNIT_DIED" then
        if bit.band(destFlags, COMBATLOG_OBJECT_TYPE_NPC) > 0
            and bit.band(destFlags, COMBATLOG_OBJECT_CONTROL_NPC) > 0
            and (bit.band(destFlags, COMBATLOG_OBJECT_REACTION_HOSTILE) > 0
            or bit.band(destFlags, COMBATLOG_OBJECT_REACTION_NEUTRAL) > 0) then
            Addon:EnemyDied(destGUID)
        end
        if (bit.band(destFlags, COMBATLOG_OBJECT_TYPE_PLAYER) > 0) and (not UnitIsFeignDeath(destName)) then
            Addon.deaths:Record(destName)
        end
    elseif bit.band(destFlags, COMBATLOG_OBJECT_TYPE_PLAYER) > 0 then
        if event == "SPELL_DAMAGE" or event == "SPELL_PERIODIC_DAMAGE" then
            IPMTDungeon.players[destName] = {
                spellId = x12,
                enemy   = sourceName,
                damage  = x15,
            }
        elseif event == "SWING_DAMAGE" then
            IPMTDungeon.players[destName] = {
                spellId = 1,
                enemy   = sourceName,
                damage  = x12,
            }
        elseif event == "RANGE_DAMAGE" then
            IPMTDungeon.players[destName] = {
                spellId = 75,
                enemy   = sourceName,
                damage  = x12,
            }
        end
    end
end

function Addon:UpdateProgress()
    local numCriteria = select(3, C_Scenario.GetStepInfo())

    for c = 1, numCriteria do
        local name, _, completed, quantity, totalQuantity, _, _, quantityString, _, _, _, _, isWeightedProgress = C_Scenario.GetCriteriaInfo(c)
        if isWeightedProgress then
            if IPMTDungeon.trash.total == nil or IPMTDungeon.trash.total == 0 then
                IPMTDungeon.trash.total = totalQuantity
            end
            local currentTrash = tonumber(strsub(quantityString, 1, -2))
            if IPMTDungeon.trash.current and currentTrash < IPMTDungeon.trash.total and currentTrash > IPMTDungeon.trash.current then
                killInfo.progress = currentTrash - IPMTDungeon.trash.current
                killInfo.progressTime = GetTime()
                GrabMobInfo()
            end
            IPMTDungeon.trash.current = currentTrash
            if Addon.season.isActive and Addon.season.Progress then
                Addon.season:Progress(IPMTDungeon.trash.current)
            end
            if IPMTOptions.progress == Addon.PROGRESS_FORMAT_PERCENT then
                local progress = IPMTDungeon.trash.current / IPMTDungeon.trash.total * 100
                progress = math.min(100, progress)
                if IPMTOptions.direction == Addon.PROGRESS_DIRECTION_DESC then
                    progress = 100 - progress
                end
                Addon.fMain.progress.text:SetFormattedText("%.2f%%", progress)
            else
                local progress = math.min(IPMTDungeon.trash.current, IPMTDungeon.trash.total)
                if IPMTOptions.direction == Addon.PROGRESS_DIRECTION_ASC then
                    Addon.fMain.progress.text:SetText(progress .. "/" .. IPMTDungeon.trash.total)
                else
                    Addon.fMain.progress.text:SetText(IPMTDungeon.trash.total - progress)
                end
            end
        end
    end
end

function Addon:OnTimerEnter(self)
    if not Addon.fOptions:IsShown() then
        GameTooltip:SetOwner(self, "ANCHOR_LEFT")
        GameTooltip:SetText(Addon.localization.TIMERCHCKP, 1, 1, 1)
        GameTooltip:AddLine(" ")
        for level = 2,0,-1 do
            local r, g, b = 0, 0, 0
            local keyText = '+' .. level + 1
            if level > 0 then
                g = 1
                if level < 2 then
                    r = 1
                end
            else
                r, g, b = 1, 1, 1
            end
            local timeText
            if level == 2 then
                timeText = SecondsToClock(IPMTDungeon.timeLimit[0]) .. ' - ' .. SecondsToClock(IPMTDungeon.timeLimit[0] - IPMTDungeon.timeLimit[2])
            elseif level == 1 then
                timeText = SecondsToClock(IPMTDungeon.timeLimit[0] - IPMTDungeon.timeLimit[2]) .. ' - ' .. SecondsToClock(IPMTDungeon.timeLimit[0] - IPMTDungeon.timeLimit[1])
            else
                timeText = SecondsToClock(IPMTDungeon.timeLimit[0] - IPMTDungeon.timeLimit[1]) .. ' - 0:00'
            end
            GameTooltip:AddDoubleLine(keyText, timeText, r, g, b, r, g, b)
        end
        GameTooltip:Show()
    end
end

function Addon:OnBossesEnter(self)
    if not Addon.fOptions:IsShown() then
        GameTooltip:SetOwner(self, "ANCHOR_BOTTOMRIGHT")
        GameTooltip:SetText(Addon.localization.HELP.BOSSES, 1, 1, 1)
        GameTooltip:AddLine(" ")
        for i, boss in ipairs(IPMTDungeon.bosses) do
            local color = 1
            if boss.killed then
                color = .45
            end
            GameTooltip:AddLine(boss.name, color, color, color)
        end
        GameTooltip:Show()
    end
end

function Addon:OnAffixEnter(self, iconNum)
    if not Addon.fOptions:IsShown() then
        GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
        local affixNum = #IPMTDungeon.affixes - iconNum + 1
        GameTooltip:SetText(IPMTDungeon.affixes[affixNum].name, 1, 1, 1, 1, true)
        GameTooltip:AddLine(IPMTDungeon.affixes[affixNum].text, nil, nil, nil, true)
        GameTooltip:Show()
    end
end

local updateTimer = 0 
function Addon:OnUpdate(elapsed)
    if IPMTDungeon and IPMTDungeon.keyActive then
        updateTimer = updateTimer + elapsed * 1000
        if updateTimer >= 300 then
            updateTimer = 0
            Addon:ShowPrognosis()
        end
    end
end

local function UpdateTime(block, elapsedTime)
    if not IPMTDungeon.keyActive then
        return
    end
    local timeCoef = {0.8, 0.6}
    local plusLevel = 0
    local plusTimer = 0
    local r, g, b = 0, 0, 0

    if IPMTDungeon.timeLimit == nil or IPMTDungeon.timeLimit[0] == nil then
        IPMTDungeon.timeLimit = {
            [0] = block.timeLimit,
        }
        for level = 2,1,-1 do
            IPMTDungeon.timeLimit[level] = timeCoef[level] * block.timeLimit
        end
    end
    if elapsedTime < block.timeLimit then
        for level = 2,1,-1 do
            if elapsedTime < IPMTDungeon.timeLimit[level] then
                plusLevel = level
                plusTimer = IPMTDungeon.timeLimit[level] - elapsedTime
                break
            end
        end
        Addon.fMain.timer.text:SetText(SecondsToClock(block.timeLimit - elapsedTime))
        Addon.fMain.timer.text:SetTextColor(0, 1, 0)
        if plusTimer > 0 then
            Addon.fMain.plusTimer.text:SetText(SecondsToClock(plusTimer))
            Addon.fMain.plusTimer:Show()
            g = 1
            if plusLevel < 2 then
                r = 1
            end
        else
            Addon.fMain.plusTimer:Hide()
            r, g, b = 1, 1, 1
        end
        plusLevel = "+" .. plusLevel+1
    else
        plusLevel = "-1"
        Addon.fMain.timer.text:SetText(SecondsToClock(elapsedTime - block.timeLimit))
        Addon.fMain.plusTimer.text:SetText(SecondsToClock(elapsedTime))
        Addon.fMain.plusTimer:Show()
        r = 1
    end
    IPMTDungeon.time = elapsedTime
    Addon.fMain.timer.text:SetTextColor(r, g, b)
    Addon.fMain.plusLevel.text:SetText(plusLevel)
end
hooksecurefunc("Scenario_ChallengeMode_UpdateTime", UpdateTime)

local function InitBossesInfo()
    IPMTDungeon.bossesKilled = 0
    if IPMTDungeon.bosses == nil then
        local mapID = C_Map.GetBestMapForUnit("player")
        local uiMapGroupID = C_Map.GetMapGroupID(mapID)
        local mapGroup = {}
        if uiMapGroupID == nil or mapID == 1490 then
            table.insert(mapGroup, {
                mapID = mapID,
            })
        else
            mapGroup = C_Map.GetMapGroupMembersInfo(uiMapGroupID)
        end
        IPMTDungeon.bosses = {}
        for g, map in ipairs(mapGroup) do
            if (mapID ~= 1490 and map.mapID ~= 1490) or (mapID == 1490 and map.mapID == 1490) then
                local encounters = C_EncounterJournal.GetEncountersOnMap(map.mapID)
                for e, encounter in ipairs(encounters) do
                    local name = EJ_GetEncounterInfo(encounter.encounterID)
                    table.insert(IPMTDungeon.bosses, {
                        name   = name,
                        killed = false,
                    })
                end
            end
        end
    else
        for b, boss in ipairs(IPMTDungeon.bosses) do
            if boss.killed then
                IPMTDungeon.bossesKilled = IPMTDungeon.bossesKilled + 1
            end
        end
    end
    Addon.fMain.bosses.text:SetText(IPMTDungeon.bossesKilled .. "/" .. #IPMTDungeon.bosses)
end

local function initAffixes()
    Addon.season.isActive = false
    local level, affixes = C_ChallengeMode.GetActiveKeystoneInfo()
    local count = #affixes
    for i,affix in pairs(affixes) do
        local name, description, filedataid = C_ChallengeMode.GetAffixInfo(affix)
        local iconNum = count - i + 1
        IPMTDungeon.affixes[i] = {
            id   = affix,
            name = name,
            text = description,
        }
        SetPortraitToTexture(Addon.fMain.affix[iconNum].Portrait, filedataid)
        Addon.fMain.affix[iconNum]:Show()

        if affix == Addon.AFFIX_TEEMING then
            IPMTDungeon.isTeeming = true
        end
        if affix == Addon.season.affix then
            Addon.season.isActive = true
        end
    end
    for a = count+1,4 do
        Addon.fMain.affix[a]:Hide()
    end
end

local function ShowTimer()
    local name, _, difficulty = GetInstanceInfo()
    if difficulty == 8 then
        local level = C_ChallengeMode.GetActiveKeystoneInfo()
        IPMTDungeon.level = level
        Addon.fMain.level.text:SetText(IPMTDungeon.level)

        InitBossesInfo()
        initAffixes()
        Addon.deaths:Update()
        Addon:UpdateProgress()
        Addon.fMain:Show()
        Addon.fMain.progress.text:SetTextColor(1,1,1)
        Addon.fMain.prognosis.text:SetTextColor(1,1,1)

        local dungeonName = C_Scenario.GetInfo()
        Addon.fMain.dungeonname.text:SetText(dungeonName)

        Addon.fMain:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
        Addon.fMain:RegisterEvent("ENCOUNTER_END")
        Addon.fMain:RegisterEvent("ENCOUNTER_START")
        IPMTDungeon.keyActive = true
        if Addon.season.ShowTimer then
            Addon.season:ShowTimer()
        end
        Addon:RecalcElem()
        Addon:CloseOptions()

        ObjectiveTracker_Collapse()
    end
end
hooksecurefunc("Scenario_ChallengeMode_ShowBlock", ShowTimer)

local function HideTimer()
    if Addon.fOptions ~= nil and not Addon.fOptions:IsShown() then
        Addon.fMain:Hide()
    end
    Addon.keyActive = false
    Addon.fMain:UnregisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
    Addon.fMain:UnregisterEvent("ENCOUNTER_END")
    Addon.fMain:UnregisterEvent("ENCOUNTER_START")
end

local function EncounterEnd(encounterName, success)
    if success == 1 then
        for b, boss in ipairs(IPMTDungeon.bosses) do
            if boss.name == encounterName then
                boss.killed = true
                IPMTDungeon.bossesKilled = IPMTDungeon.bossesKilled + 1
                Addon.fMain.bosses.text:SetText(IPMTDungeon.bossesKilled .. "/" .. #IPMTDungeon.bosses)
                break
            end
        end
    end
    if not success and #IPMTDungeon.combat.killed then
        if Addon.season.BossWipe then
            Addon.season:BossWipe()
        end
    end
    wipe(IPMTDungeon.combat.killed)
    IPMTDungeon.combat.boss = false
end

-- Copypasted from Angry Keystones
local function InsertKeystone()
    for container = BACKPACK_CONTAINER, NUM_BAG_SLOTS do
        local slots = GetContainerNumSlots(container)
        for slot = 1,slots do
            local slotLink = select(7, GetContainerItemInfo(container, slot))
            if slotLink and slotLink:match("|Hkeystone:") then
                PickupContainerItem(container, slot)
                if (CursorHasItem()) then
                    C_ChallengeMode.SlotKeystone()
                end
            end
        end
    end
end

function Addon:OnEvent(self, event, ...)
    local arg1, arg2, arg3, arg4, arg5 = ...
    if event == "ADDON_LOADED" and arg1 == AddonName then
        Addon:Init()
    elseif event == "CHALLENGE_MODE_DEATH_COUNT_UPDATED" then
        Addon.deaths:Update()
    elseif event == "SCENARIO_CRITERIA_UPDATE" then
        Addon:UpdateProgress()
    elseif event == "CHALLENGE_MODE_RESET" then
        Addon:ResetDungeon()
    elseif event == "CHALLENGE_MODE_COMPLETED" then
        IPMTDungeon.keyActive = false
    elseif event == "PLAYER_ENTERING_WORLD" then
        if IPMTDungeon == nil then
            Addon:ResetDungeon()
        end
        local inInstance, instanceType = IsInInstance()
        if not (inInstance and instanceType == "party") then
            HideTimer()
            IPMTDungeon.keyActive = false
            ObjectiveTracker_Expand()
        else
            Addon:UpdateProgress()
        end
    elseif event == "CHALLENGE_MODE_KEYSTONE_RECEPTABLE_OPEN" then
        InsertKeystone()
    elseif event == "COMBAT_LOG_EVENT_UNFILTERED" then
        Addon:CombatLogEvent()
    elseif event == "ENCOUNTER_START" then
        IPMTDungeon.combat.boss = true
    elseif event == "ENCOUNTER_END" then
        EncounterEnd(arg2, arg5)
    elseif event == "VARIABLES_LOADED" then
        Addon:InitVars()
        Addon:Render()
    end
end

function Addon:InitVars()
    Addon:InitThemes()
    IPMTOptions = Addon:CopyObject(Addon.defaultOption, IPMTOptions)

    if IPMTDB == nil then
        IPMTDB = {}
    end
    if MDT then
        local MDTversion = GetAddOnMetadata('MDT', 'Version')
        if not IPMTOptions.MDTversion or (IPMTOptions.MDTversion ~= MDTversion) then
            IPMTOptions.MDTversion = MDTversion
            IPMTDB = {}
        end
    end
end

function Addon:Render()
    Addon:RenderMain()

    if IPMTOptions.version == 0 then
        Addon:ShowOptions()
        Addon:ShowHelp()
        IPMTOptions.version = Addon.version
    end
end

function Addon:Init()
    Addon.DB = LibStub("AceDB-3.0"):New("IPMTOptions", {
        global = {
            minimap = {
                hide = false,
            },
        },
    })
    Addon:InitIcon()
end

function Addon:OnShow()
end
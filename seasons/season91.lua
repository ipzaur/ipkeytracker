local AddonName, Addon = ...

if Addon.season.number ~= 91 then return end

local LSM = LibStub("LibSharedMedia-3.0")

Addon.season.affix = 121

--function Addon.season:GetForces(npcID, isTeeming)
    --if npcID == 148716 or npcID == 148893 or npcID == 148894 then
  --      return nil
    --end
--end

local current = {
    percent = 0,
    wave    = 0,
}
local sounded = {
    percent = current.percent,
    wave    = current.wave - 1,
}
local function AlertWave()
    if not IPMTOptions.wavealert then
        return false
    end
    if current.wave ~= sounded.wave then
        PlaySoundFile(IPMTOptions.wavesound, "SFX")
        sounded.wave = current.wave
    end
end

function Addon.season:Prognosis(forces)
    local prognosisPercent = forces / IPMTDungeon.trash.total * 100
    if sounded.percent > prognosisPercent then
        sounded.wave = current.wave - 1
    end
    sounded.percent = prognosisPercent
    local prognosisWave = math.floor(prognosisPercent / 20)
    if (prognosisPercent % 20 > 18 or current.wave < prognosisWave) then
        AlertWave()
        Addon.fMain.prognosis.text:SetTextColor(1,0,0)
    elseif (prognosisPercent % 20 > 15) then
        AlertWave()
        Addon.fMain.prognosis.text:SetTextColor(1,1,0)
    else
        Addon.fMain.prognosis.text:SetTextColor(1,1,1)
    end
end

function Addon.season:Progress(forces)
    current.percent = IPMTDungeon.trash.current / IPMTDungeon.trash.total * 100
    current.wave = math.floor(current.percent / 20)
    if (current.percent % 20 > 18) then
        Addon.fMain.progress.text:SetTextColor(1,0,0)
    elseif (current.percent % 20 > 15) then
        Addon.fMain.progress.text:SetTextColor(1,1,0)
    else
        Addon.fMain.progress.text:SetTextColor(1,1,1)
    end
end

Addon.season.options = {}

-- Sound list
local function getSoundList()
    local soundList = LSM:List('sound')
    local list = {}
    for i,sound in pairs(soundList) do
        local filepath = LSM:Fetch('sound', sound)
        list[filepath] = sound
    end
    return list
end
local openOptions = false
function Addon.season.options:Render(top)
    -- Customize checkbox
    Addon.fOptions.season.wavealert = CreateFrame("CheckButton", nil, Addon.fOptions.common, "IPCheckButton")
    Addon.fOptions.season.wavealert:SetHeight(22)
    Addon.fOptions.season.wavealert:SetPoint("LEFT", Addon.fOptions.common, "TOPLEFT", 0, top)
    Addon.fOptions.season.wavealert:SetPoint("RIGHT", Addon.fOptions.common, "TOPRIGHT", 0, top)
    Addon.fOptions.season.wavealert:SetText(Addon.localization.WAVEALERT)
    Addon.fOptions.season.wavealert:SetScript("PostClick", function(self)
        IPMTOptions.wavealert = Addon.fOptions.season.wavealert:GetChecked()
    end)
    Addon.fOptions.Mapbut:SetChecked(IPMTOptions.wavealert)

    Addon.fOptions.season.soundList = CreateFrame("Button", nil, Addon.fOptions.common, "IPListBox")
    Addon.fOptions.season.soundList:SetList(getSoundList, IPMTOptions.wavesound)
    Addon.fOptions.season.soundList:SetCallback({
        OnSelect = function(self, key, text)
            IPMTOptions.wavesound = key
            PlaySoundFile(IPMTOptions.wavesound, "SFX")
        end,
    })
    Addon.fOptions.season.soundList:SetHeight(30)
    Addon.fOptions.season.soundList:SetPoint("LEFT", Addon.fOptions.common, "TOPLEFT", 0, top - 30)
    Addon.fOptions.season.soundList:SetPoint("RIGHT", Addon.fOptions.common, "TOPRIGHT", 0, top - 30)
    return 140
end

function Addon.season.options:ShowOptions()
    Addon.fOptions.season.wavealert:SetChecked(IPMTOptions.wavealert)
    Addon.fOptions.season.soundList:SelectItem(IPMTOptions.wavesound, true)
end
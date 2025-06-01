local name, ns = ...

--- @class TransmogUpgradeMaster
local TUM = {}
TransmogUpgradeMaster = TUM

--- @type TransmogUpgradeMasterData
TUM.data = ns.data
--- @type TransmogUpgradeMasterConfig
TUM.Config = ns.Config

local TIER_LFR = 1
local TIER_NORMAL = 2
local TIER_HEROIC = 3
local TIER_MYTHIC = 4
local MYTH_TRACK_STRING_ID = 978;
local HERO_TRACK_STRING_ID = 974;
local CHAMPION_TRACK_STRING_ID = 973;
local VETERAN_TRACK_STRING_ID = 972;
local TRACK_STRING_ID_TO_TIERS = {
    [VETERAN_TRACK_STRING_ID] = TIER_LFR,
    [CHAMPION_TRACK_STRING_ID] = TIER_NORMAL,
    [HERO_TRACK_STRING_ID] = TIER_HEROIC,
    [MYTH_TRACK_STRING_ID] = TIER_MYTHIC,
}
local ITEM_MOD_ID_TIERS = {
    [4] = TIER_LFR,
    [0] = TIER_NORMAL,
    [1] = TIER_HEROIC,
    [3] = TIER_MYTHIC,
}
local CLOTH = Enum.ItemArmorSubclass.Cloth
local LEATHER = Enum.ItemArmorSubclass.Leather
local MAIL = Enum.ItemArmorSubclass.Mail
local PLATE = Enum.ItemArmorSubclass.Plate
local classArmorTypeMap = {
    [1] = PLATE, -- WARRIOR
    [2] = PLATE, -- PALADIN
    [3] = MAIL, -- HUNTER
    [4] = LEATHER, -- ROGUE
    [5] = CLOTH, -- PRIEST
    [6] = PLATE, -- DEATHKNIGHT
    [7] = MAIL, -- SHAMAN
    [8] = CLOTH, -- MAGE
    [9] = CLOTH, -- WARLOCK
    [10] = LEATHER, -- MONK
    [11] = LEATHER, -- DRUID
    [12] = LEATHER, -- DEMONHUNTER
    [13] = MAIL, -- EVOKER
}
local ITEM_UPGRADE_TOOLTIP_PATTERN = ITEM_UPGRADE_TOOLTIP_FORMAT_STRING:gsub('%%d', '(%%d+)'):gsub('%%s', '(.-)');
local CATALYST_MARKUP = CreateAtlasMarkup('CreationCatalyst-32x32', 18, 18)
local UPGRADE_MARKUP = CreateAtlasMarkup('CovenantSanctum-Upgrade-Icon-Available', 18, 18)
local OK_MARKUP = "|TInterface\\RaidFrame\\ReadyCheck-Ready:0|t"
local NOK_MARKUP = "|TInterface\\RaidFrame\\ReadyCheck-NotReady:0|t"

local catalystSlots = {
    [Enum.InventoryType.IndexHeadType] = true,
    [Enum.InventoryType.IndexShoulderType] = true,
    [Enum.InventoryType.IndexChestType] = true,
    [Enum.InventoryType.IndexWaistType] = true,
    [Enum.InventoryType.IndexLegsType] = true,
    [Enum.InventoryType.IndexFeetType] = true,
    [Enum.InventoryType.IndexWristType] = true,
    [Enum.InventoryType.IndexHandType] = true,
    [Enum.InventoryType.IndexCloakType] = true,
}

local playerClassID = select(3, UnitClass("player"))

TUM.currentSeason = 14; -- TWW S2

do
    TUM.sets = TUM.data.sets;
    TUM.setSourceIDs = TUM.data.setSourceIDs;
    TUM.catalystItems = TUM.data.catalystItems;
    TUM.catalystItemByID = TUM.data.catalystItemByID;
end

EventUtil.ContinueOnAddOnLoaded(name, function()
    TUM.db = TUM.Config:Init()
    local currentSeason = C_MythicPlus.GetCurrentSeason()
    TUM.currentSeason = (currentSeason and currentSeason > 0) and currentSeason or 14

    RunNextFrame(function()
        TUM:InitItemSourceMap()
    end)

    --- @param tooltip GameTooltip
    TooltipDataProcessor.AddTooltipPostCall(Enum.TooltipDataType.Item, function(tooltip)
        if tooltip == GameTooltip or tooltip == GameTooltip.ItemTooltip.Tooltip then
            TUM:HandleTooltip(tooltip)
        end
    end)
end)

---@param classID number
---@return nil | { [1]: number, [2]: number, [3]: number, [4]: number } # lfrSetID, normalSetID, heroicSetID, mythicSetID
function TUM:GetSetsForClass(classID)
    return self.sets[self.currentSeason] and self.sets[self.currentSeason][classID] or nil;
end

--- @param classMask number
--- @return number[] classIDList
function TUM:ConvertClassMaskToClassList(classMask)
	local classIDList = {};
	for classID = 1, GetNumClasses() do
		local classAllowed = FlagsUtil.IsSet(classMask, bit.lshift(1, (classID - 1)));
		if classAllowed then
			table.insert(classIDList, classID);
		end
	end

	return classIDList;
end

function TUM:InitItemSourceMap()
    local itemSourceIDs = {}
    self.itemSourceMapInitialized = false
    self.itemSourceMapProgress = 0
    self.itemSourceMapTotal = 0
    self.itemSourceIDs = itemSourceIDs
    --- @type table<number, TransmogCategoryAppearanceInfo[]>
    local categoryAppearances = {}
    for _, category in pairs(Enum.TransmogCollectionType) do
        categoryAppearances[category] = C_TransmogCollection.GetCategoryAppearances(category)
        self.itemSourceMapTotal = self.itemSourceMapTotal + #categoryAppearances[category]
    end
    local msPerBatch = 20
    local function iterateAppearances()
        local start = debugprofilestop()
        for _, appearances in pairs(categoryAppearances) do
            for _, info in pairs(appearances) do
                local appearanceSources = C_TransmogCollection.GetAppearanceSources(info.visualID)
                if appearanceSources then
                    for _, sourceInfo in ipairs(appearanceSources) do
                        local tier = ITEM_MOD_ID_TIERS[sourceInfo.itemModID] or nil
                        if tier then
                            itemSourceIDs[sourceInfo.itemID] = itemSourceIDs[sourceInfo.itemID] or {}
                            itemSourceIDs[sourceInfo.itemID][tier] = sourceInfo.sourceID
                        end
                    end
                end
                self.itemSourceMapProgress = self.itemSourceMapProgress + 1
                if debugprofilestop() - start > msPerBatch then
                    coroutine.yield()
                    start = debugprofilestop()
                end
            end
        end
        self.itemSourceMapInitialized = true
    end
    local resumeFunc = coroutine.wrap(iterateAppearances)
    local ticker
    ticker = C_Timer.NewTicker(1, function()
        if self.itemSourceMapInitialized then
            ticker:Cancel()
            return
        end
        resumeFunc()
    end)
end

--- previous season items are not (yet?) supported
--- @param itemLink string
--- @return boolean
function TUM:IsCurrentSeasonItem(itemLink)
    local data = C_TooltipInfo.GetHyperlink(itemLink);
    for _, line in ipairs(data and data.lines or {}) do
        if line and line.leftText and line.leftText:match(ITEM_UPGRADE_TOOLTIP_PATTERN) then
            if
                line.leftText:match('|cFF808080.-')
                or line.leftColor:GenerateHexColor() == 'ff808080'
            then
                return false
            else
                return true
            end
        end
    end

    return false
end

local modifierFunctions = {
    [TUM.Config.modifierKeyOptions.always] = function() return true end,
    [TUM.Config.modifierKeyOptions.shift] = IsShiftKeyDown,
    [TUM.Config.modifierKeyOptions.ctrl] = IsControlKeyDown,
    [TUM.Config.modifierKeyOptions.alt] = IsAltKeyDown,
    [TUM.Config.modifierKeyOptions.never] = function() return false end,
}

--- @param tooltip GameTooltip
--- @param text string
--- @param isCollected boolean
function TUM:AddTooltipLine(tooltip, text, isCollected)
    local modifierSetting = isCollected
        and self.db.showCollectedModifierKey
        or self.db.showUncollectedModifierKey
    local modifierFunction = modifierFunctions[modifierSetting]
    if not modifierFunction or not modifierFunction() then
        return
    end

    local ok = OK_MARKUP .. GREEN_FONT_COLOR:WrapTextInColorCode(' Collected ') .. OK_MARKUP
    local nok = NOK_MARKUP .. RED_FONT_COLOR:WrapTextInColorCode(' Not Collected ') .. NOK_MARKUP
    tooltip:AddDoubleLine(text, isCollected and ok or nok)
end

--- @param tooltip GameTooltip
--- @param text string
function TUM:AddDebugLine(tooltip, text)
    if not self.db.debug then return end

    tooltip:AddDoubleLine('<TUM Debug>', text, 1, 0.5, 0, 1, 1, 1)
end

--- @param tooltip GameTooltip
function TUM:HandleTooltip(tooltip)
    local itemLink = select(2, TooltipUtil.GetDisplayedItem(tooltip))
    if not itemLink then return end

    local itemID = tonumber(itemLink:match("item:(%d+)"))
    if not itemID or not C_Item.IsDressableItemByID(itemID) then return end
    self:AddDebugLine(tooltip, 'itemID: ' .. tostring(itemID))

    local upgradeInfo = C_Item.GetItemUpgradeInfo(itemLink)
    if not upgradeInfo or not self:IsCurrentSeasonItem(itemLink) then
        self:AddDebugLine(tooltip, 'not upgradable current season item')
        return
    end

    local canUpgradeToNextBreakpoint = false
    local currentTier = 0;
    if upgradeInfo then
        currentTier = TRACK_STRING_ID_TO_TIERS[upgradeInfo.trackStringID] or 0
        if currentTier and upgradeInfo.currentLevel >= 5 and currentTier < 4 then
            currentTier = currentTier + 1
        end
        if upgradeInfo.currentLevel < 5 and currentTier < 4 then
            canUpgradeToNextBreakpoint = true
        end
    end
    if currentTier == 0 then return end
    self:AddDebugLine(tooltip, 'currentTier: ' .. tostring(currentTier))

    local itemSlot = C_Item.GetItemInventoryTypeByID(itemLink)
    if itemSlot == Enum.InventoryType.IndexRobeType then
        -- robes catalyse into chest pieces
        itemSlot = Enum.InventoryType.IndexChestType
    end

    local _, sourceID = C_TransmogCollection.GetItemInfo(itemID)
    self:AddDebugLine(tooltip, 'sourceID: ' .. tostring(sourceID))

    local setIDs = sourceID and C_TransmogSets.GetSetsContainingSourceID(sourceID)
    local relatedSets
    if setIDs and #setIDs > 0 then
        self:AddDebugLine(tooltip, 'setIDs: ' .. table.concat(setIDs, ', '))
        for _, setID in ipairs(setIDs) do
            local setInfo = C_TransmogSets.GetSetInfo(setID)

            local classIDList = self:ConvertClassMaskToClassList(setInfo.classMask)

            local classSets = self:GetSetsForClass(classIDList[1])
            if classSets and tIndexOf(classSets, setID) then
                relatedSets = classSets
            end
        end
    end

    local isCatalysed = self:IsItemCatalysed(itemID)
    self:AddDebugLine(tooltip, 'isCatalysed: ' .. tostring(isCatalysed))
    local canCatalyse = not isCatalysed and self:IsCatalystSlot(itemSlot) and self:IsValidArmorTypeForPlayer(itemLink)
    if canCatalyse then
        local playerSets = self:GetSetsForClass(playerClassID)
        if playerSets then
            local currentIsCollected = self:IsSetItemCollected(playerSets[currentTier], itemSlot)
            self:AddTooltipLine(tooltip, CATALYST_MARKUP .. " Catalyst appearance", currentIsCollected)
            if canUpgradeToNextBreakpoint then
                local nextIsCollected = self:IsSetItemCollected(playerSets[currentTier + 1], itemSlot)
                self:AddTooltipLine(tooltip, CATALYST_MARKUP .. " Catalyst & " .. UPGRADE_MARKUP .. " Upgrade appearance",
                    nextIsCollected)
            end
        else
            -- todo: add a 1-time error message that set info for current season+class couldn't be found
        end
    else
        self:AddDebugLine(tooltip, 'not catalysable or already catalysed')
    end
    if isCatalysed and relatedSets and canUpgradeToNextBreakpoint then
        local nextSetID = relatedSets[currentTier + 1]
        if nextSetID then
            local isCollected = self:IsSetItemCollected(nextSetID, itemSlot)
            self:AddTooltipLine(tooltip, UPGRADE_MARKUP .. " Upgrade appearance", isCollected)
        end
    elseif canUpgradeToNextBreakpoint then
        local sourceIDs = self:GetSourceIDsForItemID(itemID)
        if sourceIDs and sourceIDs[currentTier + 1] then
            local nextSourceInfo = C_TransmogCollection.GetSourceInfo(sourceIDs[currentTier + 1])
            local isCollected = nextSourceInfo and nextSourceInfo.isCollected
            self:AddTooltipLine(tooltip, UPGRADE_MARKUP .. " Upgrade appearance", isCollected)
        elseif not self.itemSourceMapInitialized then
            local progress = self.itemSourceMapProgress / self.itemSourceMapTotal * 100
            local text = string.format("TransmogUpgradeMaster is loading (%.0f%%)", progress)
            tooltip:AddLine(text, nil, nil, nil, true)
        end
    end
end

function TUM:GetSourceIDsForItemID(itemID)
    return self.itemSourceIDs[itemID]
end

--- @param itemLink string
--- @return boolean
function TUM:IsValidArmorTypeForPlayer(itemLink)
    local invType, _, itemClassID, itemSubClassID = select(4, C_Item.GetItemInfoInstant(itemLink))

    return invType == "INVTYPE_CLOAK"
        or (itemClassID == Enum.ItemClass.Armor and itemSubClassID == classArmorTypeMap[playerClassID])
end

function TUM:IsCatalystSlot(slot)
    return catalystSlots[slot] or false
end

function TUM:IsItemCatalysed(itemID)
    return not not self.catalystItemByID[itemID]
end

function TUM:IsSetItemCollected(transmogSetID, slot)
    if self.setSourceIDs[transmogSetID] then
        local sourceID = self.setSourceIDs[transmogSetID][slot]
        if sourceID then
            local sourceInfo = C_TransmogCollection.GetSourceInfo(sourceID)
            if sourceInfo and sourceInfo.isCollected then
                return true
            end
        end

        return false
    end

    local sources = C_TransmogSets.GetSourcesForSlot(transmogSetID, slot)
    for _, slotSourceInfo in ipairs(sources) do
        if slotSourceInfo.isCollected then
            return true
        end
    end

    return false
end

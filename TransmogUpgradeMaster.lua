local name, ns = ...

--- @class TransmogUpgradeMaster
local TUM = {}
TransmogUpgradeMaster = TUM
--@debug@
_G.TUM = TUM
--@end-debug@
ns.core = TUM

--- @type TransmogUpgradeMasterData
TUM.data = ns.data
--- @type TransmogUpgradeMasterConfig
TUM.Config = ns.Config
local settingKeys = TUM.Config.settingKeys

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

local classIDToName = {}
do
    for classID = 1, GetNumClasses() do
        local className, classFile = GetClassInfo(classID);
        local classColor = RAID_CLASS_COLORS[classFile];
        if className then
            classIDToName[classID] = classColor:WrapTextInColorCode(className);
        end
    end
    TUM.currentSeason = TUM.data.currentSeason;
    TUM.sets = TUM.data.sets;
    TUM.setSourceIDs = TUM.data.setSourceIDs;
    TUM.catalystItems = TUM.data.catalystItems;
    TUM.catalystItemByID = TUM.data.catalystItemByID;
end

EventUtil.ContinueOnAddOnLoaded(name, function()
    TUM.db = TUM.Config:Init()
    local currentSeason = C_MythicPlus.GetCurrentSeason()
    TUM.currentSeason = (currentSeason and currentSeason > 0) and currentSeason or TUM.data.currentSeason

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
---@param seasonID number?
---@return nil | { [1]: number, [2]: number, [3]: number, [4]: number } # lfrSetID, normalSetID, heroicSetID, mythicSetID
function TUM:GetSetsForClass(classID, seasonID)
    return self.sets[seasonID or self.currentSeason] and self.sets[seasonID or self.currentSeason][classID] or nil;
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
    if self.itemSourceMapInitialized == false then
        -- already initializing...
        return
    end
    local itemSourceIDs = {}
    self.itemSourceMapInitialized = false
    self.itemSourceMapProgress = 0
    self.itemSourceMapTotal = 0
    self.itemSourceIDs = TransmogUpgradeMasterCacheDB or itemSourceIDs
    local buildNr = select(2, GetBuildInfo())
    if buildNr == self.itemSourceIDs._buildNr then
        self.itemSourceMapInitialized = true
        self.itemSourceMapProgress = 1
        self.itemSourceMapTotal = 1
        -- only refresh the cache if the build number has changed
        return
    end
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
        self.itemSourceIDs = itemSourceIDs
        TransmogUpgradeMasterCacheDB = itemSourceIDs
        TransmogUpgradeMasterCacheDB._buildNr = buildNr
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

local BONUS_ID_OFFSET = 13;
function TUM:GetItemSeason(itemLink)
    if self:IsCurrentSeasonItem(itemLink) then
        return self.currentSeason;
    end

    local _, data = LinkUtil.ExtractLink(itemLink);
    local parts = strsplittable(':', data);
    local numBonusIDs = tonumber(parts[BONUS_ID_OFFSET]) or 0;
    for index = (BONUS_ID_OFFSET + 1), (BONUS_ID_OFFSET + numBonusIDs) do
        local bonusID = tonumber(parts[index]);
        if self.data.catalystBonusIDMap[bonusID] then
            return self.data.catalystBonusIDMap[bonusID];
        end
    end

    return nil;
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

local mailableBindings = {
    [Enum.TooltipDataItemBinding.Account] = true,
    [Enum.TooltipDataItemBinding.AccountUntilEquipped] = true,
    [Enum.TooltipDataItemBinding.BindOnEquip] = true,
    [Enum.TooltipDataItemBinding.BindOnUse] = true,
    [Enum.TooltipDataItemBinding.BindToAccount] = true,
    [Enum.TooltipDataItemBinding.BindToAccountUntilEquipped] = true,
    [Enum.TooltipDataItemBinding.BindToBnetAccount] = true,
}
function TUM:CanSendItemToAlt(itemLink)
    local binding = self:GetItemBinding(itemLink)

    return binding and mailableBindings[binding] or false
end

--- @param itemLink string
--- @return number? itemBinding # see Enum.TooltipDataItemBinding
function TUM:GetItemBinding(itemLink)
    local data = C_TooltipInfo.GetHyperlink(itemLink);
    for _, line in ipairs(data and data.lines or {}) do
        if line and line.type == Enum.TooltipDataLineType.ItemBinding then
            return line.bonding
        end
    end

    return nil
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
        and self.db[settingKeys.showCollectedModifierKey]
        or self.db[settingKeys.showUncollectedModifierKey]
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
    if not self.db[settingKeys.debug] then return end

    tooltip:AddDoubleLine('<TUM Debug>', text, 1, 0.5, 0, 1, 1, 1)
end

--- @param tbl table?
---@param value any
local function tryInsert(tbl, value)
    if tbl then
        table.insert(tbl, value)
    end
end

--- @param itemLink string
--- @param classID number? # defaults to the player's class
--- @param debugLines string[]? # if provided, debug lines will be added to this table
--- @return boolean? canCatalyse # whether the item can be catalysed; if false, the catalystAppearanceMissing return values will be nil
--- @return boolean? canUpgrade # whether the item can be upgraded to the next tier; if false, the upgradeAppearanceMissing return values will be nil
--- @return boolean? catalystAppearanceMissing # true if the item will teach a new appearance when catalysed
--- @return boolean? catalystUpgradeAppearanceMissing # true if the item will teach a new appearance when catalysed AND upgraded to the next tier
--- @return boolean? upgradeAppearanceMissing # true if the item will teach a new appearance when upgraded to the next tier
function TUM:IsAppearanceMissing(itemLink, classID, debugLines)
    if not C_Item.IsItemDataCachedByID(itemLink) then
        tryInsert(debugLines, 'item data not cached')

        return nil, nil, nil, nil, nil
    end
    classID = classID or playerClassID
    local canCatalyse, canUpgradeToNextBreakpoint = false, false
    local catalystMissing, catalystUpgradeMissing, upgradeMissing = nil, nil, nil

    local itemID = tonumber(itemLink:match("item:(%d+)"))
    if not itemID or not C_Item.IsDressableItemByID(itemID) then
        return canCatalyse, canUpgradeToNextBreakpoint, catalystMissing, catalystUpgradeMissing, upgradeMissing
    end
    tryInsert(debugLines, 'itemID: ' .. tostring(itemID))

    local upgradeInfo = C_Item.GetItemUpgradeInfo(itemLink)
    local canUpgrade = upgradeInfo and self:IsCurrentSeasonItem(itemLink)
    local seasonID = self:GetItemSeason(itemLink)
    tryInsert(debugLines, 'seasonID: ' .. tostring(seasonID))
    if not upgradeInfo or not seasonID then
        tryInsert(debugLines, 'not upgradable or no seasonID')

        return canCatalyse, canUpgradeToNextBreakpoint, catalystMissing, catalystUpgradeMissing, upgradeMissing
    end

    local currentTier = 0;
    if upgradeInfo then
        currentTier = TRACK_STRING_ID_TO_TIERS[upgradeInfo.trackStringID] or 0
        if currentTier and upgradeInfo.currentLevel >= 5 and currentTier < 4 then
            currentTier = currentTier + 1
        end
        if canUpgrade and upgradeInfo.currentLevel < 5 and currentTier < 4 then
            canUpgradeToNextBreakpoint = true
        end
    end
    if currentTier == 0 then
        local _, sourceID = C_TransmogCollection.GetItemInfo(itemLink)
        local sourceIDs = self:GetSourceIDsForItemID(itemID)
        local index = tIndexOf(sourceIDs or {}, sourceID)
        currentTier = index or 0

        if currentTier == 0 then
            tryInsert(debugLines, 'no tier info found')

            return canCatalyse, canUpgradeToNextBreakpoint, catalystMissing, catalystUpgradeMissing, upgradeMissing
        end
    end
    tryInsert(debugLines, 'currentTier: ' .. tostring(currentTier))

    local itemSlot = C_Item.GetItemInventoryTypeByID(itemLink)
    if itemSlot == Enum.InventoryType.IndexRobeType then
        -- robes catalyse into chest pieces
        itemSlot = Enum.InventoryType.IndexChestType
    end

    local _, sourceID = C_TransmogCollection.GetItemInfo(itemID)
    tryInsert(debugLines, 'sourceID: ' .. tostring(sourceID))

    local setIDs = sourceID and C_TransmogSets.GetSetsContainingSourceID(sourceID)
    local relatedSets
    if setIDs and #setIDs > 0 then
        tryInsert(debugLines, 'setIDs: ' .. table.concat(setIDs, ', '))
        for _, setID in ipairs(setIDs) do
            local setInfo = C_TransmogSets.GetSetInfo(setID)

            local classIDList = self:ConvertClassMaskToClassList(setInfo.classMask)

            local classSets = self:GetSetsForClass(classIDList[1], seasonID)
            if classSets and tIndexOf(classSets, setID) then
                relatedSets = classSets
            end
        end
    end

    local isCatalysed = self:IsItemCatalysed(itemID)
    tryInsert(debugLines, 'isCatalysed: ' .. tostring(isCatalysed))
    canCatalyse = not isCatalysed and self:IsCatalystSlot(itemSlot) and self:IsValidArmorTypeForClass(itemLink, classID)
    if canCatalyse then
        local playerSets = self:GetSetsForClass(classID, seasonID)
        if playerSets then
            catalystMissing = not self:IsSetItemCollected(playerSets[currentTier], itemSlot)
            if canUpgradeToNextBreakpoint then
                catalystUpgradeMissing = not self:IsSetItemCollected(playerSets[currentTier + 1], itemSlot)
            end
        else
            catalystMissing = not self:IsCatalystItemCollected(seasonID, classID, itemSlot, currentTier)
            if canUpgradeToNextBreakpoint then
                catalystUpgradeMissing = not self:IsCatalystItemCollected(seasonID, classID, itemSlot, currentTier + 1)
            end
        end
    else
        tryInsert(debugLines, 'can\'t catalyse or already catalysed')
    end
    if isCatalysed and relatedSets and canUpgradeToNextBreakpoint then
        local nextSetID = relatedSets[currentTier + 1]
        if nextSetID then
            upgradeMissing = not self:IsSetItemCollected(nextSetID, itemSlot)
        end
    elseif canUpgradeToNextBreakpoint then
        local sourceIDs = self:GetSourceIDsForItemID(itemID)
        if sourceIDs and sourceIDs[currentTier + 1] then
            local nextSourceInfo = C_TransmogCollection.GetSourceInfo(sourceIDs[currentTier + 1])
            upgradeMissing = not nextSourceInfo or not nextSourceInfo.isCollected
        end
    end

    if self:IsCacheWarmedUp() then
        if canCatalyse then
            catalystMissing = catalystMissing or false
            if canUpgradeToNextBreakpoint then
                catalystUpgradeMissing = catalystUpgradeMissing or false
            end
        end
        if canUpgradeToNextBreakpoint then
            upgradeMissing = upgradeMissing or false
        end
    end

    return canCatalyse, canUpgradeToNextBreakpoint, catalystMissing, catalystUpgradeMissing, upgradeMissing
end

--- @param tooltip GameTooltip
function TUM:HandleTooltip(tooltip)
    local itemLink = select(2, TooltipUtil.GetDisplayedItem(tooltip))
    if not itemLink then return end

    local debugLines = {}
    local canCatalyse, canUpgrade,
    catalystMissing, catalystUpgradeMissing, upgradeMissing = self:IsAppearanceMissing(itemLink, nil, debugLines)

    for _, line in ipairs(debugLines) do
        self:AddDebugLine(tooltip, line)
    end

    local loadingTooltipShown = false
    if canCatalyse then
        if catalystMissing == nil then
            if not loadingTooltipShown then loadingTooltipShown = self:ShowLoadingTooltipIfLoading(tooltip) end
        else
            self:AddTooltipLine(tooltip, CATALYST_MARKUP .. ' Catalyst appearance', not catalystMissing)
        end
        if canUpgrade then
            if catalystUpgradeMissing == nil then
                if not loadingTooltipShown then loadingTooltipShown = self:ShowLoadingTooltipIfLoading(tooltip) end
            else
                self:AddTooltipLine(
                    tooltip,
                    CATALYST_MARKUP .. ' Catalyst & ' .. UPGRADE_MARKUP .. ' Upgrade appearance',
                    not catalystUpgradeMissing
                )
            end
        end
    end
    if canUpgrade then
        if upgradeMissing == nil then
            if not loadingTooltipShown then loadingTooltipShown = self:ShowLoadingTooltipIfLoading(tooltip) end
        else
            self:AddTooltipLine(tooltip, UPGRADE_MARKUP .. ' Upgrade appearance', not upgradeMissing)
        end
    end

    if modifierFunctions[self.db[settingKeys.showWarbandCatalystInfoModifierKey]]() and self:CanSendItemToAlt(itemLink) then
        local catalystClassList = {}
        local catalystUpgradeClassList = {}
        for classID = 1, GetNumClasses() do
            if classID ~= playerClassID and self.db[settingKeys.warbandCatalystClassList][classID] then
                local _, _, classCatalystMissing, classCatalystUpgradeMissing = self:IsAppearanceMissing(itemLink, classID)
                if classCatalystMissing then
                    table.insert(catalystClassList, classID)
                end
                if classCatalystUpgradeMissing then
                    table.insert(catalystUpgradeClassList, classID)
                end
            end
        end
        if #catalystClassList > 0 then
            local classNames = {}
            for _, classID in ipairs(catalystClassList) do
                table.insert(classNames, classIDToName[classID])
            end
            tooltip:AddDoubleLine(CATALYST_MARKUP .. ' Catalyst missing for', table.concat(classNames, ', '))
        end
        if #catalystUpgradeClassList > 0 then
            local classNames = {}
            for _, classID in ipairs(catalystUpgradeClassList) do
                table.insert(classNames, classIDToName[classID])
            end
            tooltip:AddDoubleLine(
                CATALYST_MARKUP .. ' Catalyst & ' .. UPGRADE_MARKUP .. ' Upgrade missing for',
                table.concat(classNames, ', ')
            )
        end
    end
end

--- @return boolean isCacheWarmedUp
--- @return number progress # a number between 0 and 1, where 1 means caching has finished
function TUM:IsCacheWarmedUp()
    if not TransmogUpgradeMasterCacheDB and not self.itemSourceMapInitialized then
        return false, self.itemSourceMapProgress / self.itemSourceMapTotal
    end
    return true, 1
end

--- @return boolean loading
function TUM:ShowLoadingTooltipIfLoading(tooltip)
    local warmedUp, progress = self:IsCacheWarmedUp()
    if warmedUp then return false end

    local text = string.format("TransmogUpgradeMaster is loading (%.0f%%)", progress * 100)
    tooltip:AddLine(text, nil, nil, nil, true)

    return true
end

function TUM:GetSourceIDsForItemID(itemID)
    return self.itemSourceIDs[itemID]
end

--- @param itemLink string
--- @param classID number # defaults to the player's class
--- @return boolean
function TUM:IsValidArmorTypeForClass(itemLink, classID)
    local invType, _, itemClassID, itemSubClassID = select(4, C_Item.GetItemInfoInstant(itemLink))

    return invType == "INVTYPE_CLOAK"
        or (itemClassID == Enum.ItemClass.Armor and itemSubClassID == classArmorTypeMap[classID])
end

function TUM:IsCatalystSlot(slot)
    return catalystSlots[slot] or false
end

function TUM:IsItemCatalysed(itemID)
    return not not self.catalystItemByID[itemID]
end

--- @param seasonID number
--- @param slot number # Enum.InventoryType
--- @param tier number # one of TIER_x constants
function TUM:IsCatalystItemCollected(seasonID, classID, slot, tier)
    if not self.catalystItems[seasonID] or not self.catalystItems[seasonID][classID] then
        return nil
    end
    local itemID = self.catalystItems[seasonID][classID][slot]
    if not itemID then return nil end

    local sourceIDs = self:GetSourceIDsForItemID(itemID)
    if not sourceIDs or not sourceIDs[tier] then
        return nil
    end

    local sourceInfo = C_TransmogCollection.GetSourceInfo(sourceIDs[tier])

    return sourceInfo and sourceInfo.isCollected or false
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

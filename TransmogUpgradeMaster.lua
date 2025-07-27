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

--- @alias TUM_LearnedFromOtherItem "learnedFromOtherItem"
local LEARNED_FROM_OTHER_ITEM = 'learnedFromOtherItem'

local ITEM_UPGRADE_TOOLTIP_PATTERN = ITEM_UPGRADE_TOOLTIP_FORMAT_STRING:gsub('%%d', '(%%d+)'):gsub('%%s', '(.-)');
local CATALYST_MARKUP = CreateAtlasMarkup('CreationCatalyst-32x32', 18, 18)
local UPGRADE_MARKUP = CreateAtlasMarkup('CovenantSanctum-Upgrade-Icon-Available', 18, 18)
local OK_MARKUP = "|TInterface\\RaidFrame\\ReadyCheck-Ready:0|t"
local NOK_MARKUP = "|TInterface\\RaidFrame\\ReadyCheck-NotReady:0|t"
local OTHER_MARKUP = CreateAtlasMarkup('QuestRepeatableTurnin', 16, 16)

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
    --- @type TransmogUpgradeMaster_CollectionUI
    TUM.UI = ns.UI
    TUM.db = TUM.Config:Init()
    TUM.UI:Init()
    local currentSeason = C_MythicPlus.GetCurrentSeason()
    if currentSeason and currentSeason > 0 then
        TUM.currentSeason = (currentSeason and currentSeason > 0) and currentSeason or TUM.data.currentSeason
        TUM.UI:InitSeason(TUM.currentSeason)
    else
        RunNextFrame(function()
            C_MythicPlus.RequestMapInfo()
        end)
        EventUtil.RegisterOnceFrameEventAndCallback('CHALLENGE_MODE_MAPS_UPDATE', function()
            local currentSeason = C_MythicPlus.GetCurrentSeason()
            TUM.currentSeason = (currentSeason and currentSeason > 0) and currentSeason or TUM.data.currentSeason
            TUM.UI:InitSeason(TUM.currentSeason)
        end)
    end

    RunNextFrame(function()
        TUM:InitItemSourceMap()
        EventUtil.ContinueOnAddOnLoaded('Blizzard_ItemInteractionUI', function()
            hooksecurefunc(ItemInteractionFrame, 'InteractWithItem', function() TUM:HandleCatalystInteraction() end)
        end)
    end)

    --- @param tooltip GameTooltip
    TooltipDataProcessor.AddTooltipPostCall(Enum.TooltipDataType.Item, function(tooltip, tooltipData)
        if tooltip == GameTooltip or tooltip == GameTooltip.ItemTooltip.Tooltip then
            TUM:HandleTooltip(tooltip, tooltipData)
        end
    end)

    SLASH_TRANSMOG_UPGRADE_MASTER1 = "/tum";
    SLASH_TRANSMOG_UPGRADE_MASTER2 = "/transmogupgrademaster";
    SlashCmdList["TRANSMOG_UPGRADE_MASTER"] = function(msg)
        if msg and msg:trim() == 'config' then
            TUM.Config:OpenSettings();

            return;
        end

        TUM.UI:ToggleUI();
    end
end)

do
    function TransmogUpgradeMaster_OnAddonCompartmentClick(_, mouseButton)
        if mouseButton == 'LeftButton' then
            TUM.UI:ToggleUI();
        else
            TUM.Config:OpenSettings();
        end
    end

    function TransmogUpgradeMaster_OnAddonCompartmentEnter(_, button)
        GameTooltip:SetOwner(button, 'ANCHOR_RIGHT');
        GameTooltip:AddLine('Transmog Upgrade Master')
        GameTooltip:AddLine(CreateAtlasMarkup('NPE_LeftClick', 18, 18) .. ' to toggle the Collection UI');
        GameTooltip:AddLine(CreateAtlasMarkup('NPE_RightClick', 18, 18) .. ' to open the settings');
        GameTooltip:Show();
    end
    function TransmogUpgradeMaster_OnAddonCompartmentLeave()
        GameTooltip:Hide();
    end
end

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
                        local tier = self.data.constants.itemModIDTiers[sourceInfo.itemModID] or nil
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

function TUM:IsToken(itemID)
    return not not self.data.tokens[itemID]
end

--- @return nil|{season: number, classList: number[], tier: number|nil, slot: number}
function TUM:GetTokenInfo(itemID, itemLink)
    local tokenInfo = self.data.tokens[itemID]
    if not tokenInfo then
        return nil
    end

    local _, data = LinkUtil.ExtractLink(itemLink)
    local parts = strsplittable(':', data)
    local itemCreationContext = tonumber(parts[12])
    local tier = self.data.constants.itemContextTiers[itemCreationContext] or nil

    return {
        season = tokenInfo.season,
        tier = tier,
        slot = tokenInfo.slot,
        classList = tokenInfo.classList,
    }
end

local BONUS_ID_OFFSET = 13;
--- doesn't return season information for catalysed items from previous seasons, but that's fine, since nothing can be done with those items anyway
function TUM:GetItemSeason(itemLink)
    if self:IsCurrentSeasonItem(itemLink) then
        return self.currentSeason;
    end

    local _, data = LinkUtil.ExtractLink(itemLink);
    local parts = strsplittable(':', data);
    local itemID = tonumber(parts[1]);
    local tokenInfo = self.data.tokens[itemID];
    if tokenInfo then return tokenInfo.season; end

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

--- @param itemLink string
--- @return boolean isConquestPvpItem
function TUM:IsConquestPvpItem(itemLink)
    local _, sourceID = C_TransmogCollection.GetItemInfo(itemLink)
    if not sourceID then
        return false
    end
    local sourceInfo = C_TransmogCollection.GetSourceInfo(sourceID)

    return sourceInfo and sourceInfo.itemModID == self.data.constants.conquestItemModID or false
end

--- @param itemLink string
--- @param tooltipData TooltipData
function TUM:CanSendItemToAlt(itemLink, tooltipData)
    local binding = self:GetItemBinding(itemLink, tooltipData)

    return binding and self.data.constants.mailableBindings[binding] or false
end

--- @param itemLink string
--- @param tooltipData TooltipData
--- @return number? itemBinding # see Enum.TooltipDataItemBinding
function TUM:GetItemBinding(itemLink, tooltipData)
    local data = tooltipData or C_TooltipInfo.GetHyperlink(itemLink);
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
function TUM:AddTooltipLine(tooltip, text, isCollected, fromOtherItem)
    local modifierSetting =
        (isCollected and self.db.showCollectedModifierKey)
        or (fromOtherItem and self.db.showCollectedFromOtherItemModifierKey)
        or (self.db.showUncollectedModifierKey)
    local modifierFunction = modifierFunctions[modifierSetting]
    if not modifierFunction or not modifierFunction() then
        return
    end

    local ok = OK_MARKUP .. GREEN_FONT_COLOR:WrapTextInColorCode(' Collected ') .. OK_MARKUP
    local nok = NOK_MARKUP .. RED_FONT_COLOR:WrapTextInColorCode(' Not Collected ') .. NOK_MARKUP
    local other = OTHER_MARKUP .. BLUE_FONT_COLOR:WrapTextInColorCode(' From Another Item ') .. OTHER_MARKUP
    tooltip:AddDoubleLine(text, (isCollected and ok) or (fromOtherItem and other) or nok)
end

--- @param tooltip GameTooltip
--- @param text string
function TUM:AddDebugLine(tooltip, text)
    if not self.db.debug then return end

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
--- @return TUM_AppearanceMissingResult
function TUM:IsAppearanceMissing(itemLink, classID, debugLines)
    --- @type TUM_AppearanceMissingResult
    local result = {
        canCatalyse = nil,
        canUpgrade = nil,
        catalystAppearanceMissing = nil,
        catalystUpgradeAppearanceMissing = nil,
        upgradeAppearanceMissing = nil,
        catalystAppearanceLearnedFromOtherItem = false,
        catalystUpgradeAppearanceLearnedFromOtherItem = false,
        upgradeAppearanceLearnedFromOtherItem = false,
    }
    if not C_Item.IsItemDataCachedByID(itemLink) then
        tryInsert(debugLines, 'item data not cached')

        return result
    end
    classID = classID or playerClassID
    result.canCatalyse, result.canUpgrade = false, false
    result.contextData = {}
    local context = result.contextData

    local itemID = tonumber(itemLink:match("item:(%d+)"))
    local isToken = itemID and self:IsToken(itemID)
    if not itemID or (not isToken and not C_Item.IsDressableItemByID(itemID)) then
        return result
    end
    context.itemID = itemID
    tryInsert(debugLines, 'itemID: ' .. tostring(itemID))

    local upgradeInfo = C_Item.GetItemUpgradeInfo(itemLink)
    local canUpgrade = upgradeInfo and self:IsCurrentSeasonItem(itemLink)
    local seasonID = self:GetItemSeason(itemLink)
    context.seasonID = seasonID
    tryInsert(debugLines, 'seasonID: ' .. tostring(seasonID))
    if not upgradeInfo and not seasonID then
        tryInsert(debugLines, 'not upgradable and no seasonID')

        return result
    end

    local currentTier = 0;
    if upgradeInfo then
        currentTier = self.data.constants.trackStringIDToTiers[upgradeInfo.trackStringID] or 0
        if currentTier and upgradeInfo.currentLevel >= 5 and currentTier < 4 then
            currentTier = currentTier + 1
        end
        if canUpgrade and upgradeInfo.currentLevel < 5 and currentTier < 4 then
            result.canUpgrade = true
        end
    end
    local _, sourceID = C_TransmogCollection.GetItemInfo(itemLink)
    tryInsert(debugLines, 'sourceID: ' .. tostring(sourceID))

    if sourceID and debugLines then
        local sourceInfo = C_TransmogCollection.GetSourceInfo(sourceID)
        tryInsert(debugLines, 'itemModID: ' .. tostring(sourceInfo and sourceInfo.itemModID))
    end

    local tokenInfo = isToken and self:GetTokenInfo(itemID, itemLink)
    if tokenInfo then
        if not tokenInfo.classList[classID] then
            tryInsert(debugLines, 'item is a token for another class')

            return result
        end

        currentTier = tokenInfo.tier or currentTier
    end

    if currentTier == 0 then
        local sourceIDs = self:GetSourceIDsForItemID(itemID)
        local index = tIndexOf(sourceIDs or {}, sourceID)
        currentTier = index or 0

        if currentTier == 0 then
            tryInsert(debugLines, 'no tier info found')

            return result
        end
    end
    context.tier = currentTier
    tryInsert(debugLines, 'currentTier: ' .. tostring(currentTier))

    local itemSlot = tokenInfo and tokenInfo.slot or C_Item.GetItemInventoryTypeByID(itemLink)
    if itemSlot == Enum.InventoryType.IndexRobeType then
        -- robes catalyse into chest pieces
        itemSlot = Enum.InventoryType.IndexChestType
    end
    context.slot = itemSlot

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

    -- conquest PvP items can be catalysed for set bonus and upgraded, but they keep their appearance
    local isConquestPvpItem = self:IsConquestPvpItem(itemLink)
    tryInsert(debugLines, 'isConquestPvpItem: ' .. tostring(isConquestPvpItem))
    if isConquestPvpItem then
        result.canUpgrade = false
    end

    local isCatalysed = self:IsItemCatalysed(itemID)
    tryInsert(debugLines, 'isCatalysed: ' .. tostring(isCatalysed))
    result.canCatalyse = tokenInfo or (seasonID and not isCatalysed and not isConquestPvpItem and self:IsCatalystSlot(itemSlot) and self:IsValidArmorTypeForClass(itemLink, classID))
    if result.canCatalyse then
        local catalystCollected, catalystUpgradeCollected
        local playerSets = self:GetSetsForClass(classID, seasonID)
        if playerSets then
            catalystCollected = self:IsSetItemCollected(playerSets[currentTier], itemSlot)
            if result.canUpgrade then
                catalystUpgradeCollected = self:IsSetItemCollected(playerSets[currentTier + 1], itemSlot)
            end
        else
            catalystCollected = self:IsCatalystItemCollected(seasonID, classID, itemSlot, currentTier)
            if result.canUpgrade then
                catalystUpgradeCollected = self:IsCatalystItemCollected(seasonID, classID, itemSlot, currentTier + 1)
            end
        end
        if catalystCollected ~= nil then
            result.catalystAppearanceMissing = catalystCollected ~= true
            if catalystCollected == LEARNED_FROM_OTHER_ITEM then
                result.catalystAppearanceLearnedFromOtherItem = true
            end
        end
        if catalystUpgradeCollected ~= nil then
            result.catalystUpgradeAppearanceMissing = catalystUpgradeCollected ~= true
            if catalystUpgradeCollected == LEARNED_FROM_OTHER_ITEM then
                result.catalystUpgradeAppearanceLearnedFromOtherItem = true
            end
        end
    else
        tryInsert(debugLines, 'can\'t catalyse or catalyst keeps old appearance')
    end
    local upgradeCollected
    if isCatalysed and relatedSets and result.canUpgrade then
        local nextSetID = relatedSets[currentTier + 1]
        if nextSetID then
            upgradeCollected = self:IsSetItemCollected(nextSetID, itemSlot)
        end
    elseif result.canUpgrade then
        local sourceIDs = self:GetSourceIDsForItemID(itemID)
        if sourceIDs and sourceIDs[currentTier + 1] then
            upgradeCollected = self:IsSourceIDCollected(sourceIDs[currentTier + 1])
        end
    end
    if upgradeCollected ~= nil then
        result.upgradeAppearanceMissing = upgradeCollected ~= true
        if upgradeCollected == LEARNED_FROM_OTHER_ITEM then
            result.upgradeAppearanceLearnedFromOtherItem = true
        end
    end

    if self:IsCacheWarmedUp() then
        if result.canCatalyse then
            result.catalystAppearanceMissing = result.catalystAppearanceMissing or false
            if result.canUpgrade then
                result.catalystUpgradeAppearanceMissing = result.catalystUpgradeAppearanceMissing or false
            end
        end
        if result.canUpgrade then
            result.upgradeAppearanceMissing = result.upgradeAppearanceMissing or false
        end
    end

    return result
end

--- @param tooltip GameTooltip
--- @param tooltipData TooltipData
function TUM:HandleTooltip(tooltip, tooltipData)
    local itemLink = select(2, TooltipUtil.GetDisplayedItem(tooltip))
    if not itemLink then return end

    local debugLines = {}
    local result = self:IsAppearanceMissing(itemLink, nil, debugLines)

    for _, line in ipairs(debugLines) do
        self:AddDebugLine(tooltip, line)
    end

    local loadingTooltipShown = false
    if result.canCatalyse then
        if result.catalystAppearanceMissing == nil then
            if not loadingTooltipShown then loadingTooltipShown = self:ShowLoadingTooltipIfLoading(tooltip) end
        else
            self:AddTooltipLine(
                tooltip,
                CATALYST_MARKUP .. ' Catalyst appearance',
                not result.catalystAppearanceMissing,
                result.catalystAppearanceLearnedFromOtherItem
            )
        end
        if result.canUpgrade then
            if result.catalystUpgradeAppearanceMissing == nil then
                if not loadingTooltipShown then loadingTooltipShown = self:ShowLoadingTooltipIfLoading(tooltip) end
            else
                self:AddTooltipLine(
                    tooltip,
                    CATALYST_MARKUP .. ' Catalyst & ' .. UPGRADE_MARKUP .. ' Upgrade appearance',
                    not result.catalystUpgradeAppearanceMissing,
                    result.catalystUpgradeAppearanceLearnedFromOtherItem
                )
            end
        end
    end
    if result.canUpgrade then
        if result.upgradeAppearanceMissing == nil then
            if not loadingTooltipShown then loadingTooltipShown = self:ShowLoadingTooltipIfLoading(tooltip) end
        else
            self:AddTooltipLine(
                tooltip,
                UPGRADE_MARKUP .. ' Upgrade appearance',
                not result.upgradeAppearanceMissing,
                result.upgradeAppearanceLearnedFromOtherItem
            )
        end
    end

    if modifierFunctions[self.db.showWarbandCatalystInfoModifierKey]() and self:CanSendItemToAlt(itemLink, tooltipData) then
        local catalystClassList = {}
        local catalystUpgradeClassList = {}
        for classID = 1, GetNumClasses() do
            if classID ~= playerClassID and self.db.warbandCatalystClassList[classID] then
                local classResult = self:IsAppearanceMissing(itemLink, classID)
                if classResult.catalystAppearanceMissing then
                    table.insert(catalystClassList, classID)
                end
                if classResult.catalystUpgradeAppearanceMissing then
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

--- @param itemID number
--- @return nil|table<TUM_Tier, number>
function TUM:GetSourceIDsForItemID(itemID)
    return self.data.itemSourceIDs[itemID] or self.itemSourceIDs[itemID]
end

--- @param itemLink string
--- @param classID number # defaults to the player's class
--- @return boolean
function TUM:IsValidArmorTypeForClass(itemLink, classID)
    local invType, _, itemClassID, itemSubClassID = select(4, C_Item.GetItemInfoInstant(itemLink))

    return invType == "INVTYPE_CLOAK"
        or (itemClassID == Enum.ItemClass.Armor and itemSubClassID == self.data.constants.classArmorTypeMap[classID])
end

function TUM:IsCatalystSlot(slot)
    return self.data.constants.catalystSlots[slot] or false
end

function TUM:IsItemCatalysed(itemID)
    return not not self.catalystItemByID[itemID]
end

--- @param sourceID number
--- @return boolean|TUM_LearnedFromOtherItem
function TUM:IsSourceIDCollected(sourceID)
    local sourceInfo = C_TransmogCollection.GetSourceInfo(sourceID)
    if not sourceInfo then
        return false
    end
    if sourceInfo.isCollected then
        return true
    end
    local sourceIDs = C_TransmogCollection.GetAllAppearanceSources(sourceInfo.visualID);
    if sourceIDs and #sourceIDs > 0 then
        for _, id in ipairs(sourceIDs) do
            local info = C_TransmogCollection.GetSourceInfo(id)
            if info and info.isCollected then
                return LEARNED_FROM_OTHER_ITEM
            end
        end
    end

    return false
end

--- @param seasonID number
--- @param slot Enum.InventoryType
--- @param tier TUM_Tier
--- @return boolean|nil|TUM_LearnedFromOtherItem
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

    return self:IsSourceIDCollected(sourceIDs[tier])
end

--- @param transmogSetID number
--- @param slot number # Enum.InventoryType
--- @return boolean|nil|TUM_LearnedFromOtherItem
function TUM:IsSetItemCollected(transmogSetID, slot)
    if self.setSourceIDs[transmogSetID] then
        local sourceID = self.setSourceIDs[transmogSetID][slot]

        return sourceID and self:IsSourceIDCollected(sourceID) or false
    end

    local sources = C_TransmogSets.GetSourcesForSlot(transmogSetID, slot)
    local fromOtherItem = false
    for _, slotSourceInfo in ipairs(sources) do
        if slotSourceInfo.isCollected then
            return true
        elseif self:IsSourceIDCollected(slotSourceInfo.sourceID) == LEARNED_FROM_OTHER_ITEM then
            fromOtherItem = true
        end
    end

    return fromOtherItem and LEARNED_FROM_OTHER_ITEM or false
end

function TUM:HandleCatalystInteraction()
    local isConversion = ItemInteractionFrame:GetInteractionType() == Enum.UIItemInteractionType.ItemConversion
    local isFree = not ItemInteractionFrame:UsesCharges() and not ItemInteractionFrame:CostsCurrency()
    if not isConversion then return end

    local setting = self.db.autoConfirmCatalyst
    if
        setting == self.Config.autoConfirmCatalystOptions.always
        or (setting == self.Config.autoConfirmCatalystOptions.previousSeason and isFree)
    then
        ItemInteractionFrame:CompleteItemInteraction()
    end
end

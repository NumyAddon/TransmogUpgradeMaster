local name = ...

--- @class TransmogUpgradeMaster
local TUM = {}
TransmogUpgradeMaster = TUM

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

-- hardcoded data
do
    --- could potentially be extracted from C_TransmogSets.GetAllSets() more or less, but meh, effort, and requires linking to a specific season still anyway
    --- @type table<number, table<number, {[1]:number, [2]:number, [3]:number, [4]:number}>> [m+ seasonID][classID] = { [1] = lfrSetID, [2] = normalSetID, [3] = heroicSetID, [4] = mythicSetID }
    TUM.sets = {
        -- TWW S2
        [14] = {
            [1] = { 4326, 4325, 4323, 4324 }, -- Warrior
            [2] = { 4306, 4305, 4303, 4304 }, -- Paladin
            [3] = { 4294, 4293, 4291, 4292 }, -- Hunter
            [4] = { 4314, 4313, 4311, 4312 }, -- Rogue
            [5] = { 4310, 4309, 4307, 4308 }, -- Priest
            [6] = { 4278, 4277, 4275, 4276 }, -- Death Knight
            [7] = { 4318, 4317, 4315, 4316 }, -- Shaman
            [8] = { 4298, 4297, 4295, 4296 }, -- Mage
            [9] = { 4322, 4321, 4319, 4320 }, -- Warlock
            [10] = { 4302, 4301, 4299, 4300 }, -- Monk
            [11] = { 4286, 4285, 4283, 4284 }, -- Druid
            [12] = { 4282, 4281, 4279, 4280 }, -- Demon Hunter
            [13] = { 4290, 4289, 4287, 4288 }, -- Evoker
        },
    }
    --- C_TransmogSets.GetSourceIDsForSlot and C_TransmogSets.GetSourcesForSlot miss information for certain slots, very "fun" -.-
    --- @type table<number, table<number, number>> # [setID] = { [Enum.InventoryType.Foo] = sourceID }
    TUM.setSourceIDs = {
        -- TWW S2
        [4326] = { [1] = 225238, [3] = 225214, [5] = 225274, [6] = 225202, [7] = 225226, [8] = 225262, [9] = 225190, [10] = 225250, [16] = 225178 }, -- Warrior
        [4325] = { [1] = 225233, [3] = 225209, [5] = 225269, [6] = 225197, [7] = 225221, [8] = 225257, [9] = 225185, [10] = 225245, [16] = 225173 }, -- Warrior
        [4323] = { [1] = 225239, [3] = 225215, [5] = 225275, [6] = 225203, [7] = 225227, [8] = 225263, [9] = 225191, [10] = 225251, [16] = 225179 }, -- Warrior
        [4324] = { [1] = 225240, [3] = 225216, [5] = 225276, [6] = 225204, [7] = 225228, [8] = 225264, [9] = 225192, [10] = 225252, [16] = 225180 }, -- Warrior
        [4306] = { [1] = 225346, [3] = 225322, [5] = 225382, [6] = 225310, [7] = 225334, [8] = 225370, [9] = 225298, [10] = 225358, [16] = 225286 }, -- Paladin
        [4305] = { [1] = 225341, [3] = 225317, [5] = 225377, [6] = 225305, [7] = 225329, [8] = 225365, [9] = 225293, [10] = 225353, [16] = 225281 }, -- Paladin
        [4303] = { [1] = 225347, [3] = 225323, [5] = 225383, [6] = 225311, [7] = 225335, [8] = 225371, [9] = 225299, [10] = 225359, [16] = 225287 }, -- Paladin
        [4304] = { [1] = 225348, [3] = 225324, [5] = 225384, [6] = 225312, [7] = 225336, [8] = 225372, [9] = 225300, [10] = 225360, [16] = 225288 }, -- Paladin
        [4294] = { [1] = 225658, [3] = 225634, [5] = 225694, [6] = 225622, [7] = 225646, [8] = 225682, [9] = 225610, [10] = 225670, [16] = 225598 }, -- Hunter
        [4293] = { [1] = 225653, [3] = 225629, [5] = 225689, [6] = 225617, [7] = 225641, [8] = 225677, [9] = 225605, [10] = 225665, [16] = 225593 }, -- Hunter
        [4291] = { [1] = 225659, [3] = 225635, [5] = 225695, [6] = 225623, [7] = 225647, [8] = 225683, [9] = 225611, [10] = 225671, [16] = 225599 }, -- Hunter
        [4292] = { [1] = 225660, [3] = 225636, [5] = 225696, [6] = 225624, [7] = 225648, [8] = 225684, [9] = 225612, [10] = 225672, [16] = 225600 }, -- Hunter
        [4314] = { [1] = 225874, [3] = 225850, [5] = 225910, [6] = 225838, [7] = 225862, [8] = 225898, [9] = 225826, [10] = 225886, [16] = 225814 }, -- Rogue
        [4313] = { [1] = 225869, [3] = 225845, [5] = 225905, [6] = 224939, [7] = 225857, [8] = 225893, [9] = 225821, [10] = 225881, [16] = 225809 }, -- Rogue
        [4311] = { [1] = 225875, [3] = 225851, [5] = 225911, [6] = 225839, [7] = 225863, [8] = 225899, [9] = 225827, [10] = 225887, [16] = 225815 }, -- Rogue
        [4312] = { [1] = 225876, [3] = 225852, [5] = 225912, [6] = 225840, [7] = 225864, [8] = 225900, [9] = 225828, [10] = 225888, [16] = 225816 }, -- Rogue
        [4310] = { [1] = 226414, [3] = 226390, [5] = 226450, [6] = 226378, [7] = 226402, [8] = 226438, [9] = 226366, [10] = 226426, [16] = 226354 }, -- Priest
        [4309] = { [1] = 226409, [3] = 226385, [5] = 226445, [6] = 226373, [7] = 226397, [8] = 226433, [9] = 226361, [10] = 226421, [16] = 226349 }, -- Priest
        [4307] = { [1] = 226415, [3] = 226391, [5] = 226451, [6] = 226379, [7] = 226403, [8] = 226439, [9] = 226367, [10] = 226427, [16] = 226355 }, -- Priest
        [4308] = { [1] = 226416, [3] = 226392, [5] = 231638, [6] = 226380, [7] = 226404, [8] = 226440, [9] = 226368, [10] = 226428, [16] = 226356 }, -- Priest
        [4278] = { [1] = 225454, [3] = 225430, [5] = 225490, [6] = 225418, [7] = 225442, [8] = 225478, [9] = 225406, [10] = 225466, [16] = 225394 }, -- Death Knight
        [4277] = { [1] = 225449, [3] = 225425, [5] = 225485, [6] = 225413, [7] = 225437, [8] = 225473, [9] = 225401, [10] = 225461, [16] = 225389 }, -- Death Knight
        [4275] = { [1] = 225455, [3] = 225431, [5] = 225491, [6] = 225419, [7] = 225443, [8] = 225479, [9] = 225407, [10] = 225467, [16] = 225395 }, -- Death Knight
        [4276] = { [1] = 225456, [3] = 225432, [5] = 225492, [6] = 225420, [7] = 225444, [8] = 225480, [9] = 225408, [10] = 225468, [16] = 225396 }, -- Death Knight
        [4318] = { [1] = 225556, [3] = 225538, [5] = 225589, [6] = 225526, [7] = 225547, [8] = 225580, [9] = 225514, [10] = 225568, [16] = 225502 }, -- Shaman
        [4317] = { [1] = 225551, [3] = 225533, [5] = 225590, [6] = 225521, [7] = 225548, [8] = 225575, [9] = 225509, [10] = 225563, [16] = 225497 }, -- Shaman
        [4315] = { [1] = 225557, [3] = 225539, [5] = 225591, [6] = 225527, [7] = 225549, [8] = 225581, [9] = 225515, [10] = 225569, [16] = 225503 }, -- Shaman
        [4316] = { [1] = 225558, [3] = 225540, [5] = 225592, [6] = 225528, [7] = 225550, [8] = 225582, [9] = 225516, [10] = 225570, [16] = 225504 }, -- Shaman
        [4298] = { [1] = 226520, [3] = 226496, [5] = 226556, [6] = 226484, [7] = 226508, [8] = 226544, [9] = 226472, [10] = 226532, [16] = 226460 }, -- Mage
        [4297] = { [1] = 226515, [3] = 226491, [5] = 226551, [6] = 226479, [7] = 226503, [8] = 226539, [9] = 226467, [10] = 226527, [16] = 226455 }, -- Mage
        [4295] = { [1] = 226521, [3] = 226497, [5] = 226557, [6] = 226485, [7] = 226509, [8] = 226545, [9] = 226473, [10] = 226533, [16] = 226461 }, -- Mage
        [4296] = { [1] = 226522, [3] = 226498, [5] = 226558, [6] = 226486, [7] = 226510, [8] = 226546, [9] = 226474, [10] = 226534, [16] = 226462 }, -- Mage
        [4322] = { [1] = 226306, [3] = 226282, [5] = 226342, [6] = 226270, [7] = 226294, [8] = 226330, [9] = 226258, [10] = 226318, [16] = 226246 }, -- Warlock
        [4321] = { [1] = 226301, [3] = 226277, [5] = 226337, [6] = 226265, [7] = 226289, [8] = 226325, [9] = 226253, [10] = 226313, [16] = 226241 }, -- Warlock
        [4319] = { [1] = 226307, [3] = 226283, [5] = 226343, [6] = 226271, [7] = 226295, [8] = 226331, [9] = 226259, [10] = 226319, [16] = 226247 }, -- Warlock
        [4320] = { [1] = 226308, [3] = 226284, [5] = 226344, [6] = 226272, [7] = 226296, [8] = 226332, [9] = 226260, [10] = 226320, [16] = 226248 }, -- Warlock
        [4302] = { [1] = 225982, [3] = 225958, [5] = 226018, [6] = 225946, [7] = 225970, [8] = 226006, [9] = 225934, [10] = 225994, [16] = 225922 }, -- Monk
        [4301] = { [1] = 225977, [3] = 225953, [5] = 226013, [6] = 225941, [7] = 225965, [8] = 226001, [9] = 225929, [10] = 225989, [16] = 225917 }, -- Monk
        [4299] = { [1] = 225983, [3] = 225959, [5] = 226019, [6] = 225947, [7] = 225971, [8] = 226007, [9] = 225935, [10] = 225995, [16] = 225923 }, -- Monk
        [4300] = { [1] = 225984, [3] = 225960, [5] = 226020, [6] = 225948, [7] = 225972, [8] = 226008, [9] = 225936, [10] = 225996, [16] = 225924 }, -- Monk
        [4286] = { [1] = 226090, [3] = 226066, [5] = 226126, [6] = 226054, [7] = 226078, [8] = 226114, [9] = 226042, [10] = 226102, [16] = 226030 }, -- Druid
        [4285] = { [1] = 226085, [3] = 226061, [5] = 226121, [6] = 226049, [7] = 226073, [8] = 226109, [9] = 226037, [10] = 226097, [16] = 226025 }, -- Druid
        [4283] = { [1] = 226091, [3] = 226067, [5] = 226127, [6] = 226055, [7] = 226079, [8] = 226115, [9] = 226043, [10] = 226103, [16] = 226031 }, -- Druid
        [4284] = { [1] = 226092, [3] = 226068, [5] = 226128, [6] = 226056, [7] = 226080, [8] = 226116, [9] = 226044, [10] = 226104, [16] = 226032 }, -- Druid
        [4282] = { [1] = 226198, [3] = 226174, [5] = 226234, [6] = 226162, [7] = 226186, [8] = 226222, [9] = 226150, [10] = 226210, [16] = 226138 }, -- Demon Hunter
        [4281] = { [1] = 226193, [3] = 226169, [5] = 226229, [6] = 226157, [7] = 226181, [8] = 226217, [9] = 226145, [10] = 226205, [16] = 226133 }, -- Demon Hunter
        [4279] = { [1] = 226199, [3] = 226175, [5] = 226235, [6] = 226163, [7] = 226187, [8] = 226223, [9] = 226151, [10] = 226211, [16] = 226139 }, -- Demon Hunter
        [4280] = { [1] = 226200, [3] = 226176, [5] = 226236, [6] = 226164, [7] = 226188, [8] = 226224, [9] = 226152, [10] = 226212, [16] = 226140 }, -- Demon Hunter
        [4290] = { [1] = 225766, [3] = 225742, [5] = 225802, [6] = 225730, [7] = 225754, [8] = 225790, [9] = 225718, [10] = 225778, [16] = 225706 }, -- Evoker
        [4289] = { [1] = 225761, [3] = 225737, [5] = 225797, [6] = 225725, [7] = 225749, [8] = 225785, [9] = 225713, [10] = 225773, [16] = 225701 }, -- Evoker
        [4287] = { [1] = 225767, [3] = 225743, [5] = 225803, [6] = 225731, [7] = 225755, [8] = 225791, [9] = 225719, [10] = 225779, [16] = 225707 }, -- Evoker
        [4288] = { [1] = 225768, [3] = 225744, [5] = 225804, [6] = 225732, [7] = 225756, [8] = 225792, [9] = 225720, [10] = 225780, [16] = 225708 }, -- Evoker
    }
end

EventUtil.ContinueOnAddOnLoaded(name, function()
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

function TUM:AddTooltipLine(tooltip, text, isCollected)
    local ok = OK_MARKUP .. GREEN_FONT_COLOR:WrapTextInColorCode(' Collected ') .. OK_MARKUP
    local nok = NOK_MARKUP .. RED_FONT_COLOR:WrapTextInColorCode(' Not Collected ') .. NOK_MARKUP
    tooltip:AddDoubleLine(text, isCollected and ok or nok)
end

--- @param tooltip GameTooltip
function TUM:HandleTooltip(tooltip)
    local itemLink = select(2, TooltipUtil.GetDisplayedItem(tooltip))
    if not itemLink then return end

    local itemID = tonumber(itemLink:match("item:(%d+)"))
    if not itemID or not C_Item.IsDressableItemByID(itemID) then return end

    local upgradeInfo = C_Item.GetItemUpgradeInfo(itemLink)
    if not upgradeInfo or not self:IsCurrentSeasonItem(itemLink) then return end

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

    local itemSlot = C_Item.GetItemInventoryTypeByID(itemLink)
    if itemSlot == Enum.InventoryType.IndexRobeType then
        -- robes catalyse into chest pieces
        itemSlot = Enum.InventoryType.IndexChestType
    end

    local _, sourceID = C_TransmogCollection.GetItemInfo(itemID)

    local setIDs = sourceID and C_TransmogSets.GetSetsContainingSourceID(sourceID)
    local relatedSets
    local setClassID
    if setIDs and #setIDs > 0 then
        for _, setID in ipairs(setIDs) do
            local setInfo = C_TransmogSets.GetSetInfo(setID)

            local classIDList = self:ConvertClassMaskToClassList(setInfo.classMask)

            local classSets = self:GetSetsForClass(classIDList[1])
            if classSets and tIndexOf(classSets, setID) then
                relatedSets = classSets
                setClassID = classIDList[1]
            end
        end
    end

    local canCatalyse = self:IsCatalystSlot(itemSlot) and self:IsValidArmorTypeForPlayer(itemLink)
    if canCatalyse and setClassID ~= playerClassID then
        local playerSets = self:GetSetsForClass(playerClassID)
        if playerSets then
            local currentIsCollected = self:IsSetItemCollected(playerSets[currentTier], itemSlot)
            self:AddTooltipLine(tooltip, CATALYST_MARKUP .. " Catalyst appearance", currentIsCollected)
            if canUpgradeToNextBreakpoint then
                local nextIsCollected = self:IsSetItemCollected(playerSets[currentTier + 1], itemSlot)
                self:AddTooltipLine(tooltip, CATALYST_MARKUP .. " Catalyst & " .. UPGRADE_MARKUP .. " Upgrade appearance", nextIsCollected)
            end
        else
            -- todo: add a 1-time error message that set info for current season+class couldn't be found
        end
    end
    if canCatalyse and relatedSets and canUpgradeToNextBreakpoint then
        local nextSetID = relatedSets[currentTier + 1]
        if nextSetID then
            local isCollected = self:IsSetItemCollected(nextSetID, itemSlot)
            self:AddTooltipLine(tooltip, UPGRADE_MARKUP .. " Upgrade appearance", isCollected)
        end
    elseif canUpgradeToNextBreakpoint then
        local sourceIDs = self:GetSourceIDsForItemID(itemID)
        if sourceIDs then
            if sourceIDs[currentTier + 1] then
                local nextSourceInfo = C_TransmogCollection.GetSourceInfo(sourceIDs[currentTier + 1])
                local isCollected = nextSourceInfo and nextSourceInfo.isCollected
                self:AddTooltipLine(tooltip, UPGRADE_MARKUP .. " Upgrade appearance", isCollected)
            end
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

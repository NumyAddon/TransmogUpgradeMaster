local addonName, ns = ...;

--- @type TransmogUpgradeMaster
local TUM = ns.core;

local isSyndicatorLoaded = C_AddOns.IsAddOnLoaded('Syndicator');

local SEASON_NAMES = {
    [8] = 'SL S4',
    [9] = 'DF S1',
    [10] = 'DF S2',
    [11] = 'DF S3',
    [12] = 'DF S4',
    [13] = 'TWW S1',
    [14] = 'TWW S2',
    [15] = 'TWW S3',
};
local CATALYST_MARKUP = CreateAtlasMarkup('CreationCatalyst-32x32', 18, 18)
local UPGRADE_MARKUP = CreateAtlasMarkup('CovenantSanctum-Upgrade-Icon-Available', 18, 18)
local WARBAND_MARKUP = CreateAtlasMarkup('warbands-icon', 18, 18)
local OK_MARKUP = "|TInterface\\RaidFrame\\ReadyCheck-Ready:0|t"
local NOK_MARKUP = "|TInterface\\RaidFrame\\ReadyCheck-NotReady:0|t"
local OTHER_MARKUP = CreateAtlasMarkup('QuestRepeatableTurnin', 14, 16)

local playerClassFile, playerClassID = select(2, UnitClass('player'));
local playerFullName;

--- @class TransmogUpgradeMaster_CollectionUI: Frame, ButtonFrameTemplate
local UI = CreateFrame('Frame', 'TransmogUpgradeMaster_CollectionUI', UIParent, 'ButtonFrameTemplate');
ns.UI = UI;

function UI:Init()
    playerFullName = UnitNameUnmodified('player') .. '-' .. GetRealmName();

    self.selectedClass = playerClassID;
    self.selectedSeason = TUM.currentSeason;
    self.currentCurrencyID = 0; -- will be set later when the season is initialized

    --- @type nil|table<Enum.InventoryType, table<TUM_Tier, TUM_UI_ResultData[]>>
    self.results = nil;
    self:BuildUI();
    self:RegisterIntoBlizzMove();
end

function UI:InitSeason(currentSeasonID)
    self.selectedSeason = currentSeasonID;
    for seasonID, _ in pairs(SEASON_NAMES) do
        if seasonID > UI.selectedSeason then
            SEASON_NAMES[seasonID] = nil;
        end
    end

    self.currentCurrencyID = TUM.data.currency[currentSeasonID] or 0;
    self.Currency:UpdateText();
end

function UI:BuildUI()
    do
        self:SetPoint('CENTER');
        self:SetSize(790, 345);
        self:SetFrameStrata('MEDIUM');
        self:SetToplevel(true);
        self:SetMovable(true);
        self:EnableMouse(true);
        self:SetClampedToScreen(true);
        self:SetTitle('Transmog Upgrade Master  ' .. WHITE_FONT_COLOR:WrapTextInColorCode('Collections'));

        self:SetScript('OnShow', self.UpdateItems);
        self:SetScript('OnUpdate', self.OnUpdate);

        ButtonFrameTemplate_HidePortrait(self)
        table.insert(UISpecialFrames, self:GetName());

        self:Hide();
    end

    local titleBar = CreateFrame('Frame', nil, self, 'PanelDragBarTemplate');
    self.TitleBar = titleBar;
    do
        titleBar:SetPoint('TOPLEFT', 0, 0);
        titleBar:SetPoint('BOTTOMRIGHT', self, 'TOPRIGHT', 0, -32);
    end

    local settings = CreateFrame('DropdownButton', nil, self);
    self.Settings = settings;
    do
        settings:SetFrameStrata('HIGH');
        settings:SetPoint('RIGHT', self.TitleBar, 'RIGHT', -20, 3);
        settings:SetSize(32, 32);
        do -- icon
            settings.atlasKey = 'GM-icon-settings';
            settings:SetNormalAtlas(settings.atlasKey);
            Mixin(settings, ButtonStateBehaviorMixin);
            function settings:OnButtonStateChanged()
                local atlas = self.atlasKey;
                if self:IsDownOver() or self:IsOver() then
                    atlas = atlas .. '-hover';
                elseif self:IsDown() then
                    atlas = atlas .. '-pressed';
                end

                self:GetNormalTexture():SetAtlas(atlas, TextureKitConstants.IgnoreAtlasSize);
            end

            settings:OnLoad();
            settings:HookScript('OnEnter', settings.OnEnter);
            settings:HookScript('OnLeave', settings.OnLeave);
            settings:HookScript('OnMouseDown', settings.OnMouseDown);
            settings:HookScript('OnMouseUp', settings.OnMouseUp);
        end

        settings:HookScript('OnEnter', function()
            GameTooltip:SetOwner(settings, 'ANCHOR_TOPRIGHT');
            GameTooltip:SetText('Settings');
            GameTooltip_AddInstructionLine(GameTooltip, CreateAtlasMarkup('NPE_LeftClick', 18, 18) .. ' to open settings');
            GameTooltip:Show();
        end);
        settings:HookScript('OnLeave', function()
            GameTooltip:Hide();
        end);
        --- @param rootDescription RootMenuDescriptionProxy
        settings:SetupMenu(function(_, rootDescription)
            rootDescription:CreateButton(CreateAtlasMarkup('GM-icon-settings', 20, 20) .. ' Open General TUM Settings', function() TUM.Config:OpenSettings(); end);
            rootDescription:CreateTitle('Collection UI Settings');
            rootDescription:CreateCheckbox(
                'Treat "From Another Item" as collected',
                function()
                    return TUM.db.UI_treatOtherItemAsCollected;
                end,
                function()
                    TUM.db.UI_treatOtherItemAsCollected = not TUM.db.UI_treatOtherItemAsCollected;
                    UI.deferNewResult = true;
                end
            );
        end);
    end

    local classDropdown = CreateFrame('DropdownButton', nil, self, 'WowStyle1DropdownTemplate');
    self.classDropdown = classDropdown;
    do
        classDropdown:SetPoint('TOPRIGHT', self, 'TOPRIGHT', -11, -32);
        classDropdown:SetWidth(150);
        classDropdown:EnableMouseWheel(true);
        local numClasses = GetNumClasses();
        function classDropdown:Increment()
            local nextClass = UI.selectedClass + 1;
            if nextClass > numClasses then
                nextClass = 1;
            end
            self:PickClass(nextClass);
        end

        function classDropdown:Decrement()
            local prevClass = UI.selectedClass - 1;
            if prevClass < 1 then
                prevClass = numClasses;
            end
            self:PickClass(prevClass);
        end

        function classDropdown:PickClass(classID)
            MenuUtil.TraverseMenu(self:GetMenuDescription(), function(description)
                if description.data == classID then
                    self:Pick(description, MenuInputContext.None);
                end
            end);
        end

        local function isSelected(classID)
            return classID == UI.selectedClass;
        end
        local function setSelected(classID)
            UI.selectedClass = classID;
            UI:DeferUpdateItems();
        end
        local nameFormat = '|Tinterface/icons/classicon_%s:16|t %s';
        --- @param rootDescription RootMenuDescriptionProxy
        classDropdown:SetupMenu(function(_, rootDescription)
            for classID = 1, numClasses do
                local classInfo = C_CreatureInfo.GetClassInfo(classID);
                if classInfo then
                    rootDescription:CreateRadio(
                        nameFormat:format(classInfo.classFile, classInfo.className),
                        isSelected,
                        setSelected,
                        classID
                    )
                end
            end
        end);
        classDropdown:PickClass(UI.selectedClass);
    end

    local seasonDropdown = CreateFrame('DropdownButton', nil, self, 'WowStyle1DropdownTemplate');
    self.seasonDropdown = seasonDropdown;
    do
        seasonDropdown:SetPoint('RIGHT', classDropdown, 'LEFT', -10, 0);
        seasonDropdown:SetWidth(100);
        seasonDropdown:EnableMouseWheel(true);

        function seasonDropdown:PickSeason(seasonID)
            MenuUtil.TraverseMenu(self:GetMenuDescription(), function(description)
                if description.data == seasonID then
                    self:Pick(description, MenuInputContext.None);
                end
            end);
        end

        local function isSelected(seasonID)
            return seasonID == UI.selectedSeason;
        end
        local function setSelected(seasonID)
            UI.selectedSeason = seasonID;
            UI:DeferUpdateItems();
        end
        local orderedSeasonIDs = {};
        for seasonID, _ in pairs(SEASON_NAMES) do
            table.insert(orderedSeasonIDs, seasonID);
        end
        table.sort(orderedSeasonIDs);
        --- @param rootDescription RootMenuDescriptionProxy
        seasonDropdown:SetupMenu(function(_, rootDescription)
            for _, seasonID in ipairs(orderedSeasonIDs) do
                rootDescription:CreateRadio(
                    SEASON_NAMES[seasonID],
                    isSelected,
                    setSelected,
                    seasonID
                );
            end
        end);
        seasonDropdown:PickSeason(UI.selectedSeason);
    end

    local updateButton = CreateFrame('Button', nil, self);
    self.UpdateButton = updateButton;
    do
        updateButton:SetPoint('RIGHT', self.seasonDropdown, 'LEFT', -6, 0);
        updateButton:SetSize(32, 32);
        updateButton:SetHitRectInsets(4, 4, 4, 4);
        updateButton:SetNormalTexture('Interface\\Buttons\\UI-SquareButton-Up');
        updateButton:SetPushedTexture('Interface\\Buttons\\UI-SquareButton-Down');
        updateButton:SetDisabledTexture('Interface\\Buttons\\UI-SquareButton-Disabled');
        updateButton:SetHighlightTexture('Interface\\Buttons\\UI-Common-MouseHilight', 'ADD');

        local updateIcon = updateButton:CreateTexture('OVERLAY');
        updateButton.Icon = updateIcon;
        do
            updateIcon:SetSize(16, 16);
            updateIcon:SetPoint('CENTER', -1, -1);
            updateIcon:SetBlendMode('ADD');
            updateIcon:SetTexture('Interface\\Buttons\\UI-RefreshButton');

            updateButton:SetScript('OnEnter', function(self)
                GameTooltip:SetOwner(self, 'ANCHOR_RIGHT', -6, -4);
                GameTooltip:AddLine('Refresh');
                GameTooltip:Show();
            end);

            updateButton:SetScript('OnLeave', function()
                GameTooltip:Hide();
            end);

            updateButton:SetScript('OnMouseDown', function(self)
                if self:IsEnabled() then
                    self.Icon:SetPoint('CENTER', 1, 1);
                end
            end);

            updateButton:SetScript('OnMouseUp', function(self)
                if self:IsEnabled() then
                    self.Icon:SetPoint('CENTER', -1, -1);
                end
            end);

            updateButton:SetScript('OnClick', function()
                UI:DeferUpdateItems();
            end);

            updateButton:SetScript('OnShow', function(self)
                self.Icon:SetPoint('CENTER', -1, -1);
            end);
        end
    end

    do
        local ROW_HEIGHT = 25;
        local COLUMN_WIDTH = 175;

        self.Inset:SetPoint('TOPLEFT', 8, -86);
        self.Inset:SetPoint('BOTTOMRIGHT', -4, 30);
        local COLUMN_INFO = {
            {
                title = 'Slot',
                width = 80,
                parentKey = 'Slot',
            },
            {
                title = PLAYER_DIFFICULTY3, -- LFR
                width = COLUMN_WIDTH,
                parentKey = 'Lfr',
                tier = TUM.data.constants.tiers.lfr,
            },
            {
                title = PLAYER_DIFFICULTY1, -- Normal
                width = COLUMN_WIDTH,
                parentKey = 'Normal',
                tier = TUM.data.constants.tiers.normal,
            },
            {
                title = PLAYER_DIFFICULTY2, -- Heroic
                width = COLUMN_WIDTH,
                parentKey = 'Heroic',
                tier = TUM.data.constants.tiers.heroic,
            },
            {
                title = PLAYER_DIFFICULTY6, -- Mythic
                width = COLUMN_WIDTH,
                parentKey = 'Mythic',
                tier = TUM.data.constants.tiers.mythic,
            },
        };
        local SLOT_ORDER = {
            Enum.InventoryType.IndexHeadType,
            Enum.InventoryType.IndexShoulderType,
            Enum.InventoryType.IndexCloakType,
            Enum.InventoryType.IndexChestType,
            Enum.InventoryType.IndexWristType,
            Enum.InventoryType.IndexHandType,
            Enum.InventoryType.IndexWaistType,
            Enum.InventoryType.IndexLegsType,
            Enum.InventoryType.IndexFeetType,
        };

        local headers = CreateFrame('Frame', '$parentHeaders', self, 'ColumnDisplayTemplate');
        self.Headers = headers;
        do
            headers:SetPoint('BOTTOMLEFT', self.Inset, 'TOPLEFT', 1, -1);
            headers:SetPoint('BOTTOMRIGHT', self.Inset, 'TOPRIGHT', 0, -1);
            headers:LayoutColumns(COLUMN_INFO);
            headers:SetHeight(1);
            headers.Background:Hide();
            headers.TopTileStreaks:Hide();

            local magnifyingGlassAtlas = 'common-search-magnifyingglass'

            --- @type FramePool<BUTTON, ColumnDisplayButtonTemplate>
            local headerPool = headers.columnHeaders
            for header in headerPool:EnumerateActive() do
                --- @type ColumnDisplayButtonTemplate
                local header = header;
                local index = header:GetID();
                if index > 1 then
                    local text = header:GetFontString();
                    --- @class TUM_UI_ColumnHeader_InspectButton: Button, InsecureActionButtonTemplate
                    local inspectButton = CreateFrame('Button', nil, header, 'InsecureActionButtonTemplate');
                    header.InspectButton = inspectButton;
                    do
                        inspectButton:SetPoint('LEFT', text, 'RIGHT', 5, 0);
                        inspectButton:SetSize(14, 14);
                        inspectButton:SetNormalTexture(magnifyingGlassAtlas);
                        inspectButton:SetAttribute('type', 'macro');
                        inspectButton:SetAttribute('useOnKeyDown ', true);
                        inspectButton:RegisterForClicks('AnyDown');
                        inspectButton:SetScript('OnEnter', function()
                            GameTooltip:SetOwner(inspectButton, 'ANCHOR_CURSOR_RIGHT');
                            GameTooltip:AddLine('View set in Dressing Room');
                            if InCombatLockdown() then
                                GameTooltip_AddErrorLine(GameTooltip, 'You cannot open the Dressing Room while in combat');
                            end
                            if UI.selectedClass == 13 and UI.selectedSeason == 8 then
                                GameTooltip_AddErrorLine(GameTooltip, 'Evokers have no SL S4 set');
                            end
                            GameTooltip:Show();
                        end);
                        inspectButton:SetScript('OnLeave', function()
                            GameTooltip:Hide();
                        end);
                        inspectButton:SetScript('PreClick', function()
                            if InCombatLockdown() then
                                return;
                            end
                            if UI.selectedClass == 13 and UI.selectedSeason == 8 then
                                inspectButton:SetAttribute('macrotext', '');
                                return;
                            end
                            local tier = COLUMN_INFO[index].tier;
                            inspectButton:SetAttribute('macrotext', UI:CreateOutfitSlashCommand(tier));
                        end);
                    end
                end
            end
        end

        --- @type TUM_UI_Row[]
        self.rows = {};
        --- @param column TUM_UI_Column
        local function OnEnter(column)
            if column.isCollected == true then return; end
            GameTooltip:SetOwner(column, 'ANCHOR_CURSOR_RIGHT');
            GameTooltip:AddLine('Transmog Upgrade Master');
            if column.results and next(column.results) then
                for _, result in ipairs(column.results) do
                    local text = result.itemLink;

                    if result.requiresUpgrade then
                        text = UPGRADE_MARKUP .. ' ' .. text;
                    end
                    if result.requiresCatalyse then
                        text = CATALYST_MARKUP .. ' ' .. text;
                    end
                    if result.distance > 0 then
                        text = WARBAND_MARKUP .. ' ' .. text;
                    end
                    GameTooltip:AddDoubleLine(text, result.location, 1, 1, 1, 1, 1, 1);
                end
            else
                GameTooltip:AddLine('No items found that can be catalysed or upgraded', 1, 0.5, 0.5);
                if not isSyndicatorLoaded then
                    GameTooltip_AddInstructionLine(GameTooltip, 'Install the addon "Syndicator" to scan items from your bank and alts');
                end
            end
            GameTooltip:Show();
        end
        local function OnLeave()
            GameTooltip:Hide();
        end

        for i, slot in ipairs(SLOT_ORDER) do
            --- @class TUM_UI_Row: Button
            local row = CreateFrame('Button', '$parentRow' .. i, self);
            self.rows[i] = row;

            row.slot = slot;
            row:SetPoint('TOPLEFT', headers, 'BOTTOMLEFT', 5, -((i - 1) * ROW_HEIGHT));
            row:SetPoint('TOPRIGHT', headers, 'BOTTOMRIGHT', -5, -((i - 1) * ROW_HEIGHT));
            row:SetHeight(ROW_HEIGHT);
            row:SetHighlightTexture('Interface\\BUTTONS\\WHITE8X8')
            row:GetHighlightTexture():SetVertexColor(0.1, 0.1, 0.1, 0.75)

            --- @type TUM_UI_Column[]
            row.columns = {};
            local offset = 2;
            local padding = 2;

            for j, columnInfo in ipairs(COLUMN_INFO) do
                --- @class TUM_UI_Column: Frame
                local column = CreateFrame('Frame', '$parentColumn' .. columnInfo.parentKey, row);
                row.columns[columnInfo.parentKey] = column;
                column:SetSize(columnInfo.width - (padding * 1.25), ROW_HEIGHT);
                column.tier = columnInfo.tier;
                column.slot = slot;
                --- @type nil|TUM_UI_ResultData[]
                column.results = nil; -- will be filled later when results are available
                --- @type boolean|'learnedFromOtherItem'|nil
                column.isCollected = nil;

                if j ~= 1 then
                    column:SetScript('OnEnter', OnEnter)
                    column:SetScript('OnLeave', OnLeave);
                    column:SetPropagateMouseMotion(true);
                end

                column:SetPoint('LEFT', row, 'LEFT', offset, 0);
                offset = offset + columnInfo.width - padding;

                local colText = column:CreateFontString('$parentText', 'OVERLAY', 'GameFontNormal');
                column.Text = colText;
                colText:SetPoint('LEFT', column, 'LEFT', 0, 0);
                local text = j == 1 and C_Item.GetItemInventorySlotInfo(slot) or 'loading...';
                colText:SetText(text);
            end
        end
    end

    if not isSyndicatorLoaded then
        local syndicatorMessage = UI:CreateFontString(nil, 'OVERLAY', 'GameFontNormal');
        self.syndicatorMessage = syndicatorMessage;
        do
            syndicatorMessage:SetPoint('TOPLEFT', self, 'TOPLEFT', 12, -30);
            syndicatorMessage:SetText('Items from the bank or from alts can only be scanned if you have the addon "Syndicator" enabled.');
            syndicatorMessage:SetJustifyH('LEFT');
            syndicatorMessage:SetWidth(350);
        end
    end

    local currency = CreateFrame('Frame', nil, self);
    self.Currency = currency;
    do
        currency:SetPoint('BOTTOMLEFT', self, 'BOTTOMLEFT', 15, 5);
        currency:SetSize(200, 20);
        currency:RegisterEvent('CURRENCY_DISPLAY_UPDATE');
        currency:SetScript('OnEvent', function(_, event, currencyID)
            if event == 'CURRENCY_DISPLAY_UPDATE' and currencyID == self.currentCurrencyID then
                currency:UpdateText();
            end
        end);
        function currency:UpdateText()
            local currencyInfo = UI.currentCurrencyID ~= 0 and C_CurrencyInfo.GetCurrencyInfo(UI.currentCurrencyID);

            if not currencyInfo then
                self.Text:SetText('Catalyst Charges: N/A');
                return;
            end
            local textureMarkup = CreateSimpleTextureMarkup(currencyInfo.iconFileID, 18);
            self.Text:SetFormattedText('Catalyst Charges: |cFFFFFFFF%d/%d|r %s', currencyInfo.quantity, currencyInfo.maxQuantity, textureMarkup);
        end

        local text = currency:CreateFontString(nil, 'OVERLAY', 'GameFontNormal');
        currency.Text = text;
        text:SetPoint('LEFT', currency, 'LEFT', 0, 0);

        text:SetScript('OnEnter', function()
            if self.currentCurrencyID == 0 then
                GameTooltip:SetOwner(currency, 'ANCHOR_CURSOR_RIGHT');
                GameTooltip:AddLine('Catalyst Charges');
                GameTooltip:AddLine('Between seasons, or addon not updated for current season.', 1, 0.5, 0.5);
                GameTooltip:Show();
            else
                GameTooltip:SetOwner(currency, 'ANCHOR_CURSOR_RIGHT');
                GameTooltip:SetCurrencyByID(self.currentCurrencyID);
            end
        end);
        text:SetScript('OnLeave', function()
            GameTooltip:Hide();
        end);
        currency:UpdateText();
    end
end

function UI:ToggleUI()
    self:SetShown(not self:IsShown());
end

function UI:RegisterIntoBlizzMove()
    --- @type BlizzMoveAPI?
    local BlizzMoveAPI = BlizzMoveAPI; ---@diagnostic disable-line: undefined-global
    if BlizzMoveAPI then
        BlizzMoveAPI:RegisterAddOnFrames(
            {
                [addonName] = {
                    [self:GetName()] = {
                        SubFrames = {
                            [self:GetName() .. '.TitleBar'] = {},
                        },
                    },
                },
            }
        )
    end
end

--- @param tier TUM_Tier
--- @return string slashCommand
function UI:CreateOutfitSlashCommand(tier)
    local seasonID = self.selectedSeason;
    local classID = self.selectedClass;
    local itemTransmogInfoList = TransmogUtil.GetEmptyItemTransmogInfoList();

    for slotIndex, itemID in pairs(TUM.data.catalystItems[seasonID][classID]) do
        local invSlot = TUM.data.constants.catalystSlots[slotIndex];
        local sourceIDs = TUM:GetSourceIDsForItemID(itemID)
        if sourceIDs and sourceIDs[tier] then
            itemTransmogInfoList[invSlot] = ItemUtil.CreateItemTransmogInfo(sourceIDs[tier]);
        end
    end

    return TransmogUtil.CreateOutfitSlashCommand(itemTransmogInfoList);
end

function UI:DeferUpdateItems()
    self.deferUpdate = true;
end

function UI:OnUpdate()
    if self.deferUpdate then
        self.deferUpdate = false;
        self:UpdateItems();
        local showCurrency = self.selectedClass == playerClassID and self.selectedSeason == TUM.currentSeason;
        self.Currency:SetShown(showCurrency);
    end
    if self.deferNewResult then
        self.deferNewResult = false;
        local ok = ' ' .. OK_MARKUP .. GREEN_FONT_COLOR:WrapTextInColorCode(' Collected')
        local nok = ' ' .. NOK_MARKUP .. RED_FONT_COLOR:WrapTextInColorCode(' Not Collected')
        local other = OTHER_MARKUP .. BLUE_FONT_COLOR:WrapTextInColorCode(' From Another Item')
        for _, row in ipairs(self.rows) do
            for _, column in pairs(row.columns) do
                local tier = column.tier;
                if tier then
                    local slot = column.slot;
                    local results = self.results and self.results[slot] and self.results[slot][tier];
                    column.results = results;
                    column.isCollected = TUM:IsCatalystItemCollected(self.selectedSeason, self.selectedClass, slot, tier);
                    if TUM.db.UI_treatOtherItemAsCollected and 'learnedFromOtherItem' == column.isCollected then
                        column.isCollected = true;
                    end

                    if true == column.isCollected then
                        column.Text:SetText(ok);
                    else
                        local text = nok;
                        if 'learnedFromOtherItem' == column.isCollected then
                            text = other;
                        end
                        if results and next(results) then
                            table.sort(results, function(a, b)
                                -- Order as Catalyse, then Upgrade, then CatalyseUpgrade.
                                if a.requiresUpgrade ~= b.requiresUpgrade then
                                    return not a.requiresUpgrade and b.requiresUpgrade;
                                end
                                if a.requiresCatalyse ~= b.requiresCatalyse then
                                    return not a.requiresCatalyse and b.requiresCatalyse;
                                end
                                if a.distance ~= b.distance then
                                    return a.distance < b.distance;
                                end
                                if a.location ~= b.location then
                                    return a.location > b.location;
                                end
                                return a.itemLink > b.itemLink;
                            end);
                            local firstResult = results[1];
                            if firstResult.requiresUpgrade then
                                text = ' ' .. UPGRADE_MARKUP .. text;
                            end
                            if firstResult.requiresCatalyse then
                                text = ' ' .. CATALYST_MARKUP .. text;
                            end
                            if firstResult.distance > 0 then
                                text = ' ' .. WARBAND_MARKUP .. text;
                            end
                        end
                        column.Text:SetText(text);
                    end
                end
            end
        end
    end
end

local ARMOR_SEARCH_TERMS = {
    [Enum.ItemArmorSubclass.Cloth] = '#cloth',
    [Enum.ItemArmorSubclass.Leather] = '#leather',
    [Enum.ItemArmorSubclass.Mail] = '#mail',
    [Enum.ItemArmorSubclass.Plate] = '#plate',
};
local SLOT_SEARCH_TERMS = {
    [Enum.InventoryType.IndexHeadType] = '#head',
    [Enum.InventoryType.IndexShoulderType] = '#shoulder',
    [Enum.InventoryType.IndexChestType] = '#chest',
    [Enum.InventoryType.IndexWaistType] = '#waist',
    [Enum.InventoryType.IndexLegsType] = '#legs',
    [Enum.InventoryType.IndexFeetType] = '#feet',
    [Enum.InventoryType.IndexWristType] = '#wrist',
    [Enum.InventoryType.IndexHandType] = '#hands',
    [Enum.InventoryType.IndexCloakType] = '#back',
};
local function buildSyndicatorSearchTerm(classID)
    local slotTerms = {};
    for slot, term in pairs(SLOT_SEARCH_TERMS) do
        if slot ~= Enum.InventoryType.IndexCloakType then
            tinsert(slotTerms, term);
        end
    end
    local armorType = TUM.data.constants.classArmorTypeMap[classID];
    local searchTerms = string.format(
        '%s|(%s&(%s))',
        SLOT_SEARCH_TERMS[Enum.InventoryType.IndexCloakType],
        ARMOR_SEARCH_TERMS[armorType],
        table.concat(slotTerms, '|')
    );

    return string.format('#epic&((%s)|(#tier token))', searchTerms);
end

local function initResults()
    local results = {};
    for slot in pairs(TUM.data.constants.catalystSlots) do
        results[slot] = {
            [TUM.data.constants.tiers.lfr] = {},
            [TUM.data.constants.tiers.normal] = {},
            [TUM.data.constants.tiers.heroic] = {},
            [TUM.data.constants.tiers.mythic] = {},
        };
    end

    return results;
end

--- @param scanResult SyndicatorSearchResult
--- @param classID number
--- @param seasonID number
--- @return nil|TUM_UI_ResultData info
--- @return nil|TUM_UI_ResultData upgradeInfo
local function checkResult(scanResult, classID, seasonID)
    if
        scanResult.source.guild -- ignore guild banks, might add some filter setting later
        or seasonID ~= TUM:GetItemSeason(scanResult.itemLink)
    then
        return;
    end

    local scanClassFile = playerClassFile;
    local characterInfo = isSyndicatorLoaded and Syndicator.API.GetCharacter(scanResult.source.character);
    if characterInfo then
        scanClassFile = characterInfo.details.className;
    end

    local isToken = scanResult.itemID and TUM:IsToken(scanResult.itemID)
    local tokenInfo = isToken and TUM:GetTokenInfo(scanResult.itemID, scanResult.itemLink)
    if tokenInfo and (not tokenInfo.classList[classID] or tokenInfo.season ~= seasonID) then
        return;
    end

    local itemSlot = tokenInfo and tokenInfo.slot or C_Item.GetItemInventoryTypeByID(scanResult.itemLink)
    if itemSlot == Enum.InventoryType.IndexRobeType then
        -- robes catalyse into chest pieces
        itemSlot = Enum.InventoryType.IndexChestType
    end

    local isItemCatalysed = TUM:IsItemCatalysed(scanResult.itemID);
    if isItemCatalysed and TUM.data.catalystItems[seasonID][classID][itemSlot] ~= scanResult.itemID then
        return;
    end

    if not isItemCatalysed and scanResult.source.character and scanResult.isBound and isSyndicatorLoaded then
        --- @type SyndicatorCharacterData?
        if not characterInfo or characterInfo.details.class ~= classID then
            return; -- item is bound, and the location is a character of the wrong class
        end
    end

    local tumResult = TUM:IsAppearanceMissing(scanResult.itemLink, classID);

    local location;
    local distance = 0;
    if scanResult.source.character then
        local classColor = C_ClassColor.GetClassColor(scanClassFile)
        local classFile = C_CreatureInfo.GetClassInfo(classID).classFile
        location = string.format(
            '%s: %s',
            classColor:WrapTextInColorCode(scanResult.source.character),
            scanResult.source.container
        );
        distance = scanClassFile ~= classFile and 1000 or 0;
    elseif scanResult.source.warband then
        location = CreateAtlasMarkup('warbands-icon', 17, 13) .. ' Warband bank';
        distance = 100 + scanResult.source.warband;
    end

    local info, upgradeInfo;
    if not isItemCatalysed and tumResult.catalystAppearanceMissing then
        --- @type TUM_UI_ResultData
        info = {
            slot = itemSlot,
            tier = tumResult.contextData.tier,
            knownFromOtherItem = tumResult.catalystAppearanceLearnedFromOtherItem,
            requiresCatalyse = true,
            requiresUpgrade = false,
            itemLink = scanResult.itemLink,
            location = location,
            distance = distance,
        };
    end

    if tumResult.catalystUpgradeAppearanceMissing or (isItemCatalysed and tumResult.upgradeAppearanceMissing) then
        --- @type TUM_UI_ResultData
        upgradeInfo = {
            slot = itemSlot,
            tier = tumResult.contextData.tier + 1,
            knownFromOtherItem = (isItemCatalysed and tumResult.upgradeAppearanceLearnedFromOtherItem) or tumResult.catalystUpgradeAppearanceLearnedFromOtherItem,
            requiresCatalyse = not isItemCatalysed,
            requiresUpgrade = true,
            itemLink = scanResult.itemLink,
            location = location,
            distance = distance,
        };
    end

    return info, upgradeInfo;
end

--- @param result SyndicatorSearchResult
local function handleResult(result)
    if LinkUtil.ExtractLink(result.itemLink) ~= 'item' then
        return;
    end
    local item = Item:CreateFromItemLink(result.itemLink);
    item:ContinueOnItemLoad(function()
        local info, upgradeInfo = checkResult(result, UI.selectedClass, UI.selectedSeason);
        if info or upgradeInfo then
            UI.deferNewResult = true;
        end
        if info then
            tinsert(UI.results[info.slot][info.tier], info);
        end
        if upgradeInfo then
            tinsert(UI.results[upgradeInfo.slot][upgradeInfo.tier], upgradeInfo);
        end
    end);
end

function UI:UpdateItems()
    self.deferUpdate = false;
    if self.pending == self.selectedClass .. '|' .. self.selectedSeason then
        return; -- already pending an update for this class and season
    end
    self.pending = self.selectedClass .. '|' .. self.selectedSeason;
    self.results = initResults();
    self.deferNewResult = true;
    if isSyndicatorLoaded then
        local term = buildSyndicatorSearchTerm(self.selectedClass);
        --- @param results SyndicatorSearchResult[]
        Syndicator.Search.RequestSearchEverywhereResults(term, function(results) ---@diagnostic disable-line: undefined-global
            for _, result in pairs(results) do
                handleResult(result);
            end

            self.pending = nil;
        end);
    else
        -- manual scan
        for containerIndex = BACKPACK_CONTAINER, NUM_BAG_SLOTS do
            for slotIndex = 1, C_Container.GetContainerNumSlots(containerIndex) do
                local item = Item:CreateFromBagAndSlot(containerIndex, slotIndex);
                if not item:IsItemEmpty() then
                    item:ContinueOnItemLoad(function()
                        local containerInfo = C_Container.GetContainerItemInfo(containerIndex, slotIndex);
                        --- @type SyndicatorSearchResult
                        local result = {
                            itemLink = item:GetItemLink(),
                            itemID = item:GetItemID(),
                            isBound = containerInfo.isBound,
                            source = {
                                container = 'bag',
                                character = playerFullName,
                            },
                            quality = item:GetItemQuality(),
                        };
                        handleResult(result);
                    end);
                end
            end
        end
        for _, inventorySlotID in pairs(TUM.data.constants.catalystSlots) do
            local item = Item:CreateFromEquipmentSlot(inventorySlotID);
            item:ContinueOnItemLoad(function()
                --- @type SyndicatorSearchResult
                local result = {
                    itemLink = item:GetItemLink(),
                    itemID = item:GetItemID(),
                    isBound = true,
                    source = {
                        container = 'equipped',
                        character = playerFullName,
                    },
                    quality = item:GetItemQuality(),
                };
                handleResult(result);
            end);
        end
        self.pending = nil;
    end
end

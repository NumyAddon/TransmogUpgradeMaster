local name, ns = ...;

--- @class TransmogUpgradeMasterConfig
local Config = {}
ns.Config = Config;

--- @enum TUM_Config_ModifierKeyOptions
Config.modifierKeyOptions = {
    always = "always",
    shift = "shift",
    ctrl = "ctrl",
    alt = "alt",
    never = "never",
};

--- @enum TUM_Config_AutoConfirmCatalystOptions
Config.autoConfirmCatalystOptions = {
    never = "never",
    previousSeason = "previousSeason",
    always = "always",
};

Config.settingKeys = {
    hideWhenCollected = "hideWhenCollected",
    showCollectedModifierKey = "showCollectedModifierKey",
    showCollectedFromOtherItemModifierKey = "showCollectedFromOtherItemModifierKey",
    showUncollectedModifierKey = "showUncollectedModifierKey",
    showWarbandCatalystInfoModifierKey = "showWarbandCatalystInfoModifierKey",
    warbandCatalystClassList = "warbandCatalystClassList",
    autoConfirmCatalyst = "autoConfirmCatalyst",
    debug = "debug",
    UI_treatOtherItemAsCollected = "UI_treatOtherItemAsCollected",
};

--- @return TUM_DB
function Config:Init()
    --- @class TUM_DB
    local defaults = {
        --- @type boolean
        hideWhenCollected = false,
        --- @type boolean
        debug = false,
        --- @type TUM_Config_ModifierKeyOptions
        showCollectedModifierKey = self.modifierKeyOptions.always,
        --- @type TUM_Config_ModifierKeyOptions
        showCollectedFromOtherItemModifierKey = self.modifierKeyOptions.always,
        --- @type TUM_Config_ModifierKeyOptions
        showUncollectedModifierKey = self.modifierKeyOptions.always,
        --- @type TUM_Config_ModifierKeyOptions
        showWarbandCatalystInfoModifierKey = self.modifierKeyOptions.shift,
        --- @type table<number, boolean> # [classID] = true/false
        warbandCatalystClassList = {},
        --- @type TUM_Config_AutoConfirmCatalystOptions
        autoConfirmCatalyst = self.autoConfirmCatalystOptions.previousSeason,
        --- @type boolean
        UI_treatOtherItemAsCollected = false,
    };
    TransmogUpgradeMasterDB = TransmogUpgradeMasterDB or {};
    self.db = TransmogUpgradeMasterDB;
    for k, v in pairs(defaults) do
        if self.db[k] == nil then
            if k == "showCollectedFromOtherItemModifierKey" then
                self.db[k] = (self.db.showUncollectedModifierKey or v);
            else
                self.db[k] = v;
            end
        end
    end
    for classID = 1, GetNumClasses() do
        defaults.warbandCatalystClassList[classID] = true;
        if self.db.warbandCatalystClassList[classID] == nil then
            self.db.warbandCatalystClassList[classID] = true;
        end
    end

    local category, layout = Settings.RegisterVerticalLayoutCategory("Transmog Upgrade Master");
    self.category = category;

    local showModifierOptions = {
        { text = "Always", label = "Always",              tooltip = "Always show.",              value = self.modifierKeyOptions.always, },
        { text = "Shift",  label = "While holding SHIFT", tooltip = "Only while holding Shift.", value = self.modifierKeyOptions.shift, },
        { text = "Ctrl",   label = "While holding CTRL",  tooltip = "Only while holding Ctrl.",  value = self.modifierKeyOptions.ctrl, },
        { text = "Alt",    label = "While holding ALT",   tooltip = "Only while holding Alt.",   value = self.modifierKeyOptions.alt, },
        { text = "Never",  label = "Never",               tooltip = "Never show.",               value = self.modifierKeyOptions.never, },
    };


    layout:AddInitializer(CreateSettingsListSectionHeaderInitializer(
        "Display Transmog Collection Status in Tooltip",
        "Show whether you have collected an Upgraded or Catalysed appearance in the tooltip."
    ));
    self:MakeDropdown(
        category,
        "Collected",
        self.settingKeys.showCollectedModifierKey,
        defaults.showCollectedModifierKey,
        "When to display the Upgrade and Catalyst information for collected appearances.",
        showModifierOptions,
        Settings.VarType.String
    );
    self:MakeDropdown(
        category,
        "Collected From Other Item",
        self.settingKeys.showCollectedFromOtherItemModifierKey,
        defaults.showCollectedFromOtherItemModifierKey,
        "When to display the Upgrade and Catalyst information for collected appearances that are learned from other items.",
        showModifierOptions,
        Settings.VarType.String
    );
    self:MakeDropdown(
        category,
        "Uncollected",
        self.settingKeys.showUncollectedModifierKey,
        defaults.showUncollectedModifierKey,
        "When to display the Upgrade and Catalyst information for uncollected appearances.",
        showModifierOptions,
        Settings.VarType.String
    );


    layout:AddInitializer(CreateSettingsListSectionHeaderInitializer(
        "Warband Catalyst Info",
        "For warbound or BoE items, you can show the classes for which you can get an appearance by catalysing (and upgrading) the item."
    ));
    local showWarbandInfo = self:MakeDropdown(
        category,
        "Show Warband Catalyst Info",
        self.settingKeys.showWarbandCatalystInfoModifierKey,
        defaults.showWarbandCatalystInfoModifierKey,
        "When to display the Warband Catalyst information in the tooltip.",
        showModifierOptions,
        Settings.VarType.String
    );
    do
        local expandInitializer, isExpanded = self:MakeExpandableSection("Displayed Classes")

        local function isVisible()
            return self.db.showWarbandCatalystInfoModifierKey ~= self.modifierKeyOptions.never;
        end
        expandInitializer:AddShownPredicate(isVisible);
        layout:AddInitializer(expandInitializer);

        local tooltip = "If checked, the tooltip will show the Catalyst information for %s for warbound or BoE items."
        for classID = 1, GetNumClasses() do
            local className, classFile = GetClassInfo(classID);
            local classColor = RAID_CLASS_COLORS[classFile];
            local label = "Show " .. classColor:WrapTextInColorCode(className);
            local classCheckbox = self:MakeCheckbox(
                category,
                label,
                classID,
                defaults.warbandCatalystClassList[classID],
                tooltip:format(classColor:WrapTextInColorCode(className)),
                self.db.warbandCatalystClassList
            );
            classCheckbox:SetParentInitializer(showWarbandInfo, isVisible);
            classCheckbox:AddShownPredicate(isVisible);
            classCheckbox:AddShownPredicate(isExpanded);
        end
    end


    layout:AddInitializer(CreateSettingsListSectionHeaderInitializer("Other Settings"));
    self:MakeDropdown(
        category,
        "Auto Confirm Catalyst",
        self.settingKeys.autoConfirmCatalyst,
        defaults.autoConfirmCatalyst,
        "Automatically confirm the popup window when you try to Catalyse an item.",
        {
            { text = "Never",           label = "Never",           tooltip = "Never auto-confirm.",                                         value = self.autoConfirmCatalystOptions.never, },
            { text = "Previous Season", label = "Previous Season", tooltip = "Auto-confirm for items from previous seasons that are free.", value = self.autoConfirmCatalystOptions.previousSeason, },
            { text = "Always",          label = "Always",          tooltip = "Always auto-confirm, even if there are limited charges.",     value = self.autoConfirmCatalystOptions.always, },
        },
        Settings.VarType.String
    )
    self:MakeCheckbox(
        category,
        "Debug Tooltip Info",
        self.settingKeys.debug,
        defaults.debug,
        "If Checked, debug info will be shown in the tooltip."
    );

    self:MakeButton(
        category,
        layout,
        "Reset Transmog Cache",
        function()
            TransmogUpgradeMasterCacheDB = {}
            TUM:InitItemSourceMap()
        end,
        "Reset the Transmog cache. This will cause the addon to re-cache all items, which may take a minute or so. This can fix rare situations when transmog changes are hotfixed in by blizzard."
    )

    self:MakeButton(
        category,
        layout,
        "Open Collections UI",
        function()
            TUM.UI:ToggleUI();
        end,
        string.format(
            "Open the Collections UI, you can also type %s in chat, or click on the Addon Compartment button to open this UI.",
            GREEN_FONT_COLOR:WrapTextInColorCode("/tum")
        )
    )

    Settings.RegisterAddOnCategory(category)

    return self.db;
end

function Config:OpenSettings()
    Settings.OpenToCategory(self.category:GetID());
end

local settingPrefix = name .. "_";

--- @return SettingsListElementInitializer
function Config:MakeCheckbox(category, label, settingKey, defaultValue, tooltip, dbTableOverride)
    local variable = settingPrefix .. settingKey;

    local setting = Settings.RegisterAddOnSetting(
        category,
        variable,
        settingKey,
        dbTableOverride or self.db,
        Settings.VarType.Boolean,
        label,
        defaultValue
    );
    setting:SetValueChangedCallback(function(setting, value) self:OnSettingChange(setting:GetVariable(), value) end);

    return Settings.CreateCheckbox(category, setting, tooltip);
end

--- @alias TUMDropDownOptions { text: string, label: string, tooltip: string, value: any }[]

--- @param options TUMDropDownOptions|fun(): TUMDropDownOptions
--- @param varType "string"|"number"|"boolean" # one of Settings.VarType
--- @return SettingsListElementInitializer
function Config:MakeDropdown(category, label, settingKey, defaultValue, tooltip, options, varType)
    local variable = settingPrefix .. settingKey;

    local GetOptions = options;
    if type(options) == "table" then
        GetOptions = function() return options; end
    end

    local setting = Settings.RegisterAddOnSetting(category, variable, settingKey, self.db, varType, label, defaultValue);
    setting:SetValueChangedCallback(function(setting, value) self:OnSettingChange(setting:GetVariable(), value) end);

    return Settings.CreateDropdown(category, setting, GetOptions, tooltip);
end

--- @return SettingsListElementInitializer
function Config:MakeButton(category, layout, label, onClick, tooltip)
    local variable = settingPrefix .. label;
    local setting = Settings.RegisterAddOnSetting(category, variable, 'dummy', {}, Settings.VarType.Boolean, label, true);
    local data = Settings.CreateSettingInitializerData(setting, nil, tooltip);
    data.buttonText = label;
    data.OnButtonClick = onClick;
    local initializer = Settings.CreateSettingInitializer("TransmogUpgradeMaster_SettingsButtonControlTemplate", data);
    initializer:AddSearchTags(label);
    layout:AddInitializer(initializer);

    return initializer;
end

--- @param sectionName string
--- @return SettingsExpandableSectionInitializer initializer
--- @return fun(): boolean isExpanded
function Config:MakeExpandableSection(sectionName)
    local expandInitializer = CreateSettingsExpandableSectionInitializer(sectionName);
    function expandInitializer:GetExtent()
        return 25;
    end
    hooksecurefunc(expandInitializer, "InitFrame", function(_, frame)
        function frame:OnExpandedChanged(expanded)
            self:EvaluateVisibility(expanded);
            SettingsInbound.RepairDisplay();
        end
        function frame:EvaluateVisibility(expanded)
            -- elvui wants this function to exist
            if expanded then
                self.Button.Right:SetAtlas("Options_ListExpand_Right_Expanded", TextureKitConstants.UseAtlasSize);
            else
                self.Button.Right:SetAtlas("Options_ListExpand_Right", TextureKitConstants.UseAtlasSize);
            end
        end
        function frame:CalculateHeight()
            local initializer = self:GetElementData();

            return initializer:GetExtent();
        end
    end);

    return expandInitializer, function() return expandInitializer.data.expanded; end;
end

function Config:OnSettingChange(setting, value)
    -- nothing so far
end

-------------------
--- @class TransmogUpgradeMaster_SettingsButtonControlMixin : SettingsControlMixin
TransmogUpgradeMaster_SettingsButtonControlMixin = CreateFromMixins(SettingsControlMixin);
do
    local mixin = TransmogUpgradeMaster_SettingsButtonControlMixin;
    function mixin:OnLoad()
        SettingsControlMixin.OnLoad(self);
        self.Button = CreateFrame("Button", nil, self, "UIPanelButtonTemplate");
        self.Button:SetSize(200, 26);
        self.Button:SetPoint("LEFT", self, "CENTER", -80, 0);
    end

    function mixin:Init(initializer)
        SettingsControlMixin.Init(self, initializer);

        self.Button:SetText(self.data.buttonText);
        self.Button:SetScript("OnClick", self.data.OnButtonClick);
        self.Button:SetScript("OnEnter", function(button)
            GameTooltip:SetOwner(button, "ANCHOR_TOP");
            GameTooltip_AddHighlightLine(GameTooltip, initializer:GetName());
            GameTooltip_AddNormalLine(GameTooltip, initializer:GetTooltip());
            GameTooltip:Show();
        end);
        self.Button:SetScript("OnLeave", function() GameTooltip:Hide(); end);

        self:EvaluateState();
    end
end

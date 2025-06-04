local name, ns = ...;

--- @class TransmogUpgradeMasterConfig
local Config = {}
ns.Config = Config;

Config.modifierKeyOptions = {
    always = "always",
    shift = "shift",
    ctrl = "ctrl",
    alt = "alt",
    never = "never",
};

Config.settingKeys = {
    hideWhenCollected = "hideWhenCollected",
    showCollectedModifierKey = "showCollectedModifierKey",
    showUncollectedModifierKey = "showUncollectedModifierKey",
    showWarbandCatalystInfoModifierKey = "showWarbandCatalystInfoModifierKey",
    warbandCatalystClassList = "warbandCatalystClassList",
    debug = "debug",
};

function Config:Init()
    TransmogUpgradeMasterDB = TransmogUpgradeMasterDB or {};
    self.db = TransmogUpgradeMasterDB;
    local defaults = {
        [self.settingKeys.hideWhenCollected] = false,
        [self.settingKeys.debug] = false,
        [self.settingKeys.showCollectedModifierKey] = self.modifierKeyOptions.always,
        [self.settingKeys.showUncollectedModifierKey] = self.modifierKeyOptions.always,
        [self.settingKeys.showWarbandCatalystInfoModifierKey] = self.modifierKeyOptions.shift,
        [self.settingKeys.warbandCatalystClassList] = {},
    };
    for k, v in pairs(defaults) do
        if self.db[k] == nil then
            self.db[k] = v;
        end
    end
    for classID = 1, GetNumClasses() do
        defaults[self.settingKeys.warbandCatalystClassList][classID] = true;
        if self.db[self.settingKeys.warbandCatalystClassList][classID] == nil then
            self.db[self.settingKeys.warbandCatalystClassList][classID] = true;
        end
    end

    local category, layout = Settings.RegisterVerticalLayoutCategory("Transmog Upgrade Master");

    local showModifierOptions = {
        { text = "Always", label = "Always", tooltip = "Always show.", value = self.modifierKeyOptions.always },
        { text = "Shift", label = "While holding SHIFT", tooltip = "Only while holding Shift.", value = self.modifierKeyOptions.shift },
        { text = "Ctrl", label = "While holding CTRL", tooltip = "Only while holding Ctrl.", value = self.modifierKeyOptions.ctrl },
        { text = "Alt", label = "While holding ALT", tooltip = "Only while holding Alt.", value = self.modifierKeyOptions.alt },
        { text = "Never", label = "Never", tooltip = "Never show.", value = self.modifierKeyOptions.never },
    };

    layout:AddInitializer(CreateSettingsListSectionHeaderInitializer(
        "Display Transmog Collection Status in Tooltip",
        "Show whether you have collected an Upgraded or Catalysed appearance in the tooltip."
    ));
    self:MakeDropdown(
        category,
        "Show Collected TMog in Tooltip",
        self.settingKeys.showCollectedModifierKey,
        defaults.showCollectedModifierKey,
        "When to display the Upgrade and Catalyst information for collected appearances.",
        showModifierOptions,
        Settings.VarType.String
    );
    self:MakeDropdown(
        category,
        "Show Uncollected TMog in Tooltip",
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
        local expandInitializer, isExpanded = self:MakeExpandableSection("Displayed Classes", 25, 0)

        local function isVisible()
            return self.db[self.settingKeys.showWarbandCatalystInfoModifierKey] ~= self.modifierKeyOptions.never;
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
                defaults[self.settingKeys.warbandCatalystClassList][classID],
                tooltip:format(classColor:WrapTextInColorCode(className)),
                self.db[self.settingKeys.warbandCatalystClassList]
            );
            classCheckbox:SetParentInitializer(showWarbandInfo, isVisible);
            classCheckbox:AddShownPredicate(isVisible);
            classCheckbox:AddShownPredicate(isExpanded);
        end
    end
    layout:AddInitializer(CreateSettingsListSectionHeaderInitializer("Other Settings"));
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

    Settings.RegisterAddOnCategory(category)

    SLASH_TRANSMOG_UPGRADE_MASTER1 = "/tum";
    SLASH_TRANSMOG_UPGRADE_MASTER2 = "/transmogupgrademaster";
    SlashCmdList["TRANSMOG_UPGRADE_MASTER"] = function()
        Settings.OpenToCategory(category:GetID());
    end

    return self.db;
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
            if expanded then
                self.Button.Right:SetAtlas("Options_ListExpand_Right_Expanded", TextureKitConstants.UseAtlasSize);
            else
                self.Button.Right:SetAtlas("Options_ListExpand_Right", TextureKitConstants.UseAtlasSize);
            end

            SettingsInbound.RepairDisplay();
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
    local function InitializeSettingTooltip(initializer)
        Settings.InitTooltip(initializer:GetName(), initializer:GetTooltip());
    end

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
            GameTooltip:SetOwner(button, "ANCHOR_RIGHT");
            InitializeSettingTooltip(initializer);
            GameTooltip:Show();
        end);
        self.Button:SetScript("OnLeave", function() GameTooltip:Hide(); end);

        self:EvaluateState();
    end
end

--- @class TUM_NS
local ns = select(2, ...);

--- @class TUM_Config
local TUM_Config = {}
ns.TUM_Config = TUM_Config;

--- @type NumyConfig
local Config = ns.Config;

--- @enum TUM_Config_ModifierKeyOptions
TUM_Config.modifierKeyOptions = {
    always = "always",
    shift = "shift",
    ctrl = "ctrl",
    alt = "alt",
    never = "never",
};

--- @enum TUM_Config_AutoConfirmCatalystOptions
TUM_Config.autoConfirmCatalystOptions = {
    never = "never",
    previousSeason = "previousSeason",
    always = "always",
};

TUM_Config.settingKeys = {
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
function TUM_Config:Init()
    --- @type TransmogUpgradeMaster
    local TUM = ns.core;

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
    --- @type TUM_DB
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

    Config:Init("Transmog Upgrade Master", self.db, defaults);

    do
        local showModifierOptions = {
            { text = "Always", value = self.modifierKeyOptions.always, tooltip = "Always show." },
            { text = "Shift", value = self.modifierKeyOptions.shift, tooltip = "Only while holding Shift.", label = "While holding SHIFT" },
            { text = "Ctrl", value = self.modifierKeyOptions.ctrl, tooltip = "Only while holding Ctrl.", label = "While holding CTRL" },
            { text = "Alt", value = self.modifierKeyOptions.alt, tooltip = "Only while holding Alt.", label = "While holding ALT" },
            { text = "Never", value = self.modifierKeyOptions.never, tooltip = "Never show." },
        };

        Config:MakeHeader(
            "Display Transmog Collection Status in Tooltip",
            "Show whether you have collected an Upgraded or Catalysed appearance in the tooltip."
        );
        Config:MakeDropdown(
            "Collected",
            self.settingKeys.showCollectedModifierKey,
            "When to display the Upgrade and Catalyst information for collected appearances.",
            showModifierOptions
        );
        Config:MakeDropdown(
            "Collected From Other Item",
            self.settingKeys.showCollectedFromOtherItemModifierKey,
            "When to display the Upgrade and Catalyst information for collected appearances that are learned from other items.",
            showModifierOptions
        );
        Config:MakeDropdown(
            "Uncollected",
            self.settingKeys.showUncollectedModifierKey,
            "When to display the Upgrade and Catalyst information for uncollected appearances.",
            showModifierOptions
        );

        Config:MakeHeader(
            "Warband Catalyst Info",
            "For warbound or BoE items, you can show the classes for which you can get an appearance by catalysing (and upgrading) the item."
        );
        local showWarbandInfo = Config:MakeDropdown(
            "Show Warband Catalyst Info",
            self.settingKeys.showWarbandCatalystInfoModifierKey,
            "When to display the Warband Catalyst information in the tooltip.",
            showModifierOptions
        );
        do
            local expandInitializer, isExpanded = Config:MakeExpandableSection("Displayed Classes")

            local function isVisible()
                return self.db.showWarbandCatalystInfoModifierKey ~= self.modifierKeyOptions.never;
            end
            expandInitializer:AddShownPredicate(isVisible);

            local tooltip = "If checked, the tooltip will show the Catalyst information for %s for warbound or BoE items."
            for classID = 1, GetNumClasses() do
                local className, classFile = GetClassInfo(classID);
                local classColor = RAID_CLASS_COLORS[classFile];
                local label = "Show " .. classColor:WrapTextInColorCode(className);
                local classCheckbox = Config:MakeCheckbox(
                    label,
                    classID,
                    tooltip:format(classColor:WrapTextInColorCode(className)),
                    defaults.warbandCatalystClassList[classID],
                    self.db.warbandCatalystClassList
                );
                classCheckbox:SetParentInitializer(showWarbandInfo, isVisible);
                classCheckbox:AddShownPredicate(isVisible);
                classCheckbox:AddShownPredicate(isExpanded);
            end
        end


        Config:MakeHeader("Other Settings");
        Config:MakeDropdown(
            "Auto Confirm Catalyst",
            self.settingKeys.autoConfirmCatalyst,
            "Automatically confirm the popup window when you try to Catalyse an item.",
            {
                { text = "Never", value = self.autoConfirmCatalystOptions.never, tooltip = "Never auto-confirm." },
                { text = "Previous Season", value = self.autoConfirmCatalystOptions.previousSeason, tooltip = "Auto-confirm for items from previous seasons that are free." },
                { text = "Always", value = self.autoConfirmCatalystOptions.always, tooltip = "Always auto-confirm, even if there are limited charges." },
            }
        );
        Config:MakeCheckbox("Debug Tooltip Info", self.settingKeys.debug, "If Checked, debug info will be shown in the tooltip.");

        Config:MakeButton(
            "Reset Transmog Cache",
            function() TransmogUpgradeMasterCacheDB = {}; TUM:InitItemSourceMap(); end,
            "Reset the Transmog cache. This will cause the addon to re-cache all items, which may take a minute or so. This can fix rare situations when transmog changes are hotfixed in by blizzard."
        );

        Config:MakeButton(
            "Open Collections UI",
            function() TUM.UI:ToggleUI(); end,
            string.format(
                "Open the Collections UI, you can also type %s in chat, or click on the Addon Compartment button to open this UI.",
                GREEN_FONT_COLOR:WrapTextInColorCode("/tum")
            )
        );
    end

    return self.db;
end

function TUM_Config:OpenSettings()
    ns.Config:OpenSettings();
end

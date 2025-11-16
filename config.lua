local name = ...;
--- @class TUM_NS
local ns = select(2, ...);

--- @class TUM_Config
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

local settingPrefix = "Transmog Upgrade Master ";

local PAYPAL_TEXTURE = "|TInterface\\AddOns\\TransmogUpgradeMaster\\media\\paypal.tga:18|t";
local COFFEE_TEXTURE = "|TInterface\\AddOns\\TransmogUpgradeMaster\\media\\coffee.tga:18|t";

--- @return TUM_DB
function Config:Init()
    --- @type TransmogUpgradeMaster
    local TUM = ns.core;

    --- @class TUM_DB
    self.defaults = {
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
    self.version = C_AddOns.GetAddOnMetadata(name, "Version") or "";
    for k, v in pairs(self.defaults) do
        if self.db[k] == nil then
            if k == "showCollectedFromOtherItemModifierKey" then
                self.db[k] = (self.db.showUncollectedModifierKey or v);
            else
                self.db[k] = v;
            end
        end
    end
    for classID = 1, GetNumClasses() do
        self.defaults.warbandCatalystClassList[classID] = true;
        if self.db.warbandCatalystClassList[classID] == nil then
            self.db.warbandCatalystClassList[classID] = true;
        end
    end

    self.category, self.layout = Settings.RegisterVerticalLayoutCategory("Transmog Upgrade Master");

    self:MakeText("Version: " .. WHITE_FONT_COLOR:WrapTextInColorCode(self.version));

    self:MakeDonationPrompt();

    do
        local showModifierOptions = {
            { text = "Always", tooltip = "Always show.",      value = self.modifierKeyOptions.always, },
            { text = "Shift",  label = "While holding SHIFT", tooltip = "Only while holding Shift.", value = self.modifierKeyOptions.shift, },
            { text = "Ctrl",   label = "While holding CTRL",  tooltip = "Only while holding Ctrl.",  value = self.modifierKeyOptions.ctrl, },
            { text = "Alt",    label = "While holding ALT",   tooltip = "Only while holding Alt.",   value = self.modifierKeyOptions.alt, },
            { text = "Never",  tooltip = "Never show.",       value = self.modifierKeyOptions.never, },
        };

        self:MakeHeader(
            "Display Transmog Collection Status in Tooltip",
            "Show whether you have collected an Upgraded or Catalysed appearance in the tooltip."
        );
        self:MakeDropdown(
            "Collected",
            self.settingKeys.showCollectedModifierKey,
            "When to display the Upgrade and Catalyst information for collected appearances.",
            showModifierOptions
        );
        self:MakeDropdown(
            "Collected From Other Item",
            self.settingKeys.showCollectedFromOtherItemModifierKey,
            "When to display the Upgrade and Catalyst information for collected appearances that are learned from other items.",
            showModifierOptions
        );
        self:MakeDropdown(
            "Uncollected",
            self.settingKeys.showUncollectedModifierKey,
            "When to display the Upgrade and Catalyst information for uncollected appearances.",
            showModifierOptions
        );


        self:MakeHeader(
            "Warband Catalyst Info",
            "For warbound or BoE items, you can show the classes for which you can get an appearance by catalysing (and upgrading) the item."
        );
        local showWarbandInfo = self:MakeDropdown(
            "Show Warband Catalyst Info",
            self.settingKeys.showWarbandCatalystInfoModifierKey,
            "When to display the Warband Catalyst information in the tooltip.",
            showModifierOptions
        );
        do
            local expandInitializer, isExpanded = self:MakeExpandableSection("Displayed Classes")

            local function isVisible()
                return self.db.showWarbandCatalystInfoModifierKey ~= self.modifierKeyOptions.never;
            end
            expandInitializer:AddShownPredicate(isVisible);

            local tooltip = "If checked, the tooltip will show the Catalyst information for %s for warbound or BoE items."
            for classID = 1, GetNumClasses() do
                local className, classFile = GetClassInfo(classID);
                local classColor = RAID_CLASS_COLORS[classFile];
                local label = "Show " .. classColor:WrapTextInColorCode(className);
                local classCheckbox = self:MakeCheckbox(
                    label,
                    classID,
                    tooltip:format(classColor:WrapTextInColorCode(className)),
                    self.defaults.warbandCatalystClassList[classID],
                    self.db.warbandCatalystClassList
                );
                classCheckbox:SetParentInitializer(showWarbandInfo, isVisible);
                classCheckbox:AddShownPredicate(isVisible);
                classCheckbox:AddShownPredicate(isExpanded);
            end
        end


        self:MakeHeader("Other Settings");
        self:MakeDropdown(
            "Auto Confirm Catalyst",
            self.settingKeys.autoConfirmCatalyst,
            "Automatically confirm the popup window when you try to Catalyse an item.",
            {
                { text = "Never", tooltip = "Never auto-confirm.", value = self.autoConfirmCatalystOptions.never },
                { text = "Previous Season", tooltip = "Auto-confirm for items from previous seasons that are free.", value = self.autoConfirmCatalystOptions.previousSeason },
                { text = "Always", tooltip = "Always auto-confirm, even if there are limited charges.", value = self.autoConfirmCatalystOptions.always },
            }
        );
        self:MakeCheckbox(
            "Debug Tooltip Info",
            self.settingKeys.debug,
            "If Checked, debug info will be shown in the tooltip."
        );

        self:MakeButton(
            "Reset Transmog Cache",
            function()
                TransmogUpgradeMasterCacheDB = {}
                TUM:InitItemSourceMap()
            end,
            "Reset the Transmog cache. This will cause the addon to re-cache all items, which may take a minute or so. This can fix rare situations when transmog changes are hotfixed in by blizzard."
        );

        self:MakeButton(
            "Open Collections UI",
            function()
                TUM.UI:ToggleUI();
            end,
            string.format(
                "Open the Collections UI, you can also type %s in chat, or click on the Addon Compartment button to open this UI.",
                GREEN_FONT_COLOR:WrapTextInColorCode("/tum")
            )
        );
    end

    Settings.RegisterAddOnCategory(self.category)

    return self.db;
end

function Config:NotifyChange(forceUpdateSliders)
    if not SettingsPanel or self.category ~= SettingsPanel:GetCurrentCategory() then return end
    if forceUpdateSliders then
        -- show and hide the sliders to force them to update
        self.updatingSliders = true;
        SettingsInbound.RepairDisplay();
        self.updatingSliders = false;
    end
    SettingsInbound.RepairDisplay();
end

function Config:OpenSettings()
    Settings.OpenToCategory(self.category:GetID());
end

function Config:CopyText(text, optionalTitleSuffix)
    if not self.copyTextDialogName then
        self.copyTextDialogName = "TransmogUpgradeMaster_Config_CopyTextDialog";
        StaticPopupDialogs[self.copyTextDialogName] = {
            text = "CTRL-C to copy %s",
            button1 = CLOSE,
            --- @param dialog StaticPopupTemplate
            --- @param data string
            OnShow = function(dialog, data)
                local function HidePopup()
                    dialog:Hide();
                end
                --- @type StaticPopupTemplate_EditBox
                local editBox = dialog.GetEditBox and dialog:GetEditBox() or dialog.editBox;
                editBox:SetScript('OnEscapePressed', HidePopup);
                editBox:SetScript('OnEnterPressed', HidePopup);
                editBox:SetScript('OnKeyUp', function(_, key)
                    if IsControlKeyDown() and (key == 'C' or key == 'X') then
                        HidePopup();
                    end
                end);
                editBox:SetMaxLetters(0);
                editBox:SetText(data);
                editBox:HighlightText();
            end,
            hasEditBox = true,
            editBoxWidth = 240,
            timeout = 0,
            whileDead = true,
            hideOnEscape = true,
            preferredIndex = 3,
        };
    end

    StaticPopup_Show(self.copyTextDialogName, optionalTitleSuffix or '', nil, text);
end

function Config:GetUniqueVariable()
    self.counter = self.counter or CreateCounter();

    return settingPrefix .. self.counter();
end

do
    --- @param text string
    --- @param tooltip string?
    --- @return SettingsListElementInitializer
    function Config:MakeHeader(text, tooltip)
        local headerInitializer = CreateSettingsListSectionHeaderInitializer(text, tooltip);
        self.layout:AddInitializer(headerInitializer);

        return headerInitializer;
    end

    local calculateHeight;
    do
        local heightCalculator = UIParent:CreateFontString(nil, "ARTWORK", "GameFontNormal");
        local deferrer = CreateFrame("Frame");
        deferrer:Hide();
        deferrer.callbacks = {};
        deferrer:SetScript("OnUpdate", function()
            for _, callback in pairs(deferrer.callbacks) do
                securecallfunction(callback);
            end
            deferrer.callbacks = {};
        end);
        function deferrer:Defer(callback)
            table.insert(self.callbacks, callback);
            self:Show();
        end
        calculateHeight = function(data, deferred)
            local text, indent = data.name, data.indent;
            heightCalculator:SetWidth(635 - (indent * 15));
            heightCalculator:SetText(text);

            data.extent = heightCalculator:GetStringHeight();
            if not deferred then
                deferrer:Defer(function() calculateHeight(data, true); end);
            end
        end
    end

    --- @param text string
    --- @param indent number? # default 0
    --- @return SettingsListElementInitializer
    function Config:MakeText(text, indent)
        local data = {
            name = text,
            indent = indent or 0,
        };
        calculateHeight(data);
        --- @type SettingsListElementInitializer
        local textInitializer = Settings.CreateElementInitializer("TransmogUpgradeMaster_SettingsTextTemplate", data);

        function textInitializer:GetExtent() return self.data.extent; end

        self.layout:AddInitializer(textInitializer);

        return textInitializer;
    end

    local function sliderForcedUpdatePredicate()
        return not Config.updatingSliders;
    end

    --- @param label string
    --- @param settingKey string|number
    --- @param tooltip string?
    --- @param options TUM_Config_SliderOptions # see Settings.CreateSliderOptions
    --- @param defaultValue number?
    --- @param dbTableOverride table?
    --- @return SettingsListElementInitializer initializer
    --- @return AddOnSettingMixin setting
    function Config:MakeSlider(label, settingKey, tooltip, options, defaultValue, dbTableOverride)
        local variable = self:GetUniqueVariable();
        if defaultValue == nil then
            defaultValue = self.defaults[settingKey];
            if defaultValue == nil then
                error('No default value provided')
            end
        end

        local setting = Settings.RegisterAddOnSetting(
            self.category,
            variable,
            settingKey,
            dbTableOverride or self.db,
            Settings.VarType.Number,
            label,
            defaultValue
        );

        local initializer = Settings.CreateSlider(self.category, setting, options, tooltip);
        initializer:AddShownPredicate(sliderForcedUpdatePredicate);

        return initializer, setting;
    end

    --- @param label string
    --- @param settingKey string|number
    --- @param tooltip string?
    --- @param defaultValue boolean?
    --- @param dbTableOverride table?
    --- @return SettingsListElementInitializer initializer
    --- @return AddOnSettingMixin setting
    function Config:MakeCheckbox(label, settingKey, tooltip, defaultValue, dbTableOverride)
        local variable = self:GetUniqueVariable();
        if defaultValue == nil then
            defaultValue = self.defaults[settingKey];
            if defaultValue == nil then
                error('No default value provided')
            end
        end

        local setting = Settings.RegisterAddOnSetting(
            self.category,
            variable,
            settingKey,
            dbTableOverride or self.db,
            Settings.VarType.Boolean,
            label,
            defaultValue
        );

        return Settings.CreateCheckbox(self.category, setting, tooltip), setting;
    end

    --- @param label string
    --- @param settingKey string|number
    --- @param tooltip string?
    --- @param options TUM_Config_DropDownOptions|fun(): TUM_Config_DropDownOptions
    --- @param defaultValue any?
    --- @param dbTableOverride table?
    --- @return SettingsListElementInitializer initializer
    --- @return AddOnSettingMixin setting
    function Config:MakeDropdown(label, settingKey, tooltip, options, defaultValue, dbTableOverride)
        local variable = self:GetUniqueVariable();
        if defaultValue == nil then
            defaultValue = self.defaults[settingKey];
            if defaultValue == nil then
                error('No default value provided')
            end
        end

        local function getOptions()
            if type(options) == "function" then
                options = options()
            end
            local container = Settings.CreateControlTextContainer();
            for _, option in pairs(options) do
                local added = container:Add(option.value, option.label or option.text, option.tooltip);
                added.text = option.text;
            end

            return container:GetData();
        end
        local setting = Settings.RegisterAddOnSetting(self.category, variable, settingKey, dbTableOverride or self.db, type(defaultValue), label, defaultValue);

        return Settings.CreateDropdown(self.category, setting, getOptions, tooltip), setting;
    end

    --- @param label string
    --- @param onClick fun(self: Button)
    --- @param tooltip string?
    --- @return SettingsListElementInitializer initializer
    function Config:MakeButton(label, onClick, tooltip)
        local data = {
            name = label,
            tooltip = tooltip,
            buttonText = label,
            OnButtonClick = onClick,
        };
        data.buttonText = label;
        data.OnButtonClick = onClick;
        local initializer = Settings.CreateSettingInitializer('TransmogUpgradeMaster_SettingsButtonControlTemplate', data);
        initializer:AddSearchTags(label);
        self.layout:AddInitializer(initializer);

        return initializer;
    end

    --- @param label string
    --- @param onClick fun(button: Button, buttonIndex: number)
    --- @param tooltip string?
    --- @param buttonTexts string[]
    --- @return SettingsListElementInitializer initializer
    function Config:MakeMultiButton(label, onClick, tooltip, buttonTexts)
        local data = {
            name = label,
            tooltip = tooltip,
            buttonTexts = buttonTexts,
            OnButtonClick = onClick,
        };
        local initializer = Settings.CreateSettingInitializer('TransmogUpgradeMaster_SettingsMultiButtonControlTemplate', data);
        initializer:AddSearchTags(label);
        self.layout:AddInitializer(initializer);

        return initializer;
    end

    --- @param sectionName string|fun(): string
    --- @return SettingsExpandableSectionInitializer initializer
    --- @return fun(): boolean isExpanded
    function Config:MakeExpandableSection(sectionName)
        local nameGetter = sectionName;
        if type(sectionName) == "string" then
            nameGetter = function() return sectionName; end
        end
        local expandInitializer = CreateSettingsExpandableSectionInitializer(nameGetter());
        expandInitializer.data.nameGetter = nameGetter;
        function expandInitializer:GetExtent()
            return 25;
        end

        local origInitFrame = expandInitializer.InitFrame;
        function expandInitializer:InitFrame(frame)
            self.data.name = self.data.nameGetter();

            origInitFrame(self, frame);

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

            frame:EvaluateVisibility(self.data.expanded);
        end

        self.layout:AddInitializer(expandInitializer);

        return expandInitializer, function() return expandInitializer.data.expanded; end;
    end

    --- @param label string
    --- @param settingKey string|number
    --- @param tooltip string?
    --- @param defaultValue ColorRGBData?
    --- @param dbTableOverride table?
    --- @return SettingsListElementInitializer initializer
    --- @return AddOnSettingMixin setting
    function Config:MakeColorPicker(label, settingKey, tooltip, defaultValue, dbTableOverride)
        local variable = self:GetUniqueVariable();
        if defaultValue == nil then
            defaultValue = self.defaults[settingKey];
            if defaultValue == nil then
                error('No default value provided')
            end
        end

        --- @type AddOnSettingMixin
        local setting = Settings.RegisterAddOnSetting(
            self.category,
            variable,
            settingKey,
            dbTableOverride or self.db,
            'table',
            label,
            defaultValue
        );
        local data = Settings.CreateSettingInitializerData(setting, nil, tooltip);

        local initializer = Settings.CreateSettingInitializer('TransmogUpgradeMaster_SettingsColorControlTemplate', data);
        self.layout:AddInitializer(initializer);

        return initializer, setting;
    end

    --- @return SettingsListElementInitializer initializer
    function Config:MakeDonationPrompt()
        self:MakeText("Addon development takes a large amount of time and effort. If you enjoy using Transmog Upgrade Master, please consider supporting its development by donating. Your support helps ensure the continued improvement and maintenance of the addon. Thank you for your generosity!");

        local function onClick(_, buttonIndex)
            if buttonIndex == 1 then
                self:CopyText("https://www.paypal.com/cgi-bin/webscr?hosted_button_id=C8HP9WVKPCL8C&item_name=Transmog+Upgrade+Master&cmd=_s-xclick");
            else
                self:CopyText("https://buymeacoffee.com/numy");
            end
        end

        return self:MakeMultiButton(
            "Donate",
            onClick,
            "If you enjoy using Transmog Upgrade Master, consider supporting its development with a donation.",
            {
                PAYPAL_TEXTURE .. "PayPal",
                COFFEE_TEXTURE .. "BuyMeACoffee",
            }
        );
    end

    TransmogUpgradeMaster_SettingsColorControlMixin = CreateFromMixins(SettingsControlMixin);
    do
        --- @class TUM_Config_ColorControlMixin
        local mixin = TransmogUpgradeMaster_SettingsColorControlMixin;

        --- @param colorData ColorRGBData
        function mixin:SetColorVisual(colorData)
            local r, g, b = colorData.r, colorData.g, colorData.b;
            self.Text:SetTextColor(r, g, b);
            self.ColorSwatch.Color:SetVertexColor(r, g, b);
        end

        function mixin:Init(initializer)
            SettingsControlMixin.Init(self, initializer);

            -- "SetCallback" actually registers the callback, it doesn't replace it
            self.data.setting:SetValueChangedCallback(function(_, value) self:SetColorVisual(value) end);
            self:SetColorVisual(self.data.setting:GetValue());

            self.ColorSwatch:SetScript("OnClick", function() self:OpenColorPicker() end);
            self.ColorSwatch:SetScript("OnEnter", function(button)
                GameTooltip:SetOwner(button, "ANCHOR_TOP");
                GameTooltip_AddHighlightLine(GameTooltip, initializer:GetName());
                GameTooltip_AddNormalLine(GameTooltip, initializer:GetTooltip());
                GameTooltip:Show();
            end);
            self.ColorSwatch:SetScript("OnLeave", function() GameTooltip:Hide(); end);

            self:EvaluateState();
        end

        function mixin:EvaluateState()
            SettingsControlMixin.EvaluateState(self);
            local enabled = self:IsEnabled();

            self.ColorSwatch:SetEnabled(enabled);
            if enabled then
                self.Text:SetTextColor(self.ColorSwatch.Color:GetVertexColor());
            else
                self.Text:SetTextColor(GRAY_FONT_COLOR:GetRGB());
            end
        end

        function mixin:OpenColorPicker()
            local color = self.data.setting:GetValue();

            ColorPickerFrame:SetupColorPickerAndShow({
                r = color.r,
                g = color.g,
                b = color.b,
                opacity = color.a or nil,
                hasOpacity = color.a ~= nil,
                swatchFunc = function()
                    local r, g, b = ColorPickerFrame:GetColorRGB();
                    local a = ColorPickerFrame:GetColorAlpha();

                    self.data.setting:SetValue({ r = r, g = g, b = b, a = a, });
                end,
                cancelFunc = function()
                    local r, g, b, a = ColorPickerFrame:GetPreviousValues();

                    self.data.setting:SetValue({ r = r, g = g, b = b, a = a, });
                end,
            });
        end
    end

    TransmogUpgradeMaster_SettingsButtonControlMixin = CreateFromMixins(SettingsListElementMixin);
    do
        --- @class TUM_Config_ButtonControlMixin
        local mixin = TransmogUpgradeMaster_SettingsButtonControlMixin;

        function mixin:Init(initializer)
            SettingsListElementMixin.Init(self, initializer);

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

        function mixin:EvaluateState()
            SettingsListElementMixin.EvaluateState(self);
            local enabled = SettingsControlMixin.IsEnabled(self);

            self.Button:SetEnabled(enabled);
            self:DisplayEnabled(enabled);
        end
    end

    TransmogUpgradeMaster_SettingsMultiButtonControlMixin = CreateFromMixins(SettingsListElementMixin);
    do
        --- @class TUM_Config_MultiButtonControlMixin
        local mixin = TransmogUpgradeMaster_SettingsMultiButtonControlMixin;

        function mixin:Init(initializer)
            SettingsListElementMixin.Init(self, initializer);
            --- @param button Button
            local function onClick(button)
                self.data.OnButtonClick(button, button:GetID());
            end
            --- @param button Button
            local function onEnter(button)
                GameTooltip:SetOwner(button, "ANCHOR_TOP");
                GameTooltip_AddHighlightLine(GameTooltip, initializer:GetName());
                GameTooltip_AddNormalLine(GameTooltip, initializer:GetTooltip());
                GameTooltip:Show();
            end
            local function onLeave() GameTooltip:Hide(); end
            self.ButtonContainer.buttonPool:ReleaseAll();

            local anchorTarget;
            for i, buttonText in ipairs(self.data.buttonTexts) do
                local button = self.ButtonContainer.buttonPool:Acquire();
                button:SetID(i);
                button:SetTextToFit(buttonText);
                button:Show();
                if i == 1 then
                    button:SetPoint("LEFT", self.ButtonContainer, "LEFT", 0, 0);
                else
                    button:SetPoint("LEFT", anchorTarget, "RIGHT", 5, 0);
                end
                button:SetScript("OnClick", onClick);
                button:SetScript("OnEnter", onEnter);
                button:SetScript("OnLeave", onLeave);
                anchorTarget = button;
            end

            self:EvaluateState();
        end

        function mixin:EvaluateState()
            SettingsListElementMixin.EvaluateState(self);
            local enabled = SettingsControlMixin.IsEnabled(self);

            for button in self.ButtonContainer.buttonPool:EnumerateActive() do
                button:SetEnabled(enabled);
            end
            self:DisplayEnabled(enabled);
        end
    end

    TransmogUpgradeMaster_SettingsTextMixin = CreateFromMixins(DefaultTooltipMixin);
    do
        --- @class TUM_Config_TextMixin
        local mixin = TransmogUpgradeMaster_SettingsTextMixin;

        function mixin:Init(initializer)
            local data = initializer:GetData();
            self.Text:SetText(data.name);
            self.Text:SetHeight(data.extent);
            self:SetHeight(data.extent);
            local indent = data.indent or 0;
            self.Text:SetPoint('TOPLEFT', (7 + (indent * 15)), 0);
        end
    end

    TransmogUpgradeMaster_SettingsHeaderMixin = CreateFromMixins(DefaultTooltipMixin);
    do
        --- @class TUM_Config_HeaderMixin
        local mixin = TransmogUpgradeMaster_SettingsHeaderMixin;

        function mixin:Init(initializer)
            local data = initializer:GetData();
            self.Title:SetTextToFit(data.name);
            local indent = data.indent or 0;
            self.Title:SetPoint('TOPLEFT', (7 + (indent * 15)), -16);

            self:SetCustomTooltipAnchoring(self.Title, "ANCHOR_RIGHT");

            self:SetTooltipFunc(function() Settings.InitTooltip(initializer:GetName(), initializer:GetTooltip()) end);
        end
    end
end

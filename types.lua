--- @meta _

--- @alias SyndicatorContainer "equipped" | "bank" | "bag" | number

--- @class SyndicatorSearchResult
--- @field itemLink string
--- @field itemID number
--- @field isBound boolean
--- @field source { container: SyndicatorContainer, character: string?, warband: number?, guild: string? }
--- @field quality Enum.ItemQuality

--- @class TUM_UI_ResultData
--- @field slot number
--- @field tier TUM_Tier
--- @field knownFromOtherItem boolean
--- @field requiresUpgrade boolean
--- @field requiresCatalyse boolean
--- @field itemLink string
--- @field location string
--- @field upgradeLevel number # upgrade track level, 1-6/8
--- @field maxUpgradeLevel number # 6 or 8
--- @field distance number # 0 = same character, 100+ = warband bank, 1000 = different character.

--- @class TUM_AppearanceMissingResult
--- @field canCatalyse boolean? # whether the item can be catalysed; if false, the catalystAppearanceMissing values will be nil
--- @field canUpgrade boolean? # whether the item can be upgraded to the next tier; if false, the upgradeAppearanceMissing values will be nil
--- @field catalystAppearanceMissing boolean? # true if the item will teach a new appearance when catalysed
--- @field catalystUpgradeAppearanceMissing boolean? # true if the item will teach a new appearance when catalysed AND upgraded to the next tier
--- @field upgradeAppearanceMissing boolean? # true if the item will teach a new appearance when upgraded to the next tier
--- @field catalystAppearanceLearnedFromOtherItem boolean # true if the appearance is learned from another item
--- @field catalystUpgradeAppearanceLearnedFromOtherItem boolean # true if the appearance is learned from another item
--- @field upgradeAppearanceLearnedFromOtherItem boolean # true if the appearance is learned from another item
--- @field contextData TUM_ContextData? # some additional data about the item, nil if the item is not cached; most fields will be nil if the item cannot teach any appearance

--- @class TUM_ContextData
--- @field tier TUM_Tier?
--- @field slot Enum.InventoryType?
--- @field itemID number?
--- @field seasonID number?

--- @class SyndicatorCharacterData
--- @field details SyndicatorCharacterDetails

--- @class SyndicatorCharacterDetails
--- @field class number # classID
--- @field className ClassFile

--- @class TUM_Config_ColorSwatchButton: Button, ColorSwatchTemplate

--- @class TUM_Config_ColorControlMixin : SettingsListElementTemplate, SettingsControlMixin
--- @field ColorSwatch TUM_Config_ColorSwatchButton
--- @field data TUM_Config_SettingData

--- @class TUM_Config_ButtonControlMixin : SettingsListElementTemplate
--- @field Button UIPanelButtonTemplate
--- @field data TUM_Config_ButtonSettingData

--- @class TUM_Config_ButtonSettingData
--- @field name string
--- @field tooltip string
--- @field buttonText string
--- @field OnButtonClick fun(button: Button)

--- @class TUM_Config_MultiButtonControlMixin : SettingsListElementTemplate
--- @field ButtonContainer TUM_Config_MultiButton_ButtonContainer
--- @field data TUM_Config_MultiButtonSettingData

--- @class TUM_Config_MultiButton_ButtonContainer
--- @field buttonPool FramePool<UIPanelButtonTemplate>

--- @class TUM_Config_MultiButtonSettingData
--- @field name string
--- @field tooltip string
--- @field buttonTexts string[]
--- @field OnButtonClick fun(button: Button, buttonIndex: number)

--- @class TUM_Config_TextMixin: Frame, DefaultTooltipMixin
--- @field Text FontString

--- @class TUM_Config_SettingData
--- @field setting AddOnSettingMixin
--- @field name string
--- @field options table
--- @field tooltip string

--- @class TUM_Config_SliderOptions: SettingsSliderOptionsMixin
--- @field minValue number
--- @field maxValue number
--- @field steps number

--- @param minValue number? # Minimum value (default: 0)
--- @param maxValue number? # Maximum value (default: 1)
--- @param rate number? # Size between steps; Defaults to 100 steps
--- @return TUM_Config_SliderOptions
function Settings.CreateSliderOptions(minValue, maxValue, rate) end

--- @alias TUM_Config_DropDownOptions { text: string, label: string?, tooltip: string?, value: any }[]

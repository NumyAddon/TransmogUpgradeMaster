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
--- @field locationCharacter string
--- @field locationContainer string
--- @field upgradeLevel number # upgrade track level, 1-6/8
--- @field maxUpgradeLevel number # 6 or 8
--- @field distance number # 0 = same character, 100+ = warband bank, 1000 = different character.

--- @class TUM_UI_TodoList_ElementFrame: Button

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
--- @field isPvpItem boolean?

--- @class SyndicatorCharacterData
--- @field details SyndicatorCharacterDetails

--- @class SyndicatorCharacterDetails
--- @field class number # classID
--- @field className ClassFile

--- @param label string # User facing text string describing this corner option.
--- @param id string unique value to be used internally for the settings
--- @param onUpdate fun(cornerFrame: Region, itemDetails: BaganatorItemDetails): boolean|nil
---  Function to update the frame placed in the corner.
---  Return true to cause this corner's visual to show.
---  Return false to indicate no visual will be shown.
---  Return nil to indicate the item information needed to make the display determination isn't available yet.
--- @param onInit fun(itemButton: Frame): Region
---  Called once for each item icon to create the frame to show in the icon corner.
---  Return the frame to be positioned in the corner.
---  This frame will be hidden/shown/have its parent changed to control visiblity.
---  It may have the fields padding (number, multiplier for the padding used from the icon's corner) and sizeFont (boolean sets the font size for a font string to the user configured size)
--- @param defaultPosition nil|{corner: BaganatorCornerWidgetCorner, priority: number}
---  corner: string (top_left, top_right, bottom_left, bottom_right)
---  priority: number (priority for the corner to be placed at in the corner sort order)
function Baganator.API.RegisterCornerWidget(label, id, onUpdate, onInit, defaultPosition) end

--- @alias BaganatorCornerWidgetCorner "top_left" | "top_right" | "bottom_left" | "bottom_right"

--- @class BaganatorItemDetails
--- @field itemLink string
--- @field itemID number

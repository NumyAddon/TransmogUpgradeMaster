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

local _, ns = ...

--- @type TransmogUpgradeMaster
local TUM = ns.core

--- The function signatures in this file will remain stable, though no guarantees are made.
--- @class TransmogUpgradeMaster_API
local api = {}

TransmogUpgradeMaster_API = api

--- Transmog data is cached on login, until the cache is fully warmed up, the other APIs may return nils instead of booleans
--- @return boolean isCacheWarmedUp
--- @return number progress # a number between 0 and 1, where 1 means caching has finished
function api.IsCacheWarmedUp()
    return TUM:IsCacheWarmedUp()
end

--- Check whether an item can teach new appearances when upgraded and/or catalysed
---
--- The "canCatalyse" and "canUpgrade" return values will be nil if the item is not cached
--- It is up to you to ensure that the item gets cached, and then call this API again
---
--- The "appearance missing" return values will be nil if the item cannot be upgraded and/or catalysed, or if the required information is missing from the cache.
--- It's possible for a only subset of "appearance missing" return values to be nil while the cache is loading
---
--- You can optionally pass a classID to specify the class for which you want to check the catalyst appearance. This is useful for BoE or warbound items.
---
--- @param itemLink string
--- @param classID number? # defaults to the player's class
--- @return boolean? canCatalyse # whether the item can be catalysed; if false, the catalystAppearanceMissing return values will be nil
--- @return boolean? canUpgrade # whether the item can be upgraded to the next tier; if false, the upgradeAppearanceMissing return values will be nil
--- @return boolean? catalystAppearanceMissing # true if the item will teach a new appearance when catalysed
--- @return boolean? catalystUpgradeAppearanceMissing # true if the item will teach a new appearance when catalysed AND upgraded to the next tier
--- @return boolean? upgradeAppearanceMissing # true if the item will teach a new appearance when upgraded to the next tier
--- @return boolean catalystAppearanceLearnedFromOtherItem # true if the appearance is learned from another item
--- @return boolean catalystUpgradeAppearanceLearnedFromOtherItem # true if the appearance is learned from another item
--- @return boolean upgradeAppearanceLearnedFromOtherItem # true if the appearance is learned from another item
function api.IsAppearanceMissing(itemLink, classID)
    local result = TUM:IsAppearanceMissing(itemLink, classID)

    return
        result.canCatalyse,
        result.canUpgrade,
        result.catalystAppearanceMissing,
        result.catalystUpgradeAppearanceMissing,
        result.upgradeAppearanceMissing,
        result.catalystAppearanceLearnedFromOtherItem,
        result.catalystUpgradeAppearanceLearnedFromOtherItem,
        result.upgradeAppearanceLearnedFromOtherItem
end

--- Identical to IsAppearanceMissing, but returns a table instead
--- @see api.IsAppearanceMissing
--- @param itemLink string
--- @param classID number? # defaults to the player's class
--- @return TUM_AppearanceMissingResult result
function api.GetAppearanceMissingData(itemLink, classID)
    return TUM:IsAppearanceMissing(itemLink, classID)
end

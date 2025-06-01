local _, ns = ...;
---@class TransmogUpgradeMasterData
local data = {};
ns.data = data;

--- could potentially be extracted from C_TransmogSets.GetAllSets() more or less, but meh, effort, and requires linking to a specific season still anyway
--- @type table<number, table<number, {[1]:number, [2]:number, [3]:number, [4]:number}>> [m+ seasonID][classID] = { [1] = lfrSetID, [2] = normalSetID, [3] = heroicSetID, [4] = mythicSetID }
data.sets = {
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
data.setSourceIDs = {
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

--- @type table<number, table<number, table<number, number>>> # [m+ seasonID][classID][slotID] = itemID
data.catalystItems = {
    -- TWW S2
    [14] = {
        [1] = { -- Warrior
            [1] = 229235, -- Enforcer's Backalley Faceshield
            [3] = 229233, -- Enforcer's Backalley Shoulderplates
            [5] = 229238, -- Enforcer's Backalley Vestplate
            [6] = 229232, -- Enforcer's Backalley Girdle
            [7] = 229234, -- Enforcer's Backalley Chausses
            [8] = 229237, -- Enforcer's Backalley Stompers
            [9] = 229231, -- Enforcer's Backalley Bindings
            [10] = 229236, -- Enforcer's Backalley Crushers
            [16] = 229230, -- Enforcer's Backalley Allegiance
        },
        [2] = { -- Paladin
            [1] = 229244, -- Aureate Sentry's Pledge
            [3] = 229242, -- Aureate Sentry's Roaring Will
            [5] = 229247, -- Aureate Sentry's Encasement
            [6] = 229241, -- Aureate Sentry's Greatbelt
            [7] = 229243, -- Aureate Sentry's Legguards
            [8] = 229246, -- Aureate Sentry's Greaves
            [9] = 229240, -- Aureate Sentry's Clasps
            [10] = 229245, -- Aureate Sentry's Gauntlets
            [16] = 229239, -- Aureate Sentry's Gilded Cloak
        },
        [3] = { -- Hunter
            [1] = 229271, -- Tireless Collector's Chained Cowl
            [3] = 229269, -- Tireless Collector's Hunted Heads
            [5] = 229274, -- Tireless Collector's Battlegear
            [6] = 229268, -- Tireless Collector's First Kill
            [7] = 229270, -- Tireless Collector's Armored Breeches
            [8] = 229273, -- Tireless Collector's Spiked Cleats
            [9] = 229267, -- Tireless Collector's Manacles
            [10] = 229272, -- Tireless Collector's Gauntlets
            [16] = 229266, -- Tireless Collector's Veilmesh
        },
        [4] = { -- Rogue
            [1] = 229289, -- Spectral Gambler's Damned Visage
            [3] = 229287, -- Spectral Gambler's Bladed Mantle
            [5] = 229292, -- Spectral Gambler's Vest
            [6] = 229286, -- Spectral Gambler's Pocket Ace
            [7] = 229288, -- Spectral Gambler's Pantaloons
            [8] = 229291, -- Spectral Gambler's Cavaliers
            [9] = 229285, -- Spectral Gambler's Shackles
            [10] = 229290, -- Spectral Gambler's Gloves
            [16] = 229284, -- Spectral Gambler's Shawl
        },
        [5] = { -- Priest
            [1] = 229334, -- Confessor's Unshakable Halo
            [3] = 229332, -- Confessor's Unshakable Radiance
            [5] = 229337, -- Confessor's Unshakable Vestment
            [6] = 229331, -- Confessor's Unshakable Ornament
            [7] = 229333, -- Confessor's Unshakable Leggings
            [8] = 229336, -- Confessor's Unshakable Boots
            [9] = 229330, -- Confessor's Unshakable Faulds
            [10] = 229335, -- Confessor's Unshakable Mitts
            [16] = 229329, -- Confessor's Unshakable Lightcover
        },
        [6] = { -- Death Knight
            [1] = 229253, -- Cauldron Champion's Crown
            [3] = 229251, -- Cauldron Champion's Screamplate
            [5] = 229256, -- Cauldron Champion's Ribcage
            [6] = 229250, -- Cauldron Champion's Title Belt
            [7] = 229252, -- Cauldron Champion's Tattered Cuisses
            [8] = 229255, -- Cauldron Champion's Greatboots
            [9] = 229249, -- Cauldron Champion's Wraps
            [10] = 229254, -- Cauldron Champion's Fistguards
            [16] = 229248, -- Cauldron Champion's Spined Cloak
        },
        [7] = { -- Shaman
            [1] = 229262, -- Gale Sovereign's Charged Hood
            [3] = 229260, -- Gale Sovereign's Zephyrs
            [5] = 229265, -- Gale Sovereign's Clouded Hauberk
            [6] = 229259, -- Gale Sovereign's Ritual Belt
            [7] = 229261, -- Gale Sovereign's Pantaloons
            [8] = 229264, -- Gale Sovereign's Stormboots
            [9] = 229258, -- Gale Sovereign's Bracers
            [10] = 229263, -- Gale Sovereign's Grasps
            [16] = 229257, -- Gale Sovereign's Breeze
        },
        [8] = { -- Mage
            [1] = 229343, -- Aspectral Emissary's Crystalline Cowl
            [3] = 229341, -- Aspectral Emissary's Arcane Vents
            [5] = 229346, -- Aspectral Emissary's Primal Robes
            [6] = 229340, -- Aspectral Emissary's Cummerbund
            [7] = 229342, -- Aspectral Emissary's Trousers
            [8] = 229345, -- Aspectral Emissary's Slippers
            [9] = 229339, -- Aspectral Emissary's Gembands
            [10] = 229344, -- Aspectral Emissary's Hardened Grasp
            [16] = 229338, -- Aspectral Emissary's Chosen Drape
        },
        [9] = { -- Warlock
            [1] = 229325, -- Spliced Fiendtrader's Transcendence
            [3] = 229323, -- Spliced Fiendtrader's Loyal Servants
            [5] = 229328, -- Spliced Fiendtrader's Surgical Gown
            [6] = 229322, -- Spliced Fiendtrader's Sash
            [7] = 229324, -- Spliced Fiendtrader's Skin Tights
            [8] = 229327, -- Spliced Fiendtrader's Soles
            [9] = 229321, -- Spliced Fiendtrader's Skinbands
            [10] = 229326, -- Spliced Fiendtrader's Demonic Grasp
            [16] = 229320, -- Spliced Fiendtrader's Shady Cover
        },
        [10] = { -- Monk
            [1] = 229298, -- Ageless Serpent's Mane
            [3] = 229296, -- Ageless Serpent's Shoulderpads
            [5] = 229301, -- Ageless Serpent's Inked Coils
            [6] = 229295, -- Ageless Serpent's Rope Belt
            [7] = 229297, -- Ageless Serpent's Leggings
            [8] = 229300, -- Ageless Serpent's Ankleweights
            [9] = 229294, -- Ageless Serpent's Cuffs
            [10] = 229299, -- Ageless Serpent's Handguards
            [16] = 229293, -- Ageless Serpent's Flowing Grace
        },
        [11] = { -- Druid
            [1] = 229307, -- Branches of Reclaiming Blight
            [3] = 229305, -- Jaws of Reclaiming Blight
            [5] = 229310, -- Robes of Reclaiming Blight
            [6] = 229304, -- Wickerbelt of Reclaiming Blight
            [7] = 229306, -- Breeches of Reclaiming Blight
            [8] = 229309, -- Moccasins of Reclaiming Blight
            [9] = 229303, -- Knots of Reclaiming Blight
            [10] = 229308, -- Grips of Reclaiming Blight
            [16] = 229302, -- Leaves of Reclaiming Blight
        },
        [12] = { -- Demon Hunter
            [1] = 229316, -- Fel-Dealer's Visor
            [3] = 229314, -- Fel-Dealer's Recycled Reavers
            [5] = 229319, -- Fel-Dealer's Soul Engine
            [6] = 229313, -- Fel-Dealer's Waistwrap
            [7] = 229315, -- Fel-Dealer's Fur Kilt
            [8] = 229318, -- Fel-Dealer's Smugglers
            [9] = 229312, -- Fel-Dealer's Cuffs
            [10] = 229317, -- Fel-Dealer's Underhandlers
            [16] = 229311, -- Fel-Dealer's Fur Shawl
        },
        [13] = { -- Evoker
            [1] = 229280, -- Opulent Treasurescale's Crowned Jewel
            [3] = 229278, -- Opulent Treasurescale's Gleaming Mantle
            [5] = 229283, -- Opulent Treasurescale's Tunic
            [6] = 229277, -- Opulent Treasurescale's Radiant Chain
            [7] = 229279, -- Opulent Treasurescale's Petticoat
            [8] = 229282, -- Opulent Treasurescale's Boots
            [9] = 229276, -- Opulent Treasurescale's Vambraces
            [10] = 229281, -- Opulent Treasurescale's Gold-Counters
            [16] = 229275, -- Opulent Treasurescale's Scalecloak
        },
    },
}

--- @type table<number, number> # [itemID] = seasonID
data.catalystItemByID = {};
do
    for seasonID, classes in pairs(data.catalystItems) do
        for _, slots in pairs(classes) do
            for _, itemID in pairs(slots) do
                data.catalystItemByID[itemID] = seasonID;
            end
        end
    end
end


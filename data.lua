--- @class TUM_NS
local ns = select(2, ...);

---@class TransmogUpgradeMasterData
local data = {};
ns.data = data;

local SL_S4 = 8;
local DF_S1 = 9;
local DF_S2 = 10;
local DF_S3 = 11;
local DF_S4 = 12;
local TWW_S1 = 13;
local TWW_S2 = 14;
local TWW_S3 = 15;
local MN_S1 = 17;

local TIER_LFR = 1;
local TIER_NORMAL = 2;
local TIER_HEROIC = 3;
local TIER_MYTHIC = 4;

local HEAD = Enum.InventoryType.IndexHeadType;
local SHOULDER = Enum.InventoryType.IndexShoulderType;
local CHEST = Enum.InventoryType.IndexChestType;
local WAIST = Enum.InventoryType.IndexWaistType;
local LEGS = Enum.InventoryType.IndexLegsType;
local FEET = Enum.InventoryType.IndexFeetType;
local WRIST = Enum.InventoryType.IndexWristType;
local HAND = Enum.InventoryType.IndexHandType;
local CLOAK = Enum.InventoryType.IndexCloakType;

local WARRIOR = 1;
local PALADIN = 2;
local HUNTER = 3;
local ROGUE = 4;
local PRIEST = 5;
local DEATHKNIGHT = 6;
local SHAMAN = 7;
local MAGE = 8;
local WARLOCK = 9;
local MONK = 10;
local DRUID = 11;
local DEMONHUNTER = 12;
local EVOKER = 13;

local isMidnight = select(4, GetBuildInfo()) >= 120000;
data.currentSeason = isMidnight and MN_S1 or TWW_S3;

data.constants = {};
do
    --- @enum TUM_Tier
    data.constants.tiers = {
        lfr = TIER_LFR,
        normal = TIER_NORMAL,
        heroic = TIER_HEROIC,
        mythic = TIER_MYTHIC,
    };

    --- @enum TUM_Season
    data.constants.seasons = {
        SL_S4 = SL_S4,
        DF_S1 = DF_S1,
        DF_S2 = DF_S2,
        DF_S3 = DF_S3,
        DF_S4 = DF_S4,
        TWW_S1 = TWW_S1,
        TWW_S2 = TWW_S2,
        TWW_S3 = TWW_S3,
        MN_S1 = MN_S1,
    };
    data.constants.seasonNames = {
        [SL_S4] = 'SL S4',
        [DF_S1] = 'DF S1',
        [DF_S2] = 'DF S2',
        [DF_S3] = 'DF S3',
        [DF_S4] = 'DF S4',
        [TWW_S1] = 'TWW S1',
        [TWW_S2] = 'TWW S2',
        [TWW_S3] = 'TWW S3',
        [MN_S1] = 'MN S1',
    };

    -- see https://wago.tools/db2/SharedString
    local VETERAN_TRACK_STRING_ID = 972;
    local CHAMPION_TRACK_STRING_ID = 973;
    local HERO_TRACK_STRING_ID = 974;
    local MYTH_TRACK_STRING_ID = 978;
    data.constants.trackStringIDToTiers = {
        [VETERAN_TRACK_STRING_ID] = data.constants.tiers.lfr,
        [CHAMPION_TRACK_STRING_ID] = data.constants.tiers.normal,
        [HERO_TRACK_STRING_ID] = data.constants.tiers.heroic,
        [MYTH_TRACK_STRING_ID] = data.constants.tiers.mythic,
    };

    --- @type table<TUM_Season, number> # [seasonID] = upgrade level where the transmog changes to the next tier
    data.constants.upgradeTransmogBreakpoints = {
        [SL_S4] = 5,
        [DF_S1] = 5,
        [DF_S2] = 5,
        [DF_S3] = 5,
        [DF_S4] = 5,
        [TWW_S1] = 5,
        [TWW_S2] = 5,
        [TWW_S3] = 5,
        [MN_S1] = 6,
    };

    --- @type table<number, {track: TUM_Tier, level: number}> # [bonusID] = { track = TUM_Tier, level = number }
    data.constants.upgradeTrackBonusIDs = {
        [11969] = { track = TIER_LFR, level = 1 }, -- Veteran 1
        [11970] = { track = TIER_LFR, level = 2 }, -- Veteran 2
        [11971] = { track = TIER_LFR, level = 3 }, -- Veteran 3
        [11972] = { track = TIER_LFR, level = 4 }, -- Veteran 4
        [11973] = { track = TIER_LFR, level = 5 }, -- Veteran 5
        [11974] = { track = TIER_LFR, level = 6 }, -- Veteran 6
        [11975] = { track = TIER_LFR, level = 7 }, -- Veteran 7
        [11976] = { track = TIER_LFR, level = 8 }, -- Veteran 8
        [11977] = { track = TIER_NORMAL, level = 1 }, -- Champion 1
        [11978] = { track = TIER_NORMAL, level = 2 }, -- Champion 2
        [11979] = { track = TIER_NORMAL, level = 3 }, -- Champion 3
        [11980] = { track = TIER_NORMAL, level = 4 }, -- Champion 4
        [11981] = { track = TIER_NORMAL, level = 5 }, -- Champion 5
        [11982] = { track = TIER_NORMAL, level = 6 }, -- Champion 6
        [11983] = { track = TIER_NORMAL, level = 7 }, -- Champion 7
        [11984] = { track = TIER_NORMAL, level = 8 }, -- Champion 8
        [11985] = { track = TIER_HEROIC, level = 1 }, -- Hero 1
        [11986] = { track = TIER_HEROIC, level = 2 }, -- Hero 2
        [11987] = { track = TIER_HEROIC, level = 3 }, -- Hero 3
        [11988] = { track = TIER_HEROIC, level = 4 }, -- Hero 4
        [11989] = { track = TIER_HEROIC, level = 5 }, -- Hero 5
        [11990] = { track = TIER_HEROIC, level = 6 }, -- Hero 6
        [12371] = { track = TIER_HEROIC, level = 7 }, -- Hero 7
        [12372] = { track = TIER_HEROIC, level = 8 }, -- Hero 8
        [11991] = { track = TIER_MYTHIC, level = 1 }, -- Myth 1
        [11992] = { track = TIER_MYTHIC, level = 2 }, -- Myth 2
        [11993] = { track = TIER_MYTHIC, level = 3 }, -- Myth 3
        [11994] = { track = TIER_MYTHIC, level = 4 }, -- Myth 4
        [11995] = { track = TIER_MYTHIC, level = 5 }, -- Myth 5
        [11996] = { track = TIER_MYTHIC, level = 6 }, -- Myth 6
        [12376] = { track = TIER_MYTHIC, level = 7 }, -- Myth 7
        [12375] = { track = TIER_MYTHIC, level = 8 }, -- Myth 8
    };

    data.constants.conquestItemModID = 159;
    data.constants.itemModIDTiers = {
        [4] = data.constants.tiers.lfr,
        [0] = data.constants.tiers.normal,
        [1] = data.constants.tiers.heroic,
        [3] = data.constants.tiers.mythic,
    };

    local difficultyTierFormat = "|cFF 0FF 0%s|r"; -- no idea why the color is formatted this way..
    data.constants.difficultyTierStrings = {
        [data.constants.tiers.lfr] = difficultyTierFormat:format(PLAYER_DIFFICULTY3),
        [data.constants.tiers.normal] = difficultyTierFormat:format(PLAYER_DIFFICULTY1), -- usually the line is just absent instead
        [data.constants.tiers.heroic] = difficultyTierFormat:format(PLAYER_DIFFICULTY2),
        [data.constants.tiers.mythic] = difficultyTierFormat:format(PLAYER_DIFFICULTY6),
    };

    data.constants.itemContextTiers = {
        [Enum.ItemCreationContext.RaidFinder] = data.constants.tiers.lfr,
        [Enum.ItemCreationContext.RaidNormal] = data.constants.tiers.normal,
        [Enum.ItemCreationContext.RaidHeroic] = data.constants.tiers.heroic,
        [Enum.ItemCreationContext.RaidMythic] = data.constants.tiers.mythic,
    };

    local CLOTH = Enum.ItemArmorSubclass.Cloth;
    local LEATHER = Enum.ItemArmorSubclass.Leather;
    local MAIL = Enum.ItemArmorSubclass.Mail;
    local PLATE = Enum.ItemArmorSubclass.Plate;
    data.constants.classArmorTypeMap = {
        [WARRIOR] = PLATE,
        [PALADIN] = PLATE,
        [HUNTER] = MAIL,
        [ROGUE] = LEATHER,
        [PRIEST] = CLOTH,
        [DEATHKNIGHT] = PLATE,
        [SHAMAN] = MAIL,
        [MAGE] = CLOTH,
        [WARLOCK] = CLOTH,
        [MONK] = LEATHER,
        [DRUID] = LEATHER,
        [DEMONHUNTER] = LEATHER,
        [EVOKER] = MAIL,
    };

    data.constants.catalystSlots = {
        [Enum.InventoryType.IndexHeadType] = INVSLOT_HEAD,
        [Enum.InventoryType.IndexShoulderType] = INVSLOT_SHOULDER,
        [Enum.InventoryType.IndexChestType] = INVSLOT_CHEST,
        [Enum.InventoryType.IndexWaistType] = INVSLOT_WAIST,
        [Enum.InventoryType.IndexLegsType] = INVSLOT_LEGS,
        [Enum.InventoryType.IndexFeetType] = INVSLOT_FEET,
        [Enum.InventoryType.IndexWristType] = INVSLOT_WRIST,
        [Enum.InventoryType.IndexHandType] = INVSLOT_HAND,
        [Enum.InventoryType.IndexCloakType] = INVSLOT_BACK,
    };

    data.constants.mailableBindings = {
        [Enum.TooltipDataItemBinding.Account] = true,
        [Enum.TooltipDataItemBinding.AccountUntilEquipped] = true,
        [Enum.TooltipDataItemBinding.BindOnEquip] = true,
        [Enum.TooltipDataItemBinding.BindOnUse] = true,
        [Enum.TooltipDataItemBinding.BindToAccount] = true,
        [Enum.TooltipDataItemBinding.BindToAccountUntilEquipped] = true,
        [Enum.TooltipDataItemBinding.BindToBnetAccount] = true,
    };
end

--- @type table<TUM_Season, number> # [seasonID] = currencyID
data.currency = {
    [TWW_S2] = 3116,
    [TWW_S3] = 3269,
    [MN_S1] = 3378,
};

--- could potentially be extracted from C_TransmogSets.GetAllSets() more or less, but meh, effort, and requires linking to a specific season still anyway
--- @type table<TUM_Season, table<number, {[TUM_Tier]:number}>> [m+ seasonID][classID] = { [tier] = setID }
data.sets = {
    [TWW_S2] = {
        [WARRIOR] = { 4326, 4325, 4323, 4324 },
        [PALADIN] = { 4306, 4305, 4303, 4304 },
        [HUNTER] = { 4294, 4293, 4291, 4292 },
        [ROGUE] = { 4314, 4313, 4311, 4312 },
        [PRIEST] = { 4310, 4309, 4307, 4308 },
        [DEATHKNIGHT] = { 4278, 4277, 4275, 4276 },
        [SHAMAN] = { 4318, 4317, 4315, 4316 },
        [MAGE] = { 4298, 4297, 4295, 4296 },
        [WARLOCK] = { 4322, 4321, 4319, 4320 },
        [MONK] = { 4302, 4301, 4299, 4300 },
        [DRUID] = { 4286, 4285, 4283, 4284 },
        [DEMONHUNTER] = { 4282, 4281, 4279, 4280 },
        [EVOKER] = { 4290, 4289, 4287, 4288 },
    },
    [TWW_S3] = {
        [WARRIOR] = { 5148, 5147, 5145, 5146 },
        [PALADIN] = { 5128, 5127, 5125, 5126 },
        [HUNTER] = { 5116, 5115, 5113, 5114 },
        [ROGUE] = { 5136, 5135, 5133, 5134 },
        [PRIEST] = { 5132, 5131, 5129, 5130 },
        [DEATHKNIGHT] = { 5100, 5099, 5097, 5098 },
        [SHAMAN] = { 5140, 5139, 5137, 5138 },
        [MAGE] = { 5120, 5119, 5117, 5118 },
        [WARLOCK] = { 5144, 5143, 5141, 5142 },
        [MONK] = { 5124, 5123, 5121, 5122 },
        [DRUID] = { 5108, 5107, 5105, 5106 },
        [DEMONHUNTER] = { 5104, 5103, 5101, 5102 },
        [EVOKER] = { 5112, 5111, 5109, 5110 },
    },
    [MN_S1] = {
        [WARRIOR] = { 5465, 5466, 5467, 5468 },
        [PALADIN] = { 5445, 5446, 5447, 5448 },
        [HUNTER] = { 5433, 5434, 5435, 5436 },
        [ROGUE] = { 5453, 5454, 5455, 5456 },
        [PRIEST] = { 5449, 5450, 5451, 5452 },
        [DEATHKNIGHT] = { 5417, 5418, 5419, 5420 },
        [SHAMAN] = { 5457, 5458, 5459, 5460 },
        [MAGE] = { 5437, 5438, 5439, 5440 },
        [WARLOCK] = { 5461, 5462, 5463, 5464 },
        [MONK] = { 5441, 5442, 5443, 5444 },
        [DRUID] = { 5425, 5426, 5427, 5428 },
        [DEMONHUNTER] = { 5421, 5422, 5423, 5424 },
        [EVOKER] = { 5429, 5430, 5431, 5432 },
    },
};

--- C_TransmogSets.GetSourceIDsForSlot and C_TransmogSets.GetSourcesForSlot miss information for certain slots, very "fun" -.-
--- @type table<number, table<Enum.InventoryType, number>> # [setID] = { [Enum.InventoryType.Foo] = sourceID }
data.setSourceIDs = {
    -- TWW S2
    [4326] = { [HEAD] = 225238, [SHOULDER] = 225214, [CHEST] = 225274, [WAIST] = 225202, [LEGS] = 225226, [FEET] = 225262, [WRIST] = 225190, [HAND] = 225250, [CLOAK] = 225178 }, -- Warrior
    [4325] = { [HEAD] = 225233, [SHOULDER] = 225209, [CHEST] = 225269, [WAIST] = 225197, [LEGS] = 225221, [FEET] = 225257, [WRIST] = 225185, [HAND] = 225245, [CLOAK] = 225173 }, -- Warrior
    [4323] = { [HEAD] = 225239, [SHOULDER] = 225215, [CHEST] = 225275, [WAIST] = 225203, [LEGS] = 225227, [FEET] = 225263, [WRIST] = 225191, [HAND] = 225251, [CLOAK] = 225179 }, -- Warrior
    [4324] = { [HEAD] = 225240, [SHOULDER] = 225216, [CHEST] = 225276, [WAIST] = 225204, [LEGS] = 225228, [FEET] = 225264, [WRIST] = 225192, [HAND] = 225252, [CLOAK] = 225180 }, -- Warrior
    [4306] = { [HEAD] = 225346, [SHOULDER] = 225322, [CHEST] = 225382, [WAIST] = 225310, [LEGS] = 225334, [FEET] = 225370, [WRIST] = 225298, [HAND] = 225358, [CLOAK] = 225286 }, -- Paladin
    [4305] = { [HEAD] = 225341, [SHOULDER] = 225317, [CHEST] = 225377, [WAIST] = 225305, [LEGS] = 225329, [FEET] = 225365, [WRIST] = 225293, [HAND] = 225353, [CLOAK] = 225281 }, -- Paladin
    [4303] = { [HEAD] = 225347, [SHOULDER] = 225323, [CHEST] = 225383, [WAIST] = 225311, [LEGS] = 225335, [FEET] = 225371, [WRIST] = 225299, [HAND] = 225359, [CLOAK] = 225287 }, -- Paladin
    [4304] = { [HEAD] = 225348, [SHOULDER] = 225324, [CHEST] = 225384, [WAIST] = 225312, [LEGS] = 225336, [FEET] = 225372, [WRIST] = 225300, [HAND] = 225360, [CLOAK] = 225288 }, -- Paladin
    [4294] = { [HEAD] = 225658, [SHOULDER] = 225634, [CHEST] = 225694, [WAIST] = 225622, [LEGS] = 225646, [FEET] = 225682, [WRIST] = 225610, [HAND] = 225670, [CLOAK] = 225598 }, -- Hunter
    [4293] = { [HEAD] = 225653, [SHOULDER] = 225629, [CHEST] = 225689, [WAIST] = 225617, [LEGS] = 225641, [FEET] = 225677, [WRIST] = 225605, [HAND] = 225665, [CLOAK] = 225593 }, -- Hunter
    [4291] = { [HEAD] = 225659, [SHOULDER] = 225635, [CHEST] = 225695, [WAIST] = 225623, [LEGS] = 225647, [FEET] = 225683, [WRIST] = 225611, [HAND] = 225671, [CLOAK] = 225599 }, -- Hunter
    [4292] = { [HEAD] = 225660, [SHOULDER] = 225636, [CHEST] = 225696, [WAIST] = 225624, [LEGS] = 225648, [FEET] = 225684, [WRIST] = 225612, [HAND] = 225672, [CLOAK] = 225600 }, -- Hunter
    [4314] = { [HEAD] = 225874, [SHOULDER] = 225850, [CHEST] = 225910, [WAIST] = 225838, [LEGS] = 225862, [FEET] = 225898, [WRIST] = 225826, [HAND] = 225886, [CLOAK] = 225814 }, -- Rogue
    [4313] = { [HEAD] = 225869, [SHOULDER] = 225845, [CHEST] = 225905, [WAIST] = 224939, [LEGS] = 225857, [FEET] = 225893, [WRIST] = 225821, [HAND] = 225881, [CLOAK] = 225809 }, -- Rogue
    [4311] = { [HEAD] = 225875, [SHOULDER] = 225851, [CHEST] = 225911, [WAIST] = 225839, [LEGS] = 225863, [FEET] = 225899, [WRIST] = 225827, [HAND] = 225887, [CLOAK] = 225815 }, -- Rogue
    [4312] = { [HEAD] = 225876, [SHOULDER] = 225852, [CHEST] = 225912, [WAIST] = 225840, [LEGS] = 225864, [FEET] = 225900, [WRIST] = 225828, [HAND] = 225888, [CLOAK] = 225816 }, -- Rogue
    [4310] = { [HEAD] = 226414, [SHOULDER] = 226390, [CHEST] = 226450, [WAIST] = 226378, [LEGS] = 226402, [FEET] = 226438, [WRIST] = 226366, [HAND] = 226426, [CLOAK] = 226354 }, -- Priest
    [4309] = { [HEAD] = 226409, [SHOULDER] = 226385, [CHEST] = 226445, [WAIST] = 226373, [LEGS] = 226397, [FEET] = 226433, [WRIST] = 226361, [HAND] = 226421, [CLOAK] = 226349 }, -- Priest
    [4307] = { [HEAD] = 226415, [SHOULDER] = 226391, [CHEST] = 226451, [WAIST] = 226379, [LEGS] = 226403, [FEET] = 226439, [WRIST] = 226367, [HAND] = 226427, [CLOAK] = 226355 }, -- Priest
    [4308] = { [HEAD] = 226416, [SHOULDER] = 226392, [CHEST] = 231638, [WAIST] = 226380, [LEGS] = 226404, [FEET] = 226440, [WRIST] = 226368, [HAND] = 226428, [CLOAK] = 226356 }, -- Priest
    [4278] = { [HEAD] = 225454, [SHOULDER] = 225430, [CHEST] = 225490, [WAIST] = 225418, [LEGS] = 225442, [FEET] = 225478, [WRIST] = 225406, [HAND] = 225466, [CLOAK] = 225394 }, -- Death Knight
    [4277] = { [HEAD] = 225449, [SHOULDER] = 225425, [CHEST] = 225485, [WAIST] = 225413, [LEGS] = 225437, [FEET] = 225473, [WRIST] = 225401, [HAND] = 225461, [CLOAK] = 225389 }, -- Death Knight
    [4275] = { [HEAD] = 225455, [SHOULDER] = 225431, [CHEST] = 225491, [WAIST] = 225419, [LEGS] = 225443, [FEET] = 225479, [WRIST] = 225407, [HAND] = 225467, [CLOAK] = 225395 }, -- Death Knight
    [4276] = { [HEAD] = 225456, [SHOULDER] = 225432, [CHEST] = 225492, [WAIST] = 225420, [LEGS] = 225444, [FEET] = 225480, [WRIST] = 225408, [HAND] = 225468, [CLOAK] = 225396 }, -- Death Knight
    [4318] = { [HEAD] = 225556, [SHOULDER] = 225538, [CHEST] = 225589, [WAIST] = 225526, [LEGS] = 225547, [FEET] = 225580, [WRIST] = 225514, [HAND] = 225568, [CLOAK] = 225502 }, -- Shaman
    [4317] = { [HEAD] = 225551, [SHOULDER] = 225533, [CHEST] = 225590, [WAIST] = 225521, [LEGS] = 225548, [FEET] = 225575, [WRIST] = 225509, [HAND] = 225563, [CLOAK] = 225497 }, -- Shaman
    [4315] = { [HEAD] = 225557, [SHOULDER] = 225539, [CHEST] = 225591, [WAIST] = 225527, [LEGS] = 225549, [FEET] = 225581, [WRIST] = 225515, [HAND] = 225569, [CLOAK] = 225503 }, -- Shaman
    [4316] = { [HEAD] = 225558, [SHOULDER] = 225540, [CHEST] = 225592, [WAIST] = 225528, [LEGS] = 225550, [FEET] = 225582, [WRIST] = 225516, [HAND] = 225570, [CLOAK] = 225504 }, -- Shaman
    [4298] = { [HEAD] = 226520, [SHOULDER] = 226496, [CHEST] = 226556, [WAIST] = 226484, [LEGS] = 226508, [FEET] = 226544, [WRIST] = 226472, [HAND] = 226532, [CLOAK] = 226460 }, -- Mage
    [4297] = { [HEAD] = 226515, [SHOULDER] = 226491, [CHEST] = 226551, [WAIST] = 226479, [LEGS] = 226503, [FEET] = 226539, [WRIST] = 226467, [HAND] = 226527, [CLOAK] = 226455 }, -- Mage
    [4295] = { [HEAD] = 226521, [SHOULDER] = 226497, [CHEST] = 226557, [WAIST] = 226485, [LEGS] = 226509, [FEET] = 226545, [WRIST] = 226473, [HAND] = 226533, [CLOAK] = 226461 }, -- Mage
    [4296] = { [HEAD] = 226522, [SHOULDER] = 226498, [CHEST] = 226558, [WAIST] = 226486, [LEGS] = 226510, [FEET] = 226546, [WRIST] = 226474, [HAND] = 226534, [CLOAK] = 226462 }, -- Mage
    [4322] = { [HEAD] = 226306, [SHOULDER] = 226282, [CHEST] = 226342, [WAIST] = 226270, [LEGS] = 226294, [FEET] = 226330, [WRIST] = 226258, [HAND] = 226318, [CLOAK] = 226246 }, -- Warlock
    [4321] = { [HEAD] = 226301, [SHOULDER] = 226277, [CHEST] = 226337, [WAIST] = 226265, [LEGS] = 226289, [FEET] = 226325, [WRIST] = 226253, [HAND] = 226313, [CLOAK] = 226241 }, -- Warlock
    [4319] = { [HEAD] = 226307, [SHOULDER] = 226283, [CHEST] = 226343, [WAIST] = 226271, [LEGS] = 226295, [FEET] = 226331, [WRIST] = 226259, [HAND] = 226319, [CLOAK] = 226247 }, -- Warlock
    [4320] = { [HEAD] = 226308, [SHOULDER] = 226284, [CHEST] = 226344, [WAIST] = 226272, [LEGS] = 226296, [FEET] = 226332, [WRIST] = 226260, [HAND] = 226320, [CLOAK] = 226248 }, -- Warlock
    [4302] = { [HEAD] = 225982, [SHOULDER] = 225958, [CHEST] = 226018, [WAIST] = 225946, [LEGS] = 225970, [FEET] = 226006, [WRIST] = 225934, [HAND] = 225994, [CLOAK] = 225922 }, -- Monk
    [4301] = { [HEAD] = 225977, [SHOULDER] = 225953, [CHEST] = 226013, [WAIST] = 225941, [LEGS] = 225965, [FEET] = 226001, [WRIST] = 225929, [HAND] = 225989, [CLOAK] = 225917 }, -- Monk
    [4299] = { [HEAD] = 225983, [SHOULDER] = 225959, [CHEST] = 226019, [WAIST] = 225947, [LEGS] = 225971, [FEET] = 226007, [WRIST] = 225935, [HAND] = 225995, [CLOAK] = 225923 }, -- Monk
    [4300] = { [HEAD] = 225984, [SHOULDER] = 225960, [CHEST] = 226020, [WAIST] = 225948, [LEGS] = 225972, [FEET] = 226008, [WRIST] = 225936, [HAND] = 225996, [CLOAK] = 225924 }, -- Monk
    [4286] = { [HEAD] = 226090, [SHOULDER] = 226066, [CHEST] = 226126, [WAIST] = 226054, [LEGS] = 226078, [FEET] = 226114, [WRIST] = 226042, [HAND] = 226102, [CLOAK] = 226030 }, -- Druid
    [4285] = { [HEAD] = 226085, [SHOULDER] = 226061, [CHEST] = 226121, [WAIST] = 226049, [LEGS] = 226073, [FEET] = 226109, [WRIST] = 226037, [HAND] = 226097, [CLOAK] = 226025 }, -- Druid
    [4283] = { [HEAD] = 226091, [SHOULDER] = 226067, [CHEST] = 226127, [WAIST] = 226055, [LEGS] = 226079, [FEET] = 226115, [WRIST] = 226043, [HAND] = 226103, [CLOAK] = 226031 }, -- Druid
    [4284] = { [HEAD] = 226092, [SHOULDER] = 226068, [CHEST] = 226128, [WAIST] = 226056, [LEGS] = 226080, [FEET] = 226116, [WRIST] = 226044, [HAND] = 226104, [CLOAK] = 226032 }, -- Druid
    [4282] = { [HEAD] = 226198, [SHOULDER] = 226174, [CHEST] = 226234, [WAIST] = 226162, [LEGS] = 226186, [FEET] = 226222, [WRIST] = 226150, [HAND] = 226210, [CLOAK] = 226138 }, -- Demon Hunter
    [4281] = { [HEAD] = 226193, [SHOULDER] = 226169, [CHEST] = 226229, [WAIST] = 226157, [LEGS] = 226181, [FEET] = 226217, [WRIST] = 226145, [HAND] = 226205, [CLOAK] = 226133 }, -- Demon Hunter
    [4279] = { [HEAD] = 226199, [SHOULDER] = 226175, [CHEST] = 226235, [WAIST] = 226163, [LEGS] = 226187, [FEET] = 226223, [WRIST] = 226151, [HAND] = 226211, [CLOAK] = 226139 }, -- Demon Hunter
    [4280] = { [HEAD] = 226200, [SHOULDER] = 226176, [CHEST] = 226236, [WAIST] = 226164, [LEGS] = 226188, [FEET] = 226224, [WRIST] = 226152, [HAND] = 226212, [CLOAK] = 226140 }, -- Demon Hunter
    [4290] = { [HEAD] = 225766, [SHOULDER] = 225742, [CHEST] = 225802, [WAIST] = 225730, [LEGS] = 225754, [FEET] = 225790, [WRIST] = 225718, [HAND] = 225778, [CLOAK] = 225706 }, -- Evoker
    [4289] = { [HEAD] = 225761, [SHOULDER] = 225737, [CHEST] = 225797, [WAIST] = 225725, [LEGS] = 225749, [FEET] = 225785, [WRIST] = 225713, [HAND] = 225773, [CLOAK] = 225701 }, -- Evoker
    [4287] = { [HEAD] = 225767, [SHOULDER] = 225743, [CHEST] = 225803, [WAIST] = 225731, [LEGS] = 225755, [FEET] = 225791, [WRIST] = 225719, [HAND] = 225779, [CLOAK] = 225707 }, -- Evoker
    [4288] = { [HEAD] = 225768, [SHOULDER] = 225744, [CHEST] = 225804, [WAIST] = 225732, [LEGS] = 225756, [FEET] = 225792, [WRIST] = 225720, [HAND] = 225780, [CLOAK] = 225708 }, -- Evoker
    -- TWW S3
    [5148] = { [HEAD] = 285583, [SHOULDER] = 285559, [CHEST] = 285619, [WAIST] = 285547, [LEGS] = 285571, [FEET] = 285607, [WRIST] = 285535, [HAND] = 285595, [CLOAK] = 285523 }, -- Warrior
    [5147] = { [HEAD] = 285578, [SHOULDER] = 285554, [CHEST] = 285614, [WAIST] = 285542, [LEGS] = 285566, [FEET] = 285602, [WRIST] = 285530, [HAND] = 285590, [CLOAK] = 285518 }, -- Warrior
    [5145] = { [HEAD] = 285584, [SHOULDER] = 285560, [CHEST] = 285620, [WAIST] = 285548, [LEGS] = 285572, [FEET] = 285608, [WRIST] = 285536, [HAND] = 285596, [CLOAK] = 285524 }, -- Warrior
    [5146] = { [HEAD] = 285585, [SHOULDER] = 285561, [CHEST] = 285621, [WAIST] = 285549, [LEGS] = 285573, [FEET] = 285609, [WRIST] = 285537, [HAND] = 285597, [CLOAK] = 285525 }, -- Warrior
    [5128] = { [HEAD] = 285691, [SHOULDER] = 285667, [CHEST] = 285727, [WAIST] = 285655, [LEGS] = 285679, [FEET] = 285715, [WRIST] = 285643, [HAND] = 285703, [CLOAK] = 285631 }, -- Paladin
    [5127] = { [HEAD] = 285686, [SHOULDER] = 285662, [CHEST] = 285722, [WAIST] = 285650, [LEGS] = 285674, [FEET] = 285710, [WRIST] = 285638, [HAND] = 285698, [CLOAK] = 285626 }, -- Paladin
    [5125] = { [HEAD] = 285692, [SHOULDER] = 285668, [CHEST] = 285728, [WAIST] = 285656, [LEGS] = 285680, [FEET] = 285716, [WRIST] = 285644, [HAND] = 285704, [CLOAK] = 285632 }, -- Paladin
    [5126] = { [HEAD] = 285693, [SHOULDER] = 285669, [CHEST] = 285729, [WAIST] = 285657, [LEGS] = 285681, [FEET] = 285717, [WRIST] = 285645, [HAND] = 285705, [CLOAK] = 285633 }, -- Paladin
    [5116] = { [HEAD] = 286007, [SHOULDER] = 285983, [CHEST] = 286043, [WAIST] = 285971, [LEGS] = 285995, [FEET] = 286031, [WRIST] = 285959, [HAND] = 286019, [CLOAK] = 285947 }, -- Hunter
    [5115] = { [HEAD] = 286002, [SHOULDER] = 285978, [CHEST] = 286038, [WAIST] = 285966, [LEGS] = 285990, [FEET] = 286026, [WRIST] = 285954, [HAND] = 286014, [CLOAK] = 285942 }, -- Hunter
    [5113] = { [HEAD] = 286008, [SHOULDER] = 285984, [CHEST] = 286044, [WAIST] = 285972, [LEGS] = 285996, [FEET] = 286032, [WRIST] = 285960, [HAND] = 286020, [CLOAK] = 285948 }, -- Hunter
    [5114] = { [HEAD] = 286009, [SHOULDER] = 285985, [CHEST] = 286045, [WAIST] = 285973, [LEGS] = 285997, [FEET] = 286033, [WRIST] = 285961, [HAND] = 286021, [CLOAK] = 285949 }, -- Hunter
    [5136] = { [HEAD] = 286223, [SHOULDER] = 286199, [CHEST] = 286259, [WAIST] = 286187, [LEGS] = 286211, [FEET] = 286247, [WRIST] = 286175, [HAND] = 286235, [CLOAK] = 286163 }, -- Rogue
    [5135] = { [HEAD] = 286218, [SHOULDER] = 286194, [CHEST] = 286254, [WAIST] = 286182, [LEGS] = 286206, [FEET] = 286242, [WRIST] = 286170, [HAND] = 286230, [CLOAK] = 286158 }, -- Rogue
    [5133] = { [HEAD] = 286224, [SHOULDER] = 286200, [CHEST] = 286260, [WAIST] = 286188, [LEGS] = 286212, [FEET] = 286248, [WRIST] = 286176, [HAND] = 286236, [CLOAK] = 286164 }, -- Rogue
    [5134] = { [HEAD] = 286225, [SHOULDER] = 286201, [CHEST] = 286261, [WAIST] = 286189, [LEGS] = 286213, [FEET] = 286249, [WRIST] = 286177, [HAND] = 286237, [CLOAK] = 286165 }, -- Rogue
    [5132] = { [HEAD] = 286763, [SHOULDER] = 286739, [CHEST] = 286799, [WAIST] = 286727, [LEGS] = 286751, [FEET] = 286787, [WRIST] = 286715, [HAND] = 286775, [CLOAK] = 286703 }, -- Priest
    [5131] = { [HEAD] = 286758, [SHOULDER] = 286734, [CHEST] = 286794, [WAIST] = 286722, [LEGS] = 286746, [FEET] = 286782, [WRIST] = 286710, [HAND] = 286770, [CLOAK] = 286698 }, -- Priest
    [5129] = { [HEAD] = 286764, [SHOULDER] = 286740, [CHEST] = 286800, [WAIST] = 286728, [LEGS] = 286752, [FEET] = 286788, [WRIST] = 286716, [HAND] = 286776, [CLOAK] = 286704 }, -- Priest
    [5130] = { [HEAD] = 286765, [SHOULDER] = 286741, [CHEST] = 286801, [WAIST] = 286729, [LEGS] = 286753, [FEET] = 286789, [WRIST] = 286717, [HAND] = 286777, [CLOAK] = 286705 }, -- Priest
    [5100] = { [HEAD] = 285799, [SHOULDER] = 285775, [CHEST] = 285835, [WAIST] = 285763, [LEGS] = 285787, [FEET] = 285823, [WRIST] = 285751, [HAND] = 285811, [CLOAK] = 285739 }, -- Death Knight
    [5099] = { [HEAD] = 285794, [SHOULDER] = 285770, [CHEST] = 285830, [WAIST] = 285758, [LEGS] = 285782, [FEET] = 285818, [WRIST] = 285746, [HAND] = 285806, [CLOAK] = 285734 }, -- Death Knight
    [5097] = { [HEAD] = 285800, [SHOULDER] = 285776, [CHEST] = 285836, [WAIST] = 285764, [LEGS] = 285788, [FEET] = 285824, [WRIST] = 285752, [HAND] = 285812, [CLOAK] = 285740 }, -- Death Knight
    [5098] = { [HEAD] = 285801, [SHOULDER] = 285777, [CHEST] = 285837, [WAIST] = 285765, [LEGS] = 285789, [FEET] = 285825, [WRIST] = 285753, [HAND] = 285813, [CLOAK] = 285741 }, -- Death Knight
    [5140] = { [HEAD] = 285903, [SHOULDER] = 285883, [CHEST] = 285936, [WAIST] = 285871, [LEGS] = 285892, [FEET] = 285927, [WRIST] = 285859, [HAND] = 285915, [CLOAK] = 285847 }, -- Shaman
    [5139] = { [HEAD] = 285898, [SHOULDER] = 285878, [CHEST] = 285937, [WAIST] = 285866, [LEGS] = 285893, [FEET] = 285922, [WRIST] = 285854, [HAND] = 285910, [CLOAK] = 285842 }, -- Shaman
    [5137] = { [HEAD] = 285904, [SHOULDER] = 285884, [CHEST] = 285938, [WAIST] = 285872, [LEGS] = 285894, [FEET] = 285928, [WRIST] = 285860, [HAND] = 285916, [CLOAK] = 285848 }, -- Shaman
    [5138] = { [HEAD] = 285905, [SHOULDER] = 285885, [CHEST] = 285939, [WAIST] = 285873, [LEGS] = 285895, [FEET] = 285929, [WRIST] = 285861, [HAND] = 285917, [CLOAK] = 285849 }, -- Shaman
    [5120] = { [HEAD] = 286870, [SHOULDER] = 286846, [CHEST] = 286906, [WAIST] = 286834, [LEGS] = 286858, [FEET] = 286894, [WRIST] = 286822, [HAND] = 286882, [CLOAK] = 286810 }, -- Mage
    [5119] = { [HEAD] = 286865, [SHOULDER] = 286841, [CHEST] = 286901, [WAIST] = 286829, [LEGS] = 286853, [FEET] = 286889, [WRIST] = 286817, [HAND] = 286877, [CLOAK] = 286805 }, -- Mage
    [5117] = { [HEAD] = 286871, [SHOULDER] = 286847, [CHEST] = 286907, [WAIST] = 286835, [LEGS] = 286859, [FEET] = 286895, [WRIST] = 286823, [HAND] = 286883, [CLOAK] = 286811 }, -- Mage
    [5118] = { [HEAD] = 286872, [SHOULDER] = 286848, [CHEST] = 286908, [WAIST] = 286836, [LEGS] = 286860, [FEET] = 286896, [WRIST] = 286824, [HAND] = 286884, [CLOAK] = 286812 }, -- Mage
    [5144] = { [HEAD] = 286655, [SHOULDER] = 286631, [CHEST] = 286691, [WAIST] = 286619, [LEGS] = 286643, [FEET] = 286679, [WRIST] = 286607, [HAND] = 286667, [CLOAK] = 286595 }, -- Warlock
    [5143] = { [HEAD] = 286650, [SHOULDER] = 286626, [CHEST] = 286686, [WAIST] = 286614, [LEGS] = 286638, [FEET] = 286674, [WRIST] = 286602, [HAND] = 286662, [CLOAK] = 286590 }, -- Warlock
    [5141] = { [HEAD] = 286656, [SHOULDER] = 286632, [CHEST] = 286692, [WAIST] = 286620, [LEGS] = 286644, [FEET] = 286680, [WRIST] = 286608, [HAND] = 286668, [CLOAK] = 286596 }, -- Warlock
    [5142] = { [HEAD] = 286657, [SHOULDER] = 286633, [CHEST] = 286693, [WAIST] = 286621, [LEGS] = 286645, [FEET] = 286681, [WRIST] = 286609, [HAND] = 286669, [CLOAK] = 286597 }, -- Warlock
    [5124] = { [HEAD] = 286331, [SHOULDER] = 286307, [CHEST] = 286367, [WAIST] = 286295, [LEGS] = 286319, [FEET] = 286355, [WRIST] = 286283, [HAND] = 286343, [CLOAK] = 286271 }, -- Monk
    [5123] = { [HEAD] = 286326, [SHOULDER] = 286302, [CHEST] = 286362, [WAIST] = 286290, [LEGS] = 286314, [FEET] = 286350, [WRIST] = 286278, [HAND] = 286338, [CLOAK] = 286266 }, -- Monk
    [5121] = { [HEAD] = 286332, [SHOULDER] = 286308, [CHEST] = 286368, [WAIST] = 286296, [LEGS] = 286320, [FEET] = 286356, [WRIST] = 286284, [HAND] = 286344, [CLOAK] = 286272 }, -- Monk
    [5122] = { [HEAD] = 286333, [SHOULDER] = 286309, [CHEST] = 286369, [WAIST] = 286297, [LEGS] = 286321, [FEET] = 286357, [WRIST] = 286285, [HAND] = 286345, [CLOAK] = 286273 }, -- Monk
    [5108] = { [HEAD] = 286439, [SHOULDER] = 286415, [CHEST] = 286475, [WAIST] = 286403, [LEGS] = 286427, [FEET] = 286463, [WRIST] = 286391, [HAND] = 286451, [CLOAK] = 286379 }, -- Druid
    [5107] = { [HEAD] = 286434, [SHOULDER] = 286410, [CHEST] = 286470, [WAIST] = 286398, [LEGS] = 286422, [FEET] = 286458, [WRIST] = 286386, [HAND] = 286446, [CLOAK] = 286374 }, -- Druid
    [5105] = { [HEAD] = 286440, [SHOULDER] = 286416, [CHEST] = 286476, [WAIST] = 286404, [LEGS] = 286428, [FEET] = 286464, [WRIST] = 286392, [HAND] = 286452, [CLOAK] = 286380 }, -- Druid
    [5106] = { [HEAD] = 286441, [SHOULDER] = 286417, [CHEST] = 286477, [WAIST] = 286405, [LEGS] = 286429, [FEET] = 286465, [WRIST] = 286393, [HAND] = 286453, [CLOAK] = 286381 }, -- Druid
    [5104] = { [HEAD] = 286547, [SHOULDER] = 286523, [CHEST] = 286583, [WAIST] = 286511, [LEGS] = 286535, [FEET] = 286571, [WRIST] = 286499, [HAND] = 286559, [CLOAK] = 286487 }, -- Demon Hunter
    [5103] = { [HEAD] = 286542, [SHOULDER] = 286518, [CHEST] = 286578, [WAIST] = 286506, [LEGS] = 286530, [FEET] = 286566, [WRIST] = 286494, [HAND] = 286554, [CLOAK] = 286482 }, -- Demon Hunter
    [5101] = { [HEAD] = 286548, [SHOULDER] = 286524, [CHEST] = 286584, [WAIST] = 286512, [LEGS] = 286536, [FEET] = 286572, [WRIST] = 286500, [HAND] = 286560, [CLOAK] = 286488 }, -- Demon Hunter
    [5102] = { [HEAD] = 286549, [SHOULDER] = 286525, [CHEST] = 286585, [WAIST] = 286513, [LEGS] = 286537, [FEET] = 286573, [WRIST] = 286501, [HAND] = 286561, [CLOAK] = 286489 }, -- Demon Hunter
    [5112] = { [HEAD] = 286115, [SHOULDER] = 286091, [CHEST] = 286151, [WAIST] = 286079, [LEGS] = 286103, [FEET] = 286139, [WRIST] = 286067, [HAND] = 286127, [CLOAK] = 286055 }, -- Evoker
    [5111] = { [HEAD] = 286110, [SHOULDER] = 286086, [CHEST] = 286146, [WAIST] = 286074, [LEGS] = 286098, [FEET] = 286134, [WRIST] = 286062, [HAND] = 286122, [CLOAK] = 286050 }, -- Evoker
    [5109] = { [HEAD] = 286116, [SHOULDER] = 286092, [CHEST] = 286152, [WAIST] = 286080, [LEGS] = 286104, [FEET] = 286140, [WRIST] = 286068, [HAND] = 286128, [CLOAK] = 286056 }, -- Evoker
    [5110] = { [HEAD] = 286117, [SHOULDER] = 286093, [CHEST] = 286153, [WAIST] = 286081, [LEGS] = 286105, [FEET] = 286141, [WRIST] = 286069, [HAND] = 286129, [CLOAK] = 286057 }, -- Evoker
    -- MN S1
    [5465] = { [HEAD] = 296443, [SHOULDER] = 296419, [CHEST] = 296479, [WAIST] = 296407, [LEGS] = 296431, [FEET] = 296467, [WRIST] = 296395, [HAND] = 296455, [CLOAK] = 296383 }, -- Warrior
    [5466] = { [HEAD] = 296438, [SHOULDER] = 296414, [CHEST] = 296474, [WAIST] = 296402, [LEGS] = 296426, [FEET] = 296462, [WRIST] = 296390, [HAND] = 296450, [CLOAK] = 296378 }, -- Warrior
    [5467] = { [HEAD] = 296444, [SHOULDER] = 296420, [CHEST] = 296480, [WAIST] = 296408, [LEGS] = 296432, [FEET] = 296468, [WRIST] = 296396, [HAND] = 296456, [CLOAK] = 296384 }, -- Warrior
    [5468] = { [HEAD] = 296445, [SHOULDER] = 296421, [CHEST] = 296481, [WAIST] = 296409, [LEGS] = 296433, [FEET] = 296469, [WRIST] = 296397, [HAND] = 296457, [CLOAK] = 296385 }, -- Warrior
    [5445] = { [HEAD] = 296551, [SHOULDER] = 296527, [CHEST] = 296587, [WAIST] = 296515, [LEGS] = 296539, [FEET] = 296575, [WRIST] = 296503, [HAND] = 296563, [CLOAK] = 296491 }, -- Paladin
    [5446] = { [HEAD] = 296546, [SHOULDER] = 296522, [CHEST] = 296582, [WAIST] = 296510, [LEGS] = 296534, [FEET] = 296570, [WRIST] = 296498, [HAND] = 296558, [CLOAK] = 296486 }, -- Paladin
    [5447] = { [HEAD] = 296552, [SHOULDER] = 296528, [CHEST] = 296588, [WAIST] = 296516, [LEGS] = 296540, [FEET] = 296576, [WRIST] = 296504, [HAND] = 296564, [CLOAK] = 296492 }, -- Paladin
    [5448] = { [HEAD] = 296553, [SHOULDER] = 296529, [CHEST] = 296589, [WAIST] = 296517, [LEGS] = 296541, [FEET] = 296577, [WRIST] = 296505, [HAND] = 296565, [CLOAK] = 296493 }, -- Paladin
    [5433] = { [HEAD] = 296875, [SHOULDER] = 296851, [CHEST] = 296911, [WAIST] = 296839, [LEGS] = 296863, [FEET] = 296899, [WRIST] = 296827, [HAND] = 296887, [CLOAK] = 296815 }, -- Hunter
    [5434] = { [HEAD] = 296870, [SHOULDER] = 296846, [CHEST] = 296906, [WAIST] = 296834, [LEGS] = 296858, [FEET] = 296894, [WRIST] = 296822, [HAND] = 296882, [CLOAK] = 296810 }, -- Hunter
    [5435] = { [HEAD] = 296876, [SHOULDER] = 296852, [CHEST] = 296912, [WAIST] = 296840, [LEGS] = 296864, [FEET] = 296900, [WRIST] = 296828, [HAND] = 296888, [CLOAK] = 296816 }, -- Hunter
    [5436] = { [HEAD] = 296877, [SHOULDER] = 296853, [CHEST] = 296913, [WAIST] = 296841, [LEGS] = 296865, [FEET] = 296901, [WRIST] = 296829, [HAND] = 296889, [CLOAK] = 296817 }, -- Hunter
    [5453] = { [HEAD] = 297091, [SHOULDER] = 297067, [CHEST] = 297127, [WAIST] = 297055, [LEGS] = 297079, [FEET] = 297115, [WRIST] = 297043, [HAND] = 297103, [CLOAK] = 297031 }, -- Rogue
    [5454] = { [HEAD] = 297086, [SHOULDER] = 297062, [CHEST] = 297122, [WAIST] = 297050, [LEGS] = 297074, [FEET] = 297110, [WRIST] = 297038, [HAND] = 297098, [CLOAK] = 297026 }, -- Rogue
    [5455] = { [HEAD] = 297092, [SHOULDER] = 297068, [CHEST] = 297128, [WAIST] = 297056, [LEGS] = 297080, [FEET] = 297116, [WRIST] = 297044, [HAND] = 297104, [CLOAK] = 297032 }, -- Rogue
    [5456] = { [HEAD] = 297093, [SHOULDER] = 297069, [CHEST] = 297129, [WAIST] = 297057, [LEGS] = 297081, [FEET] = 297117, [WRIST] = 297045, [HAND] = 297105, [CLOAK] = 297033 }, -- Rogue
    [5449] = { [HEAD] = 297631, [SHOULDER] = 297607, [CHEST] = 297667, [WAIST] = 297595, [LEGS] = 297619, [FEET] = 297655, [WRIST] = 297583, [HAND] = 297643, [CLOAK] = 297571 }, -- Priest
    [5450] = { [HEAD] = 297626, [SHOULDER] = 297602, [CHEST] = 297662, [WAIST] = 297590, [LEGS] = 297614, [FEET] = 297650, [WRIST] = 297578, [HAND] = 297638, [CLOAK] = 297566 }, -- Priest
    [5451] = { [HEAD] = 297632, [SHOULDER] = 297608, [CHEST] = 297668, [WAIST] = 297596, [LEGS] = 297620, [FEET] = 297656, [WRIST] = 297584, [HAND] = 297644, [CLOAK] = 297572 }, -- Priest
    [5452] = { [HEAD] = 297633, [SHOULDER] = 297609, [CHEST] = 297669, [WAIST] = 297597, [LEGS] = 297621, [FEET] = 297657, [WRIST] = 297585, [HAND] = 297645, [CLOAK] = 297573 }, -- Priest
    [5417] = { [HEAD] = 296659, [SHOULDER] = 296635, [CHEST] = 296695, [WAIST] = 296623, [LEGS] = 296647, [FEET] = 296683, [WRIST] = 296611, [HAND] = 296671, [CLOAK] = 296599 }, -- Death Knight
    [5418] = { [HEAD] = 296654, [SHOULDER] = 296630, [CHEST] = 296690, [WAIST] = 296618, [LEGS] = 296642, [FEET] = 296678, [WRIST] = 296606, [HAND] = 296666, [CLOAK] = 296594 }, -- Death Knight
    [5419] = { [HEAD] = 296660, [SHOULDER] = 296636, [CHEST] = 296696, [WAIST] = 296624, [LEGS] = 296648, [FEET] = 296684, [WRIST] = 296612, [HAND] = 296672, [CLOAK] = 296600 }, -- Death Knight
    [5420] = { [HEAD] = 296661, [SHOULDER] = 296637, [CHEST] = 296697, [WAIST] = 296625, [LEGS] = 296649, [FEET] = 296685, [WRIST] = 296613, [HAND] = 296673, [CLOAK] = 296601 }, -- Death Knight
    [5457] = { [HEAD] = 296767, [SHOULDER] = 296743, [CHEST] = 296800, [WAIST] = 296731, [LEGS] = 296752, [FEET] = 296791, [WRIST] = 296719, [HAND] = 296779, [CLOAK] = 296707 }, -- Shaman
    [5458] = { [HEAD] = 296762, [SHOULDER] = 296738, [CHEST] = 296801, [WAIST] = 296726, [LEGS] = 296753, [FEET] = 296786, [WRIST] = 296714, [HAND] = 296774, [CLOAK] = 296702 }, -- Shaman
    [5459] = { [HEAD] = 296768, [SHOULDER] = 296744, [CHEST] = 296802, [WAIST] = 296732, [LEGS] = 296754, [FEET] = 296792, [WRIST] = 296720, [HAND] = 296780, [CLOAK] = 296708 }, -- Shaman
    [5460] = { [HEAD] = 296769, [SHOULDER] = 296745, [CHEST] = 296803, [WAIST] = 296733, [LEGS] = 296755, [FEET] = 296793, [WRIST] = 296721, [HAND] = 296781, [CLOAK] = 296709 }, -- Shaman
    [5437] = { [HEAD] = 297739, [SHOULDER] = 297715, [CHEST] = 297775, [WAIST] = 297703, [LEGS] = 297727, [FEET] = 297763, [WRIST] = 297691, [HAND] = 297751, [CLOAK] = 297679 }, -- Mage
    [5438] = { [HEAD] = 297734, [SHOULDER] = 297710, [CHEST] = 297770, [WAIST] = 297698, [LEGS] = 297722, [FEET] = 297758, [WRIST] = 297686, [HAND] = 297746, [CLOAK] = 297674 }, -- Mage
    [5439] = { [HEAD] = 297740, [SHOULDER] = 297716, [CHEST] = 297776, [WAIST] = 297704, [LEGS] = 297728, [FEET] = 297764, [WRIST] = 297692, [HAND] = 297752, [CLOAK] = 297680 }, -- Mage
    [5440] = { [HEAD] = 297741, [SHOULDER] = 297717, [CHEST] = 297777, [WAIST] = 297705, [LEGS] = 297729, [FEET] = 297765, [WRIST] = 297693, [HAND] = 297753, [CLOAK] = 297681 }, -- Mage
    [5461] = { [HEAD] = 297523, [SHOULDER] = 297499, [CHEST] = 297559, [WAIST] = 297487, [LEGS] = 297511, [FEET] = 297547, [WRIST] = 297475, [HAND] = 297535, [CLOAK] = 297463 }, -- Warlock
    [5462] = { [HEAD] = 297518, [SHOULDER] = 297494, [CHEST] = 297554, [WAIST] = 297482, [LEGS] = 297506, [FEET] = 297542, [WRIST] = 297470, [HAND] = 297530, [CLOAK] = 297458 }, -- Warlock
    [5463] = { [HEAD] = 297524, [SHOULDER] = 297500, [CHEST] = 297560, [WAIST] = 297488, [LEGS] = 297512, [FEET] = 297548, [WRIST] = 297476, [HAND] = 297536, [CLOAK] = 297464 }, -- Warlock
    [5464] = { [HEAD] = 297525, [SHOULDER] = 297501, [CHEST] = 297561, [WAIST] = 297489, [LEGS] = 297513, [FEET] = 297549, [WRIST] = 297477, [HAND] = 297537, [CLOAK] = 297465 }, -- Warlock
    [5441] = { [HEAD] = 297199, [SHOULDER] = 297175, [CHEST] = 297235, [WAIST] = 297163, [LEGS] = 297187, [FEET] = 297223, [WRIST] = 297151, [HAND] = 297211, [CLOAK] = 297139 }, -- Monk
    [5442] = { [HEAD] = 297194, [SHOULDER] = 297170, [CHEST] = 297230, [WAIST] = 297158, [LEGS] = 297182, [FEET] = 297218, [WRIST] = 297146, [HAND] = 297206, [CLOAK] = 297134 }, -- Monk
    [5443] = { [HEAD] = 297200, [SHOULDER] = 297176, [CHEST] = 297236, [WAIST] = 297164, [LEGS] = 302120, [FEET] = 297224, [WRIST] = 297152, [HAND] = 297212, [CLOAK] = 297140 }, -- Monk
    [5444] = { [HEAD] = 297201, [SHOULDER] = 297177, [CHEST] = 297237, [WAIST] = 297165, [LEGS] = 297189, [FEET] = 297225, [WRIST] = 297153, [HAND] = 297213, [CLOAK] = 297141 }, -- Monk
    [5425] = { [HEAD] = 297307, [SHOULDER] = 297283, [CHEST] = 297343, [WAIST] = 297271, [LEGS] = 297295, [FEET] = 297331, [WRIST] = 297259, [HAND] = 297319, [CLOAK] = 297247 }, -- Druid
    [5426] = { [HEAD] = 297302, [SHOULDER] = 297278, [CHEST] = 297338, [WAIST] = 297266, [LEGS] = 297290, [FEET] = 297326, [WRIST] = 297254, [HAND] = 297314, [CLOAK] = 297242 }, -- Druid
    [5427] = { [HEAD] = 297308, [SHOULDER] = 297284, [CHEST] = 297344, [WAIST] = 297272, [LEGS] = 297296, [FEET] = 297332, [WRIST] = 297260, [HAND] = 297320, [CLOAK] = 297248 }, -- Druid
    [5428] = { [HEAD] = 297309, [SHOULDER] = 297285, [CHEST] = 297345, [WAIST] = 297273, [LEGS] = 297297, [FEET] = 297333, [WRIST] = 297261, [HAND] = 297321, [CLOAK] = 297249 }, -- Druid
    [5421] = { [HEAD] = 297415, [SHOULDER] = 297391, [CHEST] = 297451, [WAIST] = 297379, [LEGS] = 297403, [FEET] = 297439, [WRIST] = 297367, [HAND] = 297427, [CLOAK] = 297355 }, -- Demon Hunter
    [5422] = { [HEAD] = 297410, [SHOULDER] = 297386, [CHEST] = 297446, [WAIST] = 297374, [LEGS] = 297398, [FEET] = 297434, [WRIST] = 297362, [HAND] = 297422, [CLOAK] = 297350 }, -- Demon Hunter
    [5423] = { [HEAD] = 297416, [SHOULDER] = 297392, [CHEST] = 297452, [WAIST] = 297380, [LEGS] = 297404, [FEET] = 297440, [WRIST] = 297368, [HAND] = 297428, [CLOAK] = 297356 }, -- Demon Hunter
    [5424] = { [HEAD] = 297417, [SHOULDER] = 297393, [CHEST] = 297453, [WAIST] = 297381, [LEGS] = 297405, [FEET] = 297441, [WRIST] = 297369, [HAND] = 297429, [CLOAK] = 297357 }, -- Demon Hunter
    [5429] = { [HEAD] = 296983, [SHOULDER] = 296959, [CHEST] = 297019, [WAIST] = 296947, [LEGS] = 296971, [FEET] = 297007, [WRIST] = 296935, [HAND] = 296995, [CLOAK] = 296923 }, -- Evoker
    [5430] = { [HEAD] = 296978, [SHOULDER] = 296954, [CHEST] = 297014, [WAIST] = 296942, [LEGS] = 296966, [FEET] = 297002, [WRIST] = 296930, [HAND] = 296990, [CLOAK] = 296918 }, -- Evoker
    [5431] = { [HEAD] = 296984, [SHOULDER] = 296960, [CHEST] = 297020, [WAIST] = 296948, [LEGS] = 296972, [FEET] = 297008, [WRIST] = 296936, [HAND] = 296996, [CLOAK] = 296924 }, -- Evoker
    [5432] = { [HEAD] = 296985, [SHOULDER] = 296961, [CHEST] = 297021, [WAIST] = 296949, [LEGS] = 296973, [FEET] = 297009, [WRIST] = 296937, [HAND] = 296997, [CLOAK] = 296925 }, -- Evoker
};

--- @type table<number, table<TUM_Tier, number>> # [itemID] = { [tier] = itemSourceID }
data.itemSourceIDs = {
    [188838] = { [TIER_LFR] = 166034, [TIER_NORMAL] = 166033, [TIER_HEROIC] = 166035, [TIER_MYTHIC] = 166036 },
    [188839] = { [TIER_LFR] = 166038, [TIER_NORMAL] = 166037, [TIER_HEROIC] = 166039, [TIER_MYTHIC] = 166040 },
    [188840] = { [TIER_LFR] = 166042, [TIER_NORMAL] = 166041, [TIER_HEROIC] = 166043, [TIER_MYTHIC] = 166044 },
    [188841] = { [TIER_LFR] = 166046, [TIER_NORMAL] = 166045, [TIER_HEROIC] = 166047, [TIER_MYTHIC] = 166048 },
    [188842] = { [TIER_LFR] = 166050, [TIER_NORMAL] = 166049, [TIER_HEROIC] = 166051, [TIER_MYTHIC] = 166052 },
    [188843] = { [TIER_LFR] = 166054, [TIER_NORMAL] = 166053, [TIER_HEROIC] = 166055, [TIER_MYTHIC] = 166056 },
    [188844] = { [TIER_LFR] = 166058, [TIER_NORMAL] = 166057, [TIER_HEROIC] = 166059, [TIER_MYTHIC] = 166060 },
    [188845] = { [TIER_LFR] = 166062, [TIER_NORMAL] = 166061, [TIER_HEROIC] = 166063, [TIER_MYTHIC] = 166064 },
    [188846] = { [TIER_LFR] = 166066, [TIER_NORMAL] = 166065, [TIER_HEROIC] = 166067, [TIER_MYTHIC] = 166068 },
    [188847] = { [TIER_LFR] = 166070, [TIER_NORMAL] = 166069, [TIER_HEROIC] = 166071, [TIER_MYTHIC] = 166072 },
    [188848] = { [TIER_LFR] = 166074, [TIER_NORMAL] = 166073, [TIER_HEROIC] = 166075, [TIER_MYTHIC] = 166076 },
    [188849] = { [TIER_LFR] = 166078, [TIER_NORMAL] = 166077, [TIER_HEROIC] = 166079, [TIER_MYTHIC] = 166080 },
    [188850] = { [TIER_LFR] = 166082, [TIER_NORMAL] = 166081, [TIER_HEROIC] = 166083, [TIER_MYTHIC] = 166084 },
    [188851] = { [TIER_LFR] = 166086, [TIER_NORMAL] = 166085, [TIER_HEROIC] = 166087, [TIER_MYTHIC] = 166088 },
    [188852] = { [TIER_LFR] = 168581, [TIER_NORMAL] = 166089, [TIER_HEROIC] = 168582, [TIER_MYTHIC] = 168583 },
    [188853] = { [TIER_LFR] = 168584, [TIER_NORMAL] = 166090, [TIER_HEROIC] = 168585, [TIER_MYTHIC] = 168586 },
    [188854] = { [TIER_LFR] = 166092, [TIER_NORMAL] = 166091, [TIER_HEROIC] = 166093, [TIER_MYTHIC] = 166094 },
    [188855] = { [TIER_LFR] = 166096, [TIER_NORMAL] = 166095, [TIER_HEROIC] = 166097, [TIER_MYTHIC] = 166098 },
    [188856] = { [TIER_LFR] = 166100, [TIER_NORMAL] = 166099, [TIER_HEROIC] = 166101, [TIER_MYTHIC] = 166102 },
    [188857] = { [TIER_LFR] = 166104, [TIER_NORMAL] = 166103, [TIER_HEROIC] = 166105, [TIER_MYTHIC] = 166106 },
    [188858] = { [TIER_LFR] = 166108, [TIER_NORMAL] = 166107, [TIER_HEROIC] = 166109, [TIER_MYTHIC] = 166110 },
    [188859] = { [TIER_LFR] = 166112, [TIER_NORMAL] = 166111, [TIER_HEROIC] = 166113, [TIER_MYTHIC] = 166114 },
    [188860] = { [TIER_LFR] = 166116, [TIER_NORMAL] = 166115, [TIER_HEROIC] = 166117, [TIER_MYTHIC] = 166118 },
    [188861] = { [TIER_LFR] = 166120, [TIER_NORMAL] = 166119, [TIER_HEROIC] = 166121, [TIER_MYTHIC] = 166122 },
    [188862] = { [TIER_LFR] = 168578, [TIER_NORMAL] = 166123, [TIER_HEROIC] = 168579, [TIER_MYTHIC] = 168580 },
    [188863] = { [TIER_LFR] = 166125, [TIER_NORMAL] = 166124, [TIER_HEROIC] = 166126, [TIER_MYTHIC] = 166127 },
    [188864] = { [TIER_LFR] = 166129, [TIER_NORMAL] = 166128, [TIER_HEROIC] = 166130, [TIER_MYTHIC] = 166131 },
    [188865] = { [TIER_LFR] = 166133, [TIER_NORMAL] = 166132, [TIER_HEROIC] = 166134, [TIER_MYTHIC] = 166135 },
    [188866] = { [TIER_LFR] = 166137, [TIER_NORMAL] = 166136, [TIER_HEROIC] = 166138, [TIER_MYTHIC] = 166139 },
    [188867] = { [TIER_LFR] = 166141, [TIER_NORMAL] = 166140, [TIER_HEROIC] = 166142, [TIER_MYTHIC] = 166143 },
    [188868] = { [TIER_LFR] = 166145, [TIER_NORMAL] = 166144, [TIER_HEROIC] = 166146, [TIER_MYTHIC] = 166147 },
    [188869] = { [TIER_LFR] = 166149, [TIER_NORMAL] = 166148, [TIER_HEROIC] = 166150, [TIER_MYTHIC] = 166151 },
    [188870] = { [TIER_LFR] = 168593, [TIER_NORMAL] = 166152, [TIER_HEROIC] = 168594, [TIER_MYTHIC] = 168595 },
    [188871] = { [TIER_LFR] = 166154, [TIER_NORMAL] = 166153, [TIER_HEROIC] = 166155, [TIER_MYTHIC] = 166156 },
    [188872] = { [TIER_LFR] = 166158, [TIER_NORMAL] = 166157, [TIER_HEROIC] = 166159, [TIER_MYTHIC] = 166160 },
    [188873] = { [TIER_LFR] = 166162, [TIER_NORMAL] = 166161, [TIER_HEROIC] = 166163, [TIER_MYTHIC] = 166164 },
    [188874] = { [TIER_LFR] = 166166, [TIER_NORMAL] = 166165, [TIER_HEROIC] = 166167, [TIER_MYTHIC] = 166168 },
    [188875] = { [TIER_LFR] = 166170, [TIER_NORMAL] = 166169, [TIER_HEROIC] = 166171, [TIER_MYTHIC] = 166172 },
    [188876] = { [TIER_LFR] = 166174, [TIER_NORMAL] = 166173, [TIER_HEROIC] = 166175, [TIER_MYTHIC] = 166176 },
    [188877] = { [TIER_LFR] = 166178, [TIER_NORMAL] = 166177, [TIER_HEROIC] = 166179, [TIER_MYTHIC] = 166180 },
    [188878] = { [TIER_LFR] = 166182, [TIER_NORMAL] = 166181, [TIER_HEROIC] = 166183, [TIER_MYTHIC] = 166184 },
    [188879] = { [TIER_LFR] = 166186, [TIER_NORMAL] = 166185, [TIER_HEROIC] = 166187, [TIER_MYTHIC] = 166188 },
    [188880] = { [TIER_LFR] = 166190, [TIER_NORMAL] = 166189, [TIER_HEROIC] = 166191, [TIER_MYTHIC] = 166192 },
    [188881] = { [TIER_LFR] = 166194, [TIER_NORMAL] = 166193, [TIER_HEROIC] = 166195, [TIER_MYTHIC] = 166196 },
    [188882] = { [TIER_LFR] = 166198, [TIER_NORMAL] = 166197, [TIER_HEROIC] = 166199, [TIER_MYTHIC] = 166200 },
    [188883] = { [TIER_LFR] = 166202, [TIER_NORMAL] = 166201, [TIER_HEROIC] = 166203, [TIER_MYTHIC] = 166204 },
    [188884] = { [TIER_LFR] = 166206, [TIER_NORMAL] = 166205, [TIER_HEROIC] = 166207, [TIER_MYTHIC] = 166208 },
    [188885] = { [TIER_LFR] = 166210, [TIER_NORMAL] = 166209, [TIER_HEROIC] = 166211, [TIER_MYTHIC] = 166212 },
    [188886] = { [TIER_LFR] = 166214, [TIER_NORMAL] = 166213, [TIER_HEROIC] = 166215, [TIER_MYTHIC] = 166216 },
    [188887] = { [TIER_LFR] = 166218, [TIER_NORMAL] = 166217, [TIER_HEROIC] = 166219, [TIER_MYTHIC] = 166220 },
    [188888] = { [TIER_LFR] = 166222, [TIER_NORMAL] = 166221, [TIER_HEROIC] = 166223, [TIER_MYTHIC] = 166224 },
    [188889] = { [TIER_LFR] = 166226, [TIER_NORMAL] = 166225, [TIER_HEROIC] = 166227, [TIER_MYTHIC] = 166228 },
    [188890] = { [TIER_LFR] = 166230, [TIER_NORMAL] = 166229, [TIER_HEROIC] = 166231, [TIER_MYTHIC] = 166232 },
    [188891] = { [TIER_LFR] = 166234, [TIER_NORMAL] = 166233, [TIER_HEROIC] = 166235, [TIER_MYTHIC] = 166236 },
    [188892] = { [TIER_LFR] = 166238, [TIER_NORMAL] = 166237, [TIER_HEROIC] = 166239, [TIER_MYTHIC] = 166240 },
    [188893] = { [TIER_LFR] = 166242, [TIER_NORMAL] = 166241, [TIER_HEROIC] = 166243, [TIER_MYTHIC] = 166244 },
    [188894] = { [TIER_LFR] = 166246, [TIER_NORMAL] = 166245, [TIER_HEROIC] = 166247, [TIER_MYTHIC] = 166248 },
    [188895] = { [TIER_LFR] = 166250, [TIER_NORMAL] = 166249, [TIER_HEROIC] = 166251, [TIER_MYTHIC] = 166252 },
    [188896] = { [TIER_LFR] = 166254, [TIER_NORMAL] = 166253, [TIER_HEROIC] = 166255, [TIER_MYTHIC] = 166256 },
    [188897] = { [TIER_LFR] = 168587, [TIER_NORMAL] = 166257, [TIER_HEROIC] = 168588, [TIER_MYTHIC] = 168589 },
    [188898] = { [TIER_LFR] = 168590, [TIER_NORMAL] = 166258, [TIER_HEROIC] = 168591, [TIER_MYTHIC] = 168592 },
    [188899] = { [TIER_LFR] = 166260, [TIER_NORMAL] = 166259, [TIER_HEROIC] = 166261, [TIER_MYTHIC] = 166262 },
    [188900] = { [TIER_LFR] = 166264, [TIER_NORMAL] = 166263, [TIER_HEROIC] = 166265, [TIER_MYTHIC] = 166266 },
    [188901] = { [TIER_LFR] = 166268, [TIER_NORMAL] = 166267, [TIER_HEROIC] = 166269, [TIER_MYTHIC] = 166270 },
    [188902] = { [TIER_LFR] = 166272, [TIER_NORMAL] = 166271, [TIER_HEROIC] = 166273, [TIER_MYTHIC] = 166274 },
    [188903] = { [TIER_LFR] = 166276, [TIER_NORMAL] = 166275, [TIER_HEROIC] = 166277, [TIER_MYTHIC] = 166278 },
    [188904] = { [TIER_LFR] = 166280, [TIER_NORMAL] = 166279, [TIER_HEROIC] = 166281, [TIER_MYTHIC] = 166282 },
    [188905] = { [TIER_LFR] = 166284, [TIER_NORMAL] = 166283, [TIER_HEROIC] = 166285, [TIER_MYTHIC] = 166286 },
    [188906] = { [TIER_LFR] = 168563, [TIER_NORMAL] = 166287, [TIER_HEROIC] = 168564, [TIER_MYTHIC] = 168565 },
    [188907] = { [TIER_LFR] = 168566, [TIER_NORMAL] = 166288, [TIER_HEROIC] = 168567, [TIER_MYTHIC] = 168568 },
    [188908] = { [TIER_LFR] = 166290, [TIER_NORMAL] = 166289, [TIER_HEROIC] = 166291, [TIER_MYTHIC] = 166292 },
    [188909] = { [TIER_LFR] = 166294, [TIER_NORMAL] = 166293, [TIER_HEROIC] = 166295, [TIER_MYTHIC] = 166296 },
    [188910] = { [TIER_LFR] = 166298, [TIER_NORMAL] = 166297, [TIER_HEROIC] = 166299, [TIER_MYTHIC] = 166300 },
    [188911] = { [TIER_LFR] = 166302, [TIER_NORMAL] = 166301, [TIER_HEROIC] = 166303, [TIER_MYTHIC] = 166304 },
    [188912] = { [TIER_LFR] = 166306, [TIER_NORMAL] = 166305, [TIER_HEROIC] = 166307, [TIER_MYTHIC] = 166308 },
    [188913] = { [TIER_LFR] = 166310, [TIER_NORMAL] = 166309, [TIER_HEROIC] = 166311, [TIER_MYTHIC] = 166312 },
    [188914] = { [TIER_LFR] = 166314, [TIER_NORMAL] = 166313, [TIER_HEROIC] = 166315, [TIER_MYTHIC] = 166316 },
    [188915] = { [TIER_LFR] = 168572, [TIER_NORMAL] = 166317, [TIER_HEROIC] = 168573, [TIER_MYTHIC] = 168574 },
    [188916] = { [TIER_LFR] = 168575, [TIER_NORMAL] = 166318, [TIER_HEROIC] = 168576, [TIER_MYTHIC] = 168577 },
    [188917] = { [TIER_LFR] = 166320, [TIER_NORMAL] = 166319, [TIER_HEROIC] = 166321, [TIER_MYTHIC] = 166322 },
    [188918] = { [TIER_LFR] = 166324, [TIER_NORMAL] = 166323, [TIER_HEROIC] = 166325, [TIER_MYTHIC] = 166326 },
    [188919] = { [TIER_LFR] = 166328, [TIER_NORMAL] = 166327, [TIER_HEROIC] = 166329, [TIER_MYTHIC] = 166330 },
    [188920] = { [TIER_LFR] = 166332, [TIER_NORMAL] = 166331, [TIER_HEROIC] = 166333, [TIER_MYTHIC] = 166334 },
    [188921] = { [TIER_LFR] = 166336, [TIER_NORMAL] = 166335, [TIER_HEROIC] = 166337, [TIER_MYTHIC] = 166338 },
    [188922] = { [TIER_LFR] = 166340, [TIER_NORMAL] = 166339, [TIER_HEROIC] = 166341, [TIER_MYTHIC] = 166342 },
    [188923] = { [TIER_LFR] = 166344, [TIER_NORMAL] = 166343, [TIER_HEROIC] = 166345, [TIER_MYTHIC] = 166346 },
    [188924] = { [TIER_LFR] = 166348, [TIER_NORMAL] = 166347, [TIER_HEROIC] = 166349, [TIER_MYTHIC] = 166350 },
    [188925] = { [TIER_LFR] = 166352, [TIER_NORMAL] = 166351, [TIER_HEROIC] = 166353, [TIER_MYTHIC] = 166354 },
    [188926] = { [TIER_LFR] = 168560, [TIER_NORMAL] = 166355, [TIER_HEROIC] = 168561, [TIER_MYTHIC] = 168562 },
    [188927] = { [TIER_LFR] = 166357, [TIER_NORMAL] = 166356, [TIER_HEROIC] = 166358, [TIER_MYTHIC] = 166359 },
    [188928] = { [TIER_LFR] = 166361, [TIER_NORMAL] = 166360, [TIER_HEROIC] = 166362, [TIER_MYTHIC] = 166363 },
    [188929] = { [TIER_LFR] = 166365, [TIER_NORMAL] = 166364, [TIER_HEROIC] = 166366, [TIER_MYTHIC] = 166367 },
    [188930] = { [TIER_LFR] = 166369, [TIER_NORMAL] = 166368, [TIER_HEROIC] = 166370, [TIER_MYTHIC] = 166371 },
    [188931] = { [TIER_LFR] = 166373, [TIER_NORMAL] = 166372, [TIER_HEROIC] = 166374, [TIER_MYTHIC] = 166375 },
    [188932] = { [TIER_LFR] = 166377, [TIER_NORMAL] = 166376, [TIER_HEROIC] = 166378, [TIER_MYTHIC] = 166379 },
    [188933] = { [TIER_LFR] = 166381, [TIER_NORMAL] = 166380, [TIER_HEROIC] = 166382, [TIER_MYTHIC] = 166383 },
    [188934] = { [TIER_LFR] = 166385, [TIER_NORMAL] = 166384, [TIER_HEROIC] = 166386, [TIER_MYTHIC] = 166387 },
    [188935] = { [TIER_LFR] = 168569, [TIER_NORMAL] = 166388, [TIER_HEROIC] = 168570, [TIER_MYTHIC] = 168571 },
    [188936] = { [TIER_LFR] = 166390, [TIER_NORMAL] = 166389, [TIER_HEROIC] = 166391, [TIER_MYTHIC] = 166392 },
    [188937] = { [TIER_LFR] = 166394, [TIER_NORMAL] = 166393, [TIER_HEROIC] = 166395, [TIER_MYTHIC] = 166396 },
    [188938] = { [TIER_LFR] = 166398, [TIER_NORMAL] = 166397, [TIER_HEROIC] = 166399, [TIER_MYTHIC] = 166400 },
    [188939] = { [TIER_LFR] = 166402, [TIER_NORMAL] = 166401, [TIER_HEROIC] = 166403, [TIER_MYTHIC] = 166404 },
    [188940] = { [TIER_LFR] = 166406, [TIER_NORMAL] = 166405, [TIER_HEROIC] = 166407, [TIER_MYTHIC] = 166408 },
    [188941] = { [TIER_LFR] = 166410, [TIER_NORMAL] = 166409, [TIER_HEROIC] = 166411, [TIER_MYTHIC] = 166412 },
    [188942] = { [TIER_LFR] = 166414, [TIER_NORMAL] = 166413, [TIER_HEROIC] = 166415, [TIER_MYTHIC] = 166416 },
    [188943] = { [TIER_LFR] = 166418, [TIER_NORMAL] = 166417, [TIER_HEROIC] = 166419, [TIER_MYTHIC] = 166420 },
    [188944] = { [TIER_LFR] = 168557, [TIER_NORMAL] = 166421, [TIER_HEROIC] = 168559, [TIER_MYTHIC] = 168558 },
    [188945] = { [TIER_LFR] = 166423, [TIER_NORMAL] = 166422, [TIER_HEROIC] = 166424, [TIER_MYTHIC] = 166425 },
    [200315] = { [TIER_LFR] = 182448, [TIER_NORMAL] = 182447, [TIER_HEROIC] = 182449, [TIER_MYTHIC] = 182450 },
    [200316] = { [TIER_LFR] = 182452, [TIER_NORMAL] = 182451, [TIER_HEROIC] = 182453, [TIER_MYTHIC] = 182454 },
    [200317] = { [TIER_LFR] = 182456, [TIER_NORMAL] = 182455, [TIER_HEROIC] = 182457, [TIER_MYTHIC] = 182458 },
    [200318] = { [TIER_LFR] = 182460, [TIER_NORMAL] = 182459, [TIER_HEROIC] = 182461, [TIER_MYTHIC] = 182462 },
    [200319] = { [TIER_LFR] = 182464, [TIER_NORMAL] = 182463, [TIER_HEROIC] = 182465, [TIER_MYTHIC] = 182466 },
    [200320] = { [TIER_LFR] = 182468, [TIER_NORMAL] = 182467, [TIER_HEROIC] = 182469, [TIER_MYTHIC] = 182470 },
    [200321] = { [TIER_LFR] = 182472, [TIER_NORMAL] = 182471, [TIER_HEROIC] = 182473, [TIER_MYTHIC] = 182474 },
    [200322] = { [TIER_LFR] = 182476, [TIER_NORMAL] = 182475, [TIER_HEROIC] = 182477, [TIER_MYTHIC] = 182478 },
    [200323] = { [TIER_LFR] = 182480, [TIER_NORMAL] = 182479, [TIER_HEROIC] = 182481, [TIER_MYTHIC] = 182482 },
    [200324] = { [TIER_LFR] = 182484, [TIER_NORMAL] = 182483, [TIER_HEROIC] = 182485, [TIER_MYTHIC] = 182486 },
    [200325] = { [TIER_LFR] = 182488, [TIER_NORMAL] = 182487, [TIER_HEROIC] = 182489, [TIER_MYTHIC] = 182490 },
    [200326] = { [TIER_LFR] = 182492, [TIER_NORMAL] = 182491, [TIER_HEROIC] = 182493, [TIER_MYTHIC] = 182494 },
    [200327] = { [TIER_LFR] = 182496, [TIER_NORMAL] = 182495, [TIER_HEROIC] = 182497, [TIER_MYTHIC] = 182498 },
    [200328] = { [TIER_LFR] = 182500, [TIER_NORMAL] = 182499, [TIER_HEROIC] = 182501, [TIER_MYTHIC] = 182502 },
    [200329] = { [TIER_LFR] = 182504, [TIER_NORMAL] = 182503, [TIER_HEROIC] = 182505, [TIER_MYTHIC] = 182506 },
    [200330] = { [TIER_LFR] = 182508, [TIER_NORMAL] = 182507, [TIER_HEROIC] = 182509, [TIER_MYTHIC] = 182510 },
    [200331] = { [TIER_LFR] = 182512, [TIER_NORMAL] = 182511, [TIER_HEROIC] = 182513, [TIER_MYTHIC] = 182514 },
    [200332] = { [TIER_LFR] = 182516, [TIER_NORMAL] = 182515, [TIER_HEROIC] = 182517, [TIER_MYTHIC] = 182518 },
    [200333] = { [TIER_LFR] = 182520, [TIER_NORMAL] = 182519, [TIER_HEROIC] = 182521, [TIER_MYTHIC] = 182522 },
    [200334] = { [TIER_LFR] = 182524, [TIER_NORMAL] = 182523, [TIER_HEROIC] = 182525, [TIER_MYTHIC] = 182526 },
    [200335] = { [TIER_LFR] = 182528, [TIER_NORMAL] = 182527, [TIER_HEROIC] = 182529, [TIER_MYTHIC] = 182530 },
    [200336] = { [TIER_LFR] = 182532, [TIER_NORMAL] = 182531, [TIER_HEROIC] = 182533, [TIER_MYTHIC] = 182534 },
    [200337] = { [TIER_LFR] = 182536, [TIER_NORMAL] = 182535, [TIER_HEROIC] = 182537, [TIER_MYTHIC] = 182538 },
    [200338] = { [TIER_LFR] = 182540, [TIER_NORMAL] = 182539, [TIER_HEROIC] = 182541, [TIER_MYTHIC] = 182542 },
    [200339] = { [TIER_LFR] = 182544, [TIER_NORMAL] = 182543, [TIER_HEROIC] = 182545, [TIER_MYTHIC] = 182546 },
    [200340] = { [TIER_LFR] = 182548, [TIER_NORMAL] = 182547, [TIER_HEROIC] = 182549, [TIER_MYTHIC] = 182550 },
    [200341] = { [TIER_LFR] = 182552, [TIER_NORMAL] = 182551, [TIER_HEROIC] = 182553, [TIER_MYTHIC] = 182554 },
    [200342] = { [TIER_LFR] = 182556, [TIER_NORMAL] = 182555, [TIER_HEROIC] = 182557, [TIER_MYTHIC] = 182558 },
    [200343] = { [TIER_LFR] = 182560, [TIER_NORMAL] = 182559, [TIER_HEROIC] = 182561, [TIER_MYTHIC] = 182562 },
    [200344] = { [TIER_LFR] = 182564, [TIER_NORMAL] = 182563, [TIER_HEROIC] = 182565, [TIER_MYTHIC] = 182566 },
    [200345] = { [TIER_LFR] = 182568, [TIER_NORMAL] = 182567, [TIER_HEROIC] = 182569, [TIER_MYTHIC] = 182570 },
    [200346] = { [TIER_LFR] = 182572, [TIER_NORMAL] = 182571, [TIER_HEROIC] = 182573, [TIER_MYTHIC] = 182574 },
    [200347] = { [TIER_LFR] = 182576, [TIER_NORMAL] = 182575, [TIER_HEROIC] = 182577, [TIER_MYTHIC] = 182578 },
    [200348] = { [TIER_LFR] = 182580, [TIER_NORMAL] = 182579, [TIER_HEROIC] = 182581, [TIER_MYTHIC] = 182582 },
    [200349] = { [TIER_LFR] = 182584, [TIER_NORMAL] = 182583, [TIER_HEROIC] = 182585, [TIER_MYTHIC] = 182586 },
    [200350] = { [TIER_LFR] = 182588, [TIER_NORMAL] = 182587, [TIER_HEROIC] = 182589, [TIER_MYTHIC] = 182590 },
    [200351] = { [TIER_LFR] = 182592, [TIER_NORMAL] = 182591, [TIER_HEROIC] = 182593, [TIER_MYTHIC] = 182594 },
    [200352] = { [TIER_LFR] = 182596, [TIER_NORMAL] = 182595, [TIER_HEROIC] = 182597, [TIER_MYTHIC] = 182598 },
    [200353] = { [TIER_LFR] = 182600, [TIER_NORMAL] = 182599, [TIER_HEROIC] = 182601, [TIER_MYTHIC] = 182602 },
    [200354] = { [TIER_LFR] = 182604, [TIER_NORMAL] = 182603, [TIER_HEROIC] = 182605, [TIER_MYTHIC] = 182606 },
    [200355] = { [TIER_LFR] = 182608, [TIER_NORMAL] = 182607, [TIER_HEROIC] = 182609, [TIER_MYTHIC] = 182610 },
    [200356] = { [TIER_LFR] = 182612, [TIER_NORMAL] = 182611, [TIER_HEROIC] = 182613, [TIER_MYTHIC] = 182614 },
    [200357] = { [TIER_LFR] = 182616, [TIER_NORMAL] = 182615, [TIER_HEROIC] = 182617, [TIER_MYTHIC] = 182618 },
    [200358] = { [TIER_LFR] = 182620, [TIER_NORMAL] = 182619, [TIER_HEROIC] = 182621, [TIER_MYTHIC] = 182622 },
    [200359] = { [TIER_LFR] = 182624, [TIER_NORMAL] = 182623, [TIER_HEROIC] = 182625, [TIER_MYTHIC] = 182626 },
    [200360] = { [TIER_LFR] = 182628, [TIER_NORMAL] = 182627, [TIER_HEROIC] = 182629, [TIER_MYTHIC] = 182630 },
    [200361] = { [TIER_LFR] = 182632, [TIER_NORMAL] = 182631, [TIER_HEROIC] = 182633, [TIER_MYTHIC] = 182634 },
    [200362] = { [TIER_LFR] = 182636, [TIER_NORMAL] = 182635, [TIER_HEROIC] = 182637, [TIER_MYTHIC] = 182638 },
    [200363] = { [TIER_LFR] = 182640, [TIER_NORMAL] = 182639, [TIER_HEROIC] = 182641, [TIER_MYTHIC] = 182642 },
    [200364] = { [TIER_LFR] = 182644, [TIER_NORMAL] = 182643, [TIER_HEROIC] = 182645, [TIER_MYTHIC] = 182646 },
    [200365] = { [TIER_LFR] = 182648, [TIER_NORMAL] = 182647, [TIER_HEROIC] = 182649, [TIER_MYTHIC] = 182650 },
    [200366] = { [TIER_LFR] = 182652, [TIER_NORMAL] = 182651, [TIER_HEROIC] = 182653, [TIER_MYTHIC] = 182654 },
    [200367] = { [TIER_LFR] = 182656, [TIER_NORMAL] = 182655, [TIER_HEROIC] = 182657, [TIER_MYTHIC] = 182658 },
    [200368] = { [TIER_LFR] = 182660, [TIER_NORMAL] = 182659, [TIER_HEROIC] = 182661, [TIER_MYTHIC] = 182662 },
    [200369] = { [TIER_LFR] = 182664, [TIER_NORMAL] = 182663, [TIER_HEROIC] = 182665, [TIER_MYTHIC] = 182666 },
    [200370] = { [TIER_LFR] = 182668, [TIER_NORMAL] = 182667, [TIER_HEROIC] = 182669, [TIER_MYTHIC] = 182670 },
    [200371] = { [TIER_LFR] = 182672, [TIER_NORMAL] = 182671, [TIER_HEROIC] = 182673, [TIER_MYTHIC] = 182674 },
    [200372] = { [TIER_LFR] = 182676, [TIER_NORMAL] = 182675, [TIER_HEROIC] = 182677, [TIER_MYTHIC] = 182678 },
    [200373] = { [TIER_LFR] = 182680, [TIER_NORMAL] = 182679, [TIER_HEROIC] = 182681, [TIER_MYTHIC] = 182682 },
    [200374] = { [TIER_LFR] = 182684, [TIER_NORMAL] = 182683, [TIER_HEROIC] = 182685, [TIER_MYTHIC] = 182686 },
    [200375] = { [TIER_LFR] = 182688, [TIER_NORMAL] = 182687, [TIER_HEROIC] = 182689, [TIER_MYTHIC] = 182690 },
    [200376] = { [TIER_LFR] = 182692, [TIER_NORMAL] = 182691, [TIER_HEROIC] = 182693, [TIER_MYTHIC] = 182694 },
    [200377] = { [TIER_LFR] = 182696, [TIER_NORMAL] = 182695, [TIER_HEROIC] = 182697, [TIER_MYTHIC] = 182698 },
    [200378] = { [TIER_LFR] = 182700, [TIER_NORMAL] = 182699, [TIER_HEROIC] = 182701, [TIER_MYTHIC] = 182702 },
    [200379] = { [TIER_LFR] = 182704, [TIER_NORMAL] = 182703, [TIER_HEROIC] = 182705, [TIER_MYTHIC] = 182706 },
    [200380] = { [TIER_LFR] = 182708, [TIER_NORMAL] = 182707, [TIER_HEROIC] = 182709, [TIER_MYTHIC] = 182710 },
    [200381] = { [TIER_LFR] = 182712, [TIER_NORMAL] = 182711, [TIER_HEROIC] = 182713, [TIER_MYTHIC] = 182714 },
    [200382] = { [TIER_LFR] = 182716, [TIER_NORMAL] = 182715, [TIER_HEROIC] = 182717, [TIER_MYTHIC] = 182718 },
    [200383] = { [TIER_LFR] = 182720, [TIER_NORMAL] = 182719, [TIER_HEROIC] = 182721, [TIER_MYTHIC] = 182722 },
    [200384] = { [TIER_LFR] = 182724, [TIER_NORMAL] = 182723, [TIER_HEROIC] = 182725, [TIER_MYTHIC] = 182726 },
    [200385] = { [TIER_LFR] = 182728, [TIER_NORMAL] = 182727, [TIER_HEROIC] = 182729, [TIER_MYTHIC] = 182730 },
    [200386] = { [TIER_LFR] = 182732, [TIER_NORMAL] = 182731, [TIER_HEROIC] = 182733, [TIER_MYTHIC] = 182734 },
    [200387] = { [TIER_LFR] = 182736, [TIER_NORMAL] = 182735, [TIER_HEROIC] = 182737, [TIER_MYTHIC] = 182738 },
    [200388] = { [TIER_LFR] = 182740, [TIER_NORMAL] = 182739, [TIER_HEROIC] = 182741, [TIER_MYTHIC] = 182742 },
    [200389] = { [TIER_LFR] = 182744, [TIER_NORMAL] = 182743, [TIER_HEROIC] = 182745, [TIER_MYTHIC] = 182746 },
    [200390] = { [TIER_LFR] = 182748, [TIER_NORMAL] = 182747, [TIER_HEROIC] = 182749, [TIER_MYTHIC] = 182750 },
    [200391] = { [TIER_LFR] = 182752, [TIER_NORMAL] = 182751, [TIER_HEROIC] = 182753, [TIER_MYTHIC] = 182754 },
    [200392] = { [TIER_LFR] = 182756, [TIER_NORMAL] = 182755, [TIER_HEROIC] = 182757, [TIER_MYTHIC] = 182758 },
    [200393] = { [TIER_LFR] = 182760, [TIER_NORMAL] = 182759, [TIER_HEROIC] = 182761, [TIER_MYTHIC] = 182762 },
    [200394] = { [TIER_LFR] = 182764, [TIER_NORMAL] = 182763, [TIER_HEROIC] = 182765, [TIER_MYTHIC] = 182766 },
    [200395] = { [TIER_LFR] = 182768, [TIER_NORMAL] = 182767, [TIER_HEROIC] = 182769, [TIER_MYTHIC] = 182770 },
    [200396] = { [TIER_LFR] = 182772, [TIER_NORMAL] = 182771, [TIER_HEROIC] = 182773, [TIER_MYTHIC] = 182774 },
    [200397] = { [TIER_LFR] = 182776, [TIER_NORMAL] = 182775, [TIER_HEROIC] = 182777, [TIER_MYTHIC] = 182778 },
    [200398] = { [TIER_LFR] = 182780, [TIER_NORMAL] = 182779, [TIER_HEROIC] = 182781, [TIER_MYTHIC] = 182782 },
    [200399] = { [TIER_LFR] = 182784, [TIER_NORMAL] = 182783, [TIER_HEROIC] = 182785, [TIER_MYTHIC] = 182786 },
    [200400] = { [TIER_LFR] = 182788, [TIER_NORMAL] = 182787, [TIER_HEROIC] = 182789, [TIER_MYTHIC] = 182790 },
    [200401] = { [TIER_LFR] = 182792, [TIER_NORMAL] = 182791, [TIER_HEROIC] = 182793, [TIER_MYTHIC] = 182794 },
    [200402] = { [TIER_LFR] = 182796, [TIER_NORMAL] = 182795, [TIER_HEROIC] = 182797, [TIER_MYTHIC] = 182798 },
    [200403] = { [TIER_LFR] = 182800, [TIER_NORMAL] = 182799, [TIER_HEROIC] = 182801, [TIER_MYTHIC] = 182802 },
    [200404] = { [TIER_LFR] = 182804, [TIER_NORMAL] = 182803, [TIER_HEROIC] = 182805, [TIER_MYTHIC] = 182806 },
    [200405] = { [TIER_LFR] = 182808, [TIER_NORMAL] = 182807, [TIER_HEROIC] = 182809, [TIER_MYTHIC] = 182810 },
    [200406] = { [TIER_LFR] = 182812, [TIER_NORMAL] = 182811, [TIER_HEROIC] = 182813, [TIER_MYTHIC] = 182814 },
    [200407] = { [TIER_LFR] = 182816, [TIER_NORMAL] = 182815, [TIER_HEROIC] = 182817, [TIER_MYTHIC] = 182818 },
    [200408] = { [TIER_LFR] = 182820, [TIER_NORMAL] = 182819, [TIER_HEROIC] = 182821, [TIER_MYTHIC] = 182822 },
    [200409] = { [TIER_LFR] = 182824, [TIER_NORMAL] = 182823, [TIER_HEROIC] = 182825, [TIER_MYTHIC] = 182826 },
    [200410] = { [TIER_LFR] = 182828, [TIER_NORMAL] = 182827, [TIER_HEROIC] = 182829, [TIER_MYTHIC] = 182830 },
    [200411] = { [TIER_LFR] = 182832, [TIER_NORMAL] = 182831, [TIER_HEROIC] = 182833, [TIER_MYTHIC] = 182834 },
    [200412] = { [TIER_LFR] = 182836, [TIER_NORMAL] = 182835, [TIER_HEROIC] = 182837, [TIER_MYTHIC] = 182838 },
    [200413] = { [TIER_LFR] = 182840, [TIER_NORMAL] = 182839, [TIER_HEROIC] = 182841, [TIER_MYTHIC] = 182842 },
    [200414] = { [TIER_LFR] = 182844, [TIER_NORMAL] = 182843, [TIER_HEROIC] = 182845, [TIER_MYTHIC] = 182846 },
    [200415] = { [TIER_LFR] = 182848, [TIER_NORMAL] = 182847, [TIER_HEROIC] = 182849, [TIER_MYTHIC] = 182850 },
    [200416] = { [TIER_LFR] = 182852, [TIER_NORMAL] = 182851, [TIER_HEROIC] = 182853, [TIER_MYTHIC] = 182854 },
    [200417] = { [TIER_LFR] = 182856, [TIER_NORMAL] = 182855, [TIER_HEROIC] = 182857, [TIER_MYTHIC] = 182858 },
    [200418] = { [TIER_LFR] = 182860, [TIER_NORMAL] = 182859, [TIER_HEROIC] = 182861, [TIER_MYTHIC] = 182862 },
    [200419] = { [TIER_LFR] = 182864, [TIER_NORMAL] = 182863, [TIER_HEROIC] = 182865, [TIER_MYTHIC] = 182866 },
    [200420] = { [TIER_LFR] = 182868, [TIER_NORMAL] = 182867, [TIER_HEROIC] = 182869, [TIER_MYTHIC] = 182870 },
    [200421] = { [TIER_LFR] = 182872, [TIER_NORMAL] = 182871, [TIER_HEROIC] = 182873, [TIER_MYTHIC] = 182874 },
    [200422] = { [TIER_LFR] = 182876, [TIER_NORMAL] = 182875, [TIER_HEROIC] = 182877, [TIER_MYTHIC] = 182878 },
    [200423] = { [TIER_LFR] = 182880, [TIER_NORMAL] = 182879, [TIER_HEROIC] = 182881, [TIER_MYTHIC] = 182882 },
    [200424] = { [TIER_LFR] = 182884, [TIER_NORMAL] = 182883, [TIER_HEROIC] = 182885, [TIER_MYTHIC] = 182886 },
    [200425] = { [TIER_LFR] = 182888, [TIER_NORMAL] = 182887, [TIER_HEROIC] = 182889, [TIER_MYTHIC] = 182890 },
    [200426] = { [TIER_LFR] = 182892, [TIER_NORMAL] = 182891, [TIER_HEROIC] = 182893, [TIER_MYTHIC] = 182894 },
    [200427] = { [TIER_LFR] = 182896, [TIER_NORMAL] = 182895, [TIER_HEROIC] = 182897, [TIER_MYTHIC] = 182898 },
    [200428] = { [TIER_LFR] = 182900, [TIER_NORMAL] = 182899, [TIER_HEROIC] = 182901, [TIER_MYTHIC] = 182902 },
    [200429] = { [TIER_LFR] = 182904, [TIER_NORMAL] = 182903, [TIER_HEROIC] = 182905, [TIER_MYTHIC] = 182906 },
    [200430] = { [TIER_LFR] = 182908, [TIER_NORMAL] = 182907, [TIER_HEROIC] = 182909, [TIER_MYTHIC] = 182910 },
    [200431] = { [TIER_LFR] = 182912, [TIER_NORMAL] = 182911, [TIER_HEROIC] = 182913, [TIER_MYTHIC] = 182914 },
    [202438] = { [TIER_LFR] = 186327, [TIER_NORMAL] = 184412, [TIER_HEROIC] = 186325, [TIER_MYTHIC] = 186326 },
    [202439] = { [TIER_LFR] = 186288, [TIER_NORMAL] = 184413, [TIER_HEROIC] = 186286, [TIER_MYTHIC] = 186287 },
    [202440] = { [TIER_LFR] = 186291, [TIER_NORMAL] = 184414, [TIER_HEROIC] = 186289, [TIER_MYTHIC] = 186290 },
    [202441] = { [TIER_LFR] = 186298, [TIER_NORMAL] = 184415, [TIER_HEROIC] = 186299, [TIER_MYTHIC] = 186300 },
    [202442] = { [TIER_LFR] = 186309, [TIER_NORMAL] = 184416, [TIER_HEROIC] = 186307, [TIER_MYTHIC] = 186308 },
    [202443] = { [TIER_LFR] = 185918, [TIER_NORMAL] = 184417, [TIER_HEROIC] = 185920, [TIER_MYTHIC] = 185919 },
    [202444] = { [TIER_LFR] = 186318, [TIER_NORMAL] = 184418, [TIER_HEROIC] = 186316, [TIER_MYTHIC] = 186317 },
    [202445] = { [TIER_LFR] = 186321, [TIER_NORMAL] = 184419, [TIER_HEROIC] = 186319, [TIER_MYTHIC] = 186320 },
    [202446] = { [TIER_LFR] = 186324, [TIER_NORMAL] = 184420, [TIER_HEROIC] = 186322, [TIER_MYTHIC] = 186323 },
    [202447] = { [TIER_LFR] = 186014, [TIER_NORMAL] = 184421, [TIER_HEROIC] = 186012, [TIER_MYTHIC] = 186013 },
    [202448] = { [TIER_LFR] = 185978, [TIER_NORMAL] = 184422, [TIER_HEROIC] = 185976, [TIER_MYTHIC] = 185977 },
    [202449] = { [TIER_LFR] = 185981, [TIER_NORMAL] = 184423, [TIER_HEROIC] = 185979, [TIER_MYTHIC] = 185980 },
    [202450] = { [TIER_LFR] = 185982, [TIER_NORMAL] = 184424, [TIER_HEROIC] = 185983, [TIER_MYTHIC] = 185984 },
    [202451] = { [TIER_LFR] = 185993, [TIER_NORMAL] = 184425, [TIER_HEROIC] = 185991, [TIER_MYTHIC] = 185992 },
    [202452] = { [TIER_LFR] = 185994, [TIER_NORMAL] = 184426, [TIER_HEROIC] = 185995, [TIER_MYTHIC] = 185996 },
    [202453] = { [TIER_LFR] = 186005, [TIER_NORMAL] = 184427, [TIER_HEROIC] = 186003, [TIER_MYTHIC] = 186004 },
    [202454] = { [TIER_LFR] = 186008, [TIER_NORMAL] = 184428, [TIER_HEROIC] = 186006, [TIER_MYTHIC] = 186007 },
    [202455] = { [TIER_LFR] = 186011, [TIER_NORMAL] = 184429, [TIER_HEROIC] = 186009, [TIER_MYTHIC] = 186010 },
    [202456] = { [TIER_LFR] = 186264, [TIER_NORMAL] = 184430, [TIER_HEROIC] = 186262, [TIER_MYTHIC] = 186263 },
    [202457] = { [TIER_LFR] = 186261, [TIER_NORMAL] = 184431, [TIER_HEROIC] = 186259, [TIER_MYTHIC] = 186260 },
    [202458] = { [TIER_LFR] = 186273, [TIER_NORMAL] = 184432, [TIER_HEROIC] = 186271, [TIER_MYTHIC] = 186272 },
    [202459] = { [TIER_LFR] = 186285, [TIER_NORMAL] = 184433, [TIER_HEROIC] = 186283, [TIER_MYTHIC] = 186284 },
    [202460] = { [TIER_LFR] = 186282, [TIER_NORMAL] = 184434, [TIER_HEROIC] = 186280, [TIER_MYTHIC] = 186281 },
    [202461] = { [TIER_LFR] = 186279, [TIER_NORMAL] = 184435, [TIER_HEROIC] = 186277, [TIER_MYTHIC] = 186278 },
    [202462] = { [TIER_LFR] = 186276, [TIER_NORMAL] = 184436, [TIER_HEROIC] = 186274, [TIER_MYTHIC] = 186275 },
    [202463] = { [TIER_LFR] = 186270, [TIER_NORMAL] = 184437, [TIER_HEROIC] = 186268, [TIER_MYTHIC] = 186269 },
    [202464] = { [TIER_LFR] = 186267, [TIER_NORMAL] = 184438, [TIER_HEROIC] = 186265, [TIER_MYTHIC] = 186266 },
    [202465] = { [TIER_LFR] = 186062, [TIER_NORMAL] = 184439, [TIER_HEROIC] = 186060, [TIER_MYTHIC] = 186061 },
    [202466] = { [TIER_LFR] = 186020, [TIER_NORMAL] = 184440, [TIER_HEROIC] = 186018, [TIER_MYTHIC] = 186019 },
    [202467] = { [TIER_LFR] = 186023, [TIER_NORMAL] = 184441, [TIER_HEROIC] = 186021, [TIER_MYTHIC] = 186022 },
    [202468] = { [TIER_LFR] = 186030, [TIER_NORMAL] = 184442, [TIER_HEROIC] = 186031, [TIER_MYTHIC] = 186032 },
    [202469] = { [TIER_LFR] = 186041, [TIER_NORMAL] = 184443, [TIER_HEROIC] = 186039, [TIER_MYTHIC] = 186040 },
    [202470] = { [TIER_LFR] = 186042, [TIER_NORMAL] = 184444, [TIER_HEROIC] = 186043, [TIER_MYTHIC] = 186044 },
    [202471] = { [TIER_LFR] = 186053, [TIER_NORMAL] = 184445, [TIER_HEROIC] = 186051, [TIER_MYTHIC] = 186052 },
    [202472] = { [TIER_LFR] = 186056, [TIER_NORMAL] = 184446, [TIER_HEROIC] = 186054, [TIER_MYTHIC] = 186055 },
    [202473] = { [TIER_LFR] = 186059, [TIER_NORMAL] = 184447, [TIER_HEROIC] = 186057, [TIER_MYTHIC] = 186058 },
    [202474] = { [TIER_LFR] = 186101, [TIER_NORMAL] = 184448, [TIER_HEROIC] = 186099, [TIER_MYTHIC] = 186100 },
    [202475] = { [TIER_LFR] = 186065, [TIER_NORMAL] = 184449, [TIER_HEROIC] = 186063, [TIER_MYTHIC] = 186064 },
    [202476] = { [TIER_LFR] = 186068, [TIER_NORMAL] = 184450, [TIER_HEROIC] = 186066, [TIER_MYTHIC] = 186067 },
    [202477] = { [TIER_LFR] = 186069, [TIER_NORMAL] = 184451, [TIER_HEROIC] = 186070, [TIER_MYTHIC] = 186071 },
    [202478] = { [TIER_LFR] = 186080, [TIER_NORMAL] = 184452, [TIER_HEROIC] = 186078, [TIER_MYTHIC] = 186079 },
    [202479] = { [TIER_LFR] = 186081, [TIER_NORMAL] = 184453, [TIER_HEROIC] = 186082, [TIER_MYTHIC] = 186083 },
    [202480] = { [TIER_LFR] = 186092, [TIER_NORMAL] = 184454, [TIER_HEROIC] = 186090, [TIER_MYTHIC] = 186091 },
    [202481] = { [TIER_LFR] = 186095, [TIER_NORMAL] = 184455, [TIER_HEROIC] = 186093, [TIER_MYTHIC] = 186094 },
    [202482] = { [TIER_LFR] = 186098, [TIER_NORMAL] = 184456, [TIER_HEROIC] = 186096, [TIER_MYTHIC] = 186097 },
    [202483] = { [TIER_LFR] = 186408, [TIER_NORMAL] = 184457, [TIER_HEROIC] = 186406, [TIER_MYTHIC] = 186407 },
    [202484] = { [TIER_LFR] = 186366, [TIER_NORMAL] = 184458, [TIER_HEROIC] = 186364, [TIER_MYTHIC] = 186365 },
    [202485] = { [TIER_LFR] = 186367, [TIER_NORMAL] = 184459, [TIER_HEROIC] = 186368, [TIER_MYTHIC] = 186369 },
    [202486] = { [TIER_LFR] = 186376, [TIER_NORMAL] = 184460, [TIER_HEROIC] = 186377, [TIER_MYTHIC] = 186378 },
    [202487] = { [TIER_LFR] = 186387, [TIER_NORMAL] = 184461, [TIER_HEROIC] = 186385, [TIER_MYTHIC] = 186386 },
    [202488] = { [TIER_LFR] = 186388, [TIER_NORMAL] = 184462, [TIER_HEROIC] = 186389, [TIER_MYTHIC] = 186390 },
    [202489] = { [TIER_LFR] = 186399, [TIER_NORMAL] = 184463, [TIER_HEROIC] = 186397, [TIER_MYTHIC] = 186398 },
    [202490] = { [TIER_LFR] = 186402, [TIER_NORMAL] = 184464, [TIER_HEROIC] = 186400, [TIER_MYTHIC] = 186401 },
    [202491] = { [TIER_LFR] = 186405, [TIER_NORMAL] = 184465, [TIER_HEROIC] = 186403, [TIER_MYTHIC] = 186404 },
    [202492] = { [TIER_LFR] = 186134, [TIER_NORMAL] = 184466, [TIER_HEROIC] = 186132, [TIER_MYTHIC] = 186133 },
    [202493] = { [TIER_LFR] = 186104, [TIER_NORMAL] = 184467, [TIER_HEROIC] = 186102, [TIER_MYTHIC] = 186103 },
    [202494] = { [TIER_LFR] = 186107, [TIER_NORMAL] = 184468, [TIER_HEROIC] = 186105, [TIER_MYTHIC] = 186106 },
    [202495] = { [TIER_LFR] = 186108, [TIER_NORMAL] = 184469, [TIER_HEROIC] = 186109, [TIER_MYTHIC] = 186110 },
    [202496] = { [TIER_LFR] = 186119, [TIER_NORMAL] = 184470, [TIER_HEROIC] = 186117, [TIER_MYTHIC] = 186118 },
    [202497] = { [TIER_LFR] = 186122, [TIER_NORMAL] = 184471, [TIER_HEROIC] = 186120, [TIER_MYTHIC] = 186121 },
    [202498] = { [TIER_LFR] = 186125, [TIER_NORMAL] = 184472, [TIER_HEROIC] = 186123, [TIER_MYTHIC] = 186124 },
    [202499] = { [TIER_LFR] = 186128, [TIER_NORMAL] = 184473, [TIER_HEROIC] = 186126, [TIER_MYTHIC] = 186127 },
    [202500] = { [TIER_LFR] = 186131, [TIER_NORMAL] = 184474, [TIER_HEROIC] = 186129, [TIER_MYTHIC] = 186130 },
    [202501] = { [TIER_LFR] = 186017, [TIER_NORMAL] = 184475, [TIER_HEROIC] = 186015, [TIER_MYTHIC] = 186016 },
    [202502] = { [TIER_LFR] = 185765, [TIER_NORMAL] = 184476, [TIER_HEROIC] = 185766, [TIER_MYTHIC] = 185767 },
    [202503] = { [TIER_LFR] = 185768, [TIER_NORMAL] = 184477, [TIER_HEROIC] = 185769, [TIER_MYTHIC] = 185770 },
    [202504] = { [TIER_LFR] = 185771, [TIER_NORMAL] = 184478, [TIER_HEROIC] = 185772, [TIER_MYTHIC] = 185773 },
    [202505] = { [TIER_LFR] = 185774, [TIER_NORMAL] = 184479, [TIER_HEROIC] = 185775, [TIER_MYTHIC] = 185776 },
    [202506] = { [TIER_LFR] = 185777, [TIER_NORMAL] = 184480, [TIER_HEROIC] = 185778, [TIER_MYTHIC] = 185779 },
    [202507] = { [TIER_LFR] = 185780, [TIER_NORMAL] = 184481, [TIER_HEROIC] = 185781, [TIER_MYTHIC] = 185782 },
    [202508] = { [TIER_LFR] = 185783, [TIER_NORMAL] = 184482, [TIER_HEROIC] = 185784, [TIER_MYTHIC] = 185785 },
    [202509] = { [TIER_LFR] = 185786, [TIER_NORMAL] = 184483, [TIER_HEROIC] = 185787, [TIER_MYTHIC] = 185788 },
    [202510] = { [TIER_LFR] = 186179, [TIER_NORMAL] = 184484, [TIER_HEROIC] = 186177, [TIER_MYTHIC] = 186178 },
    [202511] = { [TIER_LFR] = 186137, [TIER_NORMAL] = 184485, [TIER_HEROIC] = 186135, [TIER_MYTHIC] = 186136 },
    [202512] = { [TIER_LFR] = 186138, [TIER_NORMAL] = 184486, [TIER_HEROIC] = 186139, [TIER_MYTHIC] = 186140 },
    [202513] = { [TIER_LFR] = 186147, [TIER_NORMAL] = 184487, [TIER_HEROIC] = 186148, [TIER_MYTHIC] = 186149 },
    [202514] = { [TIER_LFR] = 186158, [TIER_NORMAL] = 184488, [TIER_HEROIC] = 186156, [TIER_MYTHIC] = 186157 },
    [202515] = { [TIER_LFR] = 186159, [TIER_NORMAL] = 184489, [TIER_HEROIC] = 186160, [TIER_MYTHIC] = 186161 },
    [202516] = { [TIER_LFR] = 186170, [TIER_NORMAL] = 184490, [TIER_HEROIC] = 186168, [TIER_MYTHIC] = 186169 },
    [202517] = { [TIER_LFR] = 186173, [TIER_NORMAL] = 184491, [TIER_HEROIC] = 186171, [TIER_MYTHIC] = 186172 },
    [202518] = { [TIER_LFR] = 186176, [TIER_NORMAL] = 184492, [TIER_HEROIC] = 186174, [TIER_MYTHIC] = 186175 },
    [202519] = { [TIER_LFR] = 186447, [TIER_NORMAL] = 184493, [TIER_HEROIC] = 186445, [TIER_MYTHIC] = 186446 },
    [202520] = { [TIER_LFR] = 186411, [TIER_NORMAL] = 184494, [TIER_HEROIC] = 186409, [TIER_MYTHIC] = 186410 },
    [202521] = { [TIER_LFR] = 186414, [TIER_NORMAL] = 184495, [TIER_HEROIC] = 186412, [TIER_MYTHIC] = 186413 },
    [202522] = { [TIER_LFR] = 186415, [TIER_NORMAL] = 184496, [TIER_HEROIC] = 186416, [TIER_MYTHIC] = 186417 },
    [202523] = { [TIER_LFR] = 186426, [TIER_NORMAL] = 184497, [TIER_HEROIC] = 186424, [TIER_MYTHIC] = 186425 },
    [202524] = { [TIER_LFR] = 186427, [TIER_NORMAL] = 184498, [TIER_HEROIC] = 186428, [TIER_MYTHIC] = 186429 },
    [202525] = { [TIER_LFR] = 186438, [TIER_NORMAL] = 184499, [TIER_HEROIC] = 186436, [TIER_MYTHIC] = 186437 },
    [202526] = { [TIER_LFR] = 186441, [TIER_NORMAL] = 184500, [TIER_HEROIC] = 186439, [TIER_MYTHIC] = 186440 },
    [202527] = { [TIER_LFR] = 186444, [TIER_NORMAL] = 184501, [TIER_HEROIC] = 186442, [TIER_MYTHIC] = 186443 },
    [202528] = { [TIER_LFR] = 186182, [TIER_NORMAL] = 184502, [TIER_HEROIC] = 186180, [TIER_MYTHIC] = 186181 },
    [202529] = { [TIER_LFR] = 186185, [TIER_NORMAL] = 184503, [TIER_HEROIC] = 186183, [TIER_MYTHIC] = 186184 },
    [202530] = { [TIER_LFR] = 186188, [TIER_NORMAL] = 184504, [TIER_HEROIC] = 186186, [TIER_MYTHIC] = 186187 },
    [202531] = { [TIER_LFR] = 186189, [TIER_NORMAL] = 184505, [TIER_HEROIC] = 186190, [TIER_MYTHIC] = 186191 },
    [202532] = { [TIER_LFR] = 186203, [TIER_NORMAL] = 184506, [TIER_HEROIC] = 186201, [TIER_MYTHIC] = 186202 },
    [202533] = { [TIER_LFR] = 186204, [TIER_NORMAL] = 184507, [TIER_HEROIC] = 186205, [TIER_MYTHIC] = 186206 },
    [202534] = { [TIER_LFR] = 186215, [TIER_NORMAL] = 184508, [TIER_HEROIC] = 186213, [TIER_MYTHIC] = 186214 },
    [202535] = { [TIER_LFR] = 186218, [TIER_NORMAL] = 184509, [TIER_HEROIC] = 186216, [TIER_MYTHIC] = 186217 },
    [202536] = { [TIER_LFR] = 186200, [TIER_NORMAL] = 184510, [TIER_HEROIC] = 186198, [TIER_MYTHIC] = 186199 },
    [202537] = { [TIER_LFR] = 186221, [TIER_NORMAL] = 184511, [TIER_HEROIC] = 186219, [TIER_MYTHIC] = 186220 },
    [202538] = { [TIER_LFR] = 186224, [TIER_NORMAL] = 184512, [TIER_HEROIC] = 186222, [TIER_MYTHIC] = 186223 },
    [202539] = { [TIER_LFR] = 186227, [TIER_NORMAL] = 184513, [TIER_HEROIC] = 186225, [TIER_MYTHIC] = 186226 },
    [202540] = { [TIER_LFR] = 186228, [TIER_NORMAL] = 184514, [TIER_HEROIC] = 186229, [TIER_MYTHIC] = 186230 },
    [202541] = { [TIER_LFR] = 186243, [TIER_NORMAL] = 184515, [TIER_HEROIC] = 186241, [TIER_MYTHIC] = 186242 },
    [202542] = { [TIER_LFR] = 186244, [TIER_NORMAL] = 184516, [TIER_HEROIC] = 186245, [TIER_MYTHIC] = 186246 },
    [202543] = { [TIER_LFR] = 186255, [TIER_NORMAL] = 184517, [TIER_HEROIC] = 186253, [TIER_MYTHIC] = 186254 },
    [202544] = { [TIER_LFR] = 186258, [TIER_NORMAL] = 184518, [TIER_HEROIC] = 186256, [TIER_MYTHIC] = 186257 },
    [202545] = { [TIER_LFR] = 186233, [TIER_NORMAL] = 184519, [TIER_HEROIC] = 186231, [TIER_MYTHIC] = 186232 },
    [202546] = { [TIER_LFR] = 187865, [TIER_NORMAL] = 184520, [TIER_HEROIC] = 187863, [TIER_MYTHIC] = 187864 },
    [202547] = { [TIER_LFR] = 186330, [TIER_NORMAL] = 184521, [TIER_HEROIC] = 186328, [TIER_MYTHIC] = 186329 },
    [202548] = { [TIER_LFR] = 186331, [TIER_NORMAL] = 184522, [TIER_HEROIC] = 186332, [TIER_MYTHIC] = 186333 },
    [202549] = { [TIER_LFR] = 186340, [TIER_NORMAL] = 184523, [TIER_HEROIC] = 186341, [TIER_MYTHIC] = 186342 },
    [202550] = { [TIER_LFR] = 186351, [TIER_NORMAL] = 184524, [TIER_HEROIC] = 186349, [TIER_MYTHIC] = 186350 },
    [202551] = { [TIER_LFR] = 186354, [TIER_NORMAL] = 184525, [TIER_HEROIC] = 186352, [TIER_MYTHIC] = 186353 },
    [202552] = { [TIER_LFR] = 186357, [TIER_NORMAL] = 184526, [TIER_HEROIC] = 186355, [TIER_MYTHIC] = 186356 },
    [202553] = { [TIER_LFR] = 186360, [TIER_NORMAL] = 184527, [TIER_HEROIC] = 186358, [TIER_MYTHIC] = 186359 },
    [202554] = { [TIER_LFR] = 186363, [TIER_NORMAL] = 184528, [TIER_HEROIC] = 186361, [TIER_MYTHIC] = 186362 },
    [207176] = { [TIER_LFR] = 193078, [TIER_NORMAL] = 188716, [TIER_HEROIC] = 193079, [TIER_MYTHIC] = 193080 },
    [207177] = { [TIER_LFR] = 193085, [TIER_NORMAL] = 188717, [TIER_HEROIC] = 193086, [TIER_MYTHIC] = 193087 },
    [207179] = { [TIER_LFR] = 193096, [TIER_NORMAL] = 188718, [TIER_HEROIC] = 193097, [TIER_MYTHIC] = 193098 },
    [207180] = { [TIER_LFR] = 193107, [TIER_NORMAL] = 188719, [TIER_HEROIC] = 193108, [TIER_MYTHIC] = 193109 },
    [207181] = { [TIER_LFR] = 193118, [TIER_NORMAL] = 188720, [TIER_HEROIC] = 193119, [TIER_MYTHIC] = 193120 },
    [207182] = { [TIER_LFR] = 193129, [TIER_NORMAL] = 188721, [TIER_HEROIC] = 193130, [TIER_MYTHIC] = 193131 },
    [207183] = { [TIER_LFR] = 193140, [TIER_NORMAL] = 188722, [TIER_HEROIC] = 193141, [TIER_MYTHIC] = 193142 },
    [207184] = { [TIER_LFR] = 193151, [TIER_NORMAL] = 188723, [TIER_HEROIC] = 193152, [TIER_MYTHIC] = 193153 },
    [207185] = { [TIER_LFR] = 193162, [TIER_NORMAL] = 188724, [TIER_HEROIC] = 193163, [TIER_MYTHIC] = 193164 },
    [207186] = { [TIER_LFR] = 189283, [TIER_NORMAL] = 188725, [TIER_HEROIC] = 189284, [TIER_MYTHIC] = 189285 },
    [207187] = { [TIER_LFR] = 189294, [TIER_NORMAL] = 188726, [TIER_HEROIC] = 189295, [TIER_MYTHIC] = 189296 },
    [207188] = { [TIER_LFR] = 189305, [TIER_NORMAL] = 188727, [TIER_HEROIC] = 189306, [TIER_MYTHIC] = 189307 },
    [207189] = { [TIER_LFR] = 189316, [TIER_NORMAL] = 188728, [TIER_HEROIC] = 189317, [TIER_MYTHIC] = 189318 },
    [207190] = { [TIER_LFR] = 189327, [TIER_NORMAL] = 188729, [TIER_HEROIC] = 189328, [TIER_MYTHIC] = 189329 },
    [207191] = { [TIER_LFR] = 189338, [TIER_NORMAL] = 188730, [TIER_HEROIC] = 189339, [TIER_MYTHIC] = 189340 },
    [207192] = { [TIER_LFR] = 189349, [TIER_NORMAL] = 188731, [TIER_HEROIC] = 189350, [TIER_MYTHIC] = 189351 },
    [207193] = { [TIER_LFR] = 189360, [TIER_NORMAL] = 188732, [TIER_HEROIC] = 189361, [TIER_MYTHIC] = 189362 },
    [207194] = { [TIER_LFR] = 189371, [TIER_NORMAL] = 188733, [TIER_HEROIC] = 189372, [TIER_MYTHIC] = 189373 },
    [207195] = { [TIER_LFR] = 192220, [TIER_NORMAL] = 188734, [TIER_HEROIC] = 192221, [TIER_MYTHIC] = 192222 },
    [207196] = { [TIER_LFR] = 192231, [TIER_NORMAL] = 188735, [TIER_HEROIC] = 192232, [TIER_MYTHIC] = 192233 },
    [207197] = { [TIER_LFR] = 192242, [TIER_NORMAL] = 188736, [TIER_HEROIC] = 192243, [TIER_MYTHIC] = 192244 },
    [207198] = { [TIER_LFR] = 192253, [TIER_NORMAL] = 188737, [TIER_HEROIC] = 192254, [TIER_MYTHIC] = 192255 },
    [207199] = { [TIER_LFR] = 192264, [TIER_NORMAL] = 188738, [TIER_HEROIC] = 192265, [TIER_MYTHIC] = 192266 },
    [207200] = { [TIER_LFR] = 192275, [TIER_NORMAL] = 188739, [TIER_HEROIC] = 192276, [TIER_MYTHIC] = 192277 },
    [207201] = { [TIER_LFR] = 192286, [TIER_NORMAL] = 188740, [TIER_HEROIC] = 192287, [TIER_MYTHIC] = 192288 },
    [207202] = { [TIER_LFR] = 192297, [TIER_NORMAL] = 188741, [TIER_HEROIC] = 192298, [TIER_MYTHIC] = 192299 },
    [207203] = { [TIER_LFR] = 192308, [TIER_NORMAL] = 188742, [TIER_HEROIC] = 192309, [TIER_MYTHIC] = 192310 },
    [207204] = { [TIER_LFR] = 189382, [TIER_NORMAL] = 188743, [TIER_HEROIC] = 189383, [TIER_MYTHIC] = 189384 },
    [207205] = { [TIER_LFR] = 189393, [TIER_NORMAL] = 188744, [TIER_HEROIC] = 189394, [TIER_MYTHIC] = 189395 },
    [207206] = { [TIER_LFR] = 189404, [TIER_NORMAL] = 188745, [TIER_HEROIC] = 189405, [TIER_MYTHIC] = 189406 },
    [207207] = { [TIER_LFR] = 189415, [TIER_NORMAL] = 188746, [TIER_HEROIC] = 189416, [TIER_MYTHIC] = 189417 },
    [207208] = { [TIER_LFR] = 189426, [TIER_NORMAL] = 188747, [TIER_HEROIC] = 189427, [TIER_MYTHIC] = 189428 },
    [207209] = { [TIER_LFR] = 189437, [TIER_NORMAL] = 188748, [TIER_HEROIC] = 189438, [TIER_MYTHIC] = 189439 },
    [207210] = { [TIER_LFR] = 189448, [TIER_NORMAL] = 188749, [TIER_HEROIC] = 189449, [TIER_MYTHIC] = 189450 },
    [207211] = { [TIER_LFR] = 189459, [TIER_NORMAL] = 188750, [TIER_HEROIC] = 189460, [TIER_MYTHIC] = 189461 },
    [207212] = { [TIER_LFR] = 189470, [TIER_NORMAL] = 188751, [TIER_HEROIC] = 189471, [TIER_MYTHIC] = 189472 },
    [207213] = { [TIER_LFR] = 193337, [TIER_NORMAL] = 188752, [TIER_HEROIC] = 193338, [TIER_MYTHIC] = 193339 },
    [207214] = { [TIER_LFR] = 193344, [TIER_NORMAL] = 188753, [TIER_HEROIC] = 193345, [TIER_MYTHIC] = 193346 },
    [207215] = { [TIER_LFR] = 193351, [TIER_NORMAL] = 188754, [TIER_HEROIC] = 193352, [TIER_MYTHIC] = 193353 },
    [207216] = { [TIER_LFR] = 193358, [TIER_NORMAL] = 188755, [TIER_HEROIC] = 193359, [TIER_MYTHIC] = 193360 },
    [207217] = { [TIER_LFR] = 193365, [TIER_NORMAL] = 188756, [TIER_HEROIC] = 193366, [TIER_MYTHIC] = 193367 },
    [207218] = { [TIER_LFR] = 193372, [TIER_NORMAL] = 188757, [TIER_HEROIC] = 193373, [TIER_MYTHIC] = 193374 },
    [207219] = { [TIER_LFR] = 193379, [TIER_NORMAL] = 188758, [TIER_HEROIC] = 193380, [TIER_MYTHIC] = 193381 },
    [207220] = { [TIER_LFR] = 193386, [TIER_NORMAL] = 188759, [TIER_HEROIC] = 193387, [TIER_MYTHIC] = 193388 },
    [207221] = { [TIER_LFR] = 193393, [TIER_NORMAL] = 188760, [TIER_HEROIC] = 193394, [TIER_MYTHIC] = 193395 },
    [207222] = { [TIER_LFR] = 191966, [TIER_NORMAL] = 188761, [TIER_HEROIC] = 191967, [TIER_MYTHIC] = 191968 },
    [207223] = { [TIER_LFR] = 191977, [TIER_NORMAL] = 188762, [TIER_HEROIC] = 191978, [TIER_MYTHIC] = 191979 },
    [207224] = { [TIER_LFR] = 191988, [TIER_NORMAL] = 188763, [TIER_HEROIC] = 191989, [TIER_MYTHIC] = 191990 },
    [207225] = { [TIER_LFR] = 191999, [TIER_NORMAL] = 188764, [TIER_HEROIC] = 192000, [TIER_MYTHIC] = 192001 },
    [207226] = { [TIER_LFR] = 192010, [TIER_NORMAL] = 188765, [TIER_HEROIC] = 192011, [TIER_MYTHIC] = 192012 },
    [207227] = { [TIER_LFR] = 192021, [TIER_NORMAL] = 188766, [TIER_HEROIC] = 192022, [TIER_MYTHIC] = 192023 },
    [207228] = { [TIER_LFR] = 192032, [TIER_NORMAL] = 188767, [TIER_HEROIC] = 192033, [TIER_MYTHIC] = 192034 },
    [207229] = { [TIER_LFR] = 192043, [TIER_NORMAL] = 188768, [TIER_HEROIC] = 192044, [TIER_MYTHIC] = 192045 },
    [207230] = { [TIER_LFR] = 192054, [TIER_NORMAL] = 188769, [TIER_HEROIC] = 192055, [TIER_MYTHIC] = 192056 },
    [207231] = { [TIER_LFR] = 191211, [TIER_NORMAL] = 188770, [TIER_HEROIC] = 191212, [TIER_MYTHIC] = 191213 },
    [207232] = { [TIER_LFR] = 191216, [TIER_NORMAL] = 188771, [TIER_HEROIC] = 191217, [TIER_MYTHIC] = 191218 },
    [207233] = { [TIER_LFR] = 191221, [TIER_NORMAL] = 188772, [TIER_HEROIC] = 191222, [TIER_MYTHIC] = 191223 },
    [207234] = { [TIER_LFR] = 191226, [TIER_NORMAL] = 188773, [TIER_HEROIC] = 191227, [TIER_MYTHIC] = 191228 },
    [207235] = { [TIER_LFR] = 191231, [TIER_NORMAL] = 188774, [TIER_HEROIC] = 191232, [TIER_MYTHIC] = 191233 },
    [207236] = { [TIER_LFR] = 191236, [TIER_NORMAL] = 188775, [TIER_HEROIC] = 191237, [TIER_MYTHIC] = 191238 },
    [207237] = { [TIER_LFR] = 191241, [TIER_NORMAL] = 188776, [TIER_HEROIC] = 191242, [TIER_MYTHIC] = 191243 },
    [207238] = { [TIER_LFR] = 191246, [TIER_NORMAL] = 188777, [TIER_HEROIC] = 191247, [TIER_MYTHIC] = 191248 },
    [207239] = { [TIER_LFR] = 191251, [TIER_NORMAL] = 188778, [TIER_HEROIC] = 191252, [TIER_MYTHIC] = 191253 },
    [207240] = { [TIER_LFR] = 189481, [TIER_NORMAL] = 188779, [TIER_HEROIC] = 189482, [TIER_MYTHIC] = 189483 },
    [207241] = { [TIER_LFR] = 189492, [TIER_NORMAL] = 188780, [TIER_HEROIC] = 189493, [TIER_MYTHIC] = 189494 },
    [207242] = { [TIER_LFR] = 189503, [TIER_NORMAL] = 188781, [TIER_HEROIC] = 189504, [TIER_MYTHIC] = 189505 },
    [207243] = { [TIER_LFR] = 189514, [TIER_NORMAL] = 188782, [TIER_HEROIC] = 189515, [TIER_MYTHIC] = 189516 },
    [207244] = { [TIER_LFR] = 189525, [TIER_NORMAL] = 188783, [TIER_HEROIC] = 189526, [TIER_MYTHIC] = 189527 },
    [207245] = { [TIER_LFR] = 189536, [TIER_NORMAL] = 188784, [TIER_HEROIC] = 189537, [TIER_MYTHIC] = 189538 },
    [207246] = { [TIER_LFR] = 189547, [TIER_NORMAL] = 188785, [TIER_HEROIC] = 189548, [TIER_MYTHIC] = 189549 },
    [207247] = { [TIER_LFR] = 189558, [TIER_NORMAL] = 188786, [TIER_HEROIC] = 189559, [TIER_MYTHIC] = 189560 },
    [207248] = { [TIER_LFR] = 189569, [TIER_NORMAL] = 188787, [TIER_HEROIC] = 189570, [TIER_MYTHIC] = 189571 },
    [207249] = { [TIER_LFR] = 192451, [TIER_NORMAL] = 188788, [TIER_HEROIC] = 192452, [TIER_MYTHIC] = 192453 },
    [207250] = { [TIER_LFR] = 192462, [TIER_NORMAL] = 188789, [TIER_HEROIC] = 192463, [TIER_MYTHIC] = 192464 },
    [207251] = { [TIER_LFR] = 192473, [TIER_NORMAL] = 188790, [TIER_HEROIC] = 192474, [TIER_MYTHIC] = 192475 },
    [207252] = { [TIER_LFR] = 192484, [TIER_NORMAL] = 188791, [TIER_HEROIC] = 192485, [TIER_MYTHIC] = 192486 },
    [207253] = { [TIER_LFR] = 192495, [TIER_NORMAL] = 188792, [TIER_HEROIC] = 192496, [TIER_MYTHIC] = 192497 },
    [207254] = { [TIER_LFR] = 192506, [TIER_NORMAL] = 188793, [TIER_HEROIC] = 192507, [TIER_MYTHIC] = 192508 },
    [207255] = { [TIER_LFR] = 192517, [TIER_NORMAL] = 188794, [TIER_HEROIC] = 192518, [TIER_MYTHIC] = 192519 },
    [207256] = { [TIER_LFR] = 192528, [TIER_NORMAL] = 188795, [TIER_HEROIC] = 192529, [TIER_MYTHIC] = 192530 },
    [207257] = { [TIER_LFR] = 192539, [TIER_NORMAL] = 188796, [TIER_HEROIC] = 192540, [TIER_MYTHIC] = 192541 },
    [207258] = { [TIER_LFR] = 192319, [TIER_NORMAL] = 188797, [TIER_HEROIC] = 192320, [TIER_MYTHIC] = 192321 },
    [207259] = { [TIER_LFR] = 192330, [TIER_NORMAL] = 188798, [TIER_HEROIC] = 192331, [TIER_MYTHIC] = 192332 },
    [207260] = { [TIER_LFR] = 192341, [TIER_NORMAL] = 188799, [TIER_HEROIC] = 192342, [TIER_MYTHIC] = 192343 },
    [207261] = { [TIER_LFR] = 192352, [TIER_NORMAL] = 188800, [TIER_HEROIC] = 192353, [TIER_MYTHIC] = 192354 },
    [207262] = { [TIER_LFR] = 192363, [TIER_NORMAL] = 188801, [TIER_HEROIC] = 192364, [TIER_MYTHIC] = 192365 },
    [207263] = { [TIER_LFR] = 192374, [TIER_NORMAL] = 188802, [TIER_HEROIC] = 192375, [TIER_MYTHIC] = 192376 },
    [207264] = { [TIER_LFR] = 192385, [TIER_NORMAL] = 188803, [TIER_HEROIC] = 192386, [TIER_MYTHIC] = 192387 },
    [207265] = { [TIER_LFR] = 192396, [TIER_NORMAL] = 188804, [TIER_HEROIC] = 192397, [TIER_MYTHIC] = 192398 },
    [207266] = { [TIER_LFR] = 192407, [TIER_NORMAL] = 188805, [TIER_HEROIC] = 192408, [TIER_MYTHIC] = 192409 },
    [207267] = { [TIER_LFR] = 189184, [TIER_NORMAL] = 188806, [TIER_HEROIC] = 189185, [TIER_MYTHIC] = 189186 },
    [207268] = { [TIER_LFR] = 189195, [TIER_NORMAL] = 188807, [TIER_HEROIC] = 189196, [TIER_MYTHIC] = 189197 },
    [207269] = { [TIER_LFR] = 189206, [TIER_NORMAL] = 188808, [TIER_HEROIC] = 189207, [TIER_MYTHIC] = 189208 },
    [207270] = { [TIER_LFR] = 189217, [TIER_NORMAL] = 188809, [TIER_HEROIC] = 189218, [TIER_MYTHIC] = 189219 },
    [207271] = { [TIER_LFR] = 189228, [TIER_NORMAL] = 188810, [TIER_HEROIC] = 189229, [TIER_MYTHIC] = 189230 },
    [207272] = { [TIER_LFR] = 189239, [TIER_NORMAL] = 188811, [TIER_HEROIC] = 189240, [TIER_MYTHIC] = 189241 },
    [207273] = { [TIER_LFR] = 189250, [TIER_NORMAL] = 188812, [TIER_HEROIC] = 189251, [TIER_MYTHIC] = 189252 },
    [207274] = { [TIER_LFR] = 189261, [TIER_NORMAL] = 188813, [TIER_HEROIC] = 189262, [TIER_MYTHIC] = 189263 },
    [207275] = { [TIER_LFR] = 189272, [TIER_NORMAL] = 188814, [TIER_HEROIC] = 189273, [TIER_MYTHIC] = 189274 },
    [207276] = { [TIER_LFR] = 189986, [TIER_NORMAL] = 188815, [TIER_HEROIC] = 189987, [TIER_MYTHIC] = 189988 },
    [207277] = { [TIER_LFR] = 189997, [TIER_NORMAL] = 188816, [TIER_HEROIC] = 189998, [TIER_MYTHIC] = 189999 },
    [207278] = { [TIER_LFR] = 190008, [TIER_NORMAL] = 188817, [TIER_HEROIC] = 190009, [TIER_MYTHIC] = 190010 },
    [207279] = { [TIER_LFR] = 190019, [TIER_NORMAL] = 188818, [TIER_HEROIC] = 190020, [TIER_MYTHIC] = 190021 },
    [207280] = { [TIER_LFR] = 190030, [TIER_NORMAL] = 188819, [TIER_HEROIC] = 190031, [TIER_MYTHIC] = 190032 },
    [207281] = { [TIER_LFR] = 190041, [TIER_NORMAL] = 188820, [TIER_HEROIC] = 190042, [TIER_MYTHIC] = 190043 },
    [207282] = { [TIER_LFR] = 190052, [TIER_NORMAL] = 188821, [TIER_HEROIC] = 190053, [TIER_MYTHIC] = 190054 },
    [207283] = { [TIER_LFR] = 190063, [TIER_NORMAL] = 188822, [TIER_HEROIC] = 190064, [TIER_MYTHIC] = 190065 },
    [207284] = { [TIER_LFR] = 190074, [TIER_NORMAL] = 188823, [TIER_HEROIC] = 190075, [TIER_MYTHIC] = 190076 },
    [207285] = { [TIER_LFR] = 189173, [TIER_NORMAL] = 188824, [TIER_HEROIC] = 189174, [TIER_MYTHIC] = 189183 },
    [207286] = { [TIER_LFR] = 189085, [TIER_NORMAL] = 188825, [TIER_HEROIC] = 189086, [TIER_MYTHIC] = 189087 },
    [207287] = { [TIER_LFR] = 189096, [TIER_NORMAL] = 188826, [TIER_HEROIC] = 189097, [TIER_MYTHIC] = 189098 },
    [207288] = { [TIER_LFR] = 189107, [TIER_NORMAL] = 188827, [TIER_HEROIC] = 189108, [TIER_MYTHIC] = 189109 },
    [207289] = { [TIER_LFR] = 189118, [TIER_NORMAL] = 188828, [TIER_HEROIC] = 189119, [TIER_MYTHIC] = 189120 },
    [207290] = { [TIER_LFR] = 189129, [TIER_NORMAL] = 188829, [TIER_HEROIC] = 189130, [TIER_MYTHIC] = 189131 },
    [207291] = { [TIER_LFR] = 189140, [TIER_NORMAL] = 188830, [TIER_HEROIC] = 189141, [TIER_MYTHIC] = 189142 },
    [207292] = { [TIER_LFR] = 189151, [TIER_NORMAL] = 188831, [TIER_HEROIC] = 189152, [TIER_MYTHIC] = 189153 },
    [207293] = { [TIER_LFR] = 189162, [TIER_NORMAL] = 188832, [TIER_HEROIC] = 189163, [TIER_MYTHIC] = 189164 },
    [211979] = { [TIER_LFR] = 222701, [TIER_NORMAL] = 194489, [TIER_HEROIC] = 222702, [TIER_MYTHIC] = 222703 },
    [211980] = { [TIER_LFR] = 222708, [TIER_NORMAL] = 194490, [TIER_HEROIC] = 222709, [TIER_MYTHIC] = 222710 },
    [211981] = { [TIER_LFR] = 222715, [TIER_NORMAL] = 194491, [TIER_HEROIC] = 222716, [TIER_MYTHIC] = 222717 },
    [211982] = { [TIER_LFR] = 222722, [TIER_NORMAL] = 194492, [TIER_HEROIC] = 222723, [TIER_MYTHIC] = 222724 },
    [211983] = { [TIER_LFR] = 222729, [TIER_NORMAL] = 194493, [TIER_HEROIC] = 222730, [TIER_MYTHIC] = 222731 },
    [211984] = { [TIER_LFR] = 222736, [TIER_NORMAL] = 194494, [TIER_HEROIC] = 222737, [TIER_MYTHIC] = 222738 },
    [211985] = { [TIER_LFR] = 222743, [TIER_NORMAL] = 194495, [TIER_HEROIC] = 222744, [TIER_MYTHIC] = 222745 },
    [211986] = { [TIER_LFR] = 222750, [TIER_NORMAL] = 194496, [TIER_HEROIC] = 222751, [TIER_MYTHIC] = 222752 },
    [211987] = { [TIER_LFR] = 222757, [TIER_NORMAL] = 194497, [TIER_HEROIC] = 222758, [TIER_MYTHIC] = 222759 },
    [211988] = { [TIER_LFR] = 222622, [TIER_NORMAL] = 194498, [TIER_HEROIC] = 222623, [TIER_MYTHIC] = 222624 },
    [211989] = { [TIER_LFR] = 222629, [TIER_NORMAL] = 194499, [TIER_HEROIC] = 222630, [TIER_MYTHIC] = 222631 },
    [211990] = { [TIER_LFR] = 222636, [TIER_NORMAL] = 194500, [TIER_HEROIC] = 222637, [TIER_MYTHIC] = 222638 },
    [211991] = { [TIER_LFR] = 222643, [TIER_NORMAL] = 194501, [TIER_HEROIC] = 222644, [TIER_MYTHIC] = 222645 },
    [211992] = { [TIER_LFR] = 222650, [TIER_NORMAL] = 194502, [TIER_HEROIC] = 222651, [TIER_MYTHIC] = 222652 },
    [211993] = { [TIER_LFR] = 222657, [TIER_NORMAL] = 194503, [TIER_HEROIC] = 222658, [TIER_MYTHIC] = 222659 },
    [211994] = { [TIER_LFR] = 222664, [TIER_NORMAL] = 194504, [TIER_HEROIC] = 222665, [TIER_MYTHIC] = 222666 },
    [211995] = { [TIER_LFR] = 222671, [TIER_NORMAL] = 194505, [TIER_HEROIC] = 222672, [TIER_MYTHIC] = 222673 },
    [211996] = { [TIER_LFR] = 222678, [TIER_NORMAL] = 194506, [TIER_HEROIC] = 222679, [TIER_MYTHIC] = 222680 },
    [211997] = { [TIER_LFR] = 222535, [TIER_NORMAL] = 194507, [TIER_HEROIC] = 222536, [TIER_MYTHIC] = 222537 },
    [211998] = { [TIER_LFR] = 222542, [TIER_NORMAL] = 194508, [TIER_HEROIC] = 222543, [TIER_MYTHIC] = 222544 },
    [211999] = { [TIER_LFR] = 222549, [TIER_NORMAL] = 194509, [TIER_HEROIC] = 222550, [TIER_MYTHIC] = 222551 },
    [212000] = { [TIER_LFR] = 222556, [TIER_NORMAL] = 194510, [TIER_HEROIC] = 222557, [TIER_MYTHIC] = 222558 },
    [212001] = { [TIER_LFR] = 222563, [TIER_NORMAL] = 194511, [TIER_HEROIC] = 222564, [TIER_MYTHIC] = 222565 },
    [212002] = { [TIER_LFR] = 222570, [TIER_NORMAL] = 194512, [TIER_HEROIC] = 222571, [TIER_MYTHIC] = 222572 },
    [212003] = { [TIER_LFR] = 222577, [TIER_NORMAL] = 194513, [TIER_HEROIC] = 222578, [TIER_MYTHIC] = 222579 },
    [212004] = { [TIER_LFR] = 222584, [TIER_NORMAL] = 194514, [TIER_HEROIC] = 222585, [TIER_MYTHIC] = 222586 },
    [212005] = { [TIER_LFR] = 222591, [TIER_NORMAL] = 194515, [TIER_HEROIC] = 222592, [TIER_MYTHIC] = 222593 },
    [212006] = { [TIER_LFR] = 222456, [TIER_NORMAL] = 194516, [TIER_HEROIC] = 222457, [TIER_MYTHIC] = 222458 },
    [212007] = { [TIER_LFR] = 222463, [TIER_NORMAL] = 194517, [TIER_HEROIC] = 222464, [TIER_MYTHIC] = 222465 },
    [212008] = { [TIER_LFR] = 222470, [TIER_NORMAL] = 194518, [TIER_HEROIC] = 222471, [TIER_MYTHIC] = 222472 },
    [212009] = { [TIER_LFR] = 222477, [TIER_NORMAL] = 194519, [TIER_HEROIC] = 222478, [TIER_MYTHIC] = 222479 },
    [212010] = { [TIER_LFR] = 222484, [TIER_NORMAL] = 194520, [TIER_HEROIC] = 222485, [TIER_MYTHIC] = 222486 },
    [212011] = { [TIER_LFR] = 222491, [TIER_NORMAL] = 194521, [TIER_HEROIC] = 222492, [TIER_MYTHIC] = 222493 },
    [212012] = { [TIER_LFR] = 222498, [TIER_NORMAL] = 194522, [TIER_HEROIC] = 222499, [TIER_MYTHIC] = 222500 },
    [212013] = { [TIER_LFR] = 222505, [TIER_NORMAL] = 194523, [TIER_HEROIC] = 222506, [TIER_MYTHIC] = 222507 },
    [212014] = { [TIER_LFR] = 222512, [TIER_NORMAL] = 194524, [TIER_HEROIC] = 222513, [TIER_MYTHIC] = 222514 },
    [212015] = { [TIER_LFR] = 222373, [TIER_NORMAL] = 194525, [TIER_HEROIC] = 222374, [TIER_MYTHIC] = 222375 },
    [212016] = { [TIER_LFR] = 222380, [TIER_NORMAL] = 194526, [TIER_HEROIC] = 222381, [TIER_MYTHIC] = 222382 },
    [212017] = { [TIER_LFR] = 222387, [TIER_NORMAL] = 194527, [TIER_HEROIC] = 222388, [TIER_MYTHIC] = 222389 },
    [212018] = { [TIER_LFR] = 222394, [TIER_NORMAL] = 194528, [TIER_HEROIC] = 222395, [TIER_MYTHIC] = 222396 },
    [212019] = { [TIER_LFR] = 222401, [TIER_NORMAL] = 194529, [TIER_HEROIC] = 222402, [TIER_MYTHIC] = 222403 },
    [212020] = { [TIER_LFR] = 222408, [TIER_NORMAL] = 194530, [TIER_HEROIC] = 222409, [TIER_MYTHIC] = 222410 },
    [212021] = { [TIER_LFR] = 222415, [TIER_NORMAL] = 194531, [TIER_HEROIC] = 222416, [TIER_MYTHIC] = 222417 },
    [212022] = { [TIER_LFR] = 222422, [TIER_NORMAL] = 194532, [TIER_HEROIC] = 222423, [TIER_MYTHIC] = 222424 },
    [212023] = { [TIER_LFR] = 222429, [TIER_NORMAL] = 194533, [TIER_HEROIC] = 222430, [TIER_MYTHIC] = 222431 },
    [212024] = { [TIER_LFR] = 222294, [TIER_NORMAL] = 194534, [TIER_HEROIC] = 222295, [TIER_MYTHIC] = 222296 },
    [212025] = { [TIER_LFR] = 222301, [TIER_NORMAL] = 194535, [TIER_HEROIC] = 222302, [TIER_MYTHIC] = 222303 },
    [212026] = { [TIER_LFR] = 222308, [TIER_NORMAL] = 194536, [TIER_HEROIC] = 222309, [TIER_MYTHIC] = 222310 },
    [212027] = { [TIER_LFR] = 222315, [TIER_NORMAL] = 194537, [TIER_HEROIC] = 222316, [TIER_MYTHIC] = 222317 },
    [212028] = { [TIER_LFR] = 222322, [TIER_NORMAL] = 194538, [TIER_HEROIC] = 222323, [TIER_MYTHIC] = 222324 },
    [212029] = { [TIER_LFR] = 222329, [TIER_NORMAL] = 194539, [TIER_HEROIC] = 222330, [TIER_MYTHIC] = 222331 },
    [212030] = { [TIER_LFR] = 222336, [TIER_NORMAL] = 194540, [TIER_HEROIC] = 222337, [TIER_MYTHIC] = 222338 },
    [212031] = { [TIER_LFR] = 222343, [TIER_NORMAL] = 194541, [TIER_HEROIC] = 222344, [TIER_MYTHIC] = 222345 },
    [212032] = { [TIER_LFR] = 222350, [TIER_NORMAL] = 194542, [TIER_HEROIC] = 222351, [TIER_MYTHIC] = 222352 },
    [212033] = { [TIER_LFR] = 222219, [TIER_NORMAL] = 194543, [TIER_HEROIC] = 222220, [TIER_MYTHIC] = 222221 },
    [212034] = { [TIER_LFR] = 222226, [TIER_NORMAL] = 194544, [TIER_HEROIC] = 222227, [TIER_MYTHIC] = 222228 },
    [212035] = { [TIER_LFR] = 222233, [TIER_NORMAL] = 194545, [TIER_HEROIC] = 222234, [TIER_MYTHIC] = 222235 },
    [212036] = { [TIER_LFR] = 222240, [TIER_NORMAL] = 194546, [TIER_HEROIC] = 222241, [TIER_MYTHIC] = 222242 },
    [212037] = { [TIER_LFR] = 222247, [TIER_NORMAL] = 194547, [TIER_HEROIC] = 222248, [TIER_MYTHIC] = 222249 },
    [212038] = { [TIER_LFR] = 222254, [TIER_NORMAL] = 194548, [TIER_HEROIC] = 222255, [TIER_MYTHIC] = 222256 },
    [212039] = { [TIER_LFR] = 222261, [TIER_NORMAL] = 194549, [TIER_HEROIC] = 222262, [TIER_MYTHIC] = 222263 },
    [212040] = { [TIER_LFR] = 222268, [TIER_NORMAL] = 194550, [TIER_HEROIC] = 222269, [TIER_MYTHIC] = 222270 },
    [212041] = { [TIER_LFR] = 222275, [TIER_NORMAL] = 194551, [TIER_HEROIC] = 222276, [TIER_MYTHIC] = 222277 },
    [212042] = { [TIER_LFR] = 222144, [TIER_NORMAL] = 194552, [TIER_HEROIC] = 222145, [TIER_MYTHIC] = 222146 },
    [212043] = { [TIER_LFR] = 222151, [TIER_NORMAL] = 194553, [TIER_HEROIC] = 222152, [TIER_MYTHIC] = 222153 },
    [212044] = { [TIER_LFR] = 222158, [TIER_NORMAL] = 194554, [TIER_HEROIC] = 222159, [TIER_MYTHIC] = 222160 },
    [212045] = { [TIER_LFR] = 222165, [TIER_NORMAL] = 194555, [TIER_HEROIC] = 222166, [TIER_MYTHIC] = 222167 },
    [212046] = { [TIER_LFR] = 222172, [TIER_NORMAL] = 194556, [TIER_HEROIC] = 222173, [TIER_MYTHIC] = 222174 },
    [212047] = { [TIER_LFR] = 222179, [TIER_NORMAL] = 194557, [TIER_HEROIC] = 222180, [TIER_MYTHIC] = 222181 },
    [212048] = { [TIER_LFR] = 222186, [TIER_NORMAL] = 194558, [TIER_HEROIC] = 222187, [TIER_MYTHIC] = 222188 },
    [212049] = { [TIER_LFR] = 222193, [TIER_NORMAL] = 194559, [TIER_HEROIC] = 222194, [TIER_MYTHIC] = 222195 },
    [212050] = { [TIER_LFR] = 222200, [TIER_NORMAL] = 194560, [TIER_HEROIC] = 222201, [TIER_MYTHIC] = 222202 },
    [212051] = { [TIER_LFR] = 222065, [TIER_NORMAL] = 194561, [TIER_HEROIC] = 222066, [TIER_MYTHIC] = 222067 },
    [212052] = { [TIER_LFR] = 222072, [TIER_NORMAL] = 194562, [TIER_HEROIC] = 222073, [TIER_MYTHIC] = 222074 },
    [212053] = { [TIER_LFR] = 222079, [TIER_NORMAL] = 194563, [TIER_HEROIC] = 222080, [TIER_MYTHIC] = 222081 },
    [212054] = { [TIER_LFR] = 222086, [TIER_NORMAL] = 194564, [TIER_HEROIC] = 222087, [TIER_MYTHIC] = 222088 },
    [212055] = { [TIER_LFR] = 222093, [TIER_NORMAL] = 194565, [TIER_HEROIC] = 222094, [TIER_MYTHIC] = 222095 },
    [212056] = { [TIER_LFR] = 222100, [TIER_NORMAL] = 194566, [TIER_HEROIC] = 222101, [TIER_MYTHIC] = 222102 },
    [212057] = { [TIER_LFR] = 222107, [TIER_NORMAL] = 194567, [TIER_HEROIC] = 222108, [TIER_MYTHIC] = 222109 },
    [212058] = { [TIER_LFR] = 222114, [TIER_NORMAL] = 194568, [TIER_HEROIC] = 222115, [TIER_MYTHIC] = 222116 },
    [212059] = { [TIER_LFR] = 222121, [TIER_NORMAL] = 194569, [TIER_HEROIC] = 222122, [TIER_MYTHIC] = 222123 },
    [212060] = { [TIER_LFR] = 221990, [TIER_NORMAL] = 194570, [TIER_HEROIC] = 221991, [TIER_MYTHIC] = 221992 },
    [212061] = { [TIER_LFR] = 221997, [TIER_NORMAL] = 194571, [TIER_HEROIC] = 221998, [TIER_MYTHIC] = 221999 },
    [212062] = { [TIER_LFR] = 222004, [TIER_NORMAL] = 194572, [TIER_HEROIC] = 222005, [TIER_MYTHIC] = 222006 },
    [212063] = { [TIER_LFR] = 222011, [TIER_NORMAL] = 194573, [TIER_HEROIC] = 222012, [TIER_MYTHIC] = 222013 },
    [212064] = { [TIER_LFR] = 222018, [TIER_NORMAL] = 194574, [TIER_HEROIC] = 222019, [TIER_MYTHIC] = 222020 },
    [212065] = { [TIER_LFR] = 222025, [TIER_NORMAL] = 194575, [TIER_HEROIC] = 222026, [TIER_MYTHIC] = 222027 },
    [212066] = { [TIER_LFR] = 222032, [TIER_NORMAL] = 194576, [TIER_HEROIC] = 222033, [TIER_MYTHIC] = 222034 },
    [212067] = { [TIER_LFR] = 222039, [TIER_NORMAL] = 194577, [TIER_HEROIC] = 222040, [TIER_MYTHIC] = 222041 },
    [212068] = { [TIER_LFR] = 222046, [TIER_NORMAL] = 194578, [TIER_HEROIC] = 222047, [TIER_MYTHIC] = 222048 },
    [212069] = { [TIER_LFR] = 221911, [TIER_NORMAL] = 194579, [TIER_HEROIC] = 221912, [TIER_MYTHIC] = 221913 },
    [212070] = { [TIER_LFR] = 221918, [TIER_NORMAL] = 194580, [TIER_HEROIC] = 221919, [TIER_MYTHIC] = 221920 },
    [212071] = { [TIER_LFR] = 221925, [TIER_NORMAL] = 194581, [TIER_HEROIC] = 221926, [TIER_MYTHIC] = 221927 },
    [212072] = { [TIER_LFR] = 221932, [TIER_NORMAL] = 194582, [TIER_HEROIC] = 221933, [TIER_MYTHIC] = 221934 },
    [212073] = { [TIER_LFR] = 221939, [TIER_NORMAL] = 194583, [TIER_HEROIC] = 221940, [TIER_MYTHIC] = 221941 },
    [212074] = { [TIER_LFR] = 221946, [TIER_NORMAL] = 194584, [TIER_HEROIC] = 221947, [TIER_MYTHIC] = 221948 },
    [212075] = { [TIER_LFR] = 221953, [TIER_NORMAL] = 194585, [TIER_HEROIC] = 221954, [TIER_MYTHIC] = 221955 },
    [212076] = { [TIER_LFR] = 221960, [TIER_NORMAL] = 194586, [TIER_HEROIC] = 221961, [TIER_MYTHIC] = 221962 },
    [212077] = { [TIER_LFR] = 221967, [TIER_NORMAL] = 194587, [TIER_HEROIC] = 221968, [TIER_MYTHIC] = 221969 },
    [212078] = { [TIER_LFR] = 221830, [TIER_NORMAL] = 194588, [TIER_HEROIC] = 221831, [TIER_MYTHIC] = 221832 },
    [212079] = { [TIER_LFR] = 221837, [TIER_NORMAL] = 194589, [TIER_HEROIC] = 221838, [TIER_MYTHIC] = 221839 },
    [212080] = { [TIER_LFR] = 221844, [TIER_NORMAL] = 194590, [TIER_HEROIC] = 221845, [TIER_MYTHIC] = 221846 },
    [212081] = { [TIER_LFR] = 221851, [TIER_NORMAL] = 194591, [TIER_HEROIC] = 221852, [TIER_MYTHIC] = 221853 },
    [212082] = { [TIER_LFR] = 221858, [TIER_NORMAL] = 194592, [TIER_HEROIC] = 221859, [TIER_MYTHIC] = 221860 },
    [212083] = { [TIER_LFR] = 221865, [TIER_NORMAL] = 194593, [TIER_HEROIC] = 221866, [TIER_MYTHIC] = 221867 },
    [212084] = { [TIER_LFR] = 221872, [TIER_NORMAL] = 194594, [TIER_HEROIC] = 221873, [TIER_MYTHIC] = 221874 },
    [212085] = { [TIER_LFR] = 221879, [TIER_NORMAL] = 194595, [TIER_HEROIC] = 221880, [TIER_MYTHIC] = 221881 },
    [212086] = { [TIER_LFR] = 221886, [TIER_NORMAL] = 194596, [TIER_HEROIC] = 221887, [TIER_MYTHIC] = 229638 },
    [212087] = { [TIER_LFR] = 222791, [TIER_NORMAL] = 194597, [TIER_HEROIC] = 222792, [TIER_MYTHIC] = 222793 },
    [212088] = { [TIER_LFR] = 221758, [TIER_NORMAL] = 194598, [TIER_HEROIC] = 221759, [TIER_MYTHIC] = 221760 },
    [212089] = { [TIER_LFR] = 221765, [TIER_NORMAL] = 194599, [TIER_HEROIC] = 221766, [TIER_MYTHIC] = 221767 },
    [212090] = { [TIER_LFR] = 221772, [TIER_NORMAL] = 194600, [TIER_HEROIC] = 221773, [TIER_MYTHIC] = 221774 },
    [212091] = { [TIER_LFR] = 221779, [TIER_NORMAL] = 194601, [TIER_HEROIC] = 221780, [TIER_MYTHIC] = 221781 },
    [212092] = { [TIER_LFR] = 221786, [TIER_NORMAL] = 194602, [TIER_HEROIC] = 221787, [TIER_MYTHIC] = 221788 },
    [212093] = { [TIER_LFR] = 221793, [TIER_NORMAL] = 194603, [TIER_HEROIC] = 221794, [TIER_MYTHIC] = 221795 },
    [212094] = { [TIER_LFR] = 221800, [TIER_NORMAL] = 194604, [TIER_HEROIC] = 221801, [TIER_MYTHIC] = 221802 },
    [212095] = { [TIER_LFR] = 221807, [TIER_NORMAL] = 194605, [TIER_HEROIC] = 221808, [TIER_MYTHIC] = 221809 },
    [217176] = { [TIER_LFR] = 198909, [TIER_NORMAL] = 198908, [TIER_HEROIC] = 198910, [TIER_MYTHIC] = 198911 },
    [217177] = { [TIER_LFR] = 198913, [TIER_NORMAL] = 198912, [TIER_HEROIC] = 198914, [TIER_MYTHIC] = 198915 },
    [217178] = { [TIER_LFR] = 198917, [TIER_NORMAL] = 198916, [TIER_HEROIC] = 198918, [TIER_MYTHIC] = 198919 },
    [217179] = { [TIER_LFR] = 198927, [TIER_NORMAL] = 198926, [TIER_HEROIC] = 198928, [TIER_MYTHIC] = 198929 },
    [217180] = { [TIER_LFR] = 198931, [TIER_NORMAL] = 198930, [TIER_HEROIC] = 198932, [TIER_MYTHIC] = 198933 },
    [217181] = { [TIER_LFR] = 198941, [TIER_NORMAL] = 198940, [TIER_HEROIC] = 198942, [TIER_MYTHIC] = 198943 },
    [217182] = { [TIER_LFR] = 198945, [TIER_NORMAL] = 198944, [TIER_HEROIC] = 198946, [TIER_MYTHIC] = 198947 },
    [217183] = { [TIER_LFR] = 198949, [TIER_NORMAL] = 198948, [TIER_HEROIC] = 198950, [TIER_MYTHIC] = 198951 },
    [217184] = { [TIER_LFR] = 198959, [TIER_NORMAL] = 198958, [TIER_HEROIC] = 198960, [TIER_MYTHIC] = 198961 },
    [217185] = { [TIER_LFR] = 198963, [TIER_NORMAL] = 198962, [TIER_HEROIC] = 198964, [TIER_MYTHIC] = 198965 },
    [217186] = { [TIER_LFR] = 198973, [TIER_NORMAL] = 198972, [TIER_HEROIC] = 198974, [TIER_MYTHIC] = 198975 },
    [217187] = { [TIER_LFR] = 198977, [TIER_NORMAL] = 198976, [TIER_HEROIC] = 198978, [TIER_MYTHIC] = 198979 },
    [217188] = { [TIER_LFR] = 198981, [TIER_NORMAL] = 198980, [TIER_HEROIC] = 198982, [TIER_MYTHIC] = 198983 },
    [217189] = { [TIER_LFR] = 198985, [TIER_NORMAL] = 198984, [TIER_HEROIC] = 198986, [TIER_MYTHIC] = 198987 },
    [217190] = { [TIER_LFR] = 198989, [TIER_NORMAL] = 198988, [TIER_HEROIC] = 198990, [TIER_MYTHIC] = 198991 },
    [217191] = { [TIER_LFR] = 199001, [TIER_NORMAL] = 198998, [TIER_HEROIC] = 198999, [TIER_MYTHIC] = 199000 },
    [217192] = { [TIER_LFR] = 199007, [TIER_NORMAL] = 199004, [TIER_HEROIC] = 199005, [TIER_MYTHIC] = 199006 },
    [217193] = { [TIER_LFR] = 199011, [TIER_NORMAL] = 199010, [TIER_HEROIC] = 199012, [TIER_MYTHIC] = 199013 },
    [217194] = { [TIER_LFR] = 199025, [TIER_NORMAL] = 199022, [TIER_HEROIC] = 199023, [TIER_MYTHIC] = 199024 },
    [217195] = { [TIER_LFR] = 199029, [TIER_NORMAL] = 199028, [TIER_HEROIC] = 199030, [TIER_MYTHIC] = 199031 },
    [217196] = { [TIER_LFR] = 199043, [TIER_NORMAL] = 199040, [TIER_HEROIC] = 199041, [TIER_MYTHIC] = 199042 },
    [217197] = { [TIER_LFR] = 199049, [TIER_NORMAL] = 199046, [TIER_HEROIC] = 199047, [TIER_MYTHIC] = 199048 },
    [217198] = { [TIER_LFR] = 199053, [TIER_NORMAL] = 199052, [TIER_HEROIC] = 199054, [TIER_MYTHIC] = 199055 },
    [217199] = { [TIER_LFR] = 199067, [TIER_NORMAL] = 199064, [TIER_HEROIC] = 199065, [TIER_MYTHIC] = 199066 },
    [217200] = { [TIER_LFR] = 199071, [TIER_NORMAL] = 199070, [TIER_HEROIC] = 199072, [TIER_MYTHIC] = 199073 },
    [217201] = { [TIER_LFR] = 199085, [TIER_NORMAL] = 199082, [TIER_HEROIC] = 199083, [TIER_MYTHIC] = 199084 },
    [217202] = { [TIER_LFR] = 199089, [TIER_NORMAL] = 199088, [TIER_HEROIC] = 199090, [TIER_MYTHIC] = 199091 },
    [217203] = { [TIER_LFR] = 199103, [TIER_NORMAL] = 199100, [TIER_HEROIC] = 199101, [TIER_MYTHIC] = 199102 },
    [217204] = { [TIER_LFR] = 199107, [TIER_NORMAL] = 199106, [TIER_HEROIC] = 199108, [TIER_MYTHIC] = 199109 },
    [217205] = { [TIER_LFR] = 199115, [TIER_NORMAL] = 199112, [TIER_HEROIC] = 199113, [TIER_MYTHIC] = 199114 },
    [217206] = { [TIER_LFR] = 199121, [TIER_NORMAL] = 199118, [TIER_HEROIC] = 199119, [TIER_MYTHIC] = 199120 },
    [217207] = { [TIER_LFR] = 199127, [TIER_NORMAL] = 199124, [TIER_HEROIC] = 199125, [TIER_MYTHIC] = 199126 },
    [217208] = { [TIER_LFR] = 199133, [TIER_NORMAL] = 199130, [TIER_HEROIC] = 199131, [TIER_MYTHIC] = 199132 },
    [217209] = { [TIER_LFR] = 199139, [TIER_NORMAL] = 199136, [TIER_HEROIC] = 199137, [TIER_MYTHIC] = 199138 },
    [217210] = { [TIER_LFR] = 199143, [TIER_NORMAL] = 199142, [TIER_HEROIC] = 199144, [TIER_MYTHIC] = 199145 },
    [217211] = { [TIER_LFR] = 199157, [TIER_NORMAL] = 199154, [TIER_HEROIC] = 199155, [TIER_MYTHIC] = 199156 },
    [217212] = { [TIER_LFR] = 199161, [TIER_NORMAL] = 199160, [TIER_HEROIC] = 199162, [TIER_MYTHIC] = 199163 },
    [217213] = { [TIER_LFR] = 199175, [TIER_NORMAL] = 199172, [TIER_HEROIC] = 199173, [TIER_MYTHIC] = 199174 },
    [217214] = { [TIER_LFR] = 199179, [TIER_NORMAL] = 199178, [TIER_HEROIC] = 199180, [TIER_MYTHIC] = 199181 },
    [217215] = { [TIER_LFR] = 199193, [TIER_NORMAL] = 199190, [TIER_HEROIC] = 199191, [TIER_MYTHIC] = 199192 },
    [217216] = { [TIER_LFR] = 199199, [TIER_NORMAL] = 199196, [TIER_HEROIC] = 199197, [TIER_MYTHIC] = 199198 },
    [217217] = { [TIER_LFR] = 199205, [TIER_NORMAL] = 199202, [TIER_HEROIC] = 199203, [TIER_MYTHIC] = 199204 },
    [217218] = { [TIER_LFR] = 199209, [TIER_NORMAL] = 199208, [TIER_HEROIC] = 199210, [TIER_MYTHIC] = 199211 },
    [217219] = { [TIER_LFR] = 199223, [TIER_NORMAL] = 199220, [TIER_HEROIC] = 199221, [TIER_MYTHIC] = 199222 },
    [217220] = { [TIER_LFR] = 199227, [TIER_NORMAL] = 199226, [TIER_HEROIC] = 199228, [TIER_MYTHIC] = 199229 },
    [217221] = { [TIER_LFR] = 199239, [TIER_NORMAL] = 199238, [TIER_HEROIC] = 199240, [TIER_MYTHIC] = 199241 },
    [217222] = { [TIER_LFR] = 199251, [TIER_NORMAL] = 199250, [TIER_HEROIC] = 199252, [TIER_MYTHIC] = 199253 },
    [217223] = { [TIER_LFR] = 199263, [TIER_NORMAL] = 199262, [TIER_HEROIC] = 199264, [TIER_MYTHIC] = 199265 },
    [217224] = { [TIER_LFR] = 199275, [TIER_NORMAL] = 199274, [TIER_HEROIC] = 199276, [TIER_MYTHIC] = 199277 },
    [217225] = { [TIER_LFR] = 199287, [TIER_NORMAL] = 199286, [TIER_HEROIC] = 199288, [TIER_MYTHIC] = 199289 },
    [217226] = { [TIER_LFR] = 199299, [TIER_NORMAL] = 199298, [TIER_HEROIC] = 199300, [TIER_MYTHIC] = 199301 },
    [217227] = { [TIER_LFR] = 199311, [TIER_NORMAL] = 199310, [TIER_HEROIC] = 199312, [TIER_MYTHIC] = 199313 },
    [217228] = { [TIER_LFR] = 199323, [TIER_NORMAL] = 199322, [TIER_HEROIC] = 199324, [TIER_MYTHIC] = 199325 },
    [217229] = { [TIER_LFR] = 199335, [TIER_NORMAL] = 199334, [TIER_HEROIC] = 199336, [TIER_MYTHIC] = 199337 },
    [217230] = { [TIER_LFR] = 199347, [TIER_NORMAL] = 199346, [TIER_HEROIC] = 199348, [TIER_MYTHIC] = 199349 },
    [217231] = { [TIER_LFR] = 199359, [TIER_NORMAL] = 199358, [TIER_HEROIC] = 199360, [TIER_MYTHIC] = 199361 },
    [217232] = { [TIER_LFR] = 199371, [TIER_NORMAL] = 199370, [TIER_HEROIC] = 199372, [TIER_MYTHIC] = 199373 },
    [217233] = { [TIER_LFR] = 199383, [TIER_NORMAL] = 199382, [TIER_HEROIC] = 199384, [TIER_MYTHIC] = 199385 },
    [217234] = { [TIER_LFR] = 199395, [TIER_NORMAL] = 199394, [TIER_HEROIC] = 199396, [TIER_MYTHIC] = 199397 },
    [217235] = { [TIER_LFR] = 199407, [TIER_NORMAL] = 199406, [TIER_HEROIC] = 199408, [TIER_MYTHIC] = 199409 },
    [217236] = { [TIER_LFR] = 199419, [TIER_NORMAL] = 199418, [TIER_HEROIC] = 199420, [TIER_MYTHIC] = 199421 },
    [217237] = { [TIER_LFR] = 199431, [TIER_NORMAL] = 199430, [TIER_HEROIC] = 199432, [TIER_MYTHIC] = 199433 },
    [217238] = { [TIER_LFR] = 199443, [TIER_NORMAL] = 199442, [TIER_HEROIC] = 199444, [TIER_MYTHIC] = 199445 },
    [217239] = { [TIER_LFR] = 199455, [TIER_NORMAL] = 199454, [TIER_HEROIC] = 199456, [TIER_MYTHIC] = 199457 },
    [217240] = { [TIER_LFR] = 199467, [TIER_NORMAL] = 199466, [TIER_HEROIC] = 199468, [TIER_MYTHIC] = 199469 },
    [229230] = { [TIER_LFR] = 225178, [TIER_NORMAL] = 225173, [TIER_HEROIC] = 225179, [TIER_MYTHIC] = 225180 },
    [229231] = { [TIER_LFR] = 225190, [TIER_NORMAL] = 225185, [TIER_HEROIC] = 225191, [TIER_MYTHIC] = 225192 },
    [229232] = { [TIER_LFR] = 225202, [TIER_NORMAL] = 225197, [TIER_HEROIC] = 225203, [TIER_MYTHIC] = 225204 },
    [229233] = { [TIER_LFR] = 225214, [TIER_NORMAL] = 225209, [TIER_HEROIC] = 225215, [TIER_MYTHIC] = 225216 },
    [229234] = { [TIER_LFR] = 225226, [TIER_NORMAL] = 225221, [TIER_HEROIC] = 225227, [TIER_MYTHIC] = 225228 },
    [229235] = { [TIER_LFR] = 225238, [TIER_NORMAL] = 225233, [TIER_HEROIC] = 225239, [TIER_MYTHIC] = 225240 },
    [229236] = { [TIER_LFR] = 225250, [TIER_NORMAL] = 225245, [TIER_HEROIC] = 225251, [TIER_MYTHIC] = 225252 },
    [229237] = { [TIER_LFR] = 225262, [TIER_NORMAL] = 225257, [TIER_HEROIC] = 225263, [TIER_MYTHIC] = 225264 },
    [229238] = { [TIER_LFR] = 225274, [TIER_NORMAL] = 225269, [TIER_HEROIC] = 225275, [TIER_MYTHIC] = 225276 },
    [229239] = { [TIER_LFR] = 225286, [TIER_NORMAL] = 225281, [TIER_HEROIC] = 225287, [TIER_MYTHIC] = 225288 },
    [229240] = { [TIER_LFR] = 225298, [TIER_NORMAL] = 225293, [TIER_HEROIC] = 225299, [TIER_MYTHIC] = 225300 },
    [229241] = { [TIER_LFR] = 225310, [TIER_NORMAL] = 225305, [TIER_HEROIC] = 225311, [TIER_MYTHIC] = 225312 },
    [229242] = { [TIER_LFR] = 225322, [TIER_NORMAL] = 225317, [TIER_HEROIC] = 225323, [TIER_MYTHIC] = 225324 },
    [229243] = { [TIER_LFR] = 225334, [TIER_NORMAL] = 225329, [TIER_HEROIC] = 225335, [TIER_MYTHIC] = 225336 },
    [229244] = { [TIER_LFR] = 225346, [TIER_NORMAL] = 225341, [TIER_HEROIC] = 225347, [TIER_MYTHIC] = 225348 },
    [229245] = { [TIER_LFR] = 225358, [TIER_NORMAL] = 225353, [TIER_HEROIC] = 225359, [TIER_MYTHIC] = 225360 },
    [229246] = { [TIER_LFR] = 225370, [TIER_NORMAL] = 225365, [TIER_HEROIC] = 225371, [TIER_MYTHIC] = 225372 },
    [229247] = { [TIER_LFR] = 225382, [TIER_NORMAL] = 225377, [TIER_HEROIC] = 225383, [TIER_MYTHIC] = 225384 },
    [229248] = { [TIER_LFR] = 225394, [TIER_NORMAL] = 225389, [TIER_HEROIC] = 225395, [TIER_MYTHIC] = 225396 },
    [229249] = { [TIER_LFR] = 225406, [TIER_NORMAL] = 225401, [TIER_HEROIC] = 225407, [TIER_MYTHIC] = 225408 },
    [229250] = { [TIER_LFR] = 225418, [TIER_NORMAL] = 225413, [TIER_HEROIC] = 225419, [TIER_MYTHIC] = 225420 },
    [229251] = { [TIER_LFR] = 225430, [TIER_NORMAL] = 225425, [TIER_HEROIC] = 225431, [TIER_MYTHIC] = 225432 },
    [229252] = { [TIER_LFR] = 225442, [TIER_NORMAL] = 225437, [TIER_HEROIC] = 225443, [TIER_MYTHIC] = 225444 },
    [229253] = { [TIER_LFR] = 225454, [TIER_NORMAL] = 225449, [TIER_HEROIC] = 225455, [TIER_MYTHIC] = 225456 },
    [229254] = { [TIER_LFR] = 225466, [TIER_NORMAL] = 225461, [TIER_HEROIC] = 225467, [TIER_MYTHIC] = 225468 },
    [229255] = { [TIER_LFR] = 225478, [TIER_NORMAL] = 225473, [TIER_HEROIC] = 225479, [TIER_MYTHIC] = 225480 },
    [229256] = { [TIER_LFR] = 225490, [TIER_NORMAL] = 225485, [TIER_HEROIC] = 225491, [TIER_MYTHIC] = 225492 },
    [229257] = { [TIER_LFR] = 225502, [TIER_NORMAL] = 225497, [TIER_HEROIC] = 225503, [TIER_MYTHIC] = 225504 },
    [229258] = { [TIER_LFR] = 225514, [TIER_NORMAL] = 225509, [TIER_HEROIC] = 225515, [TIER_MYTHIC] = 225516 },
    [229259] = { [TIER_LFR] = 225526, [TIER_NORMAL] = 225521, [TIER_HEROIC] = 225527, [TIER_MYTHIC] = 225528 },
    [229260] = { [TIER_LFR] = 225538, [TIER_NORMAL] = 225533, [TIER_HEROIC] = 225539, [TIER_MYTHIC] = 225540 },
    [229261] = { [TIER_LFR] = 225547, [TIER_NORMAL] = 225548, [TIER_HEROIC] = 225549, [TIER_MYTHIC] = 225550 },
    [229262] = { [TIER_LFR] = 225556, [TIER_NORMAL] = 225551, [TIER_HEROIC] = 225557, [TIER_MYTHIC] = 225558 },
    [229263] = { [TIER_LFR] = 225568, [TIER_NORMAL] = 225563, [TIER_HEROIC] = 225569, [TIER_MYTHIC] = 225570 },
    [229264] = { [TIER_LFR] = 225580, [TIER_NORMAL] = 225575, [TIER_HEROIC] = 225581, [TIER_MYTHIC] = 225582 },
    [229265] = { [TIER_LFR] = 225589, [TIER_NORMAL] = 225590, [TIER_HEROIC] = 225591, [TIER_MYTHIC] = 225592 },
    [229266] = { [TIER_LFR] = 225598, [TIER_NORMAL] = 225593, [TIER_HEROIC] = 225599, [TIER_MYTHIC] = 225600 },
    [229267] = { [TIER_LFR] = 225610, [TIER_NORMAL] = 225605, [TIER_HEROIC] = 225611, [TIER_MYTHIC] = 225612 },
    [229268] = { [TIER_LFR] = 225622, [TIER_NORMAL] = 225617, [TIER_HEROIC] = 225623, [TIER_MYTHIC] = 225624 },
    [229269] = { [TIER_LFR] = 225634, [TIER_NORMAL] = 225629, [TIER_HEROIC] = 225635, [TIER_MYTHIC] = 225636 },
    [229270] = { [TIER_LFR] = 225646, [TIER_NORMAL] = 225641, [TIER_HEROIC] = 225647, [TIER_MYTHIC] = 225648 },
    [229271] = { [TIER_LFR] = 225658, [TIER_NORMAL] = 225653, [TIER_HEROIC] = 225659, [TIER_MYTHIC] = 225660 },
    [229272] = { [TIER_LFR] = 225670, [TIER_NORMAL] = 225665, [TIER_HEROIC] = 225671, [TIER_MYTHIC] = 225672 },
    [229273] = { [TIER_LFR] = 225682, [TIER_NORMAL] = 225677, [TIER_HEROIC] = 225683, [TIER_MYTHIC] = 225684 },
    [229274] = { [TIER_LFR] = 225694, [TIER_NORMAL] = 225689, [TIER_HEROIC] = 225695, [TIER_MYTHIC] = 225696 },
    [229275] = { [TIER_LFR] = 225706, [TIER_NORMAL] = 225701, [TIER_HEROIC] = 225707, [TIER_MYTHIC] = 225708 },
    [229276] = { [TIER_LFR] = 225718, [TIER_NORMAL] = 225713, [TIER_HEROIC] = 225719, [TIER_MYTHIC] = 225720 },
    [229277] = { [TIER_LFR] = 225730, [TIER_NORMAL] = 225725, [TIER_HEROIC] = 225731, [TIER_MYTHIC] = 225732 },
    [229278] = { [TIER_LFR] = 225742, [TIER_NORMAL] = 225737, [TIER_HEROIC] = 225743, [TIER_MYTHIC] = 225744 },
    [229279] = { [TIER_LFR] = 225754, [TIER_NORMAL] = 225749, [TIER_HEROIC] = 225755, [TIER_MYTHIC] = 225756 },
    [229280] = { [TIER_LFR] = 225766, [TIER_NORMAL] = 225761, [TIER_HEROIC] = 225767, [TIER_MYTHIC] = 225768 },
    [229281] = { [TIER_LFR] = 225778, [TIER_NORMAL] = 225773, [TIER_HEROIC] = 225779, [TIER_MYTHIC] = 225780 },
    [229282] = { [TIER_LFR] = 225790, [TIER_NORMAL] = 225785, [TIER_HEROIC] = 225791, [TIER_MYTHIC] = 225792 },
    [229283] = { [TIER_LFR] = 225802, [TIER_NORMAL] = 225797, [TIER_HEROIC] = 225803, [TIER_MYTHIC] = 225804 },
    [229284] = { [TIER_LFR] = 225814, [TIER_NORMAL] = 225809, [TIER_HEROIC] = 225815, [TIER_MYTHIC] = 225816 },
    [229285] = { [TIER_LFR] = 225826, [TIER_NORMAL] = 225821, [TIER_HEROIC] = 225827, [TIER_MYTHIC] = 225828 },
    [229286] = { [TIER_LFR] = 225838, [TIER_NORMAL] = 225833, [TIER_HEROIC] = 225839, [TIER_MYTHIC] = 225840 },
    [229287] = { [TIER_LFR] = 225850, [TIER_NORMAL] = 225845, [TIER_HEROIC] = 225851, [TIER_MYTHIC] = 225852 },
    [229288] = { [TIER_LFR] = 225862, [TIER_NORMAL] = 225857, [TIER_HEROIC] = 225863, [TIER_MYTHIC] = 225864 },
    [229289] = { [TIER_LFR] = 225874, [TIER_NORMAL] = 225869, [TIER_HEROIC] = 225875, [TIER_MYTHIC] = 225876 },
    [229290] = { [TIER_LFR] = 225886, [TIER_NORMAL] = 225881, [TIER_HEROIC] = 225887, [TIER_MYTHIC] = 225888 },
    [229291] = { [TIER_LFR] = 225898, [TIER_NORMAL] = 225893, [TIER_HEROIC] = 225899, [TIER_MYTHIC] = 225900 },
    [229292] = { [TIER_LFR] = 225910, [TIER_NORMAL] = 225905, [TIER_HEROIC] = 225911, [TIER_MYTHIC] = 225912 },
    [229293] = { [TIER_LFR] = 225922, [TIER_NORMAL] = 225917, [TIER_HEROIC] = 225923, [TIER_MYTHIC] = 225924 },
    [229294] = { [TIER_LFR] = 225934, [TIER_NORMAL] = 225929, [TIER_HEROIC] = 225935, [TIER_MYTHIC] = 225936 },
    [229295] = { [TIER_LFR] = 225946, [TIER_NORMAL] = 225941, [TIER_HEROIC] = 225947, [TIER_MYTHIC] = 225948 },
    [229296] = { [TIER_LFR] = 225958, [TIER_NORMAL] = 225953, [TIER_HEROIC] = 225959, [TIER_MYTHIC] = 225960 },
    [229297] = { [TIER_LFR] = 225970, [TIER_NORMAL] = 225965, [TIER_HEROIC] = 225971, [TIER_MYTHIC] = 225972 },
    [229298] = { [TIER_LFR] = 225982, [TIER_NORMAL] = 225977, [TIER_HEROIC] = 225983, [TIER_MYTHIC] = 225984 },
    [229299] = { [TIER_LFR] = 225994, [TIER_NORMAL] = 225989, [TIER_HEROIC] = 225995, [TIER_MYTHIC] = 225996 },
    [229300] = { [TIER_LFR] = 226006, [TIER_NORMAL] = 226001, [TIER_HEROIC] = 226007, [TIER_MYTHIC] = 226008 },
    [229301] = { [TIER_LFR] = 226018, [TIER_NORMAL] = 226013, [TIER_HEROIC] = 226019, [TIER_MYTHIC] = 226020 },
    [229302] = { [TIER_LFR] = 226030, [TIER_NORMAL] = 226025, [TIER_HEROIC] = 226031, [TIER_MYTHIC] = 226032 },
    [229303] = { [TIER_LFR] = 226042, [TIER_NORMAL] = 226037, [TIER_HEROIC] = 226043, [TIER_MYTHIC] = 226044 },
    [229304] = { [TIER_LFR] = 226054, [TIER_NORMAL] = 226049, [TIER_HEROIC] = 226055, [TIER_MYTHIC] = 226056 },
    [229305] = { [TIER_LFR] = 226066, [TIER_NORMAL] = 226061, [TIER_HEROIC] = 226067, [TIER_MYTHIC] = 226068 },
    [229306] = { [TIER_LFR] = 226078, [TIER_NORMAL] = 226073, [TIER_HEROIC] = 226079, [TIER_MYTHIC] = 226080 },
    [229307] = { [TIER_LFR] = 226090, [TIER_NORMAL] = 226085, [TIER_HEROIC] = 226091, [TIER_MYTHIC] = 226092 },
    [229308] = { [TIER_LFR] = 226102, [TIER_NORMAL] = 226097, [TIER_HEROIC] = 226103, [TIER_MYTHIC] = 226104 },
    [229309] = { [TIER_LFR] = 226114, [TIER_NORMAL] = 226109, [TIER_HEROIC] = 226115, [TIER_MYTHIC] = 226116 },
    [229310] = { [TIER_LFR] = 226126, [TIER_NORMAL] = 226121, [TIER_HEROIC] = 226127, [TIER_MYTHIC] = 226128 },
    [229311] = { [TIER_LFR] = 226138, [TIER_NORMAL] = 226133, [TIER_HEROIC] = 226139, [TIER_MYTHIC] = 226140 },
    [229312] = { [TIER_LFR] = 226150, [TIER_NORMAL] = 226145, [TIER_HEROIC] = 226151, [TIER_MYTHIC] = 226152 },
    [229313] = { [TIER_LFR] = 226162, [TIER_NORMAL] = 226157, [TIER_HEROIC] = 226163, [TIER_MYTHIC] = 226164 },
    [229314] = { [TIER_LFR] = 226174, [TIER_NORMAL] = 226169, [TIER_HEROIC] = 226175, [TIER_MYTHIC] = 226176 },
    [229315] = { [TIER_LFR] = 226186, [TIER_NORMAL] = 226181, [TIER_HEROIC] = 226187, [TIER_MYTHIC] = 226188 },
    [229316] = { [TIER_LFR] = 226198, [TIER_NORMAL] = 226193, [TIER_HEROIC] = 226199, [TIER_MYTHIC] = 226200 },
    [229317] = { [TIER_LFR] = 226210, [TIER_NORMAL] = 226205, [TIER_HEROIC] = 226211, [TIER_MYTHIC] = 226212 },
    [229318] = { [TIER_LFR] = 226222, [TIER_NORMAL] = 226217, [TIER_HEROIC] = 226223, [TIER_MYTHIC] = 226224 },
    [229319] = { [TIER_LFR] = 226234, [TIER_NORMAL] = 226229, [TIER_HEROIC] = 226235, [TIER_MYTHIC] = 226236 },
    [229320] = { [TIER_LFR] = 226246, [TIER_NORMAL] = 226241, [TIER_HEROIC] = 226247, [TIER_MYTHIC] = 226248 },
    [229321] = { [TIER_LFR] = 226258, [TIER_NORMAL] = 226253, [TIER_HEROIC] = 226259, [TIER_MYTHIC] = 226260 },
    [229322] = { [TIER_LFR] = 226270, [TIER_NORMAL] = 226265, [TIER_HEROIC] = 226271, [TIER_MYTHIC] = 226272 },
    [229323] = { [TIER_LFR] = 226282, [TIER_NORMAL] = 226277, [TIER_HEROIC] = 226283, [TIER_MYTHIC] = 226284 },
    [229324] = { [TIER_LFR] = 226294, [TIER_NORMAL] = 226289, [TIER_HEROIC] = 226295, [TIER_MYTHIC] = 226296 },
    [229325] = { [TIER_LFR] = 226306, [TIER_NORMAL] = 226301, [TIER_HEROIC] = 226307, [TIER_MYTHIC] = 226308 },
    [229326] = { [TIER_LFR] = 226318, [TIER_NORMAL] = 226313, [TIER_HEROIC] = 226319, [TIER_MYTHIC] = 226320 },
    [229327] = { [TIER_LFR] = 226330, [TIER_NORMAL] = 226325, [TIER_HEROIC] = 226331, [TIER_MYTHIC] = 226332 },
    [229328] = { [TIER_LFR] = 226342, [TIER_NORMAL] = 226337, [TIER_HEROIC] = 226343, [TIER_MYTHIC] = 226344 },
    [229329] = { [TIER_LFR] = 226354, [TIER_NORMAL] = 226349, [TIER_HEROIC] = 226355, [TIER_MYTHIC] = 226356 },
    [229330] = { [TIER_LFR] = 226366, [TIER_NORMAL] = 226361, [TIER_HEROIC] = 226367, [TIER_MYTHIC] = 226368 },
    [229331] = { [TIER_LFR] = 226378, [TIER_NORMAL] = 226373, [TIER_HEROIC] = 226379, [TIER_MYTHIC] = 226380 },
    [229332] = { [TIER_LFR] = 226390, [TIER_NORMAL] = 226385, [TIER_HEROIC] = 226391, [TIER_MYTHIC] = 226392 },
    [229333] = { [TIER_LFR] = 226402, [TIER_NORMAL] = 226397, [TIER_HEROIC] = 226403, [TIER_MYTHIC] = 226404 },
    [229334] = { [TIER_LFR] = 226414, [TIER_NORMAL] = 226409, [TIER_HEROIC] = 226415, [TIER_MYTHIC] = 226416 },
    [229335] = { [TIER_LFR] = 226426, [TIER_NORMAL] = 226421, [TIER_HEROIC] = 226427, [TIER_MYTHIC] = 226428 },
    [229336] = { [TIER_LFR] = 226438, [TIER_NORMAL] = 226433, [TIER_HEROIC] = 226439, [TIER_MYTHIC] = 226440 },
    [229337] = { [TIER_LFR] = 226450, [TIER_NORMAL] = 226445, [TIER_HEROIC] = 226451, [TIER_MYTHIC] = 231638 },
    [229338] = { [TIER_LFR] = 226460, [TIER_NORMAL] = 226455, [TIER_HEROIC] = 226461, [TIER_MYTHIC] = 226462 },
    [229339] = { [TIER_LFR] = 226472, [TIER_NORMAL] = 226467, [TIER_HEROIC] = 226473, [TIER_MYTHIC] = 226474 },
    [229340] = { [TIER_LFR] = 226484, [TIER_NORMAL] = 226479, [TIER_HEROIC] = 226485, [TIER_MYTHIC] = 226486 },
    [229341] = { [TIER_LFR] = 226496, [TIER_NORMAL] = 226491, [TIER_HEROIC] = 226497, [TIER_MYTHIC] = 226498 },
    [229342] = { [TIER_LFR] = 226508, [TIER_NORMAL] = 226503, [TIER_HEROIC] = 226509, [TIER_MYTHIC] = 226510 },
    [229343] = { [TIER_LFR] = 226520, [TIER_NORMAL] = 226515, [TIER_HEROIC] = 226521, [TIER_MYTHIC] = 226522 },
    [229344] = { [TIER_LFR] = 226532, [TIER_NORMAL] = 226527, [TIER_HEROIC] = 226533, [TIER_MYTHIC] = 226534 },
    [229345] = { [TIER_LFR] = 226544, [TIER_NORMAL] = 226539, [TIER_HEROIC] = 226545, [TIER_MYTHIC] = 226546 },
    [229346] = { [TIER_LFR] = 226556, [TIER_NORMAL] = 226551, [TIER_HEROIC] = 226557, [TIER_MYTHIC] = 226558 },
    [237605] = { [TIER_LFR] = 285523, [TIER_NORMAL] = 285518, [TIER_HEROIC] = 285524, [TIER_MYTHIC] = 285525 },
    [237606] = { [TIER_LFR] = 285535, [TIER_NORMAL] = 285530, [TIER_HEROIC] = 285536, [TIER_MYTHIC] = 285537 },
    [237607] = { [TIER_LFR] = 285547, [TIER_NORMAL] = 285542, [TIER_HEROIC] = 285548, [TIER_MYTHIC] = 285549 },
    [237608] = { [TIER_LFR] = 285559, [TIER_NORMAL] = 285554, [TIER_HEROIC] = 285560, [TIER_MYTHIC] = 285561 },
    [237609] = { [TIER_LFR] = 285571, [TIER_NORMAL] = 285566, [TIER_HEROIC] = 285572, [TIER_MYTHIC] = 285573 },
    [237610] = { [TIER_LFR] = 285583, [TIER_NORMAL] = 285578, [TIER_HEROIC] = 285584, [TIER_MYTHIC] = 285585 },
    [237611] = { [TIER_LFR] = 285595, [TIER_NORMAL] = 285590, [TIER_HEROIC] = 285596, [TIER_MYTHIC] = 285597 },
    [237612] = { [TIER_LFR] = 285607, [TIER_NORMAL] = 285602, [TIER_HEROIC] = 285608, [TIER_MYTHIC] = 285609 },
    [237613] = { [TIER_LFR] = 285619, [TIER_NORMAL] = 285614, [TIER_HEROIC] = 285620, [TIER_MYTHIC] = 285621 },
    [237614] = { [TIER_LFR] = 285631, [TIER_NORMAL] = 285626, [TIER_HEROIC] = 285632, [TIER_MYTHIC] = 285633 },
    [237615] = { [TIER_LFR] = 285643, [TIER_NORMAL] = 285638, [TIER_HEROIC] = 285644, [TIER_MYTHIC] = 285645 },
    [237616] = { [TIER_LFR] = 285655, [TIER_NORMAL] = 285650, [TIER_HEROIC] = 285656, [TIER_MYTHIC] = 285657 },
    [237617] = { [TIER_LFR] = 285667, [TIER_NORMAL] = 285662, [TIER_HEROIC] = 285668, [TIER_MYTHIC] = 285669 },
    [237618] = { [TIER_LFR] = 285679, [TIER_NORMAL] = 285674, [TIER_HEROIC] = 285680, [TIER_MYTHIC] = 285681 },
    [237619] = { [TIER_LFR] = 285691, [TIER_NORMAL] = 285686, [TIER_HEROIC] = 285692, [TIER_MYTHIC] = 285693 },
    [237620] = { [TIER_LFR] = 285703, [TIER_NORMAL] = 285698, [TIER_HEROIC] = 285704, [TIER_MYTHIC] = 285705 },
    [237621] = { [TIER_LFR] = 285715, [TIER_NORMAL] = 285710, [TIER_HEROIC] = 285716, [TIER_MYTHIC] = 285717 },
    [237622] = { [TIER_LFR] = 285727, [TIER_NORMAL] = 285722, [TIER_HEROIC] = 285728, [TIER_MYTHIC] = 285729 },
    [237623] = { [TIER_LFR] = 285739, [TIER_NORMAL] = 285734, [TIER_HEROIC] = 285740, [TIER_MYTHIC] = 285741 },
    [237624] = { [TIER_LFR] = 285751, [TIER_NORMAL] = 285746, [TIER_HEROIC] = 285752, [TIER_MYTHIC] = 285753 },
    [237625] = { [TIER_LFR] = 285763, [TIER_NORMAL] = 285758, [TIER_HEROIC] = 285764, [TIER_MYTHIC] = 285765 },
    [237626] = { [TIER_LFR] = 285775, [TIER_NORMAL] = 285770, [TIER_HEROIC] = 285776, [TIER_MYTHIC] = 285777 },
    [237627] = { [TIER_LFR] = 285787, [TIER_NORMAL] = 285782, [TIER_HEROIC] = 285788, [TIER_MYTHIC] = 285789 },
    [237628] = { [TIER_LFR] = 285799, [TIER_NORMAL] = 285794, [TIER_HEROIC] = 285800, [TIER_MYTHIC] = 285801 },
    [237629] = { [TIER_LFR] = 285811, [TIER_NORMAL] = 285806, [TIER_HEROIC] = 285812, [TIER_MYTHIC] = 285813 },
    [237630] = { [TIER_LFR] = 285823, [TIER_NORMAL] = 285818, [TIER_HEROIC] = 285824, [TIER_MYTHIC] = 285825 },
    [237631] = { [TIER_LFR] = 285835, [TIER_NORMAL] = 285830, [TIER_HEROIC] = 285836, [TIER_MYTHIC] = 285837 },
    [237632] = { [TIER_LFR] = 285847, [TIER_NORMAL] = 285842, [TIER_HEROIC] = 285848, [TIER_MYTHIC] = 285849 },
    [237633] = { [TIER_LFR] = 285859, [TIER_NORMAL] = 285854, [TIER_HEROIC] = 285860, [TIER_MYTHIC] = 285861 },
    [237634] = { [TIER_LFR] = 285871, [TIER_NORMAL] = 285866, [TIER_HEROIC] = 285872, [TIER_MYTHIC] = 285873 },
    [237635] = { [TIER_LFR] = 285883, [TIER_NORMAL] = 285878, [TIER_HEROIC] = 285884, [TIER_MYTHIC] = 285885 },
    [237636] = { [TIER_LFR] = 285892, [TIER_NORMAL] = 285893, [TIER_HEROIC] = 285894, [TIER_MYTHIC] = 285895 },
    [237637] = { [TIER_LFR] = 285903, [TIER_NORMAL] = 285898, [TIER_HEROIC] = 285904, [TIER_MYTHIC] = 285905 },
    [237638] = { [TIER_LFR] = 285915, [TIER_NORMAL] = 285910, [TIER_HEROIC] = 285916, [TIER_MYTHIC] = 285917 },
    [237639] = { [TIER_LFR] = 285927, [TIER_NORMAL] = 285922, [TIER_HEROIC] = 285928, [TIER_MYTHIC] = 285929 },
    [237640] = { [TIER_LFR] = 285936, [TIER_NORMAL] = 285937, [TIER_HEROIC] = 285938, [TIER_MYTHIC] = 285939 },
    [237641] = { [TIER_LFR] = 285947, [TIER_NORMAL] = 285942, [TIER_HEROIC] = 285948, [TIER_MYTHIC] = 285949 },
    [237642] = { [TIER_LFR] = 285959, [TIER_NORMAL] = 285954, [TIER_HEROIC] = 285960, [TIER_MYTHIC] = 285961 },
    [237643] = { [TIER_LFR] = 285971, [TIER_NORMAL] = 285966, [TIER_HEROIC] = 285972, [TIER_MYTHIC] = 285973 },
    [237644] = { [TIER_LFR] = 285983, [TIER_NORMAL] = 285978, [TIER_HEROIC] = 285984, [TIER_MYTHIC] = 285985 },
    [237645] = { [TIER_LFR] = 285995, [TIER_NORMAL] = 285990, [TIER_HEROIC] = 285996, [TIER_MYTHIC] = 285997 },
    [237646] = { [TIER_LFR] = 286007, [TIER_NORMAL] = 286002, [TIER_HEROIC] = 286008, [TIER_MYTHIC] = 286009 },
    [237647] = { [TIER_LFR] = 286019, [TIER_NORMAL] = 286014, [TIER_HEROIC] = 286020, [TIER_MYTHIC] = 286021 },
    [237648] = { [TIER_LFR] = 286031, [TIER_NORMAL] = 286026, [TIER_HEROIC] = 286032, [TIER_MYTHIC] = 286033 },
    [237649] = { [TIER_LFR] = 286043, [TIER_NORMAL] = 286038, [TIER_HEROIC] = 286044, [TIER_MYTHIC] = 286045 },
    [237650] = { [TIER_LFR] = 286055, [TIER_NORMAL] = 286050, [TIER_HEROIC] = 286056, [TIER_MYTHIC] = 286057 },
    [237651] = { [TIER_LFR] = 286067, [TIER_NORMAL] = 286062, [TIER_HEROIC] = 286068, [TIER_MYTHIC] = 286069 },
    [237652] = { [TIER_LFR] = 286079, [TIER_NORMAL] = 286074, [TIER_HEROIC] = 286080, [TIER_MYTHIC] = 286081 },
    [237653] = { [TIER_LFR] = 286091, [TIER_NORMAL] = 286086, [TIER_HEROIC] = 286092, [TIER_MYTHIC] = 286093 },
    [237654] = { [TIER_LFR] = 286103, [TIER_NORMAL] = 286098, [TIER_HEROIC] = 286104, [TIER_MYTHIC] = 286105 },
    [237655] = { [TIER_LFR] = 286115, [TIER_NORMAL] = 286110, [TIER_HEROIC] = 286116, [TIER_MYTHIC] = 286117 },
    [237656] = { [TIER_LFR] = 286127, [TIER_NORMAL] = 286122, [TIER_HEROIC] = 286128, [TIER_MYTHIC] = 286129 },
    [237657] = { [TIER_LFR] = 286139, [TIER_NORMAL] = 286134, [TIER_HEROIC] = 286140, [TIER_MYTHIC] = 286141 },
    [237658] = { [TIER_LFR] = 286151, [TIER_NORMAL] = 286146, [TIER_HEROIC] = 286152, [TIER_MYTHIC] = 286153 },
    [237659] = { [TIER_LFR] = 286163, [TIER_NORMAL] = 286158, [TIER_HEROIC] = 286164, [TIER_MYTHIC] = 286165 },
    [237660] = { [TIER_LFR] = 286175, [TIER_NORMAL] = 286170, [TIER_HEROIC] = 286176, [TIER_MYTHIC] = 286177 },
    [237661] = { [TIER_LFR] = 286187, [TIER_NORMAL] = 286182, [TIER_HEROIC] = 286188, [TIER_MYTHIC] = 286189 },
    [237662] = { [TIER_LFR] = 286199, [TIER_NORMAL] = 286194, [TIER_HEROIC] = 286200, [TIER_MYTHIC] = 286201 },
    [237663] = { [TIER_LFR] = 286211, [TIER_NORMAL] = 286206, [TIER_HEROIC] = 286212, [TIER_MYTHIC] = 286213 },
    [237664] = { [TIER_LFR] = 286223, [TIER_NORMAL] = 286218, [TIER_HEROIC] = 286224, [TIER_MYTHIC] = 286225 },
    [237665] = { [TIER_LFR] = 286235, [TIER_NORMAL] = 286230, [TIER_HEROIC] = 286236, [TIER_MYTHIC] = 286237 },
    [237666] = { [TIER_LFR] = 286247, [TIER_NORMAL] = 286242, [TIER_HEROIC] = 286248, [TIER_MYTHIC] = 286249 },
    [237667] = { [TIER_LFR] = 286259, [TIER_NORMAL] = 286254, [TIER_HEROIC] = 286260, [TIER_MYTHIC] = 286261 },
    [237668] = { [TIER_LFR] = 286271, [TIER_NORMAL] = 286266, [TIER_HEROIC] = 286272, [TIER_MYTHIC] = 286273 },
    [237669] = { [TIER_LFR] = 286283, [TIER_NORMAL] = 286278, [TIER_HEROIC] = 286284, [TIER_MYTHIC] = 286285 },
    [237670] = { [TIER_LFR] = 286295, [TIER_NORMAL] = 286290, [TIER_HEROIC] = 286296, [TIER_MYTHIC] = 286297 },
    [237671] = { [TIER_LFR] = 286307, [TIER_NORMAL] = 286302, [TIER_HEROIC] = 286308, [TIER_MYTHIC] = 286309 },
    [237672] = { [TIER_LFR] = 286319, [TIER_NORMAL] = 286314, [TIER_HEROIC] = 286320, [TIER_MYTHIC] = 286321 },
    [237673] = { [TIER_LFR] = 286331, [TIER_NORMAL] = 286326, [TIER_HEROIC] = 286332, [TIER_MYTHIC] = 286333 },
    [237674] = { [TIER_LFR] = 286343, [TIER_NORMAL] = 286338, [TIER_HEROIC] = 286344, [TIER_MYTHIC] = 286345 },
    [237675] = { [TIER_LFR] = 286355, [TIER_NORMAL] = 286350, [TIER_HEROIC] = 286356, [TIER_MYTHIC] = 286357 },
    [237676] = { [TIER_LFR] = 286367, [TIER_NORMAL] = 286362, [TIER_HEROIC] = 286368, [TIER_MYTHIC] = 286369 },
    [237677] = { [TIER_LFR] = 286379, [TIER_NORMAL] = 286374, [TIER_HEROIC] = 286380, [TIER_MYTHIC] = 286381 },
    [237678] = { [TIER_LFR] = 286391, [TIER_NORMAL] = 286386, [TIER_HEROIC] = 286392, [TIER_MYTHIC] = 286393 },
    [237679] = { [TIER_LFR] = 286403, [TIER_NORMAL] = 286398, [TIER_HEROIC] = 286404, [TIER_MYTHIC] = 286405 },
    [237680] = { [TIER_LFR] = 286415, [TIER_NORMAL] = 286410, [TIER_HEROIC] = 286416, [TIER_MYTHIC] = 286417 },
    [237681] = { [TIER_LFR] = 286427, [TIER_NORMAL] = 286422, [TIER_HEROIC] = 286428, [TIER_MYTHIC] = 286429 },
    [237682] = { [TIER_LFR] = 286439, [TIER_NORMAL] = 286434, [TIER_HEROIC] = 286440, [TIER_MYTHIC] = 286441 },
    [237683] = { [TIER_LFR] = 286451, [TIER_NORMAL] = 286446, [TIER_HEROIC] = 286452, [TIER_MYTHIC] = 286453 },
    [237684] = { [TIER_LFR] = 286463, [TIER_NORMAL] = 286458, [TIER_HEROIC] = 286464, [TIER_MYTHIC] = 286465 },
    [237685] = { [TIER_LFR] = 286475, [TIER_NORMAL] = 286470, [TIER_HEROIC] = 286476, [TIER_MYTHIC] = 286477 },
    [237686] = { [TIER_LFR] = 286487, [TIER_NORMAL] = 286482, [TIER_HEROIC] = 286488, [TIER_MYTHIC] = 286489 },
    [237687] = { [TIER_LFR] = 286499, [TIER_NORMAL] = 286494, [TIER_HEROIC] = 286500, [TIER_MYTHIC] = 286501 },
    [237688] = { [TIER_LFR] = 286511, [TIER_NORMAL] = 286506, [TIER_HEROIC] = 286512, [TIER_MYTHIC] = 286513 },
    [237689] = { [TIER_LFR] = 286523, [TIER_NORMAL] = 286518, [TIER_HEROIC] = 286524, [TIER_MYTHIC] = 286525 },
    [237690] = { [TIER_LFR] = 286535, [TIER_NORMAL] = 286530, [TIER_HEROIC] = 286536, [TIER_MYTHIC] = 286537 },
    [237691] = { [TIER_LFR] = 286547, [TIER_NORMAL] = 286542, [TIER_HEROIC] = 286548, [TIER_MYTHIC] = 286549 },
    [237692] = { [TIER_LFR] = 286559, [TIER_NORMAL] = 286554, [TIER_HEROIC] = 286560, [TIER_MYTHIC] = 286561 },
    [237693] = { [TIER_LFR] = 286571, [TIER_NORMAL] = 286566, [TIER_HEROIC] = 286572, [TIER_MYTHIC] = 286573 },
    [237694] = { [TIER_LFR] = 286583, [TIER_NORMAL] = 286578, [TIER_HEROIC] = 286584, [TIER_MYTHIC] = 286585 },
    [237695] = { [TIER_LFR] = 286595, [TIER_NORMAL] = 286590, [TIER_HEROIC] = 286596, [TIER_MYTHIC] = 286597 },
    [237696] = { [TIER_LFR] = 286607, [TIER_NORMAL] = 286602, [TIER_HEROIC] = 286608, [TIER_MYTHIC] = 286609 },
    [237697] = { [TIER_LFR] = 286619, [TIER_NORMAL] = 286614, [TIER_HEROIC] = 286620, [TIER_MYTHIC] = 286621 },
    [237698] = { [TIER_LFR] = 286631, [TIER_NORMAL] = 286626, [TIER_HEROIC] = 286632, [TIER_MYTHIC] = 286633 },
    [237699] = { [TIER_LFR] = 286643, [TIER_NORMAL] = 286638, [TIER_HEROIC] = 286644, [TIER_MYTHIC] = 286645 },
    [237700] = { [TIER_LFR] = 286655, [TIER_NORMAL] = 286650, [TIER_HEROIC] = 286656, [TIER_MYTHIC] = 286657 },
    [237701] = { [TIER_LFR] = 286667, [TIER_NORMAL] = 286662, [TIER_HEROIC] = 286668, [TIER_MYTHIC] = 286669 },
    [237702] = { [TIER_LFR] = 286679, [TIER_NORMAL] = 286674, [TIER_HEROIC] = 286680, [TIER_MYTHIC] = 286681 },
    [237703] = { [TIER_LFR] = 286691, [TIER_NORMAL] = 286686, [TIER_HEROIC] = 286692, [TIER_MYTHIC] = 286693 },
    [237704] = { [TIER_LFR] = 286703, [TIER_NORMAL] = 286698, [TIER_HEROIC] = 286704, [TIER_MYTHIC] = 286705 },
    [237705] = { [TIER_LFR] = 286715, [TIER_NORMAL] = 286710, [TIER_HEROIC] = 286716, [TIER_MYTHIC] = 286717 },
    [237706] = { [TIER_LFR] = 286727, [TIER_NORMAL] = 286722, [TIER_HEROIC] = 286728, [TIER_MYTHIC] = 286729 },
    [237707] = { [TIER_LFR] = 286739, [TIER_NORMAL] = 286734, [TIER_HEROIC] = 286740, [TIER_MYTHIC] = 286741 },
    [237708] = { [TIER_LFR] = 286751, [TIER_NORMAL] = 286746, [TIER_HEROIC] = 286752, [TIER_MYTHIC] = 286753 },
    [237709] = { [TIER_LFR] = 286763, [TIER_NORMAL] = 286758, [TIER_HEROIC] = 286764, [TIER_MYTHIC] = 286765 },
    [237710] = { [TIER_LFR] = 286775, [TIER_NORMAL] = 286770, [TIER_HEROIC] = 286776, [TIER_MYTHIC] = 286777 },
    [237711] = { [TIER_LFR] = 286787, [TIER_NORMAL] = 286782, [TIER_HEROIC] = 286788, [TIER_MYTHIC] = 286789 },
    [237712] = { [TIER_LFR] = 286799, [TIER_NORMAL] = 286794, [TIER_HEROIC] = 286800, [TIER_MYTHIC] = 286801 },
    [237713] = { [TIER_LFR] = 286810, [TIER_NORMAL] = 286805, [TIER_HEROIC] = 286811, [TIER_MYTHIC] = 286812 },
    [237714] = { [TIER_LFR] = 286822, [TIER_NORMAL] = 286817, [TIER_HEROIC] = 286823, [TIER_MYTHIC] = 286824 },
    [237715] = { [TIER_LFR] = 286834, [TIER_NORMAL] = 286829, [TIER_HEROIC] = 286835, [TIER_MYTHIC] = 286836 },
    [237716] = { [TIER_LFR] = 286846, [TIER_NORMAL] = 286841, [TIER_HEROIC] = 286847, [TIER_MYTHIC] = 286848 },
    [237717] = { [TIER_LFR] = 286858, [TIER_NORMAL] = 286853, [TIER_HEROIC] = 286859, [TIER_MYTHIC] = 286860 },
    [237718] = { [TIER_LFR] = 286870, [TIER_NORMAL] = 286865, [TIER_HEROIC] = 286871, [TIER_MYTHIC] = 286872 },
    [237719] = { [TIER_LFR] = 286882, [TIER_NORMAL] = 286877, [TIER_HEROIC] = 286883, [TIER_MYTHIC] = 286884 },
    [237720] = { [TIER_LFR] = 286894, [TIER_NORMAL] = 286889, [TIER_HEROIC] = 286895, [TIER_MYTHIC] = 286896 },
    [237721] = { [TIER_LFR] = 286906, [TIER_NORMAL] = 286901, [TIER_HEROIC] = 286907, [TIER_MYTHIC] = 286908 },
    [249947] = { [TIER_LFR] = 296383, [TIER_NORMAL] = 296378, [TIER_HEROIC] = 296384, [TIER_MYTHIC] = 296385 },
    [249948] = { [TIER_LFR] = 296395, [TIER_NORMAL] = 296390, [TIER_HEROIC] = 296396, [TIER_MYTHIC] = 296397 },
    [249949] = { [TIER_LFR] = 296407, [TIER_NORMAL] = 296402, [TIER_HEROIC] = 296408, [TIER_MYTHIC] = 296409 },
    [249950] = { [TIER_LFR] = 296419, [TIER_NORMAL] = 296414, [TIER_HEROIC] = 296420, [TIER_MYTHIC] = 296421 },
    [249951] = { [TIER_LFR] = 296431, [TIER_NORMAL] = 296426, [TIER_HEROIC] = 296432, [TIER_MYTHIC] = 296433 },
    [249952] = { [TIER_LFR] = 296443, [TIER_NORMAL] = 296438, [TIER_HEROIC] = 296444, [TIER_MYTHIC] = 296445 },
    [249953] = { [TIER_LFR] = 296455, [TIER_NORMAL] = 296450, [TIER_HEROIC] = 296456, [TIER_MYTHIC] = 296457 },
    [249954] = { [TIER_LFR] = 296467, [TIER_NORMAL] = 296462, [TIER_HEROIC] = 296468, [TIER_MYTHIC] = 296469 },
    [249955] = { [TIER_LFR] = 296479, [TIER_NORMAL] = 296474, [TIER_HEROIC] = 296480, [TIER_MYTHIC] = 296481 },
    [249956] = { [TIER_LFR] = 296491, [TIER_NORMAL] = 296486, [TIER_HEROIC] = 296492, [TIER_MYTHIC] = 296493 },
    [249957] = { [TIER_LFR] = 296503, [TIER_NORMAL] = 296498, [TIER_HEROIC] = 296504, [TIER_MYTHIC] = 296505 },
    [249958] = { [TIER_LFR] = 296515, [TIER_NORMAL] = 296510, [TIER_HEROIC] = 296516, [TIER_MYTHIC] = 296517 },
    [249959] = { [TIER_LFR] = 296527, [TIER_NORMAL] = 296522, [TIER_HEROIC] = 296528, [TIER_MYTHIC] = 296529 },
    [249960] = { [TIER_LFR] = 296539, [TIER_NORMAL] = 296534, [TIER_HEROIC] = 296540, [TIER_MYTHIC] = 296541 },
    [249961] = { [TIER_LFR] = 296551, [TIER_NORMAL] = 296546, [TIER_HEROIC] = 296552, [TIER_MYTHIC] = 296553 },
    [249962] = { [TIER_LFR] = 296563, [TIER_NORMAL] = 296558, [TIER_HEROIC] = 296564, [TIER_MYTHIC] = 296565 },
    [249963] = { [TIER_LFR] = 296575, [TIER_NORMAL] = 296570, [TIER_HEROIC] = 296576, [TIER_MYTHIC] = 296577 },
    [249964] = { [TIER_LFR] = 296587, [TIER_NORMAL] = 296582, [TIER_HEROIC] = 296588, [TIER_MYTHIC] = 296589 },
    [249965] = { [TIER_LFR] = 296599, [TIER_NORMAL] = 296594, [TIER_HEROIC] = 296600, [TIER_MYTHIC] = 296601 },
    [249966] = { [TIER_LFR] = 296611, [TIER_NORMAL] = 296606, [TIER_HEROIC] = 296612, [TIER_MYTHIC] = 296613 },
    [249967] = { [TIER_LFR] = 296623, [TIER_NORMAL] = 296618, [TIER_HEROIC] = 296624, [TIER_MYTHIC] = 296625 },
    [249968] = { [TIER_LFR] = 296635, [TIER_NORMAL] = 296630, [TIER_HEROIC] = 296636, [TIER_MYTHIC] = 296637 },
    [249969] = { [TIER_LFR] = 296647, [TIER_NORMAL] = 296642, [TIER_HEROIC] = 296648, [TIER_MYTHIC] = 296649 },
    [249970] = { [TIER_LFR] = 296659, [TIER_NORMAL] = 296654, [TIER_HEROIC] = 296660, [TIER_MYTHIC] = 296661 },
    [249971] = { [TIER_LFR] = 296671, [TIER_NORMAL] = 296666, [TIER_HEROIC] = 296672, [TIER_MYTHIC] = 296673 },
    [249972] = { [TIER_LFR] = 296683, [TIER_NORMAL] = 296678, [TIER_HEROIC] = 296684, [TIER_MYTHIC] = 296685 },
    [249973] = { [TIER_LFR] = 296695, [TIER_NORMAL] = 296690, [TIER_HEROIC] = 296696, [TIER_MYTHIC] = 296697 },
    [249974] = { [TIER_LFR] = 296707, [TIER_NORMAL] = 296702, [TIER_HEROIC] = 296708, [TIER_MYTHIC] = 296709 },
    [249975] = { [TIER_LFR] = 296719, [TIER_NORMAL] = 296714, [TIER_HEROIC] = 296720, [TIER_MYTHIC] = 296721 },
    [249976] = { [TIER_LFR] = 296731, [TIER_NORMAL] = 296726, [TIER_HEROIC] = 296732, [TIER_MYTHIC] = 296733 },
    [249977] = { [TIER_LFR] = 296743, [TIER_NORMAL] = 296738, [TIER_HEROIC] = 296744, [TIER_MYTHIC] = 296745 },
    [249978] = { [TIER_LFR] = 296752, [TIER_NORMAL] = 296753, [TIER_HEROIC] = 296754, [TIER_MYTHIC] = 296755 },
    [249979] = { [TIER_LFR] = 296767, [TIER_NORMAL] = 296762, [TIER_HEROIC] = 296768, [TIER_MYTHIC] = 296769 },
    [249980] = { [TIER_LFR] = 296779, [TIER_NORMAL] = 296774, [TIER_HEROIC] = 296780, [TIER_MYTHIC] = 296781 },
    [249981] = { [TIER_LFR] = 296791, [TIER_NORMAL] = 296786, [TIER_HEROIC] = 296792, [TIER_MYTHIC] = 296793 },
    [249982] = { [TIER_LFR] = 296800, [TIER_NORMAL] = 296801, [TIER_HEROIC] = 296802, [TIER_MYTHIC] = 296803 },
    [249983] = { [TIER_LFR] = 296815, [TIER_NORMAL] = 296810, [TIER_HEROIC] = 296816, [TIER_MYTHIC] = 296817 },
    [249984] = { [TIER_LFR] = 296827, [TIER_NORMAL] = 296822, [TIER_HEROIC] = 296828, [TIER_MYTHIC] = 296829 },
    [249985] = { [TIER_LFR] = 296839, [TIER_NORMAL] = 296834, [TIER_HEROIC] = 296840, [TIER_MYTHIC] = 296841 },
    [249986] = { [TIER_LFR] = 296851, [TIER_NORMAL] = 296846, [TIER_HEROIC] = 296852, [TIER_MYTHIC] = 296853 },
    [249987] = { [TIER_LFR] = 296863, [TIER_NORMAL] = 296858, [TIER_HEROIC] = 296864, [TIER_MYTHIC] = 296865 },
    [249988] = { [TIER_LFR] = 296875, [TIER_NORMAL] = 296870, [TIER_HEROIC] = 296876, [TIER_MYTHIC] = 296877 },
    [249989] = { [TIER_LFR] = 296887, [TIER_NORMAL] = 296882, [TIER_HEROIC] = 296888, [TIER_MYTHIC] = 296889 },
    [249990] = { [TIER_LFR] = 296899, [TIER_NORMAL] = 296894, [TIER_HEROIC] = 296900, [TIER_MYTHIC] = 296901 },
    [249991] = { [TIER_LFR] = 296911, [TIER_NORMAL] = 296906, [TIER_HEROIC] = 296912, [TIER_MYTHIC] = 296913 },
    [249992] = { [TIER_LFR] = 296923, [TIER_NORMAL] = 296918, [TIER_HEROIC] = 296924, [TIER_MYTHIC] = 296925 },
    [249993] = { [TIER_LFR] = 296935, [TIER_NORMAL] = 296930, [TIER_HEROIC] = 296936, [TIER_MYTHIC] = 296937 },
    [249994] = { [TIER_LFR] = 296947, [TIER_NORMAL] = 296942, [TIER_HEROIC] = 296948, [TIER_MYTHIC] = 296949 },
    [249995] = { [TIER_LFR] = 296959, [TIER_NORMAL] = 296954, [TIER_HEROIC] = 296960, [TIER_MYTHIC] = 296961 },
    [249996] = { [TIER_LFR] = 296971, [TIER_NORMAL] = 296966, [TIER_HEROIC] = 296972, [TIER_MYTHIC] = 296973 },
    [249997] = { [TIER_LFR] = 296983, [TIER_NORMAL] = 296978, [TIER_HEROIC] = 296984, [TIER_MYTHIC] = 296985 },
    [249998] = { [TIER_LFR] = 296995, [TIER_NORMAL] = 296990, [TIER_HEROIC] = 296996, [TIER_MYTHIC] = 296997 },
    [249999] = { [TIER_LFR] = 297007, [TIER_NORMAL] = 297002, [TIER_HEROIC] = 297008, [TIER_MYTHIC] = 297009 },
    [250000] = { [TIER_LFR] = 297019, [TIER_NORMAL] = 297014, [TIER_HEROIC] = 297020, [TIER_MYTHIC] = 297021 },
    [250001] = { [TIER_LFR] = 297031, [TIER_NORMAL] = 297026, [TIER_HEROIC] = 297032, [TIER_MYTHIC] = 297033 },
    [250002] = { [TIER_LFR] = 297043, [TIER_NORMAL] = 297038, [TIER_HEROIC] = 297044, [TIER_MYTHIC] = 297045 },
    [250003] = { [TIER_LFR] = 297055, [TIER_NORMAL] = 297050, [TIER_HEROIC] = 297056, [TIER_MYTHIC] = 297057 },
    [250004] = { [TIER_LFR] = 297067, [TIER_NORMAL] = 297062, [TIER_HEROIC] = 297068, [TIER_MYTHIC] = 297069 },
    [250005] = { [TIER_LFR] = 297079, [TIER_NORMAL] = 297074, [TIER_HEROIC] = 297080, [TIER_MYTHIC] = 297081 },
    [250006] = { [TIER_LFR] = 297091, [TIER_NORMAL] = 297086, [TIER_HEROIC] = 297092, [TIER_MYTHIC] = 297093 },
    [250007] = { [TIER_LFR] = 297103, [TIER_NORMAL] = 297098, [TIER_HEROIC] = 297104, [TIER_MYTHIC] = 297105 },
    [250008] = { [TIER_LFR] = 297115, [TIER_NORMAL] = 297110, [TIER_HEROIC] = 297116, [TIER_MYTHIC] = 297117 },
    [250009] = { [TIER_LFR] = 297127, [TIER_NORMAL] = 297122, [TIER_HEROIC] = 297128, [TIER_MYTHIC] = 297129 },
    [250010] = { [TIER_LFR] = 297139, [TIER_NORMAL] = 297134, [TIER_HEROIC] = 297140, [TIER_MYTHIC] = 297141 },
    [250011] = { [TIER_LFR] = 297151, [TIER_NORMAL] = 297146, [TIER_HEROIC] = 297152, [TIER_MYTHIC] = 297153 },
    [250012] = { [TIER_LFR] = 297163, [TIER_NORMAL] = 297158, [TIER_HEROIC] = 297164, [TIER_MYTHIC] = 297165 },
    [250013] = { [TIER_LFR] = 297175, [TIER_NORMAL] = 297170, [TIER_HEROIC] = 297176, [TIER_MYTHIC] = 297177 },
    [250014] = { [TIER_LFR] = 297187, [TIER_NORMAL] = 297182, [TIER_HEROIC] = 297188, [TIER_MYTHIC] = 297189 },
    [250015] = { [TIER_LFR] = 297199, [TIER_NORMAL] = 297194, [TIER_HEROIC] = 297200, [TIER_MYTHIC] = 297201 },
    [250016] = { [TIER_LFR] = 297211, [TIER_NORMAL] = 297206, [TIER_HEROIC] = 297212, [TIER_MYTHIC] = 297213 },
    [250017] = { [TIER_LFR] = 297223, [TIER_NORMAL] = 297218, [TIER_HEROIC] = 297224, [TIER_MYTHIC] = 297225 },
    [250018] = { [TIER_LFR] = 297235, [TIER_NORMAL] = 297230, [TIER_HEROIC] = 297236, [TIER_MYTHIC] = 297237 },
    [250019] = { [TIER_LFR] = 297247, [TIER_NORMAL] = 297242, [TIER_HEROIC] = 297248, [TIER_MYTHIC] = 297249 },
    [250020] = { [TIER_LFR] = 297259, [TIER_NORMAL] = 297254, [TIER_HEROIC] = 297260, [TIER_MYTHIC] = 297261 },
    [250021] = { [TIER_LFR] = 297271, [TIER_NORMAL] = 297266, [TIER_HEROIC] = 297272, [TIER_MYTHIC] = 297273 },
    [250022] = { [TIER_LFR] = 297283, [TIER_NORMAL] = 297278, [TIER_HEROIC] = 297284, [TIER_MYTHIC] = 297285 },
    [250023] = { [TIER_LFR] = 297295, [TIER_NORMAL] = 297290, [TIER_HEROIC] = 297296, [TIER_MYTHIC] = 297297 },
    [250024] = { [TIER_LFR] = 297307, [TIER_NORMAL] = 297302, [TIER_HEROIC] = 297308, [TIER_MYTHIC] = 297309 },
    [250025] = { [TIER_LFR] = 297319, [TIER_NORMAL] = 297314, [TIER_HEROIC] = 297320, [TIER_MYTHIC] = 297321 },
    [250026] = { [TIER_LFR] = 297331, [TIER_NORMAL] = 297326, [TIER_HEROIC] = 297332, [TIER_MYTHIC] = 297333 },
    [250027] = { [TIER_LFR] = 297343, [TIER_NORMAL] = 297338, [TIER_HEROIC] = 297344, [TIER_MYTHIC] = 297345 },
    [250028] = { [TIER_LFR] = 297355, [TIER_NORMAL] = 297350, [TIER_HEROIC] = 297356, [TIER_MYTHIC] = 297357 },
    [250029] = { [TIER_LFR] = 297367, [TIER_NORMAL] = 297362, [TIER_HEROIC] = 297368, [TIER_MYTHIC] = 297369 },
    [250030] = { [TIER_LFR] = 297379, [TIER_NORMAL] = 297374, [TIER_HEROIC] = 297380, [TIER_MYTHIC] = 297381 },
    [250031] = { [TIER_LFR] = 297391, [TIER_NORMAL] = 297386, [TIER_HEROIC] = 297392, [TIER_MYTHIC] = 297393 },
    [250032] = { [TIER_LFR] = 297403, [TIER_NORMAL] = 297398, [TIER_HEROIC] = 297404, [TIER_MYTHIC] = 297405 },
    [250033] = { [TIER_LFR] = 297415, [TIER_NORMAL] = 297410, [TIER_HEROIC] = 297416, [TIER_MYTHIC] = 297417 },
    [250034] = { [TIER_LFR] = 297427, [TIER_NORMAL] = 297422, [TIER_HEROIC] = 297428, [TIER_MYTHIC] = 297429 },
    [250035] = { [TIER_LFR] = 297439, [TIER_NORMAL] = 297434, [TIER_HEROIC] = 297440, [TIER_MYTHIC] = 297441 },
    [250036] = { [TIER_LFR] = 297451, [TIER_NORMAL] = 297446, [TIER_HEROIC] = 297452, [TIER_MYTHIC] = 297453 },
    [250037] = { [TIER_LFR] = 297463, [TIER_NORMAL] = 297458, [TIER_HEROIC] = 297464, [TIER_MYTHIC] = 297465 },
    [250038] = { [TIER_LFR] = 297475, [TIER_NORMAL] = 297470, [TIER_HEROIC] = 297476, [TIER_MYTHIC] = 297477 },
    [250039] = { [TIER_LFR] = 297487, [TIER_NORMAL] = 297482, [TIER_HEROIC] = 297488, [TIER_MYTHIC] = 297489 },
    [250040] = { [TIER_LFR] = 297499, [TIER_NORMAL] = 297494, [TIER_HEROIC] = 297500, [TIER_MYTHIC] = 297501 },
    [250041] = { [TIER_LFR] = 297511, [TIER_NORMAL] = 297506, [TIER_HEROIC] = 297512, [TIER_MYTHIC] = 297513 },
    [250042] = { [TIER_LFR] = 297523, [TIER_NORMAL] = 297518, [TIER_HEROIC] = 297524, [TIER_MYTHIC] = 297525 },
    [250043] = { [TIER_LFR] = 297535, [TIER_NORMAL] = 297530, [TIER_HEROIC] = 297536, [TIER_MYTHIC] = 297537 },
    [250044] = { [TIER_LFR] = 297547, [TIER_NORMAL] = 297542, [TIER_HEROIC] = 297548, [TIER_MYTHIC] = 297549 },
    [250045] = { [TIER_LFR] = 297559, [TIER_NORMAL] = 297554, [TIER_HEROIC] = 297560, [TIER_MYTHIC] = 297561 },
    [250046] = { [TIER_LFR] = 297571, [TIER_NORMAL] = 297566, [TIER_HEROIC] = 297572, [TIER_MYTHIC] = 297573 },
    [250047] = { [TIER_LFR] = 297583, [TIER_NORMAL] = 297578, [TIER_HEROIC] = 297584, [TIER_MYTHIC] = 297585 },
    [250048] = { [TIER_LFR] = 297595, [TIER_NORMAL] = 297590, [TIER_HEROIC] = 297596, [TIER_MYTHIC] = 297597 },
    [250049] = { [TIER_LFR] = 297607, [TIER_NORMAL] = 297602, [TIER_HEROIC] = 297608, [TIER_MYTHIC] = 297609 },
    [250050] = { [TIER_LFR] = 297619, [TIER_NORMAL] = 297614, [TIER_HEROIC] = 297620, [TIER_MYTHIC] = 297621 },
    [250051] = { [TIER_LFR] = 297631, [TIER_NORMAL] = 297626, [TIER_HEROIC] = 297632, [TIER_MYTHIC] = 297633 },
    [250052] = { [TIER_LFR] = 297643, [TIER_NORMAL] = 297638, [TIER_HEROIC] = 297644, [TIER_MYTHIC] = 297645 },
    [250053] = { [TIER_LFR] = 297655, [TIER_NORMAL] = 297650, [TIER_HEROIC] = 297656, [TIER_MYTHIC] = 297657 },
    [250054] = { [TIER_LFR] = 297667, [TIER_NORMAL] = 297662, [TIER_HEROIC] = 297668, [TIER_MYTHIC] = 297669 },
    [250055] = { [TIER_LFR] = 297679, [TIER_NORMAL] = 297674, [TIER_HEROIC] = 297680, [TIER_MYTHIC] = 297681 },
    [250056] = { [TIER_LFR] = 297691, [TIER_NORMAL] = 297686, [TIER_HEROIC] = 297692, [TIER_MYTHIC] = 297693 },
    [250057] = { [TIER_LFR] = 297703, [TIER_NORMAL] = 297698, [TIER_HEROIC] = 297704, [TIER_MYTHIC] = 297705 },
    [250058] = { [TIER_LFR] = 297715, [TIER_NORMAL] = 297710, [TIER_HEROIC] = 297716, [TIER_MYTHIC] = 297717 },
    [250059] = { [TIER_LFR] = 297727, [TIER_NORMAL] = 297722, [TIER_HEROIC] = 297728, [TIER_MYTHIC] = 297729 },
    [250060] = { [TIER_LFR] = 297739, [TIER_NORMAL] = 297734, [TIER_HEROIC] = 297740, [TIER_MYTHIC] = 297741 },
    [250061] = { [TIER_LFR] = 297751, [TIER_NORMAL] = 297746, [TIER_HEROIC] = 297752, [TIER_MYTHIC] = 297753 },
    [250062] = { [TIER_LFR] = 297763, [TIER_NORMAL] = 297758, [TIER_HEROIC] = 297764, [TIER_MYTHIC] = 297765 },
    [250063] = { [TIER_LFR] = 297775, [TIER_NORMAL] = 297770, [TIER_HEROIC] = 297776, [TIER_MYTHIC] = 297777 },
};

--- @type table<number, TUM_Season> # [bonusID] = m+ seasonID
data.catalystBonusIDMap = {
    [8118] = SL_S4, [8131] = SL_S4, [8132] = SL_S4, [8133] = SL_S4, [8136] = SL_S4,
    [8821] = DF_S1, [8822] = DF_S1, [8823] = DF_S1, [8824] = DF_S1, [8825] = DF_S1,
    [9222] = DF_S2, [9223] = DF_S2, [9224] = DF_S2, [9225] = DF_S2, [9226] = DF_S2,
    [9505] = DF_S3, [9506] = DF_S3, [9507] = DF_S3, [9508] = DF_S3, [9509] = DF_S3,
    [10870] = DF_S4, [10871] = DF_S4, [10872] = DF_S4, [10873] = DF_S4, [10874] = DF_S4,
    [10376] = TWW_S1, [10377] = TWW_S1, [10378] = TWW_S1, [10379] = TWW_S1, [10380] = TWW_S1,
    [11964] = TWW_S2, [11965] = TWW_S2, [11966] = TWW_S2, [11967] = TWW_S2, [11998] = TWW_S2,
    [12239] = TWW_S3, [12240] = TWW_S3, [12241] = TWW_S3, [12242] = TWW_S3, [12243] = TWW_S3,
    [13577] = MN_S1, -- @todo add rest when available
};

--- @type table<TUM_Season, table<number, table<Enum.InventoryType, number>>> # [m+ seasonID][classID][slotID] = itemID
data.catalystItems = {
    [SL_S4] = {
        [WARRIOR] = { [HEAD] = 188942, [SHOULDER] = 188941, [CHEST] = 188938, [WAIST] = 188944, [LEGS] = 188940, [FEET] = 188939, [WRIST] = 188943, [HAND] = 188937, [CLOAK] = 188945 },
        [PALADIN] = { [HEAD] = 188933, [SHOULDER] = 188932, [CHEST] = 188929, [WAIST] = 188935, [LEGS] = 188931, [FEET] = 188930, [WRIST] = 188934, [HAND] = 188928, [CLOAK] = 188936 },
        [HUNTER] = { [HEAD] = 188859, [SHOULDER] = 188856, [CHEST] = 188858, [WAIST] = 188857, [LEGS] = 188860, [FEET] = 188862, [WRIST] = 188855, [HAND] = 188861, [CLOAK] = 188872 },
        [ROGUE] = { [HEAD] = 188901, [SHOULDER] = 188905, [CHEST] = 188903, [WAIST] = 188906, [LEGS] = 188902, [FEET] = 188908, [WRIST] = 188904, [HAND] = 188907, [CLOAK] = 188909 },
        [PRIEST] = { [HEAD] = 188880, [SHOULDER] = 188879, [CHEST] = 188875, [WAIST] = 188877, [LEGS] = 188878, [FEET] = 188874, [WRIST] = 188876, [HAND] = 188881, [CLOAK] = 188882 },
        [DEATHKNIGHT] = { [HEAD] = 188868, [SHOULDER] = 188867, [CHEST] = 188864, [WAIST] = 188870, [LEGS] = 188866, [FEET] = 188865, [WRIST] = 188869, [HAND] = 188863, [CLOAK] = 188873 },
        [SHAMAN] = { [HEAD] = 188923, [SHOULDER] = 188920, [CHEST] = 188922, [WAIST] = 188921, [LEGS] = 188924, [FEET] = 188926, [WRIST] = 188919, [HAND] = 188925, [CLOAK] = 188927 },
        [MAGE] = { [HEAD] = 188844, [SHOULDER] = 188843, [CHEST] = 188839, [WAIST] = 188841, [LEGS] = 188842, [FEET] = 188838, [WRIST] = 188840, [HAND] = 188845, [CLOAK] = 188846 },
        [WARLOCK] = { [HEAD] = 188889, [SHOULDER] = 188888, [CHEST] = 188884, [WAIST] = 188886, [LEGS] = 188887, [FEET] = 188883, [WRIST] = 188885, [HAND] = 188890, [CLOAK] = 188891 },
        [MONK] = { [HEAD] = 188910, [SHOULDER] = 188914, [CHEST] = 188912, [WAIST] = 188915, [LEGS] = 188911, [FEET] = 188917, [WRIST] = 188913, [HAND] = 188916, [CLOAK] = 188918 },
        [DRUID] = { [HEAD] = 188847, [SHOULDER] = 188851, [CHEST] = 188849, [WAIST] = 188852, [LEGS] = 188848, [FEET] = 188854, [WRIST] = 188850, [HAND] = 188853, [CLOAK] = 188871 },
        [DEMONHUNTER] = { [HEAD] = 188892, [SHOULDER] = 188896, [CHEST] = 188894, [WAIST] = 188897, [LEGS] = 188893, [FEET] = 188899, [WRIST] = 188895, [HAND] = 188898, [CLOAK] = 188900 },
    },
    [DF_S1] = {
        [WARRIOR] = { [HEAD] = 200426, [SHOULDER] = 200428, [CHEST] = 200423, [WAIST] = 200429, [LEGS] = 200427, [FEET] = 200424, [WRIST] = 200430, [HAND] = 200425, [CLOAK] = 200431 },
        [PALADIN] = { [HEAD] = 200417, [SHOULDER] = 200419, [CHEST] = 200414, [WAIST] = 200420, [LEGS] = 200418, [FEET] = 200415, [WRIST] = 200421, [HAND] = 200416, [CLOAK] = 200422 },
        [HUNTER] = { [HEAD] = 200390, [SHOULDER] = 200392, [CHEST] = 200387, [WAIST] = 200393, [LEGS] = 200391, [FEET] = 200388, [WRIST] = 200394, [HAND] = 200389, [CLOAK] = 200395 },
        [ROGUE] = { [HEAD] = 200372, [SHOULDER] = 200374, [CHEST] = 200369, [WAIST] = 200375, [LEGS] = 200373, [FEET] = 200370, [WRIST] = 200376, [HAND] = 200371, [CLOAK] = 200377 },
        [PRIEST] = { [HEAD] = 200327, [SHOULDER] = 200329, [CHEST] = 200324, [WAIST] = 200330, [LEGS] = 200328, [FEET] = 200325, [WRIST] = 200331, [HAND] = 200326, [CLOAK] = 200332 },
        [DEATHKNIGHT] = { [HEAD] = 200408, [SHOULDER] = 200410, [CHEST] = 200405, [WAIST] = 200411, [LEGS] = 200409, [FEET] = 200406, [WRIST] = 200412, [HAND] = 200407, [CLOAK] = 200413 },
        [SHAMAN] = { [HEAD] = 200399, [SHOULDER] = 200401, [CHEST] = 200396, [WAIST] = 200402, [LEGS] = 200400, [FEET] = 200397, [WRIST] = 200403, [HAND] = 200398, [CLOAK] = 200404 },
        [MAGE] = { [HEAD] = 200318, [SHOULDER] = 200320, [CHEST] = 200315, [WAIST] = 200321, [LEGS] = 200319, [FEET] = 200316, [WRIST] = 200322, [HAND] = 200317, [CLOAK] = 200323 },
        [WARLOCK] = { [HEAD] = 200336, [SHOULDER] = 200338, [CHEST] = 200333, [WAIST] = 200339, [LEGS] = 200337, [FEET] = 200334, [WRIST] = 200340, [HAND] = 200335, [CLOAK] = 200341 },
        [MONK] = { [HEAD] = 200363, [SHOULDER] = 200365, [CHEST] = 200360, [WAIST] = 200366, [LEGS] = 200364, [FEET] = 200361, [WRIST] = 200367, [HAND] = 200362, [CLOAK] = 200368 },
        [DRUID] = { [HEAD] = 200354, [SHOULDER] = 200356, [CHEST] = 200351, [WAIST] = 200357, [LEGS] = 200355, [FEET] = 200352, [WRIST] = 200358, [HAND] = 200353, [CLOAK] = 200359 },
        [DEMONHUNTER] = { [HEAD] = 200345, [SHOULDER] = 200347, [CHEST] = 200342, [WAIST] = 200348, [LEGS] = 200346, [FEET] = 200343, [WRIST] = 200349, [HAND] = 200344, [CLOAK] = 200350 },
        [EVOKER] = { [HEAD] = 200381, [SHOULDER] = 200383, [CHEST] = 200378, [WAIST] = 200384, [LEGS] = 200382, [FEET] = 200379, [WRIST] = 200385, [HAND] = 200380, [CLOAK] = 200386 },
    },
    [DF_S2] = {
        [WARRIOR] = { [HEAD] = 202443, [SHOULDER] = 202441, [CHEST] = 202446, [WAIST] = 202440, [LEGS] = 202442, [FEET] = 202445, [WRIST] = 202439, [HAND] = 202444, [CLOAK] = 202438 },
        [PALADIN] = { [HEAD] = 202452, [SHOULDER] = 202450, [CHEST] = 202455, [WAIST] = 202449, [LEGS] = 202451, [FEET] = 202454, [WRIST] = 202448, [HAND] = 202453, [CLOAK] = 202447 },
        [HUNTER] = { [HEAD] = 202479, [SHOULDER] = 202477, [CHEST] = 202482, [WAIST] = 202476, [LEGS] = 202478, [FEET] = 202481, [WRIST] = 202475, [HAND] = 202480, [CLOAK] = 202474 },
        [ROGUE] = { [HEAD] = 202497, [SHOULDER] = 202495, [CHEST] = 202500, [WAIST] = 202494, [LEGS] = 202496, [FEET] = 202499, [WRIST] = 202493, [HAND] = 202498, [CLOAK] = 202492 },
        [PRIEST] = { [HEAD] = 202542, [SHOULDER] = 202540, [CHEST] = 202545, [WAIST] = 202539, [LEGS] = 202541, [FEET] = 202544, [WRIST] = 202538, [HAND] = 202543, [CLOAK] = 202537 },
        [DEATHKNIGHT] = { [HEAD] = 202461, [SHOULDER] = 202459, [CHEST] = 202464, [WAIST] = 202458, [LEGS] = 202460, [FEET] = 202463, [WRIST] = 202457, [HAND] = 202462, [CLOAK] = 202456 },
        [SHAMAN] = { [HEAD] = 202470, [SHOULDER] = 202468, [CHEST] = 202473, [WAIST] = 202467, [LEGS] = 202469, [FEET] = 202472, [WRIST] = 202466, [HAND] = 202471, [CLOAK] = 202465 },
        [MAGE] = { [HEAD] = 202551, [SHOULDER] = 202549, [CHEST] = 202554, [WAIST] = 202548, [LEGS] = 202550, [FEET] = 202553, [WRIST] = 202547, [HAND] = 202552, [CLOAK] = 202546 },
        [WARLOCK] = { [HEAD] = 202533, [SHOULDER] = 202531, [CHEST] = 202536, [WAIST] = 202530, [LEGS] = 202532, [FEET] = 202535, [WRIST] = 202529, [HAND] = 202534, [CLOAK] = 202528 },
        [MONK] = { [HEAD] = 202506, [SHOULDER] = 202504, [CHEST] = 202509, [WAIST] = 202503, [LEGS] = 202505, [FEET] = 202508, [WRIST] = 202502, [HAND] = 202507, [CLOAK] = 202501 },
        [DRUID] = { [HEAD] = 202515, [SHOULDER] = 202513, [CHEST] = 202518, [WAIST] = 202512, [LEGS] = 202514, [FEET] = 202517, [WRIST] = 202511, [HAND] = 202516, [CLOAK] = 202510 },
        [DEMONHUNTER] = { [HEAD] = 202524, [SHOULDER] = 202522, [CHEST] = 202527, [WAIST] = 202521, [LEGS] = 202523, [FEET] = 202526, [WRIST] = 202520, [HAND] = 202525, [CLOAK] = 202519 },
        [EVOKER] = { [HEAD] = 202488, [SHOULDER] = 202486, [CHEST] = 202491, [WAIST] = 202485, [LEGS] = 202487, [FEET] = 202490, [WRIST] = 202484, [HAND] = 202489, [CLOAK] = 202483 },
    },
    [DF_S3] = {
        [WARRIOR] = { [HEAD] = 207182, [SHOULDER] = 207180, [CHEST] = 207185, [WAIST] = 207179, [LEGS] = 207181, [FEET] = 207184, [WRIST] = 207177, [HAND] = 207183, [CLOAK] = 207176 },
        [PALADIN] = { [HEAD] = 207191, [SHOULDER] = 207189, [CHEST] = 207194, [WAIST] = 207188, [LEGS] = 207190, [FEET] = 207193, [WRIST] = 207187, [HAND] = 207192, [CLOAK] = 207186 },
        [HUNTER] = { [HEAD] = 207218, [SHOULDER] = 207216, [CHEST] = 207221, [WAIST] = 207215, [LEGS] = 207217, [FEET] = 207220, [WRIST] = 207214, [HAND] = 207219, [CLOAK] = 207213 },
        [ROGUE] = { [HEAD] = 207236, [SHOULDER] = 207234, [CHEST] = 207239, [WAIST] = 207233, [LEGS] = 207235, [FEET] = 207238, [WRIST] = 207232, [HAND] = 207237, [CLOAK] = 207231 },
        [PRIEST] = { [HEAD] = 207281, [SHOULDER] = 207279, [CHEST] = 207284, [WAIST] = 207278, [LEGS] = 207280, [FEET] = 207283, [WRIST] = 207277, [HAND] = 207282, [CLOAK] = 207276 },
        [DEATHKNIGHT] = { [HEAD] = 207200, [SHOULDER] = 207198, [CHEST] = 207203, [WAIST] = 207197, [LEGS] = 207199, [FEET] = 207202, [WRIST] = 207196, [HAND] = 207201, [CLOAK] = 207195 },
        [SHAMAN] = { [HEAD] = 207209, [SHOULDER] = 207207, [CHEST] = 207212, [WAIST] = 207206, [LEGS] = 207208, [FEET] = 207211, [WRIST] = 207205, [HAND] = 207210, [CLOAK] = 207204 },
        [MAGE] = { [HEAD] = 207290, [SHOULDER] = 207288, [CHEST] = 207293, [WAIST] = 207287, [LEGS] = 207289, [FEET] = 207292, [WRIST] = 207286, [HAND] = 207291, [CLOAK] = 207285 },
        [WARLOCK] = { [HEAD] = 207272, [SHOULDER] = 207270, [CHEST] = 207275, [WAIST] = 207269, [LEGS] = 207271, [FEET] = 207274, [WRIST] = 207268, [HAND] = 207273, [CLOAK] = 207267 },
        [MONK] = { [HEAD] = 207245, [SHOULDER] = 207243, [CHEST] = 207248, [WAIST] = 207242, [LEGS] = 207244, [FEET] = 207247, [WRIST] = 207241, [HAND] = 207246, [CLOAK] = 207240 },
        [DRUID] = { [HEAD] = 207254, [SHOULDER] = 207252, [CHEST] = 207257, [WAIST] = 207251, [LEGS] = 207253, [FEET] = 207256, [WRIST] = 207250, [HAND] = 207255, [CLOAK] = 207249 },
        [DEMONHUNTER] = { [HEAD] = 207263, [SHOULDER] = 207261, [CHEST] = 207266, [WAIST] = 207260, [LEGS] = 207262, [FEET] = 207265, [WRIST] = 207259, [HAND] = 207264, [CLOAK] = 207258 },
        [EVOKER] = { [HEAD] = 207227, [SHOULDER] = 207225, [CHEST] = 207230, [WAIST] = 207224, [LEGS] = 207226, [FEET] = 207229, [WRIST] = 207223, [HAND] = 207228, [CLOAK] = 207222 },
    },
    [DF_S4] = {
        [WARRIOR] = { [HEAD] = 217218, [SHOULDER] = 217220, [CHEST] = 217216, [WAIST] = 202440, [LEGS] = 217219, [FEET] = 202445, [WRIST] = 202439, [HAND] = 217217, [CLOAK] = 202438 },
        [PALADIN] = { [HEAD] = 217198, [SHOULDER] = 217200, [CHEST] = 217196, [WAIST] = 202449, [LEGS] = 217199, [FEET] = 202454, [WRIST] = 202448, [HAND] = 217197, [CLOAK] = 202447 },
        [HUNTER] = { [HEAD] = 217183, [SHOULDER] = 217185, [CHEST] = 217181, [WAIST] = 200393, [LEGS] = 217184, [FEET] = 200388, [WRIST] = 200394, [HAND] = 217182, [CLOAK] = 200395 },
        [ROGUE] = { [HEAD] = 217208, [SHOULDER] = 217210, [CHEST] = 217206, [WAIST] = 202494, [LEGS] = 217209, [FEET] = 202499, [WRIST] = 202493, [HAND] = 217207, [CLOAK] = 202492 },
        [PRIEST] = { [HEAD] = 217202, [SHOULDER] = 217204, [CHEST] = 217205, [WAIST] = 202539, [LEGS] = 217203, [FEET] = 202544, [WRIST] = 202538, [HAND] = 217201, [CLOAK] = 202537 },
        [DEATHKNIGHT] = { [HEAD] = 217223, [SHOULDER] = 217225, [CHEST] = 217221, [WAIST] = 207197, [LEGS] = 217224, [FEET] = 207202, [WRIST] = 207196, [HAND] = 217222, [CLOAK] = 207195 },
        [SHAMAN] = { [HEAD] = 217238, [SHOULDER] = 217240, [CHEST] = 217236, [WAIST] = 207206, [LEGS] = 217239, [FEET] = 207211, [WRIST] = 207205, [HAND] = 217237, [CLOAK] = 207204 },
        [MAGE] = { [HEAD] = 217232, [SHOULDER] = 217234, [CHEST] = 217235, [WAIST] = 207287, [LEGS] = 217233, [FEET] = 207292, [WRIST] = 207286, [HAND] = 217231, [CLOAK] = 207285 },
        [WARLOCK] = { [HEAD] = 217212, [SHOULDER] = 217214, [CHEST] = 217215, [WAIST] = 202530, [LEGS] = 217213, [FEET] = 202535, [WRIST] = 202529, [HAND] = 217211, [CLOAK] = 202528 },
        [MONK] = { [HEAD] = 217188, [SHOULDER] = 217190, [CHEST] = 217186, [WAIST] = 200366, [LEGS] = 217189, [FEET] = 200361, [WRIST] = 200367, [HAND] = 217187, [CLOAK] = 200368 },
        [DRUID] = { [HEAD] = 217193, [SHOULDER] = 217195, [CHEST] = 217191, [WAIST] = 202512, [LEGS] = 217194, [FEET] = 202517, [WRIST] = 202511, [HAND] = 217192, [CLOAK] = 202510 },
        [DEMONHUNTER] = { [HEAD] = 217228, [SHOULDER] = 217230, [CHEST] = 217226, [WAIST] = 207260, [LEGS] = 217229, [FEET] = 207265, [WRIST] = 207259, [HAND] = 217227, [CLOAK] = 207258 },
        [EVOKER] = { [HEAD] = 217178, [SHOULDER] = 217180, [CHEST] = 217176, [WAIST] = 200384, [LEGS] = 217179, [FEET] = 200379, [WRIST] = 200385, [HAND] = 217177, [CLOAK] = 200386 },
    },
    [TWW_S1] = {
        [WARRIOR] = { [HEAD] = 211984, [SHOULDER] = 211982, [CHEST] = 211987, [WAIST] = 211981, [LEGS] = 211983, [FEET] = 211986, [WRIST] = 211980, [HAND] = 211985, [CLOAK] = 211979 },
        [PALADIN] = { [HEAD] = 211993, [SHOULDER] = 211991, [CHEST] = 211996, [WAIST] = 211990, [LEGS] = 211992, [FEET] = 211995, [WRIST] = 211989, [HAND] = 211994, [CLOAK] = 211988 },
        [HUNTER] = { [HEAD] = 212020, [SHOULDER] = 212018, [CHEST] = 212023, [WAIST] = 212017, [LEGS] = 212019, [FEET] = 212022, [WRIST] = 212016, [HAND] = 212021, [CLOAK] = 212015 },
        [ROGUE] = { [HEAD] = 212038, [SHOULDER] = 212036, [CHEST] = 212041, [WAIST] = 212035, [LEGS] = 212037, [FEET] = 212040, [WRIST] = 212034, [HAND] = 212039, [CLOAK] = 212033 },
        [PRIEST] = { [HEAD] = 212083, [SHOULDER] = 212081, [CHEST] = 212086, [WAIST] = 212080, [LEGS] = 212082, [FEET] = 212085, [WRIST] = 212079, [HAND] = 212084, [CLOAK] = 212078 },
        [DEATHKNIGHT] = { [HEAD] = 212002, [SHOULDER] = 212000, [CHEST] = 212005, [WAIST] = 211999, [LEGS] = 212001, [FEET] = 212004, [WRIST] = 211998, [HAND] = 212003, [CLOAK] = 211997 },
        [SHAMAN] = { [HEAD] = 212011, [SHOULDER] = 212009, [CHEST] = 212014, [WAIST] = 212008, [LEGS] = 212010, [FEET] = 212013, [WRIST] = 212007, [HAND] = 212012, [CLOAK] = 212006 },
        [MAGE] = { [HEAD] = 212092, [SHOULDER] = 212090, [CHEST] = 212095, [WAIST] = 212089, [LEGS] = 212091, [FEET] = 212094, [WRIST] = 212088, [HAND] = 212093, [CLOAK] = 212087 },
        [WARLOCK] = { [HEAD] = 212074, [SHOULDER] = 212072, [CHEST] = 212077, [WAIST] = 212071, [LEGS] = 212073, [FEET] = 212076, [WRIST] = 212070, [HAND] = 212075, [CLOAK] = 212069 },
        [MONK] = { [HEAD] = 212047, [SHOULDER] = 212045, [CHEST] = 212050, [WAIST] = 212044, [LEGS] = 212046, [FEET] = 212049, [WRIST] = 212043, [HAND] = 212048, [CLOAK] = 212042 },
        [DRUID] = { [HEAD] = 212056, [SHOULDER] = 212054, [CHEST] = 212059, [WAIST] = 212053, [LEGS] = 212055, [FEET] = 212058, [WRIST] = 212052, [HAND] = 212057, [CLOAK] = 212051 },
        [DEMONHUNTER] = { [HEAD] = 212065, [SHOULDER] = 212063, [CHEST] = 212068, [WAIST] = 212062, [LEGS] = 212064, [FEET] = 212067, [WRIST] = 212061, [HAND] = 212066, [CLOAK] = 212060 },
        [EVOKER] = { [HEAD] = 212029, [SHOULDER] = 212027, [CHEST] = 212032, [WAIST] = 212026, [LEGS] = 212028, [FEET] = 212031, [WRIST] = 212025, [HAND] = 212030, [CLOAK] = 212024 },
    },
    [TWW_S2] = {
        [WARRIOR] = { [HEAD] = 229235, [SHOULDER] = 229233, [CHEST] = 229238, [WAIST] = 229232, [LEGS] = 229234, [FEET] = 229237, [WRIST] = 229231, [HAND] = 229236, [CLOAK] = 229230 },
        [PALADIN] = { [HEAD] = 229244, [SHOULDER] = 229242, [CHEST] = 229247, [WAIST] = 229241, [LEGS] = 229243, [FEET] = 229246, [WRIST] = 229240, [HAND] = 229245, [CLOAK] = 229239 },
        [HUNTER] = { [HEAD] = 229271, [SHOULDER] = 229269, [CHEST] = 229274, [WAIST] = 229268, [LEGS] = 229270, [FEET] = 229273, [WRIST] = 229267, [HAND] = 229272, [CLOAK] = 229266 },
        [ROGUE] = { [HEAD] = 229289, [SHOULDER] = 229287, [CHEST] = 229292, [WAIST] = 229286, [LEGS] = 229288, [FEET] = 229291, [WRIST] = 229285, [HAND] = 229290, [CLOAK] = 229284 },
        [PRIEST] = { [HEAD] = 229334, [SHOULDER] = 229332, [CHEST] = 229337, [WAIST] = 229331, [LEGS] = 229333, [FEET] = 229336, [WRIST] = 229330, [HAND] = 229335, [CLOAK] = 229329 },
        [DEATHKNIGHT] = { [HEAD] = 229253, [SHOULDER] = 229251, [CHEST] = 229256, [WAIST] = 229250, [LEGS] = 229252, [FEET] = 229255, [WRIST] = 229249, [HAND] = 229254, [CLOAK] = 229248 },
        [SHAMAN] = { [HEAD] = 229262, [SHOULDER] = 229260, [CHEST] = 229265, [WAIST] = 229259, [LEGS] = 229261, [FEET] = 229264, [WRIST] = 229258, [HAND] = 229263, [CLOAK] = 229257 },
        [MAGE] = { [HEAD] = 229343, [SHOULDER] = 229341, [CHEST] = 229346, [WAIST] = 229340, [LEGS] = 229342, [FEET] = 229345, [WRIST] = 229339, [HAND] = 229344, [CLOAK] = 229338 },
        [WARLOCK] = { [HEAD] = 229325, [SHOULDER] = 229323, [CHEST] = 229328, [WAIST] = 229322, [LEGS] = 229324, [FEET] = 229327, [WRIST] = 229321, [HAND] = 229326, [CLOAK] = 229320 },
        [MONK] = { [HEAD] = 229298, [SHOULDER] = 229296, [CHEST] = 229301, [WAIST] = 229295, [LEGS] = 229297, [FEET] = 229300, [WRIST] = 229294, [HAND] = 229299, [CLOAK] = 229293 },
        [DRUID] = { [HEAD] = 229307, [SHOULDER] = 229305, [CHEST] = 229310, [WAIST] = 229304, [LEGS] = 229306, [FEET] = 229309, [WRIST] = 229303, [HAND] = 229308, [CLOAK] = 229302 },
        [DEMONHUNTER] = { [HEAD] = 229316, [SHOULDER] = 229314, [CHEST] = 229319, [WAIST] = 229313, [LEGS] = 229315, [FEET] = 229318, [WRIST] = 229312, [HAND] = 229317, [CLOAK] = 229311 },
        [EVOKER] = { [HEAD] = 229280, [SHOULDER] = 229278, [CHEST] = 229283, [WAIST] = 229277, [LEGS] = 229279, [FEET] = 229282, [WRIST] = 229276, [HAND] = 229281, [CLOAK] = 229275 },
    },
    [TWW_S3] = {
        [WARRIOR] = { [HEAD] = 237610, [SHOULDER] = 237608, [CHEST] = 237613, [WAIST] = 237607, [LEGS] = 237609, [FEET] = 237612, [WRIST] = 237606, [HAND] = 237611, [CLOAK] = 237605 },
        [PALADIN] = { [HEAD] = 237619, [SHOULDER] = 237617, [CHEST] = 237622, [WAIST] = 237616, [LEGS] = 237618, [FEET] = 237621, [WRIST] = 237615, [HAND] = 237620, [CLOAK] = 237614 },
        [HUNTER] = { [HEAD] = 237646, [SHOULDER] = 237644, [CHEST] = 237649, [WAIST] = 237643, [LEGS] = 237645, [FEET] = 237648, [WRIST] = 237642, [HAND] = 237647, [CLOAK] = 237641 },
        [ROGUE] = { [HEAD] = 237664, [SHOULDER] = 237662, [CHEST] = 237667, [WAIST] = 237661, [LEGS] = 237663, [FEET] = 237666, [WRIST] = 237660, [HAND] = 237665, [CLOAK] = 237659 },
        [PRIEST] = { [HEAD] = 237709, [SHOULDER] = 237707, [CHEST] = 237712, [WAIST] = 237706, [LEGS] = 237708, [FEET] = 237711, [WRIST] = 237705, [HAND] = 237710, [CLOAK] = 237704 },
        [DEATHKNIGHT] = { [HEAD] = 237628, [SHOULDER] = 237626, [CHEST] = 237631, [WAIST] = 237625, [LEGS] = 237627, [FEET] = 237630, [WRIST] = 237624, [HAND] = 237629, [CLOAK] = 237623 },
        [SHAMAN] = { [HEAD] = 237637, [SHOULDER] = 237635, [CHEST] = 237640, [WAIST] = 237634, [LEGS] = 237636, [FEET] = 237639, [WRIST] = 237633, [HAND] = 237638, [CLOAK] = 237632 },
        [MAGE] = { [HEAD] = 237718, [SHOULDER] = 237716, [CHEST] = 237721, [WAIST] = 237715, [LEGS] = 237717, [FEET] = 237720, [WRIST] = 237714, [HAND] = 237719, [CLOAK] = 237713 },
        [WARLOCK] = { [HEAD] = 237700, [SHOULDER] = 237698, [CHEST] = 237703, [WAIST] = 237697, [LEGS] = 237699, [FEET] = 237702, [WRIST] = 237696, [HAND] = 237701, [CLOAK] = 237695 },
        [MONK] = { [HEAD] = 237673, [SHOULDER] = 237671, [CHEST] = 237676, [WAIST] = 237670, [LEGS] = 237672, [FEET] = 237675, [WRIST] = 237669, [HAND] = 237674, [CLOAK] = 237668 },
        [DRUID] = { [HEAD] = 237682, [SHOULDER] = 237680, [CHEST] = 237685, [WAIST] = 237679, [LEGS] = 237681, [FEET] = 237684, [WRIST] = 237678, [HAND] = 237683, [CLOAK] = 237677 },
        [DEMONHUNTER] = { [HEAD] = 237691, [SHOULDER] = 237689, [CHEST] = 237694, [WAIST] = 237688, [LEGS] = 237690, [FEET] = 237693, [WRIST] = 237687, [HAND] = 237692, [CLOAK] = 237686 },
        [EVOKER] = { [HEAD] = 237655, [SHOULDER] = 237653, [CHEST] = 237658, [WAIST] = 237652, [LEGS] = 237654, [FEET] = 237657, [WRIST] = 237651, [HAND] = 237656, [CLOAK] = 237650 },
    },
    [MN_S1] = {
        [WARRIOR] = { [HEAD] = 249952, [SHOULDER] = 249950, [CHEST] = 249955, [WAIST] = 249949, [LEGS] = 249951, [FEET] = 249954, [WRIST] = 249948, [HAND] = 249953, [CLOAK] = 249947 },
        [PALADIN] = { [HEAD] = 249961, [SHOULDER] = 249959, [CHEST] = 249964, [WAIST] = 249958, [LEGS] = 249960, [FEET] = 249963, [WRIST] = 249957, [HAND] = 249962, [CLOAK] = 249956 },
        [HUNTER] = { [HEAD] = 249988, [SHOULDER] = 249986, [CHEST] = 249991, [WAIST] = 249985, [LEGS] = 249987, [FEET] = 249990, [WRIST] = 249984, [HAND] = 249989, [CLOAK] = 249983 },
        [ROGUE] = { [HEAD] = 250006, [SHOULDER] = 250004, [CHEST] = 250009, [WAIST] = 250003, [LEGS] = 250005, [FEET] = 250008, [WRIST] = 250002, [HAND] = 250007, [CLOAK] = 250001 },
        [PRIEST] = { [HEAD] = 250051, [SHOULDER] = 250049, [CHEST] = 250054, [WAIST] = 250048, [LEGS] = 250050, [FEET] = 250053, [WRIST] = 250047, [HAND] = 250052, [CLOAK] = 250046 },
        [DEATHKNIGHT] = { [HEAD] = 249970, [SHOULDER] = 249968, [CHEST] = 249973, [WAIST] = 249967, [LEGS] = 249969, [FEET] = 249972, [WRIST] = 249966, [HAND] = 249971, [CLOAK] = 249965 },
        [SHAMAN] = { [HEAD] = 249979, [SHOULDER] = 249977, [CHEST] = 249982, [WAIST] = 249976, [LEGS] = 249978, [FEET] = 249981, [WRIST] = 249975, [HAND] = 249980, [CLOAK] = 249974 },
        [MAGE] = { [HEAD] = 250060, [SHOULDER] = 250058, [CHEST] = 250063, [WAIST] = 250057, [LEGS] = 250059, [FEET] = 250062, [WRIST] = 250056, [HAND] = 250061, [CLOAK] = 250055 },
        [WARLOCK] = { [HEAD] = 250042, [SHOULDER] = 250040, [CHEST] = 250045, [WAIST] = 250039, [LEGS] = 250041, [FEET] = 250044, [WRIST] = 250038, [HAND] = 250043, [CLOAK] = 250037 },
        [MONK] = { [HEAD] = 250015, [SHOULDER] = 250013, [CHEST] = 250018, [WAIST] = 250012, [LEGS] = 250014, [FEET] = 250017, [WRIST] = 250011, [HAND] = 250016, [CLOAK] = 250010 },
        [DRUID] = { [HEAD] = 250024, [SHOULDER] = 250022, [CHEST] = 250027, [WAIST] = 250021, [LEGS] = 250023, [FEET] = 250026, [WRIST] = 250020, [HAND] = 250025, [CLOAK] = 250019 },
        [DEMONHUNTER] = { [HEAD] = 250033, [SHOULDER] = 250031, [CHEST] = 250036, [WAIST] = 250030, [LEGS] = 250032, [FEET] = 250035, [WRIST] = 250029, [HAND] = 250034, [CLOAK] = 250028 },
        [EVOKER] = { [HEAD] = 249997, [SHOULDER] = 249995, [CHEST] = 250000, [WAIST] = 249994, [LEGS] = 249996, [FEET] = 249999, [WRIST] = 249993, [HAND] = 249998, [CLOAK] = 249992 },
    },
};

--- @type table<number, TUM_Season> # [itemID] = seasonID
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

local classCombo = {
    dk_dh_lock = { [DEATHKNIGHT] = true, [DEMONHUNTER] = true, [WARLOCK] = true },
    druid_hunter_mage = { [DRUID] = true, [HUNTER] = true, [MAGE] = true },
    pala_priest_shaman = { [PALADIN] = true, [PRIEST] = true, [SHAMAN] = true },
    monk_rogue_warrior = { [MONK] = true, [ROGUE] = true, [WARRIOR] = true },
    evoker_monk_rogue_warrior = { [EVOKER] = true, [MONK] = true, [ROGUE] = true, [WARRIOR] = true },
    cloth = { [MAGE] = true, [PRIEST] = true, [WARLOCK] = true },
    leather = { [DRUID] = true, [MONK] = true, [ROGUE] = true, [DEMONHUNTER] = true },
    mail = { [HUNTER] = true, [SHAMAN] = true, [EVOKER] = true },
    plate = { [WARRIOR] = true, [PALADIN] = true, [DEATHKNIGHT] = true },
};
--- @type table<number, { season: TUM_Season, slot: Enum.InventoryType, classList: table<number, boolean> }>
data.tokens = {
    [191005] = { season = SL_S4, slot = HEAD, classList = classCombo.dk_dh_lock }, -- Dreadful Helm Module
    [191006] = { season = SL_S4, slot = SHOULDER, classList = classCombo.dk_dh_lock }, -- Dreadful Shoulder Module
    [191010] = { season = SL_S4, slot = CHEST, classList = classCombo.dk_dh_lock }, -- Dreadful Chest Module
    [191018] = { season = SL_S4, slot = LEGS, classList = classCombo.dk_dh_lock }, -- Dreadful Leg Module
    [191014] = { season = SL_S4, slot = HAND, classList = classCombo.dk_dh_lock }, -- Dreadful Hand Module
    [191002] = { season = SL_S4, slot = HEAD, classList = classCombo.druid_hunter_mage }, -- Mystic Helm Module
    [191007] = { season = SL_S4, slot = SHOULDER, classList = classCombo.druid_hunter_mage }, -- Mystic Shoulder Module
    [191011] = { season = SL_S4, slot = CHEST, classList = classCombo.druid_hunter_mage }, -- Mystic Chest Module
    [191019] = { season = SL_S4, slot = LEGS, classList = classCombo.druid_hunter_mage }, -- Mystic Leg Module
    [191015] = { season = SL_S4, slot = HAND, classList = classCombo.druid_hunter_mage }, -- Mystic Hand Module
    [191003] = { season = SL_S4, slot = HEAD, classList = classCombo.pala_priest_shaman }, -- Venerated Helm Module
    [191008] = { season = SL_S4, slot = SHOULDER, classList = classCombo.pala_priest_shaman }, -- Venerated Shoulder Module
    [191012] = { season = SL_S4, slot = CHEST, classList = classCombo.pala_priest_shaman }, -- Venerated Chest Module
    [191020] = { season = SL_S4, slot = LEGS, classList = classCombo.pala_priest_shaman }, -- Venerated Leg Module
    [191016] = { season = SL_S4, slot = HAND, classList = classCombo.pala_priest_shaman }, -- Venerated Hand Module
    [191004] = { season = SL_S4, slot = HEAD, classList = classCombo.monk_rogue_warrior }, -- Zenith Helm Module
    [191009] = { season = SL_S4, slot = SHOULDER, classList = classCombo.monk_rogue_warrior }, -- Zenith Shoulder Module
    [191013] = { season = SL_S4, slot = CHEST, classList = classCombo.monk_rogue_warrior }, -- Zenith Chest Module
    [191021] = { season = SL_S4, slot = LEGS, classList = classCombo.monk_rogue_warrior }, -- Zenith Leg Module
    [191017] = { season = SL_S4, slot = HAND, classList = classCombo.monk_rogue_warrior }, -- Zenith Hand Module
    [196590] = { season = DF_S1, slot = HEAD, classList = classCombo.dk_dh_lock }, -- Dreadful Topaz Forgestone
    [196589] = { season = DF_S1, slot = SHOULDER, classList = classCombo.dk_dh_lock }, -- Dreadful Lapis Forgestone
    [196586] = { season = DF_S1, slot = CHEST, classList = classCombo.dk_dh_lock }, -- Dreadful Amethyst Forgestone
    [196588] = { season = DF_S1, slot = LEGS, classList = classCombo.dk_dh_lock }, -- Dreadful Jade Forgestone
    [196587] = { season = DF_S1, slot = HAND, classList = classCombo.dk_dh_lock }, -- Dreadful Garnet Forgestone
    [196600] = { season = DF_S1, slot = HEAD, classList = classCombo.druid_hunter_mage }, -- Mystic Topaz Forgestone
    [196599] = { season = DF_S1, slot = SHOULDER, classList = classCombo.druid_hunter_mage }, -- Mystic Lapis Forgestone
    [196596] = { season = DF_S1, slot = CHEST, classList = classCombo.druid_hunter_mage }, -- Mystic Amethyst Forgestone
    [196598] = { season = DF_S1, slot = LEGS, classList = classCombo.druid_hunter_mage }, -- Mystic Jade Forgestone
    [196597] = { season = DF_S1, slot = HAND, classList = classCombo.druid_hunter_mage }, -- Mystic Garnet Forgestone
    [196605] = { season = DF_S1, slot = HEAD, classList = classCombo.pala_priest_shaman }, -- Venerated Topaz Forgestone
    [196604] = { season = DF_S1, slot = SHOULDER, classList = classCombo.pala_priest_shaman }, -- Venerated Lapis Forgestone
    [196601] = { season = DF_S1, slot = CHEST, classList = classCombo.pala_priest_shaman }, -- Venerated Amethyst Forgestone
    [196603] = { season = DF_S1, slot = LEGS, classList = classCombo.pala_priest_shaman }, -- Venerated Jade Forgestone
    [196602] = { season = DF_S1, slot = HAND, classList = classCombo.pala_priest_shaman }, -- Venerated Garnet Forgestone
    [196595] = { season = DF_S1, slot = HEAD, classList = classCombo.evoker_monk_rogue_warrior }, -- Zenith Topaz Forgestone
    [196594] = { season = DF_S1, slot = SHOULDER, classList = classCombo.evoker_monk_rogue_warrior }, -- Zenith Lapis Forgestone
    [196591] = { season = DF_S1, slot = CHEST, classList = classCombo.evoker_monk_rogue_warrior }, -- Zenith Amethyst Forgestone
    [196593] = { season = DF_S1, slot = LEGS, classList = classCombo.evoker_monk_rogue_warrior }, -- Zenith Jade Forgestone
    [196592] = { season = DF_S1, slot = HAND, classList = classCombo.evoker_monk_rogue_warrior }, -- Zenith Garnet Forgestone
    [202627] = { season = DF_S2, slot = HEAD, classList = classCombo.dk_dh_lock }, -- Dreadful Melting Fluid
    [202621] = { season = DF_S2, slot = SHOULDER, classList = classCombo.dk_dh_lock }, -- Dreadful Corrupting Fluid
    [202631] = { season = DF_S2, slot = CHEST, classList = classCombo.dk_dh_lock }, -- Dreadful Ventilation Fluid
    [202634] = { season = DF_S2, slot = LEGS, classList = classCombo.dk_dh_lock }, -- Dreadful Cooling Fluid
    [202624] = { season = DF_S2, slot = HAND, classList = classCombo.dk_dh_lock }, -- Dreadful Mixing Fluid
    [202628] = { season = DF_S2, slot = HEAD, classList = classCombo.druid_hunter_mage }, -- Mystic Melting Fluid
    [202622] = { season = DF_S2, slot = SHOULDER, classList = classCombo.druid_hunter_mage }, -- Mystic Corrupting Fluid
    [202632] = { season = DF_S2, slot = CHEST, classList = classCombo.druid_hunter_mage }, -- Mystic Ventilation Fluid
    [202635] = { season = DF_S2, slot = LEGS, classList = classCombo.druid_hunter_mage }, -- Mystic Cooling Fluid
    [202625] = { season = DF_S2, slot = HAND, classList = classCombo.druid_hunter_mage }, -- Mystic Mixing Fluid
    [202629] = { season = DF_S2, slot = HEAD, classList = classCombo.pala_priest_shaman }, -- Venerated Melting Fluid
    [202623] = { season = DF_S2, slot = SHOULDER, classList = classCombo.pala_priest_shaman }, -- Venerated Corrupting Fluid
    [202633] = { season = DF_S2, slot = CHEST, classList = classCombo.pala_priest_shaman }, -- Venerated Ventilation Fluid
    [202636] = { season = DF_S2, slot = LEGS, classList = classCombo.pala_priest_shaman }, -- Venerated Cooling Fluid
    [202626] = { season = DF_S2, slot = HAND, classList = classCombo.pala_priest_shaman }, -- Venerated Mixing Fluid
    [202630] = { season = DF_S2, slot = HEAD, classList = classCombo.evoker_monk_rogue_warrior }, -- Zenith Melting Fluid
    [202637] = { season = DF_S2, slot = SHOULDER, classList = classCombo.evoker_monk_rogue_warrior }, -- Zenith Corrupting Fluid
    [202639] = { season = DF_S2, slot = CHEST, classList = classCombo.evoker_monk_rogue_warrior }, -- Zenith Ventilation Fluid
    [202640] = { season = DF_S2, slot = LEGS, classList = classCombo.evoker_monk_rogue_warrior }, -- Zenith Cooling Fluid
    [202638] = { season = DF_S2, slot = HAND, classList = classCombo.evoker_monk_rogue_warrior }, -- Zenith Mixing Fluid
    [207470] = { season = DF_S3, slot = HEAD, classList = classCombo.dk_dh_lock }, -- Dreadful Blazing Dreamheart
    [207478] = { season = DF_S3, slot = SHOULDER, classList = classCombo.dk_dh_lock }, -- Dreadful Smoldering Dreamheart
    [207462] = { season = DF_S3, slot = CHEST, classList = classCombo.dk_dh_lock }, -- Dreadful Verdurous Dreamheart
    [207474] = { season = DF_S3, slot = LEGS, classList = classCombo.dk_dh_lock }, -- Dreadful Ashen Dreamheart
    [207466] = { season = DF_S3, slot = HAND, classList = classCombo.dk_dh_lock }, -- Dreadful Tormented Dreamheart
    [207471] = { season = DF_S3, slot = HEAD, classList = classCombo.druid_hunter_mage }, -- Mystic Blazing Dreamheart
    [207479] = { season = DF_S3, slot = SHOULDER, classList = classCombo.druid_hunter_mage }, -- Mystic Smoldering Dreamheart
    [207463] = { season = DF_S3, slot = CHEST, classList = classCombo.druid_hunter_mage }, -- Mystic Verdurous Dreamheart
    [207475] = { season = DF_S3, slot = LEGS, classList = classCombo.druid_hunter_mage }, -- Mystic Ashen Dreamheart
    [207467] = { season = DF_S3, slot = HAND, classList = classCombo.druid_hunter_mage }, -- Mystic Tormented Dreamheart
    [207472] = { season = DF_S3, slot = HEAD, classList = classCombo.pala_priest_shaman }, -- Venerated Blazing Dreamheart
    [207480] = { season = DF_S3, slot = SHOULDER, classList = classCombo.pala_priest_shaman }, -- Venerated Smoldering Dreamheart
    [207464] = { season = DF_S3, slot = CHEST, classList = classCombo.pala_priest_shaman }, -- Venerated Verdurous Dreamheart
    [207476] = { season = DF_S3, slot = LEGS, classList = classCombo.pala_priest_shaman }, -- Venerated Ashen Dreamheart
    [207468] = { season = DF_S3, slot = HAND, classList = classCombo.pala_priest_shaman }, -- Venerated Tormented Dreamheart
    [207473] = { season = DF_S3, slot = HEAD, classList = classCombo.evoker_monk_rogue_warrior }, -- Zenith Blazing Dreamheart
    [207481] = { season = DF_S3, slot = SHOULDER, classList = classCombo.evoker_monk_rogue_warrior }, -- Zenith Smoldering Dreamheart
    [207465] = { season = DF_S3, slot = CHEST, classList = classCombo.evoker_monk_rogue_warrior }, -- Zenith Verdurous Dreamheart
    [207477] = { season = DF_S3, slot = LEGS, classList = classCombo.evoker_monk_rogue_warrior }, -- Zenith Ashen Dreamheart
    [207469] = { season = DF_S3, slot = HAND, classList = classCombo.evoker_monk_rogue_warrior }, -- Zenith Tormented Dreamheart
    [217324] = { season = DF_S4, slot = HEAD, classList = classCombo.dk_dh_lock }, -- Dreadful Decelerating Chronograph
    [217332] = { season = DF_S4, slot = SHOULDER, classList = classCombo.dk_dh_lock }, -- Dreadful Synchronous Timestrand
    [217316] = { season = DF_S4, slot = CHEST, classList = classCombo.dk_dh_lock }, -- Dreadful Fleeting Hourglass
    [217328] = { season = DF_S4, slot = LEGS, classList = classCombo.dk_dh_lock }, -- Dreadful Ephemeral Hypersphere
    [217320] = { season = DF_S4, slot = HAND, classList = classCombo.dk_dh_lock }, -- Dreadful Quickened Bronzestone
    [217325] = { season = DF_S4, slot = HEAD, classList = classCombo.druid_hunter_mage }, -- Mystic Decelerating Chronograph
    [217333] = { season = DF_S4, slot = SHOULDER, classList = classCombo.druid_hunter_mage }, -- Mystic Synchronous Timestrand
    [217317] = { season = DF_S4, slot = CHEST, classList = classCombo.druid_hunter_mage }, -- Mystic Fleeting Hourglass
    [217329] = { season = DF_S4, slot = LEGS, classList = classCombo.druid_hunter_mage }, -- Mystic Ephemeral Hypersphere
    [217321] = { season = DF_S4, slot = HAND, classList = classCombo.druid_hunter_mage }, -- Mystic Quickened Bronzestone
    [217326] = { season = DF_S4, slot = HEAD, classList = classCombo.pala_priest_shaman }, -- Venerated Decelerating Chronograph
    [217334] = { season = DF_S4, slot = SHOULDER, classList = classCombo.pala_priest_shaman }, -- Venerated Synchronous Timestrand
    [217318] = { season = DF_S4, slot = CHEST, classList = classCombo.pala_priest_shaman }, -- Venerated Fleeting Hourglass
    [217330] = { season = DF_S4, slot = LEGS, classList = classCombo.pala_priest_shaman }, -- Venerated Ephemeral Hypersphere
    [217322] = { season = DF_S4, slot = HAND, classList = classCombo.pala_priest_shaman }, -- Venerated Quickened Bronzestone
    [217327] = { season = DF_S4, slot = HEAD, classList = classCombo.evoker_monk_rogue_warrior }, -- Zenith Decelerating Chronograph
    [217335] = { season = DF_S4, slot = SHOULDER, classList = classCombo.evoker_monk_rogue_warrior }, -- Zenith Synchronous Timestrand
    [217319] = { season = DF_S4, slot = CHEST, classList = classCombo.evoker_monk_rogue_warrior }, -- Zenith Fleeting Hourglass
    [217331] = { season = DF_S4, slot = LEGS, classList = classCombo.evoker_monk_rogue_warrior }, -- Zenith Ephemeral Hypersphere
    [217323] = { season = DF_S4, slot = HAND, classList = classCombo.evoker_monk_rogue_warrior }, -- Zenith Quickened Bronzestone
    [225622] = { season = TWW_S1, slot = HEAD, classList = classCombo.dk_dh_lock }, -- Dreadful Conniver's Badge
    [225630] = { season = TWW_S1, slot = SHOULDER, classList = classCombo.dk_dh_lock }, -- Dreadful Obscenity's Idol
    [225614] = { season = TWW_S1, slot = CHEST, classList = classCombo.dk_dh_lock }, -- Dreadful Blasphemer's Effigy
    [225626] = { season = TWW_S1, slot = LEGS, classList = classCombo.dk_dh_lock }, -- Dreadful Slayer's Icon
    [225618] = { season = TWW_S1, slot = HAND, classList = classCombo.dk_dh_lock }, -- Dreadful Stalwart's Emblem
    [225623] = { season = TWW_S1, slot = HEAD, classList = classCombo.druid_hunter_mage }, -- Mystic Conniver's Badge
    [225631] = { season = TWW_S1, slot = SHOULDER, classList = classCombo.druid_hunter_mage }, -- Mystic Obscenity's Idol
    [225615] = { season = TWW_S1, slot = CHEST, classList = classCombo.druid_hunter_mage }, -- Mystic Blasphemer's Effigy
    [225627] = { season = TWW_S1, slot = LEGS, classList = classCombo.druid_hunter_mage }, -- Mystic Slayer's Icon
    [225619] = { season = TWW_S1, slot = HAND, classList = classCombo.druid_hunter_mage }, -- Mystic Stalwart's Emblem
    [225624] = { season = TWW_S1, slot = HEAD, classList = classCombo.pala_priest_shaman }, -- Venerated Conniver's Badge
    [225632] = { season = TWW_S1, slot = SHOULDER, classList = classCombo.pala_priest_shaman }, -- Venerated Obscenity's Idol
    [225616] = { season = TWW_S1, slot = CHEST, classList = classCombo.pala_priest_shaman }, -- Venerated Blasphemer's Effigy
    [225628] = { season = TWW_S1, slot = LEGS, classList = classCombo.pala_priest_shaman }, -- Venerated Slayer's Icon
    [225620] = { season = TWW_S1, slot = HAND, classList = classCombo.pala_priest_shaman }, -- Venerated Stalwart's Emblem
    [225625] = { season = TWW_S1, slot = HEAD, classList = classCombo.evoker_monk_rogue_warrior }, -- Zenith Conniver's Badge
    [225633] = { season = TWW_S1, slot = SHOULDER, classList = classCombo.evoker_monk_rogue_warrior }, -- Zenith Obscenity's Idol
    [225617] = { season = TWW_S1, slot = CHEST, classList = classCombo.evoker_monk_rogue_warrior }, -- Zenith Blasphemer's Effigy
    [225629] = { season = TWW_S1, slot = LEGS, classList = classCombo.evoker_monk_rogue_warrior }, -- Zenith Slayer's Icon
    [225621] = { season = TWW_S1, slot = HAND, classList = classCombo.evoker_monk_rogue_warrior }, -- Zenith Stalwart's Emblem
    [228807] = { season = TWW_S2, slot = HEAD, classList = classCombo.dk_dh_lock }, -- Dreadful Gilded Gallybux
    [228815] = { season = TWW_S2, slot = SHOULDER, classList = classCombo.dk_dh_lock }, -- Dreadful Polished Gallybux
    [228799] = { season = TWW_S2, slot = CHEST, classList = classCombo.dk_dh_lock }, -- Dreadful Greased Gallybux
    [228811] = { season = TWW_S2, slot = LEGS, classList = classCombo.dk_dh_lock }, -- Dreadful Rusty Gallybux
    [228803] = { season = TWW_S2, slot = HAND, classList = classCombo.dk_dh_lock }, -- Dreadful Bloody Gallybux
    [228808] = { season = TWW_S2, slot = HEAD, classList = classCombo.druid_hunter_mage }, -- Mystic Gilded Gallybux
    [228816] = { season = TWW_S2, slot = SHOULDER, classList = classCombo.druid_hunter_mage }, -- Mystic Polished Gallybux
    [228800] = { season = TWW_S2, slot = CHEST, classList = classCombo.druid_hunter_mage }, -- Mystic Greased Gallybux
    [228812] = { season = TWW_S2, slot = LEGS, classList = classCombo.druid_hunter_mage }, -- Mystic Rusty Gallybux
    [228804] = { season = TWW_S2, slot = HAND, classList = classCombo.druid_hunter_mage }, -- Mystic Bloody Gallybux
    [228809] = { season = TWW_S2, slot = HEAD, classList = classCombo.pala_priest_shaman }, -- Venerated Gilded Gallybux
    [228817] = { season = TWW_S2, slot = SHOULDER, classList = classCombo.pala_priest_shaman }, -- Venerated Polished Gallybux
    [228801] = { season = TWW_S2, slot = CHEST, classList = classCombo.pala_priest_shaman }, -- Venerated Greased Gallybux
    [228813] = { season = TWW_S2, slot = LEGS, classList = classCombo.pala_priest_shaman }, -- Venerated Rusty Gallybux
    [228805] = { season = TWW_S2, slot = HAND, classList = classCombo.pala_priest_shaman }, -- Venerated Bloody Gallybux
    [228810] = { season = TWW_S2, slot = HEAD, classList = classCombo.evoker_monk_rogue_warrior }, -- Zenith Gilded Gallybux
    [228818] = { season = TWW_S2, slot = SHOULDER, classList = classCombo.evoker_monk_rogue_warrior }, -- Zenith Polished Gallybux
    [228802] = { season = TWW_S2, slot = CHEST, classList = classCombo.evoker_monk_rogue_warrior }, -- Zenith Greased Gallybux
    [228814] = { season = TWW_S2, slot = LEGS, classList = classCombo.evoker_monk_rogue_warrior }, -- Zenith Rusty Gallybux
    [228806] = { season = TWW_S2, slot = HAND, classList = classCombo.evoker_monk_rogue_warrior }, -- Zenith Bloody Gallybux
    [237589] = { season = TWW_S3, slot = HEAD, classList = classCombo.dk_dh_lock }, -- Dreadful Foreboding Beaker
    [237597] = { season = TWW_S3, slot = SHOULDER, classList = classCombo.dk_dh_lock }, -- Dreadful Yearning Cursemark
    [237581] = { season = TWW_S3, slot = CHEST, classList = classCombo.dk_dh_lock }, -- Dreadful Voidglass Contaminant
    [237593] = { season = TWW_S3, slot = LEGS, classList = classCombo.dk_dh_lock }, -- Dreadful Silken Offering
    [237585] = { season = TWW_S3, slot = HAND, classList = classCombo.dk_dh_lock }, -- Dreadful Binding Agent
    [237590] = { season = TWW_S3, slot = HEAD, classList = classCombo.druid_hunter_mage }, -- Mystic Foreboding Beaker
    [237598] = { season = TWW_S3, slot = SHOULDER, classList = classCombo.druid_hunter_mage }, -- Mystic Yearning Cursemark
    [237582] = { season = TWW_S3, slot = CHEST, classList = classCombo.druid_hunter_mage }, -- Mystic Voidglass Contaminant
    [237594] = { season = TWW_S3, slot = LEGS, classList = classCombo.druid_hunter_mage }, -- Mystic Silken Offering
    [237586] = { season = TWW_S3, slot = HAND, classList = classCombo.druid_hunter_mage }, -- Mystic Binding Agent
    [237591] = { season = TWW_S3, slot = HEAD, classList = classCombo.pala_priest_shaman }, -- Venerated Foreboding Beaker
    [237599] = { season = TWW_S3, slot = SHOULDER, classList = classCombo.pala_priest_shaman }, -- Venerated Yearning Cursemark
    [237583] = { season = TWW_S3, slot = CHEST, classList = classCombo.pala_priest_shaman }, -- Venerated Voidglass Contaminant
    [237595] = { season = TWW_S3, slot = LEGS, classList = classCombo.pala_priest_shaman }, -- Venerated Silken Offering
    [237587] = { season = TWW_S3, slot = HAND, classList = classCombo.pala_priest_shaman }, -- Venerated Binding Agent
    [237592] = { season = TWW_S3, slot = HEAD, classList = classCombo.evoker_monk_rogue_warrior }, -- Zenith Foreboding Beaker
    [237600] = { season = TWW_S3, slot = SHOULDER, classList = classCombo.evoker_monk_rogue_warrior }, -- Zenith Yearning Cursemark
    [237584] = { season = TWW_S3, slot = CHEST, classList = classCombo.evoker_monk_rogue_warrior }, -- Zenith Voidglass Contaminant
    [237596] = { season = TWW_S3, slot = LEGS, classList = classCombo.evoker_monk_rogue_warrior }, -- Zenith Silken Offering
    [237588] = { season = TWW_S3, slot = HAND, classList = classCombo.evoker_monk_rogue_warrior }, -- Zenith Binding Agent
    [249355] = { season = MN_S1, slot = HEAD, classList = classCombo.cloth }, -- Voidwoven Fanatical Nullcore
    [249363] = { season = MN_S1, slot = SHOULDER, classList = classCombo.cloth }, -- Voidwoven Unraveled Nullcore
    [249359] = { season = MN_S1, slot = LEGS, classList = classCombo.cloth }, -- Voidwoven Corrupted Nullcore
    [249351] = { season = MN_S1, slot = HAND, classList = classCombo.cloth }, -- Voidwoven Hungering Nullcore
    [249356] = { season = MN_S1, slot = HEAD, classList = classCombo.leather }, -- Voidcured Fanatical Nullcore
    [249364] = { season = MN_S1, slot = SHOULDER, classList = classCombo.leather }, -- Voidcured Unraveled Nullcore
    [249360] = { season = MN_S1, slot = LEGS, classList = classCombo.leather }, -- Voidcured Corrupted Nullcore
    [249352] = { season = MN_S1, slot = HAND, classList = classCombo.leather }, -- Voidcured Hungering Nullcore
    [249357] = { season = MN_S1, slot = HEAD, classList = classCombo.mail }, -- Voidcast Fanatical Nullcore
    [249365] = { season = MN_S1, slot = SHOULDER, classList = classCombo.mail }, -- Voidcast Unraveled Nullcore
    [249361] = { season = MN_S1, slot = LEGS, classList = classCombo.mail }, -- Voidcast Corrupted Nullcore
    [249353] = { season = MN_S1, slot = HAND, classList = classCombo.mail }, -- Voidcast Hungering Nullcore
    [249358] = { season = MN_S1, slot = HEAD, classList = classCombo.plate }, -- Voidforged Fanatical Nullcore
    [249366] = { season = MN_S1, slot = SHOULDER, classList = classCombo.plate }, -- Voidforged Unraveled Nullcore
    [249362] = { season = MN_S1, slot = LEGS, classList = classCombo.plate }, -- Voidforged Corrupted Nullcore
    [249354] = { season = MN_S1, slot = HAND, classList = classCombo.plate }, -- Voidforged Hungering Nullcore
};

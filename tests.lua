--- @class TUM_NS
local ns = select(2, ...);

local TUM = ns.core;
local data = TUM.data;
local constants = data.constants;

local tests = {
    lfrItemWIthRaidNormalContext = {
        link = "|cnIQ4:|Hitem:218057::::::::80:577::3:6:10341:10532:11311:10871:1602:8767:1:28:2474:::::|h[Dalaran Defender's Mask]|h|r",
        classID = constants.classes.MONK,
        expected = {
            seasonID = constants.seasons.DF_S4,
            tier = constants.tiers.lfr,
            canCatalyse = true,
        },
    },
    blueItem = {
        link = "|cnIQ3:|Hitem:245734::::::::80:268::25:6:6652:12921:12244:12272:3194:10254:1:28:2462:::::|h[Unstable Sample Bindings]|h|r",
        classID = constants.classes.MONK,
        expected = {
            seasonID = constants.seasons.TWW_S3,
            tier = nil,
            canCatalyse = false,
        },
    },
    mPlusItem = {
        link = "|cnIQ4:|Hitem:159305::::::::80:577::33:7:11987:10390:42:11964:10383:10063:10255:1:28:2462:::::|h[Corrosive Handler's Gloves]|h|r",
        classID = constants.classes.MONK,
        expected = {
            seasonID = constants.seasons.TWW_S2,
            tier = constants.tiers.heroic,
            canCatalyse = true,
        },
    },
    delveItem = {
        link = "|cnIQ4:|Hitem:235445::::::::80:577::109:7:11978:6652:12176:11964:3322:10255:10876:1:28:2462:::::|h[Nitroclad Strap]|h|r",
        classID = constants.classes.MONK,
        expected = {
            seasonID = constants.seasons.TWW_S2,
            tier = constants.tiers.normal,
            canCatalyse = true,
        },
    },
    weapon = {
        link = "|cnIQ4:|Hitem:237739::::::::80:577::5:1:3524:1:28:3229:::::|h[Obliteration Beamglaive]|h|r",
        classID = constants.classes.MONK,
        expected = {
            seasonID = constants.seasons.TWW_S3,
            tier = constants.tiers.heroic,
            canCatalyse = false,
        },
    },
    SL_Token = {
        link = "|cnIQ4:|Hitem:191014::::::::80:577::5:1:3524:1:28:2166:::::|h[Dreadful Hand Module]|h|r",
        classID = constants.classes.WARLOCK,
        expected = {
            seasonID = constants.seasons.SL_S4,
            tier = constants.tiers.heroic,
            canCatalyse = true,
        },
    },
    conquestItem = {
        link = "|cnIQ4:|Hitem:229599::::::::80:577::57:6:11984:12030:11964:12020:1546:10255:1:28:2462:::::|h[Prized Gladiator's Leather Vest]|h|r",
        classID = constants.classes.DEMONHUNTER,
        expected = {
            seasonID = constants.seasons.TWW_S2,
            tier = constants.tiers.heroic,
            canCatalyse = false,
            isPvpItem = true,
        },
    },
    primalInfused = {
        link = "|cnIQ4:|Hitem:200421::::::::71:66::14:5:6652:8943:9343:7937:1468::::::|h|Virtuous Silver Bracers]|h|r",
        classID = constants.classes.MONK,
        expected = {
            seasonID = nil,
            tier = nil,
            canCatalyse = false,
        },
    },
};

local function runTests()
    C_Timer.After(0, function()
        local completedTests = 0;
        local anyFailed = false;
        for testKey, test in pairs(tests) do
            local item = Item:CreateFromItemLink(test.link);
            item:ContinueOnItemLoad(function()
                completedTests = completedTests + 1;
                local ok, results = xpcall(TUM.IsAppearanceMissing, CallErrorHandler, TUM, test.link, test.classID);

                if ok then
                    local contextData = results and results.contextData;
                    local actual = {
                        seasonID = contextData and contextData.seasonID or nil,
                        tier = contextData and contextData.tier or nil,
                        canCatalyse = results and results.canCatalyse or false,
                        isPvpItem = contextData and contextData.isPvpItem or false,
                    };
                    local testFailed = false;

                    for key, expectedValue in pairs(test.expected) do
                        local actualValue = actual[key];
                        if actualValue ~= expectedValue then
                            testFailed = true;
                            anyFailed = true;
                            print("Test", testKey, "-", key, "failed. Expected'", expectedValue, "', got'", actualValue, "'. Link:", test.link);
                        end
                    end
                    if testFailed and DevTool and DevTool.AddData then
                        DevTool:AddData({
                            testIndex = testKey,
                            itemLink = test.link,
                            expected = test.expected,
                            actual = actual,
                            results = results,
                        }, "TUM Test Failure");
                    end
                else
                    anyFailed = true;
                    print("Test", testKey, "errored. Link:", test.link);
                end
            end);
        end

        local ticker;
        ticker = C_Timer.NewTicker(0.1, function()
            if completedTests >= #tests then
                ticker:Cancel();
                if not anyFailed then
                    print("TUM: All tests passed! |TInterface\\RaidFrame\\ReadyCheck-Ready:0|t");
                else
                    print("TUM: Some tests failed. |TInterface\\RaidFrame\\ReadyCheck-NotReady:0|t");
                end
            end
        end);
    end);
end

local ticker;
ticker = C_Timer.NewTicker(0.5, function()
    if TUM:IsCacheWarmedUp() and TUM.seasonInitialized then
        ticker:Cancel();
        runTests();
    end
end);

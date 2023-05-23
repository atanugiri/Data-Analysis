% Author: Atanu Giri
% Date: 12/11/2022
% This function generates an array of thre tables of baseline and
% two weeks of food deprivation data based on taskType L1 or L3
function [dataForHealthType,dataLabel] = foodDeprivationDataForTaskType ...
(taskType,splitLightLevel,mergedTable,varargin)
% loadFile = load('mergedTable.mat'); mergedTable = loadFile.mergedTable;
% taskType = 1; splitLightLevel = 0;
switch taskType
    case 1
        dataForHealthType = {'(P2L1)baseline of FD','(P2L1)foodDeprivation(Week2)', ...
            '(P2L1)foodDeprivation(Week3)'};
        dataForHealthType{1} = mergedTable(mergedTable.referencetime >= "06/16/2022" & ...
            mergedTable.referencetime <= "06/23/2022" & mergedTable.health == "N/A",:);

        dataForHealthType{2} = mergedTable(mergedTable.referencetime >= "08/16/2022" & ...
            mergedTable.referencetime <= "08/19/2022" & mergedTable.health == "Food Deprivation",:);
        dataForHealthType{3} = mergedTable(mergedTable.referencetime >= "08/23/2022" & ...
            mergedTable.referencetime <= "08/25/2022" & mergedTable.health == "Food Deprivation",:);
        dataLabel = {'(P2L1)baseline','(P2L1)foodDeprivation2','(P2L1)foodDeprivation3'};
    case 2
        BLandFD = {'(P2L1L3)baseline of FD','(P2L1L3)foodDeprivation(Week2)', ...
            '(P2L1L3)foodDeprivation(Week3)'};
        BLandFD{1} = mergedTable(mergedTable.referencetime == "06/20/2022" & ...
            mergedTable.health == "N/A",:);
        BLandFD{2} = mergedTable(mergedTable.referencetime == "08/11/2022" & ...
            mergedTable.health == "Food Deprivation",:);
        BLandFD{3} = mergedTable(mergedTable.referencetime == "08/24/2022" & ...
            mergedTable.health == "Food Deprivation",:);
        if splitLightLevel
            dataForHealthType = {'(P2L1L3)L1baseline','(P2L1L3)L3baseline','(P2L1L3)L1foodDeprivation(Week2)', ...
                '(P2L1L3)L3foodDeprivation(Week2)','(P2L1L3)L1foodDeprivation(Week3)', ...
                '(P2L1L3)L3foodDeprivation(Week3)'};
            dataForHealthType{1} = BLandFD{1}(BLandFD{1}.lightlevel == "1",:);
            dataForHealthType{2} = BLandFD{1}(BLandFD{1}.lightlevel == "2",:);
            dataForHealthType{3} = BLandFD{2}(BLandFD{2}.lightlevel == "1",:);
            dataForHealthType{4} = BLandFD{2}(BLandFD{2}.lightlevel == "2",:);
            dataForHealthType{5} = BLandFD{3}(BLandFD{3}.lightlevel == "1",:);
            dataForHealthType{6} = BLandFD{3}(BLandFD{3}.lightlevel == "2",:);
            dataLabel = {'(P2L1L3)L1baseline','(P2L1L3)L3baseline','(P2L1L3)L1foodDeprivation(Week2)', ...
                '(P2L1L3)L3foodDeprivation(Week2)','(P2L1L3)L1foodDeprivation(Week3)', ...
                '(P2L1L3)L3foodDeprivation(Week3)'};
        else
            dataForHealthType = BLandFD;
            dataLabel = {'(P2L1L3)baseline','(P2L1L3)foodDeprivation(Week2)', ...
                '(P2L1L3)foodDeprivation(Week3)'};
        end
    otherwise
        warning("Unexpected taskType");
end
end
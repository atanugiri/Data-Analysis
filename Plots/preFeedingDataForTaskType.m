% Author: Atanu Giri
% Date: 12/11/2022
% This function generates an array of thre tables of baseline and
% one week of Pre-Feeding data based on taskType L1 or L3
function [dataForHealthType,dataLabel] = preFeedingDataForTaskType ...
    (taskType,splitLightLevel,mergedTable,varargin)
% loadFile = load('mergedTable.mat'); mergedTable = loadFile.mergedTable;
% taskType = 1; splitLightLevel = 0;
switch taskType
    case 1
        dataForHealthType = {'(P2L1)baseline','(P2L1)Prefeeding'};
        dataForHealthType{1} = mergedTable(mergedTable.referencetime >= "06/23/2022" & ...
            mergedTable.referencetime <= "06/23/2022" & mergedTable.health == "N/A",:);

%         % Delete dates for which normalization is not possible
%         deleteRows = dataForHealthType{1}.referencetime == "06/23/2022";
%         dataForHealthType{1}(deleteRows,:) = [];

        dataForHealthType{2} = mergedTable(mergedTable.referencetime >= "08/02/2022" & ...
            mergedTable.referencetime <= "08/02/2022" & mergedTable.health == "Pre-Feeding",:);
        dataLabel = {'(P2L1)baseline of PF','(P2L1)Prefeeding'};
    case 2
        BLandPF = {'(P2L3)baseline','(P2L3)Prefeeding'};
        BLandPF{1} = mergedTable(mergedTable.referencetime == "06/20/2022" & ...
            mergedTable.health == 'N/A',:);
        BLandPF{2} = mergedTable(mergedTable.referencetime == "08/04/2022" & ...
            mergedTable.health == 'Pre-Feeding',:);
        if splitLightLevel
            dataForHealthType = {'(P2L1L3)L1baseline','(P2L1L3)L3baseline','(P2L1L3)L1Prefeeding', ...
                '(P2L1L3)L3Prefeeding'};
            dataForHealthType{1} = BLandPF{1}(BLandPF{1}.lightlevel == "1",:);
            dataForHealthType{2} = BLandPF{1}(BLandPF{1}.lightlevel == "2",:);
            dataForHealthType{3} = BLandPF{2}(BLandPF{2}.lightlevel == "1",:);
            dataForHealthType{4} = BLandPF{2}(BLandPF{2}.lightlevel == "2",:);
            dataLabel = {'(P2L1L3)L1 baseline of PF','(P2L1L3)L3 baseline of PF', ...
                '(P2L1L3)L1Prefeeding','(P2L1L3)L3Prefeeding'};
        else
            dataForHealthType = BLandPF;
            dataLabel = {'(P2L3)baseline','(P2L3)Prefeeding'};
        end
    otherwise
        warning("Unexpected taskType");
end
end
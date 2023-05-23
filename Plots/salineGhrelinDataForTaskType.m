% Author: Atanu Giri
% Date: 12/11/2022
% This function generates an array of two tables of saline and
% ghrelin data based on taskType L1 or L3
function [dataForHealthType,dataLabel] = salineGhrelinDataForTaskType ...
    (taskType,splitLightLevel,mergedTable,varargin)
% loadFile = load('mergedTable.mat'); mergedTable = loadFile.mergedTable;
% taskType = 1; splitLightLevel = 0;
switch taskType
    case 1
        dataForHealthType = {'(P2L1)Saline','(P2L1)Ghrelin'};
        salineData = mergedTable(contains(mergedTable.health,'Saline'),:);
        ghrelinData = mergedTable(contains(mergedTable.health,'Ghrelin'),:);
        % Select proper date range
        maleSalineData = salineData(strcmpi(salineData.gender,'Male') & ...
            salineData.referencetime >= "06/27/2022" & ...
            salineData.referencetime <= "07/07/2022",:);
        femaleSalineData = salineData(strcmpi(salineData.gender,'Female') & ...
            salineData.referencetime >= "06/28/2022" & ...
            salineData.referencetime <= "07/13/2022",:);

        maleGhrelinData = ghrelinData(strcmpi(ghrelinData.gender,'Male') & ...
            ghrelinData.referencetime >= "06/27/2022" & ...
            ghrelinData.referencetime <= "07/07/2022",:);
        femaleGhrelinData = ghrelinData(strcmpi(ghrelinData.gender,'Female') & ...
            ghrelinData.referencetime >= "06/28/2022" & ...
            ghrelinData.referencetime <= "07/13/2022",:);

        dataForHealthType{1} = [maleSalineData;femaleSalineData];
        dataForHealthType{2} = [maleGhrelinData;femaleGhrelinData];

%         % Delete dates for which normalization is not possible
%         deleteRowsSaline = dataForHealthType{1}.referencetime == "06/30/2022" | ...
%             dataForHealthType{1}.referencetime == "07/01/2022";
%         dataForHealthType{1}(deleteRowsSaline,:) = [];
% 
%         deleteRowsGhrelin = dataForHealthType{2}.referencetime == "06/30/2022" | ...
%             dataForHealthType{2}.referencetime == "07/01/2022";
%         dataForHealthType{2}(deleteRowsGhrelin,:) = [];
        dataLabel = {'(P2L1)Saline','(P2L1)Ghrelin'};
    case 2
        salineGhrelinData = {'(P2L1L3)Saline','(P2L1L3)Ghrelin'};
        salineData = mergedTable(contains(mergedTable.health,'Saline'),:);
        ghrelinData = mergedTable(contains(mergedTable.health,'Ghrelin'),:);
        % Select proper date range
        maleSalineData = salineData(strcmpi(salineData.gender,'Male') & ...
            salineData.referencetime >= "07/08/2022",:);
        femaleSalineData = salineData(strcmpi(salineData.gender,'Female') & ...
            salineData.referencetime >= "07/14/2022",:);

        maleGhrelinData = ghrelinData(strcmpi(ghrelinData.gender,'Male') & ...
            ghrelinData.referencetime >= "07/08/2022",:);
        femaleGhrelinData = ghrelinData(strcmpi(ghrelinData.gender,'Female') & ...
            ghrelinData.referencetime >= "07/14/2022",:);
        salineGhrelinData{1} = [maleSalineData;femaleSalineData];
        salineGhrelinData{2} = [maleGhrelinData;femaleGhrelinData];
        if splitLightLevel
            dataForHealthType = {'(P2L1L3)L1Saline','(P2L1L3)L3Saline', ...
                '(P2L1L3)L1Ghrelin','(P2L1L3)L3Ghrelin'};
            dataForHealthType{1} = salineGhrelinData{1}(salineGhrelinData{1}.lightlevel == "1",:);
            dataForHealthType{2} = salineGhrelinData{1}(salineGhrelinData{1}.lightlevel == "2",:);
            dataForHealthType{3} = salineGhrelinData{2}(salineGhrelinData{2}.lightlevel == "1",:);
            dataForHealthType{4} = salineGhrelinData{2}(salineGhrelinData{2}.lightlevel == "2",:);
            dataLabel = {'(P2L1L3)L1Saline','(P2L1L3)L3Saline', ...
                '(P2L1L3)L1Ghrelin','(P2L1L3)L3Ghrelin'};
        else
            dataForHealthType = salineGhrelinData;
            dataLabel = {'(P2L1L3)Saline','(P2L1L3)Ghrelin'};
        end
    otherwise
        warning("Unexpected taskType");
end
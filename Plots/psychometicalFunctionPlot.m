% Author: Atanu Giri
% Date: 12/14/2022
% This function plots psychometical function of features according to input

%% Invokes liveDatabaseQueryFun, DataForTaskType, psychometicalFunPlotValues,
%% psychometicalFunPlotOfFeature, figureLimitFun

% taskType: 1(P2L1); 2(P2L1L3)
% healthType: 1(Saline-Ghrelin); 2(Food Deprivation); 3(Pre-Feeding);
% 4(Forced Alcohol)

function [featureForEachSubjectId,avFeature,stdError] = psychometicalFunctionPlot(feature,healthType, ...
    taskType,splitLightLevel,approachTrials,varargin)
% feature = 'approachavoid';healthType = 2;taskType = 1;splitLightLevel = 0;approachTrials = 0;

close all; clc;
% connect to database
datasource = 'live_database';
conn = database(datasource,'postgres','1234');

% How many unique tasktypedone are there?
tasktypedoneQuery = "SELECT tasktypedone FROM featuretable2 ORDER BY id;";
allTasktypedone = fetch(conn,tasktypedoneQuery);
allTasktypedone.tasktypedone = string(allTasktypedone.tasktypedone);
% uniqueTasktypedone = unique(allTasktypedone.tasktypedone);
taskOfInetrest = {'P2L1';'P2L1L3'};

% How many unique rewardComposition are there?
rewardCompositionQuery = "SELECT rewardComposition FROM featuretable2 ORDER BY id;";
allRewardComposition = fetch(conn,rewardCompositionQuery);
allRewardComposition.rewardcomposition = string(allRewardComposition.rewardcomposition);
uniqueRewardComposition = unique(allRewardComposition.rewardcomposition);

% invoke allQueryFun function for query from live_table
liveDatabaseQuery = liveDatabaseQueryFun(healthType,approachTrials);
allData = fetch(conn,liveDatabaseQuery);
featureQuery = sprintf(strcat("SELECT id, tasktypedone, %s, distanceaftertoneuntillimitingtimestamp, intensityofcost1, " + ...
    "intensityofcost2, intensityofcost3 ", ...
    "FROM featuretable2 WHERE rewardcomposition = '%s' AND tasktypedone = '%s' ", ...
    "ORDER BY id;"),feature,uniqueRewardComposition(3),taskOfInetrest{taskType});
featureData = fetch(conn,featureQuery);
% Join two tables by id
mergedTable = innerjoin(allData,featureData,'Keys','id');
% drop the timestamps from referencetime for clustering
mergedTable.referencetime = datetime(mergedTable.referencetime);
mergedTable.referencetime.Format = "MM/dd/yyyy";
% convert all the mergedTable data to string (except for id)
for columns = 2:length(mergedTable.Properties.VariableNames)
    mergedTable.(columns) = string(mergedTable.(columns));
end
% determine if the feature is logical
logicalFeature = any(ismember(mergedTable.(feature),'true') | ismember(mergedTable.(feature),'false'));
if ~logicalFeature
    % convert feature column from string to double
    mergedTable.(feature) = str2double(mergedTable.(feature));
end
% get dataForTaskType
switch healthType
    case 1
        [dataForHealthType,dataLabel] = salineGhrelinDataForTaskType ...
            (taskType,splitLightLevel,mergedTable,varargin);
    case 2
        [dataForHealthType,dataLabel] = foodDeprivationDataForTaskType ...
            (taskType,splitLightLevel,mergedTable,varargin);
    case 3
        [dataForHealthType,dataLabel] = preFeedingDataForTaskType ...
            (taskType,splitLightLevel,mergedTable,varargin);
    otherwise
        warning("Unexpected healthType");
end

% Don't want to plot FoodDeprivation week 2 data
dataForHealthType{2} = [];
dataLabel{2} = [];
% for cellNo = 2:length(dataForHealthType)
%     dataForHealthType{cellNo} = [];
%     dataLabel{cellNo} = [];
% end

% If any cell array is empty remove it
nonEmptyCells = ~cellfun(@isempty,dataForHealthType);
dataForHealthType = dataForHealthType(nonEmptyCells);
dataLabel = dataLabel(nonEmptyCells);


% invoke psychometicalFunPlotValues function for the parameters for plot
[featureForEachSubjectId,avFeature,stdError] ...
    = psychometricFunPlotValues(dataForHealthType,logicalFeature,feature);
% invoke psychometicalFunPlotOfFeature function for plot
[p,h] = psychometricFunPlotOfFeature(featureForEachSubjectId,avFeature, ...
    stdError);
% legend(p{1}{1},dataLabel{1},'Location','northwest');
legend([p{:}],dataLabel(1:length(p)),'Location','northwest');
% invoke figureLimitFun function for y-axis limit
figureLimit = figureLimitFun(feature);
ylim([0 figureLimit]);
% ylim([0 5]); % for entryTime feature
% feature = "Approach Time";
ylabel(sprintf('%s',feature),"Interpreter",'latex','FontSize',15);
sgtitle(sprintf("%s",taskOfInetrest{taskType}));
% save figure
healthTypeLegend = {'SalineGhrelin','FoodDeprivation','PreFeeding','ForcedAlcohol'};
fig_name = sprintf('%s_%s_%s',feature,taskOfInetrest{taskType},healthTypeLegend{healthType});
% print(h,fig_name,'-dpng','-r400');
% savefig(h,sprintf('%s.fig',fig_name));
end
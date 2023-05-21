% Author: Atanu Giri
% Date: 12/11/2022
% This function plot bar graph of features according to input provided
% healthType: 1(Saline-Ghrelin); 2(Food Deprivation); 3(Pre-Feeding)
% taskType: 1(P2L1); 2(P2L1L3)
% splitLightLevel(affects P2L1L3 only): logical(0/1)
% approachTrials = logical(0/1)

function featureComparisonPlot(feature,healthType,taskType,splitLightLevel,approachTrials,varargin)
% feature = 'approachavoid';healthType = 1;taskType = 1;splitLightLevel = 0;approachTrials = 0;
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
featureQuery = sprintf(strcat("SELECT id, tasktypedone, %s, intensityofcost1, " + ...
    "intensityofcost2, intensityofcost3 ", ...
    "FROM featuretable2 WHERE rewardcomposition = '%s' AND tasktypedone = '%s' ", ...
    "ORDER BY id;"),feature,uniqueRewardComposition(2),taskOfInetrest{taskType});
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
logicalFeature = ismember("true",mergedTable.(9)) || ismember("false",mergedTable.(9));
if ~logicalFeature
    % convert feature column from string to double
    mergedTable.(9) = str2double(mergedTable.(9));
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
% invoke barGrpahValues function for the parameters for bar plot
[healthFeatureForEachSubjectId,avFeatureOfHealthType,stdErrHealthType,pValues] ...
    = barGrpahValues(dataForHealthType,logicalFeature);
% invoke barPlotOfFeature function for bar plot
[p,h] = barPlotOfFeature(healthFeatureForEachSubjectId,avFeatureOfHealthType, ...
    stdErrHealthType,pValues);
% invoke figureLimitFun function for y-axis limit
figureLimit = figureLimitFun(feature);
ylim([0 figureLimit]);
label = categorical(dataLabel);
label = reordercats(label,dataLabel);
legend(p,label,'Location','northeast');
ylabel(sprintf('%s',feature),"Interpreter",'latex','FontSize',15);
sgtitle(sprintf("%s",taskOfInetrest{taskType}));
% save figure
healthTypeLegend = {'Saline-Ghrelin','Food Deprivation)','Pre-Feeding'};
fig_name = sprintf('%s_%s_%s',feature,taskOfInetrest{taskType},healthTypeLegend{healthType});
print(h,fig_name,'-dpng','-r400');
end
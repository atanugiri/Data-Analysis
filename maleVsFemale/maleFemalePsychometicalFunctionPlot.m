% Author: Atanu Giri
% Date: 02/01/2023
% This function generate the query to get data from live_database according
% to the input argument

%% health: 1(Saline-Ghrelin), 2(Food-Deprivation [BL, Week2, Week3]),
%% 3(Pre-Feeding[BL, Weel1])

function maleFemalePsychometicalFunctionPlot(feature,healthType, ...
    taskType,splitLightLevel,approachTrials,varargin)
% feature = 'passingcentralzonerejectinitialpresence';healthType = 2;taskType = 1;splitLightLevel = 0;approachTrials = 0;
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
logicalFeature = ismember("true",mergedTable.(feature)) || ismember("false",mergedTable.(feature));
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
% invoke psychometicalFunPlotValues function for the parameters for plot
[whichManipulation,featureForEachSubjectId,avFeatureOfGender,stdErrofGender] ...
    = maleFemalePsychometicalFunPlotValues(dataForHealthType,feature,logicalFeature);

% invoke psychometicalFunPlotOfFeature function for plot
[p,h] = psychometicalFunPlotOfFeature(featureForEachSubjectId,avFeatureOfGender,stdErrofGender);

% invoke figureLimitFun function for y-axis limit
figureLimit = figureLimitFun(feature);
ylim([0 figureLimit]);

% Label the data
label = {'Female','Male'};
legend([p{:}],label(1:length(p)),'Location','northwest');
% feature = "Stopping Points Per Unit Travel";
ylabel(sprintf('%s',feature),"Interpreter",'latex','FontSize',15);
sgtitle(sprintf("%s",dataLabel{whichManipulation}));

% save figure
fig_name = sprintf('%s_%s',feature,dataLabel{whichManipulation});
% print(h,fig_name,'-dpng','-r400');
savefig(h,sprintf('%s.fig',fig_name));
end
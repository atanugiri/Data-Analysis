% Author: Atanu Giri
% Date: 02/09/2023
% This function generate psycometrical function plot according
% to the input argument
% Baseline(N/A): 06/16/2022 - 06/23/2022, Food Deprivation: 08/23/2022 - 08/25/2022

%% Invokes psychometricFunPlotValues, maleFemalePsychometricFunPlotValues
%% psychometricFunPlotOfFeature, figureLimitFun

function featureForEachSubjectId = masterPsychometricFunctionPlot(feature,varargin)
% feature = 'approachavoid';
close all; clc;

% connect to database
datasource = 'live_database';
conn = database(datasource,'postgres','1234');

%% Select genotype
genotypeQuery = "SELECT DISTINCT genotype FROM live_table ORDER BY genotype;";
uniqueGenotype = fetch(conn,genotypeQuery);
uniqueGenotype = string(uniqueGenotype.genotype);
fprintf('Unique genotype:\n');
fprintf('%s, ',uniqueGenotype);
fprintf('\n');
genotype = input('Enter genotype: ','s');


%% Do you want to analyze only approach trials
approachTrials = input('Do you want to analyze only approach trials? (y/n) ', 's');

if strcmpi(approachTrials,'y')
    liveDatabaseQuery = sprintf(strcat("SELECT id, subjectid, referencetime, " + ...
        "gender, feeder, health, lightlevel, genotype FROM live_table WHERE " + ...
        "genotype = '%s' AND approachavoid = '1.000000' ORDER BY id"),genotype);
else
    liveDatabaseQuery = sprintf(strcat("SELECT id, subjectid, referencetime, " + ...
        "gender, feeder, health, lightlevel, genotype FROM live_table WHERE " + ...
        "genotype = '%s' ORDER BY id"),genotype);
end
allData = fetch(conn,liveDatabaseQuery);

%% Select tasktypedone
taskQuery = "SELECT DISTINCT tasktypedone FROM featuretable2 ORDER BY tasktypedone;";
uniqueTask = fetch(conn,taskQuery);
uniqueTask = string(uniqueTask.tasktypedone);
fprintf('Unique tasktypedone:\n');
fprintf('%s, ',uniqueTask);
fprintf('\n');

taskType = input('Enter tasktypedone (or enter "all" for all task types): ','s');

if strcmpi(taskType, 'all')
    % select all task types
    featureQuery = sprintf(strcat("SELECT id, tasktypedone, %s, intensityofcost1, " + ...
        "intensityofcost2, intensityofcost3, rewardconcentration1, rewardconcentration2, ", ...
        "rewardconcentration3, rewardconcentration4 FROM featuretable2 ORDER BY id;"),feature);
else
    % select a specific task type
    featureQuery = sprintf(strcat("SELECT id, tasktypedone, %s, intensityofcost1, " + ...
        "intensityofcost2, intensityofcost3, rewardconcentration1, rewardconcentration2, ", ...
        "rewardconcentration3, rewardconcentration4 FROM featuretable2 WHERE " + ...
        "tasktypedone = '%s' ORDER BY id;"),feature,taskType);
end

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

%% Since there are too many health options, use health as user input
uniqueHealth = unique(mergedTable.health);
fprintf('Unique health types:\n');
numPerLine = 10;
numValues = length(uniqueHealth);
for i = 1:numPerLine:numValues
    fprintf('%s, ', uniqueHealth(i:min(i+numPerLine-1, numValues)));
    fprintf('\n');
end
healthType = input(['Which health types do you want to analyze?\n' ...
    '(enter multiple values separated by comma and a space or type ''all'' for all types): '],'s');
if strcmpi(healthType, 'all')
    allDataOfHealthType = mergedTable;
else
    healthType = strsplit(healthType, ', ');
    allDataOfHealthType = mergedTable(ismember(mergedTable.health, healthType), :);
end

%% Select Dates
uniqueDates = unique(allDataOfHealthType.referencetime);
fprintf('Unique dates:\n');
fprintf('%s, ',uniqueDates);
fprintf('\n');
startDate = input('Start date? ','s');
endDate = input('End date? ','s');

% date filter
dateFilter = (allDataOfHealthType.referencetime >= startDate) & ...
    (allDataOfHealthType.referencetime <= endDate);
dataForHealthType = allDataOfHealthType(dateFilter,:);
dataLabel = sprintf('%s, %s, %s',genotype,taskType,string(healthType));

%% Ask  user if they want to split data by male, female
splitByGender = input('Do you want to split the graph by gender? (y/n) ', 's');

% check the user input and call the appropriate function
if strcmpi(splitByGender, 'y')
    [~,featureForEachSubjectId,avFeature,stdError] ...
        = maleFemalePsychometricFunPlotValues(dataForHealthType,logicalFeature,feature);
    label = {sprintf('Female: %s-%s',startDate,endDate),sprintf('Male: %s-%s',startDate,endDate)};
    %     label = {'Female','Male'};
else
    specificAnimal = input('Do you want to a graph for specific animal? (y/n) ', 's');

    if strcmpi(specificAnimal, 'y')
        males = dataForHealthType.subjectid(strcmpi(dataForHealthType.gender,'Male'),:);
        females = dataForHealthType.subjectid(strcmpi(dataForHealthType.gender,'Female'),:);

        fprintf('Females:\n');
        fprintf('%s, ',unique(females));
        fprintf('\n');
        fprintf('Males:\n');
        fprintf('%s, ',unique(males));
        fprintf('\n');
        whichAnimal = input('Which Animal? ','s');
        dataForHealthType = dataForHealthType(dataForHealthType.subjectid == whichAnimal,:);
        [featureForEachSubjectId,avFeature,stdError] ...
            = psychometricFunPlotValues({dataForHealthType},logicalFeature,feature);
        label = {sprintf('%s: %s-%s',whichAnimal,startDate,endDate)};
    else
        [featureForEachSubjectId,avFeature,stdError] ...
            = psychometricFunPlotValues({dataForHealthType},logicalFeature,feature);
        label = {sprintf('%s_%s',feature,string(healthType))};
    end
end

%% Check if the user needs to fit with a sigmoid curve
% h = sigmoid_fit(cell2mat(avFeature));
% hold on;
% text(2,0.9,label{:},'FontSize', 12, 'FontWeight', 'bold');

%% invoke psychometicalFunPlotOfFeature function for plot
[p,h] = psychometricFunPlotOfFeature(featureForEachSubjectId,avFeature,stdError);
legend([p{:}],label(1:length(p)),'Location','northwest');

% invoke figureLimitFun function for y-axis limit
figureLimit = figureLimitFun(feature);
ylim([0 figureLimit]);

%% Label the data
ylabel(sprintf('%s',feature),"Interpreter",'latex','FontSize',15);
sgtitle(dataLabel,'Interpreter','latex');

% save figure
fig_name = sprintf('%s_%s_%sFrom%s_%s',genotype,taskType,string(healthType),startDate,endDate);
% fig_name = sprintf('%s',whichAnimal);
fig_name = strrep(fig_name, '/', '');
fig_name = strrep(fig_name, ':', '_');
fig_name = strrep(fig_name, ' ', '');
% print(h,fig_name,'-dpng','-r400');
savefig(h,sprintf('%s.fig',fig_name));
end
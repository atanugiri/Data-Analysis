% Author: Atanu Giri
% Date: 04/15/2023
% This function generate psychometric function plot according
% to the input feature only for Oxycodon and Incubation health type.

%% Invokes psychometricFunPlotValues, maleFemalePsychometricFunPlotValues
%% psychometricFunPlotOfFeature, figureLimitFun
function featureForEachSubjectId = oxyPsychometricFunctionPlot(feature,varargin)
% feature = 'approachavoid';
close all; clc;

% connect to database
datasource = 'live_database';
conn = database(datasource,'postgres','1234');

% Invoke getOxyIncubIds
[oxyId, incubationId] = getOxyIncubIds();
oxyId = sprintf('%d,', oxyId); % convert array to string
oxyId = oxyId(1:end-1); % remove last comma
incubationId = sprintf('%d,', incubationId); % convert array to string
incubationId = incubationId(1:end-1); % remove last comma

% Do you want to plot for Oxy or Incubation?
healthType = input('Which data do you want to analyze? Print "Oxycodon" or "Incubation"\n','s');
if strcmpi(healthType,'Oxycodon')
    ids = oxyId;
else
    ids = incubationId;
end

%% Do you want to analyze only approach trials
approachTrials = input('Do you want to analyze only approach trials? (y/n) ', 's');

if strcmpi(approachTrials,'y')
    oxyLiveTableQuery = sprintf("SELECT id, genotype, tasktypedone, subjectid, health, referencetime, " + ...
        "gender, feeder FROM live_table WHERE id IN (%s) AND approachavoid = '1.000000' ORDER BY id;",ids);
else
    oxyLiveTableQuery = sprintf("SELECT id, genotype, tasktypedone, subjectid, health, referencetime, " + ...
        "gender, feeder FROM live_table WHERE id IN (%s) ORDER BY id;",ids);
end
liveTableData = fetch(conn,oxyLiveTableQuery);

featuretableQuery = sprintf("SELECT id, %s FROM featuretable2 WHERE id IN (%s) ORDER BY id;", ...
    feature,ids);
featuretableData = fetch(conn,featuretableQuery);

% Join two tables by id
healthData = innerjoin(liveTableData,featuretableData,'Keys','id');
% drop the timestamps from referencetime for clustering
healthData.referencetime = datetime(healthData.referencetime);
healthData.referencetime.Format = "MM/dd/yyyy";
% convert all the oxyData to string (except for id)
for columns = 2:size(healthData,2)
    healthData.(columns) = string(healthData.(columns));
end
% determine if the feature is logical
logicalFeature = any(ismember(healthData.(feature),'true') | ismember(healthData.(feature),'false'));
if ~logicalFeature
    % convert feature column from string to double
    healthData.(feature) = str2double(healthData.(feature));
end

dataForHealthType = healthData;

%% Ask  user if they want to split data by male, female
splitByGender = input('Do you want to split the graph by gender? (y/n) ', 's');

% check the user input and call the appropriate function
if strcmpi(splitByGender, 'y')
    [~,featureForEachSubjectId,avFeature,stdError] ...
        = maleFemalePsychometricFunPlotValues(dataForHealthType,logicalFeature,feature);
    label = {'Female','Male'};
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
        label = {sprintf('%s',whichAnimal)};
    else
        [featureForEachSubjectId,avFeature,stdError] ...
            = psychometricFunPlotValues({dataForHealthType},logicalFeature,feature);
        label = {'Oxycodon'};
    end
end

%% invoke psychometicalFunPlotOfFeature function for plot
[p,h] = psychometricFunPlotOfFeature(featureForEachSubjectId,avFeature,stdError);
legend([p{:}],label(1:length(p)),'Location','northwest');

% invoke figureLimitFun function for y-axis limit
figureLimit = figureLimitFun(feature);
ylim([0 figureLimit]);

%% Label the data
ylabel(sprintf('%s',feature),"Interpreter",'latex','FontSize',15);
sgtitle(sprintf('%s',healthType),'Interpreter','latex');

% save figure
dataLabel = sprintf('%s_%s',healthType,feature);
fig_name = string(dataLabel);
% print(h,fig_name,'-dpng','-r400');
% savefig(h,sprintf('%s.fig',fig_name));
end
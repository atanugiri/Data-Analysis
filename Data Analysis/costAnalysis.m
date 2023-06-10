% Author: Atanu Giri
% Date: 06/07/2023
% This function plots approach rate and change in approach rate as a
% function of cost for both genders.

%% Invokes psychometricFunctionValues

close all; clc; clear;
% connect to database
datasource = 'live_database';
conn = database(datasource,'postgres','1234');

% Placeholder for data
data = cell(1,3);
dataLabel = {'P2L1Data', 'P2L1L3Data(L1)', 'P2L1L3Data(L3)'};
uniqueSubjects = cell(1,3);

%% Query for P2L1 Data
P2L1DataQuery = "SELECT id, referencetime, gender, health, tasktypedone, subjectid, intensityofcost1, intensityofcost2, " + ...
    "intensityofcost3, lightlevel, feeder, approachavoid FROM live_table WHERE genotype = 'CRL: Long Evans' AND " + ...
    "(tasktypedone = 'P2 L1' OR tasktypedone = 'P2L1') AND lightlevel = '1' AND health = 'N/A' ORDER BY id;";
P2L1Data = fetch(conn,P2L1DataQuery);
data{1} = P2L1Data;

%% Query for P2L1L3(L3) Data
P2L1L3_L1DataQuery = "SELECT id, referencetime, gender, health, tasktypedone, subjectid, intensityofcost1, intensityofcost2, " + ...
    "intensityofcost3, lightlevel, feeder, approachavoid FROM live_table WHERE genotype = 'CRL: Long Evans' AND " + ...
    "(tasktypedone = 'P2 L1L3' OR tasktypedone = 'P2L1L3') AND health = 'N/A' ORDER BY id;";
P2L1L3Data_L1 = fetch(conn,P2L1L3_L1DataQuery);
data{2} = P2L1L3Data_L1;

data{3} = data{2};

% drop the timestamps from referencetime for clustering
for task = 1:size(data,2)
    data{task}.referencetime = datetime(data{task}.referencetime);
    data{task}.referencetime.Format = "MM/dd/yyyy";
    % convert all table data to string (except for id)
    for columns = 2:length(data{task}.Properties.VariableNames)
        data{task}.(columns) = string(data{task}.(columns));
    end
    data{task}.approachavoid = str2double(data{task}.approachavoid);
    data{task}.feeder = str2double(data{task}.feeder);
    uniqueSubjects{task} = unique(data{task}.subjectid);
end

% Choose desired date range for P2L1 tasktype
data{1} = data{1}(data{1}.referencetime >= '06/16/2022' & data{1}.referencetime <= '06/23/2022',:);

intensityOfCostfilter = contains(data{2}.intensityofcost1,'15') & contains(data{2}.intensityofcost3,'290');
% Choose intensity of cost for P2L1L3_L3 tasktype
data{2} = data{2}(intensityOfCostfilter & contains(data{2}.lightlevel,'1'),:);
% Choose intensity of cost for P2L1L3_L3 tasktype
data{3} = data{3}(intensityOfCostfilter & contains(data{3}.lightlevel,'3'),:);

% Make sure subjectids are same in P2L1 and P2L1L3 tasks
uniqueEntriesIn1and2 = intersect(uniqueSubjects{1}, uniqueSubjects{2});
commonEntries = intersect(uniqueEntriesIn1and2, uniqueSubjects{3});

% data with only common animals
for task = 1:size(data,2)
    data{task} = data{task}(ismember(data{task}.subjectid, commonEntries), :);
end

% Initialize an empty cell array
femaleSubjects = {};
maleSubjects = {};

% Iterate over each entry in commonEntries
for i = 1:numel(commonEntries)
    % Get the current entry
    entry = commonEntries{i};

    % Find the first row index where entry matches subjectid in data{1} table
    rowIndex = find(strcmp(data{1}.subjectid, entry), 1);

    % If a matching row is found, retrieve the gender value
    if ~isempty(rowIndex)
        gender = data{1}.gender(rowIndex);

        % Check if the gender value is 'female' or 'Female'
        if strcmpi(gender, 'female') || strcmpi(gender, 'Female')
            % Add the entry to the femaleSubjects cell array
            femaleSubjects = [femaleSubjects, entry];
        elseif strcmpi(gender, 'male') || strcmpi(gender, 'Male')
            maleSubjects = [maleSubjects, entry];
        end
    end
end

% Convert the cell array to a string array
femaleSubjects = string(femaleSubjects);
maleSubjects = string(maleSubjects);

[P2L1FemaleData, P2L1FemaleMean, P2L1FemaleStdErr] = psychometricFunctionValues(data{1},femaleSubjects);
[P2L1MaleData, P2L1MaleMean, P2L1MaleStdErr] = psychometricFunctionValues(data{1},maleSubjects);

[P2L1L3_L1FemaleData, P2L1L3_L1FemaleMean, P2L1L3_L1FemaleStdErr] = psychometricFunctionValues(data{2},femaleSubjects);
[P2L1L3_L1MaleData, P2L1L3_L1MaleMean, P2L1L3_L1MaleStdErr] = psychometricFunctionValues(data{2},maleSubjects);

[P2L1L3_L3FemaleData, P2L1L3_L3FemaleMean, P2L1L3_L3FemaleStdErr] = psychometricFunctionValues(data{3},femaleSubjects);
[P2L1L3_L3MaleData, P2L1L3_L3MaleMean, P2L1L3_L3MaleStdErr] = psychometricFunctionValues(data{3},maleSubjects);

% Plot all approach rates
figure(1);
hold on;
xVal = [1 2 3 4];
errorbar(xVal,P2L1FemaleMean,P2L1FemaleStdErr,'r-o','MarkerFaceColor',[1 0.8 0.8],'LineWidth',2,'Color', [1 0.8 0.8]);
errorbar(xVal,P2L1MaleMean,P2L1MaleStdErr,'b-o','MarkerFaceColor',[0.8 0.8 1],'LineWidth',2,'Color', [0.8 0.8 1]);
errorbar(xVal,P2L1L3_L1FemaleMean,P2L1L3_L1FemaleStdErr,'r-o','MarkerFaceColor',[1 0 0],'LineWidth',2,'Color', [1 0 0]);
% errorbar(xVal,P2L1L3_L3FemaleMean,P2L1L3_L3FemaleStdErr,'r-o','MarkerFaceColor',[0.8 0 0],'LineWidth',2,'Color', [0.8 0 0]);
errorbar(xVal,P2L1L3_L1MaleMean,P2L1L3_L1MaleStdErr,'b-o','MarkerFaceColor',[0 0 1],'LineWidth',2,'Color', [0 0 1]);
% errorbar(xVal,P2L1L3_L3MaleMean,P2L1L3_L3MaleStdErr,'b-o','MarkerFaceColor',[0 0 0.8],'LineWidth',2,'Color', [0 0 0.8]);

% legend
legend({'P2L1L3_L1 Approach Rate (Female)', 'P2L1L3_L3 Approach Rate (Female)', ...
    'P2L1L3_L1 Approach Rate (Male)', 'P2L1L3_L3 Approach Rate (Male)'},'Interpreter','latex');
hold off;
label = [0.5 "" 2 "" 5 "" 9];
set(gca,'xticklabel',label,'TickLabelInterpreter','latex');
xlabel("sucrose concentration","Interpreter","latex",'FontSize',20);
ylabel('Approach rate','Interpreter','latex','FontSize',20);

% Get the change in approach rate
femaleRelativeChange = cell(1,4);
for ratIndex = 1:length(femaleSubjects)
    for conc = 1:4
        change = P2L1L3_L3FemaleData{conc}(ratIndex) - P2L1FemaleData{conc}(ratIndex);
        femaleRelativeChange{conc}(ratIndex) = (change/P2L1FemaleData{conc}(ratIndex))*100;
    end
end

maleRelativeChange = cell(1,4);
for ratIndex = 1:length(maleSubjects)
    for conc = 1:4
        change = P2L1L3_L3MaleData{conc}(ratIndex) - P2L1MaleData{conc}(ratIndex);
        maleRelativeChange{conc}(ratIndex) = (change/P2L1MaleData{conc}(ratIndex))*100;
    end
end

% Get the mean and standard error of relative change
[femaleRelativeChangeMean, femaleRelativeChangeStdErr] = relativeChangeValues(femaleRelativeChange);
[maleRelativeChangeMean, maleRelativeChangeStdErr] = relativeChangeValues(maleRelativeChange);

% Plot relative change
figure(2);
hold on;
errorbar(xVal,femaleRelativeChangeMean,femaleRelativeChangeStdErr,'r-o','MarkerFaceColor',[0.8 0 0],'LineWidth',2,'Color', [0.8 0 0]);
errorbar(xVal,maleRelativeChangeMean,maleRelativeChangeStdErr,'b-o','MarkerFaceColor',[0 0 0.8],'LineWidth',2,'Color', [0 0 0.8]);
hold off;
legend({'Relative change (Female)', 'Relative change (Male)'},'Interpreter','latex');
label = [0.5 "" 2 "" 5 "" 9];
set(gca,'xticklabel',label,'TickLabelInterpreter','latex');
xlabel("sucrose concentration","Interpreter","latex",'FontSize',20);
ylabel('Percent change in approach rate','Interpreter','latex','FontSize',20);

% Write a small function to get relativeChangeMean, relativeChangeStdErr
function [relativeChangeMean, relativeChangeStdErr] = relativeChangeValues(relativeChange)
relativeChangeMean = zeros(1,4);
relativeChangeStdErr = zeros(1,4);
for reward = 1:4
    relativeChangeVector = relativeChange{reward}(isfinite(relativeChange{reward}));
    relativeChangeMean(reward) = mean(relativeChangeVector);
    relativeChangeStdErr(reward) = std(relativeChangeVector)/sqrt(length(relativeChangeVector));
end
end
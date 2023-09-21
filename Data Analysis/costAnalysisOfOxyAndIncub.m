% Author: Atanu Giri
% Date: 08/18/2023

% This function plots approach rate of males and females at different light
% intensity for Oxycodon and Incubation data

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
healthType = input('Which data do you want to analyze? Print "Oxycodon" or "Incubation": ','s');
if strcmpi(healthType,'Oxycodon')
    ids = oxyId;
else
    ids = incubationId;
end

liveTableQuery = sprintf("SELECT id, genotype, subjectid, health, referencetime, " + ...
    "gender, feeder, intensityofcost1, intensityofcost2, intensityofcost3, " + ...
    "tasktypedone, lightlevel, approachavoid FROM live_table WHERE id IN (%s) ORDER BY id;", ids);

lightIntensityData = fetch(conn, liveTableQuery);

% drop the timestamps from referencetime for clustering
lightIntensityData.referencetime = datetime(lightIntensityData.referencetime);
lightIntensityData.referencetime.Format = "MM/dd/yyyy";
% convert all table data to string (except for id)
for columns = 2:length(lightIntensityData.Properties.VariableNames)
    lightIntensityData.(columns) = string(lightIntensityData.(columns));
end

% Convert all intensityofcost columns to uniform format
for col = 8:10
    % Extract numerical part using regular expressions
    numbers = regexp(lightIntensityData.(col), '\d+(\.\d+)?', 'match', 'once');
    for ii = 1:numel(numbers)
        numbers{ii} = sprintf('%.0f',numbers(ii));
    end
    % Convert the cell array of numbers to a numeric array
    lightIntensityData.(col) = str2double(numbers);
end

lightIntensityData.lightlevel = str2double(lightIntensityData.lightlevel);
lightIntensityData.approachavoid = str2double(lightIntensityData.approachavoid);

% Get rid of nan values in lightlevel column
lightlevelFilter = isfinite(lightIntensityData.lightlevel);
lightIntensityData = lightIntensityData(lightlevelFilter,:);

% Get intensityofcost for each trial and store it in an array
intensityofcost = zeros(height(lightIntensityData),1);
for i = 1:height(lightIntensityData)
    currentLightLevel = lightIntensityData.lightlevel(i);
    currentIntensityOfCostCol = lightIntensityData.(7+currentLightLevel);
    intensityofcost(i) = currentIntensityOfCostCol(i);
end

% Add intensityofcost array to table
lightIntensityData.intensityofcost1 = []; lightIntensityData.intensityofcost2 = []; lightIntensityData.intensityofcost3 = [];
lightIntensityData.intensityofcost = intensityofcost;

% Visualize uniqueCostList
uniqueCostList = unique(lightIntensityData.intensityofcost(isfinite(lightIntensityData.intensityofcost)));

taskDataLabel = cell(size(uniqueCostList));
for i = 1:length(uniqueCostList)
    taskDataLabel{i} = sprintf('%s Lux', num2str(uniqueCostList(i)));
end

% Find animals corresponding to each unique cost
animalsInUnqCost = cell(1, numel(uniqueCostList));
for cost = 1:numel(uniqueCostList)
    allAnimals = lightIntensityData.subjectid(lightIntensityData.intensityofcost ...
        == uniqueCostList(cost), :);
    animalsInUnqCost{cost} = unique(allAnimals);
end

femaleArray = cell(1, numel(uniqueCostList));
maleArray = cell(1, numel(uniqueCostList));

for i = 1:numel(uniqueCostList)
    femaleAnimals = []; maleAnimals = [];
    for j = 1:numel(animalsInUnqCost{i})
        animalIndex = find(lightIntensityData.subjectid == animalsInUnqCost{i}(j), 1);
        if strcmpi(lightIntensityData.gender(animalIndex), "Female")
            femaleAnimals = [femaleAnimals; animalsInUnqCost{i}(j)];
        elseif strcmpi(lightIntensityData.gender(animalIndex), "Male")
            maleAnimals = [maleAnimals; animalsInUnqCost{i}(j)];
        end
    end
    femaleArray{i} = femaleAnimals;
    maleArray{i} = maleAnimals;
end

[appRateOfEachFemale, meanValueFemale, stdErrFemale] = psychometricFunctionCostValues( ...
    lightIntensityData, femaleArray, uniqueCostList);
[appRateOfEachMale, meanValueMale, stdErrMale] = psychometricFunctionCostValues( ...
    lightIntensityData, maleArray, uniqueCostList);

% Plot data
myBar(taskDataLabel, meanValueFemale, meanValueMale, stdErrFemale, stdErrMale);



%% Description of myBar
function myBar(taskDataLabel, meanFemale, meanMale, stdErrFemale, stdErrMale)
figure;
hold on;

barWidth = 0.35;  % Width of each bar group
groupOffset = 0.2;  % Offset between male and female bars

for i = 1:length(taskDataLabel)
    xPositions = i - groupOffset : barWidth : i + groupOffset;

    % Plot female data
    bar(xPositions(1), meanFemale(i), barWidth, 'r');
    errorbar(xPositions(1), meanFemale(i), stdErrFemale(i), 'k', 'LineWidth', 1.5);

    % Plot male data
    bar(xPositions(2), meanMale(i), barWidth, 'b');
    errorbar(xPositions(2), meanMale(i), stdErrMale(i), 'k', 'LineWidth', 1.5);
end
ylim([0 1]);
xticks(1:length(taskDataLabel));
xticklabels(taskDataLabel);
xlabel('taskDataLabel');
ylabel('Approach Rate');
legend('Female', '', 'Male', '');
hold off;
end

%% Function to get approach rate for male and female subjects
function [appRateOfEach, meanValue, stdErr] = psychometricFunctionCostValues(data, animalList, costArray)
appRateOfEach = cell(1, numel(costArray));
meanValue = zeros(1, numel(costArray));
stdErr = zeros(1, numel(costArray));

for cost = 1:numel(costArray)
    appRateOfEach{cost} = zeros(numel(animalList{cost}),1);
end

% Collect approach rate data
for cost = 1:numel(costArray)
    for animal = 1:length(animalList{cost})
        subjectid = animalList{cost}(animal);
        dataOfSubjectid = data(data.subjectid == subjectid & data.intensityofcost == costArray(cost), :);
        approachavoidData = dataOfSubjectid.approachavoid(isfinite(dataOfSubjectid.approachavoid));
        appRateOfEach{cost}(animal) = sum(approachavoidData)/length(approachavoidData);
    end
end

% Get mean approach rate at each cost
for cost = 1:numel(costArray)
    approachVector = appRateOfEach{cost}(isfinite(appRateOfEach{cost}));
    meanValue(cost) = mean(approachVector);
    stdErr(cost) = std(approachVector)/sqrt(length(approachVector));
end
end
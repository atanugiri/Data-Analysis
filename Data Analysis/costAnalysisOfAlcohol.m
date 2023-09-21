% Author: Atanu Giri
% Date: 08/18/2023

% Bayesian and Cost analysis approach rate of males and females at different
% light intensity for Initial and late task data

close all; clc;
% connect to database
datasource = 'live_database';
conn = database(datasource,'postgres','1234');

% Do you want to plot for Initial or Late?
healthType = input('Which task do you want to analyze? Print "Initial" or "Late": ','s');
if strcmpi(healthType, 'Initial')
    liveTableQuery = "SELECT id, genotype, subjectid, health, referencetime, " + ...
    "gender, feeder, intensityofcost1, intensityofcost2, intensityofcost3, " + ...
    "tasktypedone, lightlevel, approachavoid FROM live_table WHERE " + ...
    "genotype = 'CRL: Long Evans' AND health = 'N/A' ORDER BY id;";

elseif strcmpi(healthType, 'Late')
    liveTableQuery = "SELECT id, genotype, subjectid, health, referencetime, " + ...
        "gender, feeder, intensityofcost1, intensityofcost2, intensityofcost3, " + ...
        "tasktypedone, lightlevel, approachavoid FROM live_table WHERE " + ...
        "(genotype = 'lg_boost' OR genotype = 'lg_etoh') AND health = 'N/A' ORDER BY id;";

else
    fprintf("Please check input")
end

lightIntensityData = fetch(conn, liveTableQuery);

% drop the timestamps from referencetime for clustering
lightIntensityData.referencetime = datetime(lightIntensityData.referencetime);
lightIntensityData.referencetime.Format = "MM/dd/yyyy";
% convert all table data to string (except for id)
for columns = 2:size(lightIntensityData, 2)
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

% Fix some lightlevel entries to recitify bad databasebase entries
filter320 = lightIntensityData.intensityofcost3 == 320 & lightIntensityData.lightlevel == 2;
lightIntensityData.lightlevel(filter320) = 3;

filterP2L1 = lightIntensityData.tasktypedone == "P2 L1" | lightIntensityData.tasktypedone == "P2L1";
lightIntensityData.lightlevel(filterP2L1) = 1;

analysisType = input('What anslysis do you want? ("Bayesian" or "Cost"): ', 's');

% Fetch all data
if strcmpi(analysisType, 'Cost')
P2Adata = lightIntensityData(lightIntensityData.tasktypedone == 'P2A' & ...
    lightIntensityData.lightlevel == 1 & lightIntensityData.intensityofcost1 == 15, :);
P2L1data = lightIntensityData((lightIntensityData.tasktypedone == 'P2 L1' | ...
    lightIntensityData.tasktypedone == 'P2L1') & lightIntensityData.lightlevel == 1 ...
    & lightIntensityData.intensityofcost1 == 15, :);
P2L1L3data = lightIntensityData((lightIntensityData.tasktypedone == 'P2 L1L3' | ...
    lightIntensityData.tasktypedone == 'P2L1L3') & lightIntensityData.lightlevel == 3 ...
    & lightIntensityData.intensityofcost3 == 320, :);

elseif strcmpi(analysisType, 'Bayesian')
P2Adata = lightIntensityData(lightIntensityData.tasktypedone == 'P2A' & ...
    lightIntensityData.lightlevel == 1 & lightIntensityData.intensityofcost1 == 15, :);
P2L1data = lightIntensityData((lightIntensityData.tasktypedone == 'P2 L1' | ... 
    lightIntensityData.tasktypedone == 'P2L1') & lightIntensityData.lightlevel == 1 ...
    & lightIntensityData.intensityofcost1 == 15, :);
P2L1L3data = lightIntensityData((lightIntensityData.tasktypedone == 'P2 L1L3' | ...
    lightIntensityData.tasktypedone == 'P2L1L3') & lightIntensityData.lightlevel == 1 ...
    & lightIntensityData.intensityofcost1 == 15, :);

else
    fprintf("Please check your input")
end

taskData = cell(1, 3);
taskData{1} = P2Adata; taskData{2} = P2L1data; taskData{3} = P2L1L3data;
taskDataLabel = {'P2A', 'P2L1', 'P2L1L3'};

unqAnimalsInTask = cell(1, numel(taskData));
for task = 1:numel(taskData)
    allAnimals = taskData{task}.subjectid;
    unqAnimalsInTask{task} = unique(allAnimals);
end

[femaleAnimalsP2A, maleAnimalsP2A] = extractMaleFemale(unqAnimalsInTask{1}, taskData{1});
[femaleAnimalsP2L1, maleAnimalsP2L1] = extractMaleFemale(unqAnimalsInTask{2}, taskData{2});
[femaleAnimalsP2L1L3, maleAnimalsP2L1L3] = extractMaleFemale(unqAnimalsInTask{3}, taskData{3});

% Get male and female data for each task
[appRateFeP2A, meanFeP2A, stdErrFeP2A] = psychometricFunctionValues(taskData{1}, femaleAnimalsP2A);
[appRateMaP2A, meanMaP2A, stdErrMaP2A] = psychometricFunctionValues(taskData{1}, maleAnimalsP2A);

[appRateFeP2L1, meanFeP2L1, stdErrFeP2L1] = psychometricFunctionValues(taskData{2}, femaleAnimalsP2L1);
[appRateMaP2L1, meanMaP2L1, stdErrMaP2L1] = psychometricFunctionValues(taskData{2}, maleAnimalsP2L1);

[appRateFeP2L1L3, meanFeP2L1L3, stdErrFeP2L1L3] = psychometricFunctionValues(taskData{3}, femaleAnimalsP2L1L3);
[appRateMaP2L1L3, meanMaP2L1L3, stdErrMaP2L1L3] = psychometricFunctionValues(taskData{3}, maleAnimalsP2L1L3);

% Concatenate all mean values and std error
meanFemale = [meanFeP2A, meanFeP2L1, meanFeP2L1L3];
stdErrFemale = [stdErrFeP2A, stdErrFeP2L1, stdErrFeP2L1L3];

meanMale = [meanMaP2A, meanMaP2L1, meanMaP2L1L3];
stdErrMale = [stdErrMaP2A, stdErrMaP2L1, stdErrMaP2L1L3];

% Plot data
myBar(taskDataLabel, meanFemale, meanMale, stdErrFemale, stdErrMale);

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
title('Bayssian Analysis of Approach Rate at 15 lux');
legend('Female', '', 'Male', '');

hold off;
end

%% Description of extractMaleFemale
function [femaleAnimals, maleAnimals] = extractMaleFemale(animalList, dataTable)
femaleAnimals = []; maleAnimals = [];
for i = 1:numel(animalList)
    animalIndex = find(dataTable.subjectid == animalList(i), 1);
    if strcmpi(dataTable.gender(animalIndex), "Female")
        femaleAnimals = [femaleAnimals; animalList(i)];
    elseif strcmpi(dataTable.gender(animalIndex), "Male")
        maleAnimals = [maleAnimals; animalList(i)];
    end
end
end

%% Function to get approach rate for male and female subjects
function [appRateOfEach, meanValue, stdErr] = psychometricFunctionValues(data, animalList)
appRateOfEach = zeros(1, numel(animalList));

% Collect approach rate data
for animal = 1:length(animalList)
    subjectid = animalList(animal);
    dataOfSubjectid = data(data.subjectid == subjectid, :);
    approachavoidData = dataOfSubjectid.approachavoid(isfinite(dataOfSubjectid.approachavoid));
    appRateOfEach(animal) = sum(approachavoidData)/length(approachavoidData);
end

approachVector = appRateOfEach(isfinite(appRateOfEach));
meanValue = mean(approachVector);
stdErr = std(approachVector)/sqrt(length(approachVector));
end
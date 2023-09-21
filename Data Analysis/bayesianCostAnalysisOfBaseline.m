% Author: Atanu Giri
% Date: 08/17/2023

% This script analyzes approach rate of Baseline animals at 15 lux
% for different tasktype

close all; clc;

% connect to database
datasource = 'live_database';
conn = database(datasource,'postgres','1234');

liveTableQuery = "SELECT id, subjectid, referencetime, " + ...
    "gender, intensityofcost1, intensityofcost2, intensityofcost3, " + ...
    "tasktypedone, lightlevel, approachavoid FROM live_table WHERE " + ...
    "(health = 'N/A' AND genotype = 'CRL: Long Evans') ORDER BY id;";

lightIntensityData = fetch(conn, liveTableQuery);

% drop the timestamps from referencetime for clustering
lightIntensityData.referencetime = datetime(lightIntensityData.referencetime);
lightIntensityData.referencetime.Format = "MM/dd/yyyy";
% convert all table data to string (except for id)
for columns = 2:size(lightIntensityData, 2)
    lightIntensityData.(columns) = string(lightIntensityData.(columns));
end

% Convert all intensityofcost columns to uniform format
for col = 5:7
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

P2L1data = lightIntensityData((lightIntensityData.tasktypedone == 'P2 L1' | ...
    lightIntensityData.tasktypedone == 'P2L1') & lightIntensityData.lightlevel == 1 ...
    & lightIntensityData.intensityofcost1 == 15, :);
P2L1L3data = lightIntensityData((lightIntensityData.tasktypedone == 'P2 L1L3' | ...
    lightIntensityData.tasktypedone == 'P2L1L3') & lightIntensityData.lightlevel == 1 ...
    & lightIntensityData.intensityofcost1 == 15, :);

allLightInP2L1L3data = unique(P2L1L3data.intensityofcost3);

% Collect all 15 lux data corresponding to allLightInP2L1L3data
taskData = cell(1, numel(allLightInP2L1L3data)+1);

taskData{1} = P2L1data;
for i = 2:numel(taskData)
    taskData{i} = P2L1L3data(P2L1L3data.intensityofcost3 == allLightInP2L1L3data(i - 1), :);
end
taskDataLabel = {'P2L1', '162', '218', '240', '260', '290', '320'};


unqAnimalsInTask = cell(1, numel(taskData));
for task = 1:numel(taskData)
    allAnimals = taskData{task}.subjectid;
    unqAnimalsInTask{task} = unique(allAnimals);
end

% User input
whichAnimals = input('Do you want common animals in all tasktypes for analysis? (y or n): ', 's');

if strcmpi(whichAnimals, 'y')
    % Get the common animals
    commonAnimals = unqAnimalsInTask{1};
    % Iterate over the remaining cells and find the common entries
    for i = 2:numel(unqAnimalsInTask)
        commonAnimals = intersect(commonAnimals, unqAnimalsInTask{i});
    end

    % Find male and female animals
    [femaleAnimals, maleAnimals] = extractMaleFemale(commonAnimals, lightIntensityData);

    % Get male and female data for each task
    [appRateFeP2L1, meanFeP2L1, stdErrFeP2L1] = psychometricFunctionValues(taskData{1}, femaleAnimals);
    [appRateMaP2L1, meanMaP2L1, stdErrMaP2L1] = psychometricFunctionValues(taskData{1}, maleAnimals);

    [appRateFe162, meanFe162, stdErrFe162] = psychometricFunctionValues(taskData{2}, femaleAnimals);
    [appRateMa162, meanMa162, stdErrMa162] = psychometricFunctionValues(taskData{2}, maleAnimals);

    [appRateFe218, meanFe218, stdErrFe218] = psychometricFunctionValues(taskData{3}, femaleAnimals);
    [appRateMa218, meanMa218, stdErrMa218] = psychometricFunctionValues(taskData{3}, maleAnimals);

    [appRateFe240, meanFe240, stdErrFe240] = psychometricFunctionValues(taskData{4}, femaleAnimals);
    [appRateMa240, meanMa240, stdErrMa240] = psychometricFunctionValues(taskData{4}, maleAnimals);

    [appRateFe260, meanFe260, stdErrFe260] = psychometricFunctionValues(taskData{5}, femaleAnimals);
    [appRateMa260, meanMa260, stdErrMa260] = psychometricFunctionValues(taskData{5}, maleAnimals);

    [appRateFe290, meanFe290, stdErrFe290] = psychometricFunctionValues(taskData{6}, femaleAnimals);
    [appRateMa290, meanMa290, stdErrMa290] = psychometricFunctionValues(taskData{6}, maleAnimals);

    [appRateFe320, meanFe320, stdErrFe320] = psychometricFunctionValues(taskData{7}, femaleAnimals);
    [appRateMa320, meanMa320, stdErrMa320] = psychometricFunctionValues(taskData{7}, maleAnimals);

    % Concatenate all mean values and std error
    meanFemale = [meanFeP2L1, meanFe162, meanFe218, meanFe240, meanFe260, meanFe290, meanFe320];
    stdErrFemale = [stdErrFeP2L1, stdErrFe162, stdErrFe218, stdErrFe240, stdErrFe260, stdErrFe290, stdErrFe320];

    meanMale = [meanMaP2L1, meanMa162, meanMa218, meanMa240, meanMa260, meanMa290, meanMa320];
    stdErrMale = [stdErrMaP2L1, stdErrMa162, stdErrMa218, stdErrMa240, stdErrMa260, stdErrMa290, stdErrMa320];

    % Plot data
    myBar(taskDataLabel, meanFemale, meanMale, stdErrFemale, stdErrMale);


else
    mergeGender = input('Do you want to merge gender? (y or n): ', 's');
    if strcmpi(mergeGender, 'n')
        % Find male and female animals
        [femaleAnimalsP2L1, maleAnimalsP2L1] = extractMaleFemale(unqAnimalsInTask{1}, taskData{1});
        [femaleAnimals162, maleAnimals162] = extractMaleFemale(unqAnimalsInTask{2}, taskData{2});
        [femaleAnimals218, maleAnimals218] = extractMaleFemale(unqAnimalsInTask{3}, taskData{3});
        [femaleAnimals240, maleAnimals240] = extractMaleFemale(unqAnimalsInTask{4}, taskData{4});
        [femaleAnimals260, maleAnimals260] = extractMaleFemale(unqAnimalsInTask{5}, taskData{5});
        [femaleAnimals290, maleAnimals290] = extractMaleFemale(unqAnimalsInTask{6}, taskData{6});
        [femaleAnimals320, maleAnimals320] = extractMaleFemale(unqAnimalsInTask{7}, taskData{7});


        % Get male and female data for each task
        [appRateFeP2L1, meanFeP2L1, stdErrFeP2L1] = psychometricFunctionValues(taskData{1}, femaleAnimalsP2L1);
        [appRateMaP2L1, meanMaP2L1, stdErrMaP2L1] = psychometricFunctionValues(taskData{1}, maleAnimalsP2L1);

        [appRateFe162, meanFe162, stdErrFe162] = psychometricFunctionValues(taskData{2}, femaleAnimals162);
        [appRateMa162, meanMa162, stdErrMa162] = psychometricFunctionValues(taskData{2}, maleAnimals162);

        [appRateFe218, meanFe218, stdErrFe218] = psychometricFunctionValues(taskData{3}, femaleAnimals218);
        [appRateMa218, meanMa218, stdErrMa218] = psychometricFunctionValues(taskData{3}, maleAnimals218);

        [appRateFe240, meanFe240, stdErrFe240] = psychometricFunctionValues(taskData{4}, femaleAnimals240);
        [appRateMa240, meanMa240, stdErrMa240] = psychometricFunctionValues(taskData{4}, maleAnimals240);

        [appRateFe260, meanFe260, stdErrFe260] = psychometricFunctionValues(taskData{5}, femaleAnimals260);
        [appRateMa260, meanMa260, stdErrMa260] = psychometricFunctionValues(taskData{5}, maleAnimals260);

        [appRateFe290, meanFe290, stdErrFe290] = psychometricFunctionValues(taskData{6}, femaleAnimals290);
        [appRateMa290, meanMa290, stdErrMa290] = psychometricFunctionValues(taskData{6}, maleAnimals290);

        [appRateFe320, meanFe320, stdErrFe320] = psychometricFunctionValues(taskData{7}, femaleAnimals320);
        [appRateMa320, meanMa320, stdErrMa320] = psychometricFunctionValues(taskData{7}, maleAnimals320);

        % Concatenate all mean values and std error
        meanFemale = [meanFeP2L1, meanFe162, meanFe218, meanFe240, meanFe260, meanFe290, meanFe320];
        stdErrFemale = [stdErrFeP2L1, stdErrFe162, stdErrFe218, stdErrFe240, stdErrFe260, stdErrFe290, stdErrFe320];

        meanMale = [meanMaP2L1, meanMa162, meanMa218, meanMa240, meanMa260, meanMa290, meanMa320];
        stdErrMale = [stdErrMaP2L1, stdErrMa162, stdErrMa218, stdErrMa240, stdErrMa260, stdErrMa290, stdErrMa320];

        % Plot data
        myBar(taskDataLabel, meanFemale, meanMale, stdErrFemale, stdErrMale);
    else
        % Do it later
    end
end

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
title('Approach Rate by Concentration and Gender');
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
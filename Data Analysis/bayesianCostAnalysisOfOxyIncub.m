% Author: Atanu Giri
% Date: 08/16/2023

% This script analyzes approach rate of Oxycodon and Incubation animals at 
% 15 lux for different tasktype

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

P1L1data = lightIntensityData(lightIntensityData.tasktypedone == 'P1 L1', :);
P2L1L2data = lightIntensityData(lightIntensityData.tasktypedone == 'P2 L1L2' & lightIntensityData.lightlevel == 1, :);

taskData = cell(1, 2);
taskData{1} = P1L1data; taskData{2} = P2L1L2data;

unqAnimalsInTask = cell(1, numel(taskData));
for task = 1:numel(taskData)
    allAnimals = taskData{task}.subjectid;
    unqAnimalsInTask{task} = unique(allAnimals);
end

% User input
whichAnimals = input('Do you want common animals in 2 tasktypes for analysis? (y or n): ', 's');

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
    [appRateFeP1L1, meanFeP1L1, stdErrFeP1L1] = psychometricFunctionValues(P1L1data, femaleAnimals);
    [appRateMaP1L1, meanMaP1L1, stdErrMaP1L1] = psychometricFunctionValues(P1L1data, maleAnimals);

    [appRateFeP2L1L2, meanFeP2L1L2, stdErrFeP2L1L2] = psychometricFunctionValues(P2L1L2data, femaleAnimals);
    [appRateMaP2L1L2, meanMaP2L1L2, stdErrMaP2L1L2] = psychometricFunctionValues(P2L1L2data, maleAnimals);

    % Plot data
    myBar(meanFeP1L1, meanMaP1L1, meanFeP2L1L2, meanMaP2L1L2, stdErrFeP1L1, stdErrMaP1L1, stdErrFeP2L1L2, stdErrMaP2L1L2);

else
    mergeGender = input('Do you want to merge gender? (y or n): ', 's');
    
    if strcmpi(mergeGender, 'n')
        % Find male and female animals
        [femaleAnimalsP1L1, maleAnimalsP1L1] = extractMaleFemale(unqAnimalsInTask{1}, taskData{1});
        [femaleAnimalsP2L1L2, maleAnimalsP2L1L2] = extractMaleFemale(unqAnimalsInTask{2}, taskData{2});

        % Get male and female data for each task
        [appRateFeP1L1, meanFeP1L1, stdErrFeP1L1] = psychometricFunctionValues(P1L1data, femaleAnimalsP1L1);
        [appRateMaP1L1, meanMaP1L1, stdErrMaP1L1] = psychometricFunctionValues(P1L1data, maleAnimalsP1L1);

        [appRateFeP2L1L2, meanFeP2L1L2, stdErrFeP2L1L2] = psychometricFunctionValues(P2L1L2data, femaleAnimalsP2L1L2);
        [appRateMaP2L1L2, meanMaP2L1L2, stdErrMaP2L1L2] = psychometricFunctionValues(P2L1L2data, maleAnimalsP2L1L2);

        % Plot data
        myBar(meanFeP1L1, meanMaP1L1, meanFeP2L1L2, meanMaP2L1L2, stdErrFeP1L1, stdErrMaP1L1, stdErrFeP2L1L2, stdErrMaP2L1L2);
    
    else
        % Don't split
        [appRateP1L1, meanP1L1, stdErrP1L1] = psychometricFunctionValues(P1L1data, unqAnimalsInTask{1});
        [appRateP2L1L2, meanP2L1L2, stdErrP2L1L2] = psychometricFunctionValues(P2L1L2data, unqAnimalsInTask{2});

        figure;
        bar(1:2, [meanP1L1, meanP2L1L2], 0.4, "green");
        ylim([0 1]);
        hold on;
        errorbar(1:2, [meanP1L1, meanP2L1L2], [stdErrP1L1, stdErrP2L1L2], 'k.', 'LineWidth', 1.5)
        hold off;
    end
end


%% Description of myBar
function myBar(meanFeP1L1, meanMaP1L1, meanFeP2L1L2, meanMaP2L1L2, stdErrFeP1L1, stdErrMaP1L1, stdErrFeP2L1L2, stdErrMaP2L1L2)
h = figure;
barWidth = 0.4;
barCenters = 1:2;
bar(barCenters - barWidth/2, [meanFeP1L1, meanFeP2L1L2], barWidth, 'r');
hold on;
bar(barCenters + barWidth/2, [meanMaP1L1, meanMaP2L1L2], barWidth, 'b');
errorbar(barCenters - barWidth/2, [meanFeP1L1, meanFeP2L1L2], [stdErrFeP1L1, stdErrFeP2L1L2], 'k.', 'LineWidth', 1.5);
errorbar(barCenters + barWidth/2, [meanMaP1L1, meanMaP2L1L2], [stdErrMaP1L1, stdErrMaP2L1L2], 'k.', 'LineWidth', 1.5);
ylim([0 1]);
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
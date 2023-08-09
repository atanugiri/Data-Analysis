% Author: Atanu Giri
% Date: 06/10/2023
% This function plots approach rate of males and females at different light intensity

function [appRateOfEachFemale, appRateOfEachMale] = approachRateAtDifferentCost
close all; clc; clear;
% connect to database
datasource = 'live_database';
conn = database(datasource,'postgres','1234');

%% Query for Data
lightIntensityQuery = "SELECT id, referencetime, gender, health, tasktypedone, subjectid, intensityofcost1, intensityofcost2, " + ...
    "intensityofcost3, lightlevel, approachavoid FROM live_table WHERE genotype = 'CRL: Long Evans' AND " + ...
    "health = 'N/A' ORDER BY id;";
lightIntensityData = fetch(conn,lightIntensityQuery);

% drop the timestamps from referencetime for clustering
lightIntensityData.referencetime = datetime(lightIntensityData.referencetime);
lightIntensityData.referencetime.Format = "MM/dd/yyyy";
% convert all table data to string (except for id)
for columns = 2:length(lightIntensityData.Properties.VariableNames)
    lightIntensityData.(columns) = string(lightIntensityData.(columns));
end

% Convert all intensityofcost columns to uniform format
for col = 7:9
    % Extract numerical part using regular expressions
    numbers = regexp(lightIntensityData.(col), '\d+(\.\d+)?', 'match', 'once');
    for ii = 1:numel(numbers)
        numbers{ii} = sprintf('%.0f',numbers(ii));
    end
    % Convert the cell array of numbers to a numeric array
    lightIntensityData.(col) = str2double(numbers);
end

% Choose subjects
femaleSubjects = ["alexis", "andrea", "fiona", "harley", "juana", "kryssia", ...
    "neftali", "raissa", "raven", "renata", "sarah", "shakira"];
maleSubjects = ["aladdin", "carl", "jafar", "jimi", "johnny", "jr", "kobe", ...
    "mike", "scar", "simba", "sully"];
subjectFilter = ismember(lightIntensityData.subjectid, [femaleSubjects, maleSubjects]);
lightIntensityData = lightIntensityData(subjectFilter, :);

lightIntensityData.lightlevel = str2double(lightIntensityData.lightlevel);
lightIntensityData.approachavoid = str2double(lightIntensityData.approachavoid);

% Fix some lightlevel entries to recitify bad databasebase entries
filter320 = lightIntensityData.intensityofcost3 == 320 & lightIntensityData.lightlevel == 2;
lightIntensityData.lightlevel(filter320) = 3;

filter290 = lightIntensityData.intensityofcost3 == 290 & lightIntensityData.lightlevel == 2;
lightIntensityData.lightlevel(filter290) = 3;

filter218 = lightIntensityData.intensityofcost3 == 218 & lightIntensityData.lightlevel == 2;
lightIntensityData.lightlevel(filter218) = 3;

filterP2L1 = lightIntensityData.tasktypedone == "P2 L1" | lightIntensityData.tasktypedone == "P2L1";
lightIntensityData.lightlevel(filterP2L1) = 1;

% Get rid of nan values in lightlevel column
lightlevelFilter = isfinite(lightIntensityData.lightlevel);
lightIntensityData = lightIntensityData(lightlevelFilter,:);

% Get intensityofcost for each trial and store it in an array
intensityofcost = zeros(height(lightIntensityData),1);
for i = 1:height(lightIntensityData)
    currentLightLevel = lightIntensityData.lightlevel(i);
    currentIntensityOfCostCol = lightIntensityData.(6+currentLightLevel);
    intensityofcost(i) = currentIntensityOfCostCol(i);
end

% Add intensityofcost array to table
lightIntensityData.intensityofcost1 = []; lightIntensityData.intensityofcost2 = []; lightIntensityData.intensityofcost3 = [];
lightIntensityData.intensityofcost = intensityofcost;

% Remove data below 240lux
lightIntensityData = lightIntensityData(lightIntensityData.intensityofcost >= 240, :);

% Loop through all light intensities for each subject
uniqueSubjects = unique(lightIntensityData.subjectid);

costValuesOfEachAnimal = cell(1,numel(uniqueSubjects));
for animal = 1:numel(uniqueSubjects)
    animalData = lightIntensityData(lightIntensityData.subjectid == uniqueSubjects(animal),:);
    % Unique intensityofcost values
    costValues = unique(animalData.intensityofcost);
    costValues = costValues(isfinite(costValues));
    costValuesOfEachAnimal{animal} = sort(costValues);
end

% Get the common cost entries
commonCost = costValuesOfEachAnimal{1};
% Iterate over the remaining cells and find the common entries
for i = 2:numel(costValuesOfEachAnimal)
    commonCost = intersect(commonCost, costValuesOfEachAnimal{i});
end

% Ask if user wants average plot
averagePlot = input('Do you want average plot? (y/n) ', 's');

% Intiate a if-else condition
if strcmpi(averagePlot,'y')
    [appRateOfEachFemale, meanValueFemale, stdErrFemale] = psychometricFunctionCostValues(lightIntensityData, femaleSubjects, commonCost);
    [appRateOfEachMale, meanValueMale, stdErrMale] = psychometricFunctionCostValues(lightIntensityData, maleSubjects, commonCost);

    % Plot approach rate at different cost
    h = figure;
    hold on;
    %   psychometric plot
    errorbar(commonCost,meanValueFemale,stdErrFemale,'r-o','MarkerFaceColor',[1 0 0],'LineWidth',2,'Color', [0.8 0 0]);
    errorbar(commonCost,meanValueMale,stdErrMale,'b-o','MarkerFaceColor',[0 0 1],'LineWidth',2,'Color', [0 0 0.8]);
    %     ylim([0 1]);
    xlabel('Cost value','Interpreter','latex','FontSize',20);
    ylabel('Approach rate','Interpreter','latex','FontSize',20);
    legend("Female","Male");
    hold off;

    % bar plot
    %     barWidth = 0.4;
    %     barCenters = 1:4;
    %     bar(barCenters - barWidth/2, meanValueFemale, barWidth, 'r');
    %     hold on;
    %     bar(barCenters + barWidth/2, meanValueMale, barWidth, 'b');
    %     errorbar(barCenters - barWidth/2, meanValueFemale, stdErrFemale, 'k.', 'LineWidth', 1);
    %     errorbar(barCenters + barWidth/2, meanValueMale, stdErrMale, 'k.', 'LineWidth', 1);
    %     ylim([0 1]);
    %     hold off;

    % Label graph
    %     xlabel('Light intensity',"Interpreter","latex");
    %     ylabel('Aproach rate',"Interpreter","latex");
    %     legend('Female', 'Male');
    %     title('Effect of cost on approach rate');
    %     xticks(barCenters); % Set the x-axis tick locations
    %     xticklabels({'240 lux', '260 lux', '290 lux', '320 lux'});
    %     set(gca, 'TickLabelInterpreter', 'latex');
else
    h = figure;
    hold on;
    for female = 1:numel(femaleSubjects)
        subject = femaleSubjects(female);
        [~, meanValueFemale, ~] = psychometricFunctionCostValues(lightIntensityData, subject, commonCost);
        plot(commonCost, meanValueFemale, 'r-o','MarkerFaceColor',[1 0 0],'LineWidth',1.5);
    end
    for male = 1:numel(maleSubjects)
        subject = maleSubjects(male);
        [~, meanValueMale, ~] = psychometricFunctionCostValues(lightIntensityData, subject, commonCost);
        plot(commonCost, meanValueMale, 'b-o','MarkerFaceColor',[0 0 1],'LineWidth',1.5);
    end
    hold off;
end

% save plot
% savefig(h,'costAnalysisPlot.fig');

%% Function to get approach rate for male and female subjects
    function [appRateOfEach, meanValue, stdErr] = psychometricFunctionCostValues(data, animalList, costArray)
        appRateOfEach = cell(1, numel(costArray));
        meanValue = zeros(numel(costArray), 1);
        stdErr = zeros(numel(costArray), 1);

        for cost = 1:numel(costArray)
            appRateOfEach{cost} = zeros(numel(animalList),1);
        end

        % Collect approach rate data
        for ratIndex = 1:length(animalList)
            for cost = 1:numel(costArray)
                subjectid = animalList(ratIndex);
                dataOfSubjectid = data(data.subjectid == subjectid & data.intensityofcost == costArray(cost), :);
                approachavoidData = dataOfSubjectid.approachavoid(isfinite(dataOfSubjectid.approachavoid));
                appRateOfEach{cost}(ratIndex) = sum(approachavoidData)/length(approachavoidData);
            end
        end

        % Get mean approach rate at each cost
        for cost = 1:numel(costArray)
            approachVector = appRateOfEach{cost}(isfinite(appRateOfEach{cost}));
            meanValue(cost) = mean(approachVector);
            stdErr(cost) = std(approachVector)/sqrt(length(approachVector));
        end
    end
end
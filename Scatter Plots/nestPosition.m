% Author: Atanu Giri
% Date: 10/03/2022
% This script maps the scatter plot for animal trajectories in a particular
% maze to see if the animal forms a nest for a certain healthtype.

close all; clc;

% connect to database
datasource = 'live_database';
conn = database(datasource,'postgres','1234');

% Select genotype
genotypeQuery = "SELECT DISTINCT genotype FROM live_table;";
uniqueGenotype = fetch(conn,genotypeQuery);
uniqueGenotype = string(uniqueGenotype.genotype);
fprintf('Unique genotype:\n');
fprintf('%s, ',uniqueGenotype);
fprintf('\n');
genotype = input('Enter genotype: ','s');

% Since there are too many health options, use health as user input
healthQuery = "SELECT DISTINCT health FROM live_table;";
uniqueHealth = fetch(conn, healthQuery);
fprintf('Unique health types:\n');
numPerLine = 10;
numValues = length(uniqueHealth.health);
for i = 1:numPerLine:numValues
    fprintf('%s, ', uniqueHealth.health{i:min(i+numPerLine-1, numValues)});
    fprintf('\n');
end

healthType = input('Which health types do you want to analyze? ' ,'s');

% Select animal name
animalQuery = "SELECT DISTINCT subjectid FROM live_table;";
uniqueAnimal = fetch(conn, animalQuery);
fprintf('Unique animals:\n');
numValues = length(uniqueAnimal.subjectid);
for i = 1:numPerLine:numValues
    fprintf('%s, ', uniqueAnimal.subjectid{i:min(i+numPerLine-1, numValues)});
    fprintf('\n');
end

whichAnimal = input('Which animal? ','s');

% Select tasktypedone
taskQuery = "SELECT DISTINCT tasktypedone FROM live_table;";
uniqueTask = fetch(conn, taskQuery);
fprintf('Unique tasks:\n');
numValues = length(uniqueTask.tasktypedone);
for i = 1:numPerLine:numValues
    fprintf('%s, ', uniqueTask.tasktypedone{i:min(i+numPerLine-1, numValues)});
    fprintf('\n');
end

task = input('Which task? ','s');

% Fetch data
liveDatabaseQuery = sprintf(strcat("SELECT id, subjectid, referencetime, " + ...
    "tasktypedone, gender, health, lightlevel, genotype, coordinatetimes2, " + ...
    "xcoordinates2, ycoordinates2, mazenumber, feeder FROM live_table WHERE " + ...
    "genotype = '%s' AND health = '%s' AND subjectid = '%s' AND " + ...
    "tasktypedone = '%s' ORDER BY id"), genotype, healthType, whichAnimal, task);

subjectData = fetch(conn,liveDatabaseQuery);

% drop the timestamps from referencetime for clustering
subjectData.referencetime = datetime(subjectData.referencetime);
subjectData.referencetime.Format = "MM/dd/yyyy";
subjectData.feeder = str2double(subjectData.feeder);

% remove space from mazenumber
subjectData.mazenumber = char(lower(strrep(subjectData.mazenumber,' ','')));
subjectData.subjectid = string(subjectData.subjectid);
subjectData.tasktypedone = string(subjectData.tasktypedone);
subjectData.referencetime = string(subjectData.referencetime);

% Select maximum entry for a date
uniqueDates = unique(subjectData.referencetime);
numberOfOccurance = zeros(length(uniqueDates),1);
for targetString = 1:length(uniqueDates)
    occurrenceCount = 0;
    for i = 1:length(subjectData.referencetime)
        if subjectData.referencetime(i) == uniqueDates(targetString)
            occurrenceCount = occurrenceCount+1;
        end
    end
    numberOfOccurance(targetString) = occurrenceCount;
end
maxValue = max(numberOfOccurance);
indexOfMaxOccurance = find(numberOfOccurance == maxValue,1);
subjectData = subjectData(subjectData.referencetime == uniqueDates(indexOfMaxOccurance),:);

% Accessing PGArray data as double
for column = 9:11
    allTrials = cell(height(subjectData),1);
    for idx = 1:length(allTrials)
        stringData = string(subjectData.(column)(idx,1));
        regexData = regexprep(stringData,'{|}','');
        splitData = split(regexData,',');
        allTrials{idx,1} = str2double(splitData);
        subjectData.(column){idx,1} = allTrials{idx,1};
    end
end

% concatenate all X and Y coordinates
allT = vertcat(subjectData.coordinatetimes2{:});
allX = vertcat(subjectData.xcoordinates2{:}); 
allY = vertcat(subjectData.ycoordinates2{:});

% invoke coordinateNormalization function to normalize the coordinates
[xNorm, yNorm] = coordinateNormalization(allX,allY,subjectData.id(1));

% remove nan entries
badDataWithTone = table(allT,xNorm,yNorm,'VariableNames',{'t','X','Y'});
cleanedData = badDataWithTone;
% remove nan values
idx = all(isfinite(cleanedData{:,:}),2);
cleanedData = cleanedData(idx,:);

% set figure limit
maze = {'maze2','maze1','maze3','maze4'};
figureLimit = {{[-0.2 1.2],[-0.2 1.2]},{[-1.2 0.2],[-0.2 1.2]}, ...
    {[-1.2 0.2],[-1.2 0.2]},{[-0.2 1.2],[-1.2 0.2]}};
% get the index in maze array
mazeIndex = find(ismember(maze,subjectData.mazenumber(1,:)));

% Find the edge of x and y for histogram plot
xEdgeLeft = figureLimit{mazeIndex}{1}(1); xEdgeRight = figureLimit{mazeIndex}{1}(2);
yEdgeLeft = figureLimit{mazeIndex}{2}(1); yEdgeRight = figureLimit{mazeIndex}{2}(2);
cleanedData = cleanedData(cleanedData.X > xEdgeLeft & cleanedData.X < xEdgeRight ...
    & cleanedData.Y > yEdgeLeft & cleanedData.Y < yEdgeRight,:);

% plot figure
h = figure;
plot(cleanedData.X, cleanedData.Y, 'k.');
xlim(figureLimit{mazeIndex}{1}); ylim(figureLimit{mazeIndex}{2});

% shade feeder zones by calling mazeMethods
mazeMethods(mazeIndex,1);
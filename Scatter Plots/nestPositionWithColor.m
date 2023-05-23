% Author: Atanu Giri
% Date: 12/28/2022
% This function maps the heatplot for animal trajectories over the
% healthtype in a particular maze to see if the animal forms a nest for a
% certain healthtype.

% Inputs: animal, healthtype, maze number

function nestPositionWithColor(animal,healthType,taskType,approachTrials,splitLightLevel,varargin)
% animal = 'raissa'; healthType = 1; taskType = 1; approachTrials = 0; splitLightLevel = 0;
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
liveTableData = fetch(conn,liveDatabaseQuery);
% get few other columns from live_table
wantedId = sprintf('%d,', liveTableData.id); % convert array to string
wantedId = wantedId(1:end-1); % remove last comma
moreQuery = sprintf("SELECT id, coordinatetimes2, xcoordinates2, ycoordinates2, " + ...
    "mazenumber FROM live_table WHERE id IN (%s)", wantedId);
moreData = fetch(conn,moreQuery);
allTrials = innerjoin(liveTableData,moreData,'Keys','id');

% get data from featuretable2
featureQuery = sprintf(strcat("SELECT id, tasktypedone, entrytime " + ...
    "FROM featuretable2 WHERE rewardcomposition = '%s' AND tasktypedone = '%s' ", ...
    "ORDER BY id;"),uniqueRewardComposition(2),taskOfInetrest{taskType});
featureData = fetch(conn,featureQuery);
% close conn;
% Join two tables by id
mergedTable = innerjoin(allTrials,featureData,'Keys','id');
% drop the timestamps from referencetime for clustering
mergedTable.referencetime = datetime(mergedTable.referencetime);
mergedTable.referencetime.Format = "MM/dd/yyyy";
% format mergedTable
mergedTable.feeder = str2double(mergedTable.feeder);
mergedTable.entrytime = str2double(mergedTable.entrytime);

% remove space from mazenumber
mergedTable.mazenumber = char(lower(strrep(mergedTable.mazenumber,' ','')));
mergedTable.subjectid = string(mergedTable.subjectid);
mergedTable.tasktypedone = string(mergedTable.tasktypedone);
mergedTable.referencetime = string(mergedTable.referencetime);

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


for health = 1:length(dataForHealthType)
    subjectData = dataForHealthType{health}(dataForHealthType{health}.subjectid ...
        == sprintf('%s',animal),:);
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

    %%
    % Accessing PGArray data as double
    %
    for column = 8:10
        allTrials = cell(height(subjectData),1);
        for idx = 1:length(allTrials)
            stringData = string(subjectData.(column)(idx,1));
            regexData = regexprep(stringData,'{|}','');
            splitData = split(regexData,',');
            allTrials{idx,1} = str2double(splitData);
            subjectData.(column){idx,1} = allTrials{idx,1};
        end
    end
    % Plot all X and Y coordinates separately
    h = figure;
    for row = 1:height(subjectData)
        % remove nan entries
        badDataWithTone = table(subjectData.coordinatetimes2{row}, ...
            subjectData.xcoordinates2{row},subjectData.ycoordinates2{row}, ...
            'VariableNames',{'t','X','Y'});
        cleanedData = badDataWithTone;
        % remove nan values
        idx = all(isfinite(cleanedData{:,:}),2);
        cleanedData = cleanedData(idx,:);

        % Check if the camera moved during these trials
        %         plot(cleanedData.X,cleanedData.Y,'.k');
        %         hold on;
        % invoke coordinateNormalization function to normalize the coordinates
        [xNorm, yNorm] = coordinateNormalization(cleanedData.X, ...
            cleanedData.Y,subjectData.id(row));
        % set entryTime flag
        entryTimeIndex = find(cleanedData.t == subjectData.entrytime(row));
        plot(xNorm(1:entryTimeIndex-1),yNorm(1:entryTimeIndex-1),'.k');
        hold on;
        plot(xNorm(entryTimeIndex:end),yNorm(entryTimeIndex:end),'.r');
    end
    % set figure limit
    maze = {'maze2','maze1','maze3','maze4'};
    figureLimit = {{[-0.2 1.2],[-0.2 1.2]},{[-1.2 0.2],[-0.2 1.2]}, ...
        {[-1.2 0.2],[-1.2 0.2]},{[-0.2 1.2],[-1.2 0.2]}};
    % get the index in maze array
    mazeIndex = find(ismember(maze,subjectData.mazenumber(1,:)));

    % Find the edge of x and y for histogram plot
%     xEdgeLeft = figureLimit{mazeIndex}{1}(1); xEdgeRight = figureLimit{mazeIndex}{1}(2);
%     yEdgeLeft = figureLimit{mazeIndex}{2}(1); yEdgeRight = figureLimit{mazeIndex}{2}(2);
%     cleanedData = cleanedData(cleanedData.X > xEdgeLeft & cleanedData.X < xEdgeRight ...
%         & cleanedData.Y > yEdgeLeft & cleanedData.Y < yEdgeRight,:);

    % set figure limit
    xlim(figureLimit{mazeIndex}{1}); ylim(figureLimit{mazeIndex}{2});

    % shade feeder zones by calling mazeMethods
    mazeMethods(mazeIndex,1);

    xlabel('X (normalized)',"Interpreter",'latex','FontSize',15);
    ylabel('Y (normalized)',"Interpreter",'latex','FontSize',15);
    fig_name = sprintf('%s %s',animal,dataLabel{health});
    title(fig_name, 'FontSize', 15, 'Color', 'r', 'HorizontalAlignment', 'center');
    %     save figure
    print(h,fig_name,'-dpng','-r400');
    savefig(h,sprintf('%s.fig',fig_name));
    %     h = histogram2(cleanedData.X,cleanedData.Y,[20 20], ...
    % 'DisplayStyle','tile','ShowEmptyBins','on');
end
end
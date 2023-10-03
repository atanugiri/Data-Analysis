% Author: Atanu Giri
% Date: 11/22/2022
% This function takes the id as input and uses the corresponding date
% to remove the outlier/bad data of all the trials on the date. 
% The clean data is used as reference to normalize the data for plotting trajectory

function [xCleanedByYAxis,yCleanedByYAxis] = cleanedDataOnDate(id)
% id = 1103;
% connection
datasource = 'live_database';
conn = database(datasource,'postgres','1234');
dateQuery = sprintf("SELECT referencetime FROM live_table WHERE id = %d;", id);
subjectData = fetch(conn,dateQuery);

% We need same tasktype as id for coherent normalization
taskTypeDoneQuery = sprintf("SELECT tasktypedone FROM live_table WHERE id = %d;", id);
taskTypeDone = fetch(conn,taskTypeDoneQuery);

% drop the timestamps from referencetime for clustering
referencetime = char(subjectData.referencetime);
thisDate = referencetime(1:10);
% Select data of same date
dataOnDateQuery = strcat("SELECT id, xcoordinates2, ycoordinates2 " + ...
    "FROM live_table WHERE referencetime LIKE '",sprintf('%s',thisDate), "%';");
dataOnDate = fetch(conn,dataOnDateQuery);

% Get ids with same tasktype from featuretable2
sameTaskTypeQuery = strcat(sprintf("SELECT id " + ...
    "FROM live_table WHERE tasktypedone = '%s';",string(taskTypeDone.tasktypedone)));

sameTaskTypeId = fetch(conn,sameTaskTypeQuery);

% update dataOnDate with same tasktype 
dataOnDate = innerjoin(sameTaskTypeId,dataOnDate,"Keys",'id');

%%
% Accessing PGArray data as double
%
all_xcoordinates = cell(length(dataOnDate.xcoordinates2),1);
for idx = 1:length(dataOnDate.xcoordinates2)
    string_all_xcoordinates = string(dataOnDate.xcoordinates2(idx,1));
    reg_all_xcoordinates = regexprep(string_all_xcoordinates,'{|}','');
    split_all_xcoordinates = split(reg_all_xcoordinates,',');
    all_xcoordinates{idx,1} = str2double(split_all_xcoordinates);
    dataOnDate.xcoordinates2{idx,1} = all_xcoordinates{idx,1};
end
all_ycoordinates = cell(length(dataOnDate.ycoordinates2),1);
for idx = 1:length(dataOnDate.ycoordinates2)
    string_all_ycoordinates = string(dataOnDate.ycoordinates2(idx,1));
    reg_all_ycoordinates = regexprep(string_all_ycoordinates,'{|}','');
    split_all_ycoordinates = split(reg_all_ycoordinates,',');
    all_ycoordinates{idx,1} = str2double(split_all_ycoordinates);
    dataOnDate.ycoordinates2{idx,1} = all_ycoordinates{idx,1};
end
%%
% Collect all xcoordinates2, ycoordinates2 for all subjects on the
% date to define Maze coordinates
%
xcoordinates2 = vertcat(dataOnDate.xcoordinates2{:});
ycoordinates2 = vertcat(dataOnDate.ycoordinates2{:});
data_on_date_table = table(xcoordinates2, ycoordinates2);

% remove nan values
idx = all(isfinite(data_on_date_table{:,:}),2);
data_on_date_table = data_on_date_table(idx,:);

% % Plot uncleaned data
% plot(data_on_date_table.xcoordinates2,data_on_date_table.ycoordinates2,'k.');

% create a container for data for all mazes
Maze = {'Maze2','Maze1','Maze3','Maze4'};
% define the coordinates of the mazes
Maze{1} = data_on_date_table(data_on_date_table.xcoordinates2>=0 ...
    & data_on_date_table.ycoordinates2>=0,:);
Maze{2} = data_on_date_table(data_on_date_table.xcoordinates2<=0 ...
    & data_on_date_table.ycoordinates2>=0,:);
Maze{3} = data_on_date_table(data_on_date_table.xcoordinates2<=0 ...
    & data_on_date_table.ycoordinates2<=0,:);
Maze{4} = data_on_date_table(data_on_date_table.xcoordinates2>=0 ...
    & data_on_date_table.ycoordinates2<=0,:);

% Create a container for clean x and y coordinates
xCleanedByYAxis = {'xCleanMaze2','xCleanMaze1','xCleanMaze3','xCleanMaze4'};
yCleanedByYAxis = {'yCleanMaze2','yCleanMaze1','yCleanMaze3','yCleanMaze4'};

% populate clean x and y ordiantes for each maze using loop
for i = 1:length(Maze)
    xOriginal = Maze{i}.xcoordinates2;
    yOriginal = Maze{i}.ycoordinates2;
%     plot(xOriginal,yOriginal,'k.');
    %%
    % Clean up data/remove outliers separately along X and Y axis
    %
    % clean X axis data
    [countsOfX, edgesOfX] = histcounts(xOriginal, 100);
    theCDFofX = rescale(cumsum(countsOfX) / sum(countsOfX), 0, 100);
    % Find the index of the 5% and 95% points
    index1ofX = find(theCDFofX > 5, 1, 'first');
    x1ofMaze = edgesOfX(index1ofX);
    index2ofX = find(theCDFofX > 95, 1, 'first');
    x2ofMaze = edgesOfX(index2ofX);
    % Get a mask for the x values we want to exclude
    indexesToKeepOfX = xOriginal >= x1ofMaze & xOriginal <= x2ofMaze;
    xCleanedByXAxis = xOriginal(indexesToKeepOfX);
    yCleanedByXAxis = yOriginal(indexesToKeepOfX);

    % clean y axis data
    [countsOfY, edgesOfY] = histcounts(yCleanedByXAxis, 100);
    theCDFofY = rescale(cumsum(countsOfY) / sum(countsOfY), 0, 100);
    % Find the index of the 5% and 95% points
    index1ofY = find(theCDFofY > 5, 1, 'first');
    y1ofMaze = edgesOfY(index1ofY);
    index2ofY = find(theCDFofY > 95, 1, 'first');
    y2ofMaze = edgesOfY(index2ofY);
    % Get a mask for the x values we want to exclude
    indexesToKeepOfY = yCleanedByXAxis >= y1ofMaze & yCleanedByXAxis <= y2ofMaze;
    xCleanedByYAxis{i} = xCleanedByXAxis(indexesToKeepOfY);
    yCleanedByYAxis{i} = yCleanedByXAxis(indexesToKeepOfY);


%     % plot raw vs clean data
%     subplot(2, 1, 1);
%     plot(xOriginal, yOriginal, 'r.', 'MarkerSize', 8);
%     title('Raw Data');
%     hold on;
%     subplot(2, 1, 2);
%     plot(xCleanedByYAxis{i}, yCleanedByYAxis{i}, 'r.', 'MarkerSize', 8);
%     title('Cleaned Data');
%     linkaxes([subplot(2,1,1),subplot(2,1,2)],'xy')
%     hold off; clf;
end
end
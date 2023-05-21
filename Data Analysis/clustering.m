% Author: Atanu Giri
% Date: 03/22/2023
% This function gives scatterplot of two features for clustering

function h = clustering(feature1,feature2)
feature1 = 'bigaccelerationperunittravel';
feature2 = 'entrytime';

close all; clc;
% connect to database
datasource = 'live_database';
conn = database(datasource,'postgres','1234');

% load files
femaleBeforeAlcohol = load('femaleBeforeAlcohol.mat');
femaleAfterAlcohol = load('femaleAfterAlcohol.mat');
maleBeforeAlcohol = load('maleBeforeAlcohol.mat');
maleAfterAlcohol = load('maleAfterAlcohol.mat');

% load features for id's present in the table
femaleBeforeAlcohol = femaleBeforeAlcohol.femaleBeforeAlcohol;
femaleAfterAlcohol = femaleAfterAlcohol.femaleAfterAlcohol;
maleBeforeAlcohol = maleBeforeAlcohol.maleBeforeAlcohol;
maleAfterAlcohol = maleAfterAlcohol.maleAfterAlcohol;

%% Get only selected data
% femaleBeforeAlcohol = femaleBeforeAlcohol(ismember(femaleBeforeAlcohol.feeder, [4,3]),:);
% femaleAfterAlcohol = femaleAfterAlcohol(ismember(femaleAfterAlcohol.feeder, [4,3]),:);
% maleBeforeAlcohol = maleBeforeAlcohol(ismember(maleBeforeAlcohol.feeder, [4,3]),:);
% maleAfterAlcohol = maleAfterAlcohol(ismember(maleAfterAlcohol.feeder, [4,3]),:);

dataSets = {femaleBeforeAlcohol, femaleAfterAlcohol, maleBeforeAlcohol, maleAfterAlcohol};
% dataSets = {maleBeforeAlcohol, maleAfterAlcohol};

colors = {'b', 'r', 'g', 'm'}; % define colors for each dataset

% Create a new figure outside of the loop
% h = figure;
% Loop over each dataset and plot it on the same axes
for dataSetIndex = 1:length(dataSets)
    dataSet = dataSets{dataSetIndex};
    ids = sprintf('%d,', dataSet.id); % convert array to string
    ids = ids(1:end-1); % remove last comma
    featuresQuery = sprintf("SELECT id, %s, %s FROM featuretable2 WHERE id IN (%s)", ...
        feature1, feature2, ids);
    features = fetch(conn, featuresQuery);
    dataSet = innerjoin(dataSet, features, 'Keys', 'id');
    for col = 19:20
        dataSet.(col) = str2double(dataSet.(col));
    end
    dataSets{dataSetIndex} = dataSet;
%     plot(dataSet.(feature1),dataSet.(feature2),colors{dataSetIndex},'Marker','.','LineStyle','none');
%     hold on;
end

xlabel(sprintf('%s',feature1),'Interpreter','latex',FontSize=15);
ylabel(sprintf('%s',feature2),'Interpreter','latex',FontSize=15);
% xlim([0 figureLimitFun(feature1)]); ylim([0 figureLimitFun(feature2)]);
xlim([0 30]); ylim([0 25]);
fig_name = sprintf('clustering_%s_%s',feature2,feature1);
% print(h,fig_name,'-dpng','-r400');
end
% Author: Atanu Giri
% Date: 05/17/2023
% This script performs one-way ANOVA and post-hoc analysis for Fig 3e (V66)

clc; clear; close all;
Fig3e = readtable("inscopix_analysis.xlsx","Sheet","All data");

uniqueUtility = unique(Fig3e.utility);
utilityTable = cell(1,length(uniqueUtility));
unnamedVal = zeros(1,length(uniqueUtility));
meanVal = zeros(1,length(uniqueUtility));
stdErr = zeros(1,length(uniqueUtility));
avg_0 = cell(1,length(uniqueUtility));


for i = 1:numel(utilityTable)
    utilityTable{i} = Fig3e(Fig3e.utility == uniqueUtility(i),:);
    unnamedVal(i) = mean(utilityTable{1,i}.Unnamed_0,'omitnan');
    avg_0{i} = utilityTable{1,i}.avg_0;
    meanVal(i) = mean(avg_0{i},'omitnan');
    stdErr(i) = std(avg_0{i},'omitnan')/sqrt(size(avg_0{i}(~isnan(avg_0{i})),1));
end

% %% Plot data
% xVal = uniqueUtility';
% plot(xVal,meanVal);
% hold on;
% errorbar(xVal,meanVal,stdErr);
% hold off;

data = [];
uniqueGroups = {'G1','G2','G3','G4','G5','G6','G7','G8'};
group = {};
for i = 1:numel(avg_0)
    % Remove NaN entries from the group data
    group_data = avg_0{i};
    group_data(isnan(group_data)) = [];

    % Append the non-NaN data to the main data array
    data = [data group_data'];
    group = [group, repmat(uniqueGroups(i),[1,size(group_data,1)])];
end

% Perform one-way ANOVA
[p, tbl, stats] = anova1(data,group,'off');

% Display the ANOVA table
disp('One-Way ANOVA Results:');
disp(tbl);

% Perform post hoc analysis (e.g., Tukey's HSD)
[c,~,~,gnames] = multcompare(stats);
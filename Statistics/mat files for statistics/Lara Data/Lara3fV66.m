% Author: Atanu Giri
% Date: 05/17/2023
% This script performs one-way ANOVA and post-hoc analysis for Fig 3f and 3g (V66)
% Use reawardTable{i} = Fig3f(Fig3f.cost_level == 3 & Fig3f.reward_level ==
% i,:) in line 17 to obtain analysis for Fig 3g


clc; clear; close all;
Fig3f = readtable("inscopix_analysis.xlsx","Sheet","All data");

reawardTable = cell(1,4);
meanVal = zeros(1,length(reawardTable));
stdErr = zeros(1,length(reawardTable));
avg_0 = cell(1,length(reawardTable));

for i = 1:4
    reawardTable{i} = Fig3f(Fig3f.cost_level == 1 & Fig3f.reward_level == i,:);
    avg_0{i} = reawardTable{1,i}.avg_0;
    meanVal(i) = mean(avg_0{i},'omitnan');
    stdErr(i) = std(avg_0{i},'omitnan')/sqrt(size(avg_0{i}(~isnan(avg_0{i})),1));
end

%% Plot data
xVal = [1 2 3 4];
plot(xVal,meanVal);
hold on;
errorbar(xVal,meanVal,stdErr);
hold off;

data = [];
uniqueGroups = {'G1','G2','G3','G4'};
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

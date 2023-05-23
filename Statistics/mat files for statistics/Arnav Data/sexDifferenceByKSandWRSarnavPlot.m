% Author: Atanu Giri
% Date: 05/13/2023
% This script performs repeated measures ANOVA, post-hoc analysis
% and KS2 test for figure 2b (Sex difference before alcohol) and 6c (Effect 
% of alcohol on male and female) from the analysis provided by Arnav (V66)

function sexDifferenceByKSandWRSarnavPlot
clear; close all; clc;
% Read from the Excel sheet provided by Arnav
Fig2b = readtable("DataForStatistics_Arnav.xlsx","Sheet","Figure2b");
% Fig6c = readtable("AlcoholBoostAndETOHData_Arnav.xlsx"); % Uncomment this
% to analyze before and after alcohol data

noOfFemales = 12; noOfMales = 9;
dataMatrix = Fig2b([3:14,16:24],2:5);
% dataMatrix =
% vertcat(table2array(Fig2b(16:24,2:5)),table2array(Fig6c(14:23,9:12))); % 
% Uncomment this to analyze before and after alcohol male data

Gender = [repmat({'F'},1,noOfFemales),repmat({'M'},1,noOfMales)]';
t = [Gender, dataMatrix];
% t = [Gender, array2table(dataMatrix)]; % Uncomment this to analyze before 
% and after alcohol data

t.Properties.VariableNames = {'Gender','c1','c2','c3','c4'};

% perform the KS test for each column
for i = 2:5 % loop over the four columns c1-c4
    [h, p, ks2stat] = kstest2(table2array(t(1:noOfFemales,i)), table2array(t(noOfFemales+1:end,i)));
    fprintf('KStest2: Conc %d: h=%d, p=%.4f, ks2stat=%.4f\n', i-1, h, p, ks2stat);
    [p2, h2, stats] = ranksum(table2array(t(1:noOfFemales,i)), table2array(t(noOfFemales+1:end,i)));
%     fprintf('RStest: Conc %d: h=%d, p=%.4f, zval=%.4f\n', i-1, h2, p2, stats.zval);
    fprintf('RStest: Conc %d: h=%d, p=%.4f\n', i-1, h2, p2);
    fprintf('\n');
end
end
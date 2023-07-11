% Author: Atanu Giri
% Date: 07/11/2023
% This script performs repeated measures ANOVA, post-hoc analysis and KS2
% test for difference in baseline and health manipulation for each gender. 
% It also performs KS2 and ranksum test at each concentration value.

function BLvsManipulationDifferenceOfRewardStatistics
clear; close all; clc;
% Load the desired mat file for analysis
loadFile1 = load('BLsexDiffDistance.mat'); 
loadFile2 = load('INCsexDiffDistance.mat');

dataForGenderInBL = loadFile1.featureForEachSubjectId{2};
dataForGenderInManipulation = loadFile2.featureForEachSubjectId{2};

for i = 1:4
    dataMatrix(:,i) = [dataForGenderInBL{i} dataForGenderInManipulation{i}]';
end
Gender = [repmat({'F'},1,length(dataForGenderInBL{1})),repmat({'M'},1,length(dataForGenderInManipulation{1}))]';
t = [Gender, array2table(dataMatrix)];
t.Properties.VariableNames = {'Gender','c1','c2','c3','c4'};

% setup and do the ANOVA
WithinDesign = table([1 2 3 4]','VariableNames', {'Concentration'});
WithinDesign.Concentration = categorical(WithinDesign.Concentration);
rm = fitrm(t, 'c1-c4 ~ Gender', 'WithinDesign', WithinDesign);
result = ranova(rm,"WithinModel",'Concentration');
disp(result);

% do post hoc multiple comparisons (check m for significant pairwise differences)
m1 = multcompare(rm, 'Concentration', 'By', 'Gender');
m2 = multcompare(rm, 'Gender', 'By', 'Concentration');
for i = 1:2:8
    fprintf('%.4e\n',m2.pValue(i))
end
fprintf('\n');

% Perform the Kolmogorov-Smirnov test For Gender distribution
[h2,p2,ks2stat] = kstest2([dataForGenderInBL{:}],[dataForGenderInManipulation{:}]);
fprintf('kstest2 results: h=%d, p=%.4e, ks2stat=%.4f\n', h2, p2, ks2stat);
fprintf('\n\n');

%% perform the KS2 and ranksum test at each conc level
for i = 1:4 % loop over the four columns c1-c4
    [h, p, ks2stat] = kstest2(dataForGenderInBL{i}, dataForGenderInManipulation{i});
    fprintf('KStest2: Conc %d: h=%d, p=%.4f, ks2stat=%.4f\n', i, h, p, ks2stat);
    [p2, h2, stats] = ranksum(dataForGenderInBL{i}, dataForGenderInManipulation{i});
    %     fprintf('RStest: Conc %d: h=%d, p=%.4f, zval=%.4f\n', i-1, h2, p2, stats.zval);
    fprintf('RStest: Conc %d: h=%d, p=%.4f\n', i, h2, p2);
    fprintf('\n');
end
end
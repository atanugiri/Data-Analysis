% Author: Atanu Giri
% Date: 05/12/2023
% This script performs repeated measures ANOVA, post-hoc analysis and KS2 
% test for sex difference in BL, FD, Alcohol, Oxy, Incubation 
% and for BL vs FD plots (V66)

function sexDifferenceStatistics
clear; close all; clc;
loadFile = load('INCsexDiffPassing.mat'); % Load the desired mat file for analysis
dataForFemale = loadFile.featureForEachSubjectId{1};
dataForMale = loadFile.featureForEachSubjectId{2};

for i = 1:4
    dataMatrix(:,i) = [dataForFemale{i} dataForMale{i}]';
end
Gender = [repmat({'F'},1,length(dataForFemale{1})),repmat({'M'},1,length(dataForMale{1}))]';
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

% Perform the Kolmogorov-Smirnov test For Gender distribution
[h2,p2,ks2stat] = kstest2([dataForFemale{:}],[dataForMale{:}]);
fprintf('kstest2 results: h=%d, p=%.4e, ks2stat=%.4f\n', h2, p2, ks2stat);
end
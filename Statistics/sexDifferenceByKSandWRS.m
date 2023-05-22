% Author: Atanu Giri
% Date: 05/12/2023
% This script performs pairwise comparison test for sex difference in BL, 
% FD, Alcohol, Oxy, Incubation and for BL vs FD plots (V66)

function sexDifferenceByKSandWRS
clear; close all; clc;
loadFile = load('INCsexDiffPassing.mat');

dataForFemale = loadFile.featureForEachSubjectId{1};
dataForMale = loadFile.featureForEachSubjectId{2};

for i = 1:4
    dataMatrix(:,i) = [dataForFemale{i} dataForMale{i}]';
end
Gender = [repmat({'F'},1,length(dataForFemale{1})),repmat({'M'},1,length(dataForMale{1}))]';
t = [Gender, array2table(dataMatrix)];
t.Properties.VariableNames = {'Gender','c1','c2','c3','c4'};

% perform the KS test for each column
for i = 1:4 % loop over the four columns c1-c4
    [h, p, ks2stat] = kstest2(dataForFemale{i}, dataForMale{i});
    fprintf('KStest2: Conc %d: h=%d, p=%.4f, ks2stat=%.4f\n', i, h, p, ks2stat);
    [p2, h2, stats] = ranksum(dataForFemale{i}, dataForMale{i});
%     fprintf('RStest: Conc %d: h=%d, p=%.4f, zval=%.4f\n', i-1, h2, p2, stats.zval);
    fprintf('RStest: Conc %d: h=%d, p=%.4f\n', i, h2, p2);
    fprintf('\n');
end
end
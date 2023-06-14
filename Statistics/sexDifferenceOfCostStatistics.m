% Author: Atanu Giri
% Date: 06/12/2023
% This script performs repeated measures ANOVA, post-hoc analysis, overall KS2 
% test for sex difference. It also performs KS2 and ranksum test for sex
% difference at each light intensity value.

function sexDifferenceOfCostStatistics
clear; close all; clc;
loadFile = load("costAnalysisForGender.mat"); % Load the desired mat file for analysis
dataForFemale = loadFile.appRateOfEachFemale;
dataForMale = loadFile.appRateOfEachMale;

% Prepare data for repeat meaures ANOVA
dataMatrix = vertcat(cell2mat(dataForFemale), cell2mat(dataForMale));

Gender = [repmat({'F'},1,length(dataForFemale{1})),repmat({'M'},1,length(dataForMale{1}))]';
t = [Gender, array2table(dataMatrix)];
t.Properties.VariableNames = {'Gender', 'c1', 'c2', 'c3', 'c4'};

% setup and do the ANOVA
WithinDesign = table((1:size(dataMatrix,2))','VariableNames', {'Cost'});
WithinDesign.Cost = categorical(WithinDesign.Cost);
rm = fitrm(t, 'c1-c4 ~ Gender', 'WithinDesign', WithinDesign);
result = ranova(rm,"WithinModel",'Cost');
disp(result);

% do post hoc multiple comparisons (check m for significant pairwise differences)
m1 = multcompare(rm, 'Cost', 'By', 'Gender');
m2 = multcompare(rm, 'Gender', 'By', 'Cost');
for i = 1:2:2*size(dataMatrix,2)
    fprintf('%.4e\n',m2.pValue(i))
end
fprintf('\n');

% Perform the Kolmogorov-Smirnov test For Gender distribution
[h2,p2,ks2stat] = kstest2(vertcat(dataForFemale{:}),vertcat(dataForMale{:}));
fprintf('kstest2 results: h=%d, p=%.4e, ks2stat=%.4f\n', h2, p2, ks2stat);
fprintf('\n\n');

%% perform the KS and WRS test for each column
for i = 1:numel(dataForFemale) % loop over the four columns c1-c4
    [h, p, ks2stat] = kstest2(dataForFemale{i}, dataForMale{i});
    fprintf('KStest2: Conc %d: h=%d, p=%.4f, ks2stat=%.4f\n', i, h, p, ks2stat);
    [p2, h2, stats] = ranksum(dataForFemale{i}, dataForMale{i});
%     fprintf('RStest: Conc %d: h=%d, p=%.4f, zval=%.4f\n', i-1, h2, p2, stats.zval);
    fprintf('RStest: Conc %d: h=%d, p=%.4f\n', i, h2, p2);
    fprintf('\n');
end
end
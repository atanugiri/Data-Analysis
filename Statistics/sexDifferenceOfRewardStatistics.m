% Author: Atanu Giri
% Date: 05/12/2023
% This script performs repeated measures ANOVA, post-hoc analysis and KS2
% test for sex difference in BL, FD, Alcohol, Oxy, Incubation
% and for BL vs FD plots. It also performs KS2 and ranksum test for sex
% difference at each concentration value.

function sexDifferenceOfRewardStatistics
clear; close all; clc;

% Load the desired mat file for analysis
loadFile = load("BLsexDiffRejectPassing.mat");
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

% disp(result);
fprintf("Effect of concentration: d.f. = %d, F = %0.4f, p = %0.4e.\n", result.DF(4), ...
    result.F(4), result.pValue(4));
fprintf("Effect of gender: d.f. = %d, F = %0.4f, p = %0.4f.\n", result.DF(2), ...
    result.F(2), result.pValue(2));

% Perform the Kolmogorov-Smirnov test For Gender distribution
[h2,p2,ks2stat] = kstest2([dataForFemale{:}],[dataForMale{:}]);
fprintf(['kstest2 results: h=%d, p=%.4e, ks2stat=%.4f ' ...
    '(overall gender difference)\n'], h2, p2, ks2stat);

% do post hoc multiple comparisons (check m for significant pairwise differences)
m1 = multcompare(rm, 'Concentration', 'By', 'Gender');
m2 = multcompare(rm, 'Gender', 'By', 'Concentration');

fprintf('\nPost-hoc analysis: \n');
for i = 1:2:8
    fprintf('%.4f, ',m2.pValue(i))
end
fprintf('\n\n');


%% perform the KS2 and ranksum test at each conc level
fprintf(['KStest2 and Wilcoxon rank sum test Results ' ...
    '(complementary to post-hoc analysis)\n']);
for i = 1:4 % loop over the four columns c1-c4
    [h, p, ks2stat] = kstest2(dataForFemale{i}, dataForMale{i});
    fprintf('KStest2: Conc %d: h=%d, p=%.4f, ks2stat=%.4f\n', i, h, p, ks2stat);
    [p2, h2, stats] = ranksum(dataForFemale{i}, dataForMale{i});
    %     fprintf('RStest: Conc %d: h=%d, p=%.4f, zval=%.4f\n', i-1, h2, p2, stats.zval);
    fprintf('RStest: Conc %d: h=%d, p=%.4f\n', i, h2, p2);
    fprintf('\n');
end
end
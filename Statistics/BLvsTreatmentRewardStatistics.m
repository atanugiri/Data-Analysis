% Author: Atanu Giri
% Date: 08/08/2023
% This script performs repeated measures ANOVA, post-hoc analysis and KS2
% test for difference in BL and FD without splitting by gender. It also 
% performs KS2 and ranksum test for sex difference at each concentration value.

function BLvsTreatmentRewardStatistics
 % Load the desired mat file for analysis
loadFile1 = load("BLapproachavoid.mat");
loadFile2 = load("incApproachavoid.mat");

dataForBL = loadFile1.featureForEachSubjectId{1};
dataForFD = loadFile2.featureForEachSubjectId{1};

for i = 1:4
    dataMatrix(:,i) = [dataForBL{i} dataForFD{i}]';
end
Gender = [repmat({'BL'},1,length(dataForBL{1})),repmat({'FD'},1,length(dataForFD{1}))]';
t = [Gender, array2table(dataMatrix)];
t.Properties.VariableNames = {'Condition','c1','c2','c3','c4'};

% setup and do the ANOVA
WithinDesign = table([1 2 3 4]','VariableNames', {'Concentration'});
WithinDesign.Concentration = categorical(WithinDesign.Concentration);
rm = fitrm(t, 'c1-c4 ~ Condition', 'WithinDesign', WithinDesign);
result = ranova(rm,"WithinModel",'Concentration');
% disp(result);

% Print result
fprintf("Effect of condition: d.f. = %d, F = %0.4f, p = %0.4f.\n", result.DF(2), ...
    result.F(2), result.pValue(2));

% Perform the Kolmogorov-Smirnov test For Gender distribution
[h2,p2,ks2stat] = kstest2([dataForBL{:}],[dataForFD{:}]);
fprintf('kstest2 results: h=%d, p=%.4f, ks2stat=%.4f\n', h2, p2, ks2stat);
fprintf('\n\n');
end
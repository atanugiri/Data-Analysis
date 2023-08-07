% Author: Atanu Giri
% Date: 07/19/2023
% This script performs 3-way ANOVA to analyze the effect of concentration,
% gender and codition

function ThreeWayBLvsManipulationDiffStatistics
clear; close all; clc;

% Load the desired mat file for analysis
loadFile1 = load('BLsexDiffDistance.mat');
loadFile2 = load('INCsexDiffDistance.mat');

femaleDataOfBL = loadFile1.featureForEachSubjectId{1};
maleDataOfBL = loadFile1.featureForEachSubjectId{2};

femaleDataOfMan = loadFile2.featureForEachSubjectId{1};
maleDataOfMan = loadFile2.featureForEachSubjectId{2};

% Combine data
responseData = [femaleDataOfBL{:}, maleDataOfBL{:}, femaleDataOfMan{:}, maleDataOfMan{:}]';

% Create factor vectors
gender = categorical([repmat({'Female'}, length(femaleDataOfBL{1})*4, 1); ...
    repmat({'Male'}, length(maleDataOfBL{1})*4, 1); ...
    repmat({'Female'}, length(femaleDataOfMan{1})*4, 1); ...
    repmat({'Male'}, length(maleDataOfMan{1})*4, 1)]);

condition = categorical([repmat({'Baseline'}, length(femaleDataOfBL{1})*4, 1); ...
    repmat({'Baseline'}, length(maleDataOfBL{1})*4, 1); ...
    repmat({'Man'}, length(femaleDataOfMan{1})*4, 1); ...
    repmat({'Man'}, length(maleDataOfMan{1})*4, 1)]);

concFemaleBL = repelem(1:4, length(femaleDataOfBL{1}));
concMaleBL = repelem(1:4, length(maleDataOfBL{1}));
concFemaleMan = repelem(1:4, length(femaleDataOfMan{1}));
concMaleMan = repelem(1:4, length(maleDataOfMan{1}));

% Combine concentration factors for baseline and food deprivation conditions
concentration = categorical([concFemaleBL, concMaleBL, concFemaleMan, concMaleMan]');

% Perform n-way ANOVA
[~, tbl, ~] = anovan(responseData, {gender, condition, concentration}, ...
    'varnames', {'Gender', 'Condition', 'Concentration'}, 'model', 'interaction', 'display','off');
% disp(tbl);

% Print 3-way ANOVA result
fprintf("Effect of condition: d.f. = %d, F = %0.4f, p = %0.4f.\n", tbl{3,3}, tbl{3,6}, tbl{3,7})
fprintf("Effect of concentration: d.f. = %d, F = %0.4f, p = %e.\n", tbl{4,3}, tbl{4,6}, tbl{4,7})
fprintf("Effect of gender: d.f. = %d, F = %0.4f, p = %0.4f.\n", tbl{2,3}, tbl{2,6}, tbl{2,7})
end
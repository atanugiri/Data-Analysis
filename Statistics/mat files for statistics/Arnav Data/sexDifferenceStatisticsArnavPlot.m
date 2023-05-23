% Author: Atanu Giri
% Date: 05/13/2023
% This script performs repeated measures ANOVA, post-hoc analysis
% and KS2 test for figure 2b (Sex difference before alcohol) and 6c (Effect 
% of alcohol on male and female) from the analysis provided by Arnav (V66)

function sexDifferenceStatisticsArnavPlot
clc; clear; close all;

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

dataForFemale = [];
dataForMale = [];
for col = 2:5
    dataForFemale = [dataForFemale;table2array(t(1:noOfFemales,col))];
    dataForMale = [dataForMale;table2array(t(1:noOfMales,col))];
end
% Perform the Kolmogorov-Smirnov test For Gender distribution
[h2,p2,ks2stat] = kstest2(dataForFemale,dataForMale);
fprintf('kstest2 results: h=%d, p=%.4e, ks2stat=%.4f\n', h2, p2, ks2stat);
end
% Author: Atanu Giri
% Date: 05/15/2023
% This script plots figure 6c (Effect of alcohol on male and female) from 
% the analysis provided by Arnav (V66)

function overlayBeforeAndAfterAlcoholPlotFromArnavData
clc; clear; close all;
% Read from the Excel sheet provided by Arnav
Fig6c = readtable("AlcoholBoostAndETOHData_Arnav.xlsx");

noOfFemales = 10; noOfMales = 10;
dataMatrix = Fig6c([3:12,14:23],9:12);
Gender = [repmat({'F'},1,noOfFemales),repmat({'M'},1,noOfMales)]';
t = [Gender, dataMatrix];
t.Properties.VariableNames = {'Gender','c1','c2','c3','c4'};
femaleAv = zeros(4,1);
maleAv = zeros(4,1);
stdErrFemale = zeros(4,1); 
stdErrMale = zeros(4,1);

for i = 1:4
    femaleAv(i) = mean(table2array(t(1:noOfFemales,i+1)));
    maleAv(i) = mean(table2array(t(noOfFemales+1:end,i+1)));
    stdErrFemale(i) = std(table2array(t(1:noOfFemales,i+1)),'omitnan')/ ...
            sqrt(length(table2array(t(1:noOfFemales,i+1))));
    stdErrMale(i) = std(table2array(t(noOfFemales+1:end,i+1)),'omitnan')/ ...
            sqrt(length(table2array(t(1:noOfFemales,i+1))));
end

Fig2b = readtable("DataForStatistics_Arnav.xlsx","Sheet","Figure2b");
noOfFemales2 = 12; noOfMales2 = 9;
dataMatrix2 = Fig2b([3:14,16:24],2:5);
Gender2 = [repmat({'F'},1,noOfFemales2),repmat({'M'},1,noOfMales2)]';
t2 = [Gender2, dataMatrix2];
t2.Properties.VariableNames = {'Gender','c1','c2','c3','c4'};
femaleAv2 = zeros(4,1);
maleAv2 = zeros(4,1);
stdErrFemale2 = zeros(4,1); 
stdErrMale2 = zeros(4,1);

for i = 1:4
    femaleAv2(i) = mean(table2array(t2(1:noOfFemales2,i+1)));
    maleAv2(i) = mean(table2array(t2(noOfFemales2+1:end,i+1)));
    stdErrFemale2(i) = std(table2array(t2(1:noOfFemales2,i+1)),'omitnan')/ ...
            sqrt(length(table2array(t2(1:noOfFemales2,i+1))));
    stdErrMale2(i) = std(table2array(t2(noOfFemales2+1:end,i+1)),'omitnan')/ ...
            sqrt(length(table2array(t2(1:noOfFemales2,i+1))));
end


xVal = [1,2,3,4];
h = figure;
p1 = plot(xVal',femaleAv',"LineWidth",1.5,'Color','r','LineStyle','--');
hold on;
p2 = plot(xVal',maleAv',"LineWidth",1.5,'Color','b','LineStyle','--');
errorbar(xVal,femaleAv,stdErrFemale,'LineStyle','none','LineWidth',1.5,'Color','r');
errorbar(xVal,maleAv,stdErrMale,'LineStyle','none','LineWidth',1.5,'Color','b');

p3 = plot(xVal',femaleAv2',"LineWidth",1.5,'Color','r');
hold on;
p4 = plot(xVal',maleAv2',"LineWidth",1.5,'Color','b');
errorbar(xVal,femaleAv2,stdErrFemale2,'LineStyle','none','LineWidth',1.5,'Color','r');
errorbar(xVal,maleAv2,stdErrMale2,'LineStyle','none','LineWidth',1.5,'Color','b');

label = [0.5 "" 2 "" 5 "" 9];
set(gca,'xticklabel',label,'TickLabelInterpreter','latex');
xlabel("sucrose concentration","Interpreter","latex",'FontSize',15);
ylabel("Change in acceptance rate over cost (%)","Interpreter","latex",'FontSize',15);
p = [p1, p2, p3, p4];
legend(p,["Female PA","Male PA","Female BA","Male BA"],'Location','northeast');
savefig(h,'Fig6c.fig');
end
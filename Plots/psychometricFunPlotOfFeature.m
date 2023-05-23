% Author: Atanu Giri
% Date: 12/16/2022
% This function plot graph of features according to input provided and
% return the figure and line objects of the plot

function [p,h] = psychometricFunPlotOfFeature(healthFeatureForEachSubjectId,avFeatureOfHealthType, ...
    stdErrHealthType,~)
% loadFile = load("output.mat");
% healthFeatureForEachSubjectId = loadFile.healthFeatureForEachSubjectId;
% avFeatureOfHealthType = loadFile.avFeatureOfHealthType;
% stdErrHealthType = loadFile.stdErrHealthType;
h = figure;
hold on;
xCoordinate = [1 2 3 4];
plotStyle = ["k-o","r-o","g-o","m-o","c-o","y-o"]; plotColor = ["k","r","g","m","c","y"];
p = cell(1,length(avFeatureOfHealthType));

% for health = 1:1
for health = 1:length(avFeatureOfHealthType)
    p{health} = plot(xCoordinate,avFeatureOfHealthType{health},plotStyle(health), ...
        'MarkerFaceColor',plotColor(health),LineWidth=1.5);
    for reward = 1:4
        plot(repmat(xCoordinate(reward),length(healthFeatureForEachSubjectId{health}{reward}),1), ...
            (healthFeatureForEachSubjectId{health}{reward})','.','Color',plotColor(health));
    end
end
label = [0.5 "" 2 "" 5 "" 9];
set(gca,'xticklabel',label,'TickLabelInterpreter','latex');
xlabel("sucrose concentration","Interpreter","latex",'FontSize',15);
% error bar plot
% for health = 1:1
for health = 1:length(avFeatureOfHealthType)
    errorbar(xCoordinate,avFeatureOfHealthType{health},stdErrHealthType{health}, ...
        'Color',plotColor(health),'LineStyle','none','LineWidth',1.5);
end
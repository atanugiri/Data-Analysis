% Author: Atanu Giri
% Date: 12/11/2022
% This function plot bar graph of features according to input provided

function [p,h] = barPlotOfFeature(healthFeatureForEachSubjectId,averageFeature,stdErrror,pValues)
% loadFile = load("output.mat");
% healthFeatureForEachSubjectId = loadFile.healthFeatureForEachSubjectId;
% averageFeature = loadFile.avFeatureOfHealthType;
% stdErrror = loadFile.stdErrHealthType;
h = figure;
% bar plot
p = bar(diag(averageFeature),'stacked');
hold on;
% find the X center of the bars to plot error bars
[ngroups,nbars] = size(averageFeature);
xCenter = nan(nbars,ngroups);
for barPosition = 1:nbars
    xCenter(barPosition,:) = p(barPosition).XEndPoints;
end
% error bar plot
errorbar(xCenter',averageFeature,stdErrror,'k','LineStyle','none','LineWidth',1.5);
% scatter plot each datapoint individually
for type = 1:length(averageFeature)
    plot(repmat(xCenter(type),length(healthFeatureForEachSubjectId{type}),1),healthFeatureForEachSubjectId{type}, ...
        'o','MarkerEdgeColor','k','LineWidth',0.5);
end
% indicate p values on the top of the bars
text(2:length(averageFeature),averageFeature(2:end),num2str(pValues(2:end)), ...
    'VerticalAlignment','bottom','HorizontalAlignment','left','FontSize',10,'FontWeight','bold','Color',[1 0 1],'Interpreter','latex','Rotation',0);
box off;
end
% Author: Atanu Giri
% Date: 05/15/2023
% Statistiscal analysis of figure S2a and S2b by one-way ANOVA


clc; clear; close all;
% ANOVA for Fig2a
Fig2a = readtable("SupplementalFig2aData_Arnav.xlsx");
Fig2a = table2array(Fig2a(1:5,2:5));
p1 = anova1(Fig2a);
% xVal = [1 2 3 4];
% h = figure;
% for i = 1:size(Fig2a,1)
%     plot(xVal,Fig2a(i,:),"LineWidth",1.5,"Marker","square");
%     hold on;
% end
% label = [15 "" 191.5 "" 246.67 "" 297.5];
% set(gca,'xticklabel',label,'TickLabelInterpreter','latex');
% xlabel("Light intensity (Lux)","Interpreter","latex",'FontSize',15);
% ylabel("Acceptance Rate","Interpreter","latex",'FontSize',15);
% legend(["aladdin","jimi","mike","sara","simba"],'Location','northeast');

% ANOVA for Fig2b
Fig2b = readtable("SupplementaryFigure2bData_Arnav.xlsx");
Fig2b = table2array(Fig2b(1:23,2:4));
p2 = anova1(Fig2b);
% yVal = zeros(1,size(Fig2b,2));
% for i = 1:size(Fig2b,2)
%     yVal(1,i) = mean(Fig2b(:,i));
% end
% xVal = [1 2 3];
% h = figure;
% plot(xVal,yVal,"LineWidth",1.5,"Marker","square");
% hold on;
% label = [191.5 "" 246.67 "" 297.5];
% set(gca,'xticklabel',label,'TickLabelInterpreter','latex');
% xlabel("Light intensity (Lux)","Interpreter","latex",'FontSize',15);
% ylabel("Percent Change in Acceptance Rate over Cost","Interpreter","latex",'FontSize',15);
% stdErr = zeros(1,size(Fig2b,2));
% for i = 1:length(stdErr)
%     stdErr(i) = std(Fig2b(:,i))/sqrt(size(Fig2b,1));
% end
% errorbar(xVal,yVal,stdErr,'LineStyle','none','LineWidth',1.5);
% savefig(h,'FigS2a.fig');
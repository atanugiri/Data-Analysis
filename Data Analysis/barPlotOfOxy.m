% Author: Atanu Giri
% Date: 04/11/2023
% This script plots bar graph of sigmoid fraction of sessions in 
% baseline, oxycodon, and alcohol

close all; clc; clear;

%% Baseline
baselineFemales = {'fiona','juana','kryssia','neftali','raven', ...
    'alexis','harley','renata','sarah','shakira'};
baselineMales = {'aladdin','jafar','jimi','scar','simba', ...
    'carl','jr','kobe','mike','sully'};
femaleBLSigFrac = [0.75, 1, 1, 0.75, 1, 1, 1, 1, 0.75, 1]; % BL = Baseline
maleBLSigFrac = [1, 1, 1, 1, 1, 1, 1, 0.75, 1, 1];

%% Oxy and Incubation
% oxyAnimal = {'Pepper','Captain','Buzz','Woody','Rex','Barbie', ...
%     'Slinky','Ken','Wanda','Vision','Bopeep','Trixie'};
% % Fraction of Sigmoid
% oxySigFrac = [nan, nan, 0.5, 0.5, 0.5, 0.25, ...
%     0.3333, 0.1429, 0.1667, 0.50, 0.50, 0.3750];
% incubSigFrac = [0.5, 0.25, 0.25, 0.7, 0.5833, 0.3750, ...
%     0.7143, 0.75, 0.25, 0.5714, 1.00, 0.8750];

% separate male and female into array
oxyFemales = {'Pepper','Barbie','Wanda','Vision','Bopeep','Trixie'};
oxyMales = {'Captain','Buzz','Woody','Rex','Slinky','Ken'};

% data to be plotted in bar graph
femaleOxySigFrac = [nan, 0.25, 0.1667, 0.50, 0.50, 0.3750];
% femaleOxySigFrac = oxySigFrac(ismember(oxyAnimal, oxyFemales));
femaleOxySigFrac = [femaleOxySigFrac, nan, nan, nan, nan];
% maleOxySigFrac = oxySigFrac(ismember(oxyAnimal, oxyMales));
maleOxySigFrac = [nan, 0.5, 0.5, 0.5, 0.3333, 0.1429];
maleOxySigFrac = [maleOxySigFrac, nan, nan, nan, nan];

femaleIncubSigFrac = [0.5, 0.3750, 0.25, 0.5714, 1.00, 0.8750];
% femaleIncubSigFrac = incubSigFrac(ismember(oxyAnimal, oxyFemales));
femaleIncubSigFrac = [femaleIncubSigFrac, nan, nan, nan, nan];
maleIncubSigFrac = [0.25, 0.25, 0.7, 0.5833, 0.7143, 0.75];
% maleIncubSigFrac = incubSigFrac(ismember(oxyAnimal, oxyMales));
maleIncubSigFrac = [maleIncubSigFrac, nan, nan, nan, nan];


%% Alcohol
alcoholFemales = {'fiona','juana','kryssia','neftali','raven'};
alcoholMales = {'aladdin','jafar','jimi','scar','simba'};
boostFemales = ["alexis","harley","renata","sarah","shakira"];
boostMales = ["carl","jr","kobe","mike","sully"];


femaleBASigFrac = [0.25, 1, 0.222, 0.667, 1]; % BA = Before Alcohol
maleBASigFrac = [1, 0, 0.2, 0, 1];

femalePASigFrac = [0.571, 1, 0.889, 0.857, 1]; % PA = Post Alcohol
malePASigFrac = [0.556, 0.556, 0.8, 0.75, 1];

femaleBoostSigFrac = [1, 0.5, 1, 1, 1]; % Fix this 
maleBoostSigFrac = [1, 1, 0.8, 0.889, 0.667]; % Fix this


% Entries for bar graph
SigFracGrouped = [femaleBLSigFrac; maleBLSigFrac; femaleOxySigFrac; maleOxySigFrac; ...
    femaleIncubSigFrac; maleIncubSigFrac; femalePASigFrac, femaleBoostSigFrac; 
    malePASigFrac, maleBoostSigFrac];

% Calculate the means and standard errors for each group, omitting NaN values
means = mean(SigFracGrouped, 2, 'omitnan');
n = sum(~isnan(SigFracGrouped), 2);
stderrs = std(SigFracGrouped, 0, 2, 'omitnan') ./ sqrt(n);

% Define the x-axis labels
groupLabels = {'Female BL', 'Male BL', 'Female Oxy', 'Male Oxy', ...
    'Female Incub', 'Male Incub', 'Female PA', 'Male PA'};

% Define the bar heights and errors for each group
barHeights = means';
barErrors = stderrs';

% Plot the bar graph with grouped bars
bar(1:length(barHeights), barHeights, 'grouped');
hold on;
errorbar(1:length(barHeights), barHeights, barErrors, 'k.', 'LineWidth', 1);

% Set the x-axis labels and plot title
set(gca, 'XTick', 1:length(barHeights), 'XTickLabel', groupLabels, ...
    'TickLabelInterpreter','latex');
xlabel('Group','Interpreter','latex','FontSize',15);
ylabel('Fraction of Sigmoid','Interpreter','latex','FontSize',15);
title('Fraction of Sigmoid by Group','Interpreter','latex','FontSize',20);
% savefig(gcf,sprintf('%s.fig',"sigmoidFraction"));

% Perform one-way ANOVA
[p, tbl, stats] = anova1(SigFracGrouped', [], 'off', 'omitnan');

% Display the ANOVA table
disp('One-Way ANOVA Results:');
disp(tbl);

% Check if there are significant differences between the groups
if p < 0.05
    disp('There are significant differences between the groups.');
else
    disp('There are no significant differences between the groups.');
end

% Perform post hoc analysis (e.g., Tukey's HSD)
[c,~,~,gnames] = multcompare(stats, 'Display','off');
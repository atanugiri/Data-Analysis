% Author: Atanu Giri
% Date: 04/08/2023
% This function looks for correlation of number of pokes provided by Travis
% with normal sigmoid function.

close all; clc;
animal = {'Pepper','Captain','Buzz','Woody','Rex','Barbie','Slinky', ...
    'Ken','Wanda','Vision'};
females = {'Pepper','Barbie','Wanda','Vision'};
males = {'Captain','Buzz','Woody','Rex','Slinky','Ken'};

day1poke = [47,15,18,10,13,57,2,14,39,16];
day30poke = [25,27,96,37,32,70,20,24,50,72];
averagePoke = (day1poke + day30poke)/2;

femaleday1poke = [47, 57, 39, 16];
femaleday30poke = [25, 70, 50, 72];
femaleaveragePoke = (femaleday1poke + femaleday30poke)/2;

maleday1poke = [15,18,10,13,2,14];
maleday30poke = [27,96,37,32,20,24];
maleaveragePoke = (maleday1poke + maleday30poke)/2;

% P1L1 and P2L1L2 together
sigmoidNo = [4/5, 1/6, 3/11, 7/10, 6/11, 3/8, 5/7, 6/8, 1/4, 4/7]; % with R^2 >= 0.4
femalesigmoidNo = [4/5, 3/8, 1/4, 4/7];
malesigmoidNo = [1/6, 3/11, 7/10, 6/11, 5/7, 6/8];

% Plot
subplot(1,3,1);
% plot(day1poke(3:10)',sigmoidNo(3:10)','ko');
% plot(femaleday1poke',femalesigmoidNo','ko');
plot(maleday1poke',malesigmoidNo','ko');
title('Day1 Poke','Interpreter','latex','FontSize',15);
ylim([0 1]);
hold on;
subplot(1,3,2);
% plot(day30poke(3:10)',sigmoidNo(3:10)','ko');
% plot(femaleday30poke',femalesigmoidNo','ko');
plot(maleday30poke',malesigmoidNo','ko');
title('Day30 Poke','Interpreter','latex','FontSize',15);
subplot(1,3,3);
% plot(averagePoke(3:10)',sigmoidNo(3:10)','ko');
% plot(femaleaveragePoke',femalesigmoidNo','ko');
plot(maleaveragePoke',malesigmoidNo','ko');
title('Average Poke','Interpreter','latex','FontSize',15);

for i = 1:3
    subplot(1,3,i);
    xlim([0,100]);
    ylim([0,1]);
    xlabel('Poke','Interpreter','latex','FontSize',15);
    ylabel('Sigmoid Value','Interpreter','latex','FontSize',15);
end
print(gcf,'poke correlation','-dpng','-r400');
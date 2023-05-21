function [h, a, b, goodness] = sigmoid_fit(y)
% Define the sigmoid function
sigmoid = @(a,b,x) 1./(1 + exp(-(x-a)/b));

% Create x data as equally spaced integers from 1 to the number of elements in y
x = [1 2 3 4];

% Fit the sigmoid function to the data using nonlinear regression
[fitresult,gof] = fit(x', y', sigmoid, 'StartPoint', [mean(x), 1]);

% Evaluate goodness of fit
a = fitresult.a;
b = fitresult.b;
goodness = gof.rsquare;

% Plot the psychometric curve and the fitted sigmoid function
h = figure;
plot(x', y', 'ko', 'MarkerFaceColor', 'k', 'MarkerSize', 8);
hold on;
x_fit = linspace(min(x), max(x), 100);
y_fit = sigmoid(a, b, x_fit);
plot(x_fit, y_fit, 'b-', 'LineWidth', 2);
% Add legend and axis labels
legend('Data', 'Fitted sigmoid','Location','northwest');
text(max(x_fit), max(y_fit), sprintf('a=%0.2f, b=%0.2f, R^2=%0.2f', a, b, goodness), ...
    'HorizontalAlignment', 'right', 'VerticalAlignment', 'top', 'FontSize', 12, 'FontWeight', 'bold');

label = [0.5 "" 2 "" 5 "" 9];
set(gca,'xticklabel',label,'TickLabelInterpreter','latex');
xlabel("sucrose concentration","Interpreter","latex",'FontSize',15);
end
% Author: Atanu Giri
% Date: 09/11/2023
% This script calculates the correlation between amount of Oxy and fraction
% of sigmoid for each animal

file = 'oxy self admin.xlsx';
dataTable = readtable(file);
dataTable = dataTable(5:12, :);
pokeData = dataTable{:, 2:15};

for col = 1:size(pokeData, 2)
    if col <= 7
        pokeData(:,col) = 0.1*pokeData(:,col);
    else
        pokeData(:,col) = 0.05*pokeData(:,col);
    end
end

pokeData(:,size(pokeData, 2)+1) = mean(pokeData, 2);


%% Poke correlation
oxyFemales = {'Pepper','Barbie','Wanda','Vision','Bopeep','Trixie'};
oxyMales = {'Captain','Buzz','Woody','Rex','Slinky','Ken'};

femaleOxySigFrac = [nan, 0.25, 0.1667, 0.50, 0.50, 0.3750];
maleOxySigFrac = [nan, 0.5, 0.5, 0.5, 0.3333, 0.1429];

animalNames = {'Barbie','Buzz','Captain','Pepper','Rex','Slinky', ...
    'Vision','Wanda'};

% Initialize a cell array to store the data
sigmoidData = zeros(1, numel(animalNames));

% Loop through the animal names and fetch the data
for i = 1:numel(animalNames)
    animal = animalNames{i};

    % Check if the animal is in the oxyFemales array
    if ismember(animal, oxyFemales)
        sigmoidData(i) = femaleOxySigFrac(strcmp(animal, oxyFemales));
    end

    % Check if the animal is in the oxyMales array
    if ismember(animal, oxyMales)
        sigmoidData(i) = maleOxySigFrac(strcmp(animal, oxyMales));
    end
end

subplot_count = 0;
figure('Position', [100, 100, 1200, 800]);

% Placeholder for R and P
Rarray = zeros(1, size(pokeData, 2));
Parray = zeros(1, size(pokeData, 2));

for i = 1:size(pokeData, 2)
    try
        subplot_count = subplot_count+1;
        subplot(3, 5, subplot_count);
        plot(sigmoidData, pokeData(:,i), '.', 'MarkerSize', 20);
        xlabel("Fraction of sigmoid","Interpreter","latex");
        ylabel("Number of pokes","Interpreter","latex");
        title(sprintf("Day %d poke data", i));
        hold on;

        % Statistics
        filter = isfinite(sigmoidData);
        x = sigmoidData(filter);
        thisCol = pokeData(:,i)';
        y = thisCol(filter);
        [R, P] = corrcoef(x, y);
        Rarray(i) = R(1,2);
        Parray(i) = P(1,2);

         % Plot the correlation line
        coefficients = polyfit(x, y, 1); % Fit a linear regression line
        x_fit = min(x):0.01:max(x);
        y_fit = polyval(coefficients, x_fit);
        plot(x_fit, y_fit, 'r', 'LineWidth', 2);
        text(mean(x), max(y), sprintf("R = %.2f",R(1,2)));

    catch
        error("Data not found.");
    end
    
end
% Author: Atanu Giri
% Date: 03/01/2024

% This script generates bar plot of acceptance rate between low and high cost 
% based on the raw data provided in the Excel sheet.


file = 'Food Dep stat (Baseline vs 12-19%).xlsx';
dataTable = readmatrix(file);

%% Low-cost benefit
fLCbl = [36; dataTable(1:11,3)];
mLCbl = [23; dataTable(1:9,5)];

fLCfd = [38; dataTable(1:11,7)];
mLCfd = [38; dataTable(1:9,9)];

% Combine the data into a single variable
allDataLC = {fLCbl, mLCbl, fLCfd, mLCfd};
paddedDataLC = paddedDataFun(allDataLC);

% Create a grouping variable indicating the groups
groupsLC = {'fLCbl', 'mLCbl', 'fLCfd', 'mLCfd'};

% Perform one-way ANOVA between female LC
[p_flc, tbl_flc, stats_flc] = anova1(paddedDataLC(:,[1,3]), groupsLC([1,3]), 'off');

% Perform one-way ANOVA between male LC
[p_mlc, tbl_mlc, stats_mlc] = anova1(paddedDataLC(:,[2,4]), groupsLC([2,4]), 'off');

%% High-cost benefit
fHCbl = dataTable(23:33,3);
mHCbl = dataTable(23:33,5);

fHCfd = dataTable(23:33,8);
mHCfd = dataTable(23:32,10);

allDataHC = {fHCbl, mHCbl, fHCfd, mHCfd};
paddedDataHC = paddedDataFun(allDataHC);

groupsHC = {'fHCbl', 'mHCbl', 'fHCfd', 'mHCfd'};

[p_fhc, tbl_fhc, stats_fhc] = anova1(paddedDataHC(:,[1,3]), groupsHC([1,3]),"off");
[p_mhc, tbl_mhc, stats_mhc] = anova1(paddedDataHC(:,[2,4]), groupsHC([2,4]),"off");

%% Data analysis
meanLC = zeros(1, length(groupsLC));
sdLC = zeros(1, length(groupsLC));

meanHC = zeros(1, length(groupsHC));
sdHC = zeros(1, length(groupsHC));

for i = 1:size(paddedDataLC,2)
    LCdata = paddedDataLC(:,i);
    HCdata = paddedDataHC(:,i);

    ftDataLC = LCdata(isfinite(LCdata));
    ftDataHC = HCdata(isfinite(HCdata));

    meanLC(i) = mean(ftDataLC);
    meanHC(i) = mean(ftDataHC);

    sdLC(i) = std(ftDataLC)/sqrt(length(ftDataLC));
    sdHC(i) = std(ftDataHC)/sqrt(length(ftDataHC));
end

%% Plotting
figure;
set(gcf, 'Windowstyle', 'docked');
Color = ["r","b"];

for i = 1:length(meanLC)
    subplot(1,2,1);
    hold on;
    bar(i, meanLC(i), Color(mod(i+1,2) + 1));
    errorbar(i, meanLC(i), sdLC(i),'LineStyle', 'none', 'LineWidth', 1.5, ...
        'Color','k');
    % Plot individual data points
    dataPoints = allDataLC{i};
    scatter(i*ones(size(dataPoints)), dataPoints, 'filled', ...
        'MarkerFaceColor', 'none', 'MarkerEdgeColor', 'k');
    ylim([0, 100]);
    title("Low cost", 'Interpreter','latex');
end

for i = 1:length(meanHC)
    subplot(1,2,2);
    hold on;
    bar(i, meanHC(i), Color(mod(i+1,2) + 1));
    errorbar(i, meanHC(i), sdHC(i),'LineStyle', 'none', 'LineWidth', 1.5, ...
        'Color','k');
    dataPoints = allDataHC{i};
    scatter(i*ones(size(dataPoints)), dataPoints, 'filled', ...
        'MarkerFaceColor', 'none', 'MarkerEdgeColor', 'k');
    ylim([0, 100]);
    title("High cost", 'Interpreter','latex');
end



%% Description of paddedData
function paddedData = paddedDataFun(allData)
maxLClength = max(cellfun(@length, allData));

for i = 1:numel(allData)
    if length(allData{i}) < maxLClength
        numNans = maxLClength - length(allData{i});
        allData{i} = [allData{i}; nan(numNans,1)];
    end
end

% Combine the padded data into a single matrix
paddedData = cell2mat(allData);
end

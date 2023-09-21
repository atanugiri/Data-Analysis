femaleBLSigFrac = [0.75, 1, 1, 0.75, 1, 1, 1, 1, 0.75, 1]; % BL = Baseline
maleBLSigFrac = [1, 1, 1, 1, 1, 1, 1, 0.75, 1, 1];

femaleOxySigFrac = [0.25, 0.1667, 0.50, 0.50, 0.3750];
maleOxySigFrac = [0.5, 0.5, 0.5, 0.3333, 0.1429];

BLsigFrac = [femaleBLSigFrac, maleBLSigFrac];
OxySigFrac = [femaleOxySigFrac, maleOxySigFrac];

figure;

subplot(1,2,1);

% Create a bar chart for the first 10 bars (femaleBLSigFrac) and set their color to red
bar(1:10, BLsigFrac(1:10), 'r');
hold on;

% Create a bar chart for the last 10 bars (maleBLSigFrac) and set their color to blue
bar(11:20, BLsigFrac(11:20), 'b');
hold off;

ylim([0 1]);

subplot(1,2,2);

% Create a bar chart for the first 5 bars (femaleOxySigFrac) and set their color to red
bar(1:5, OxySigFrac(1:5), 'r');
hold on;

% Create a bar chart for the last 5 bars (maleOxySigFrac) and set their color to blue
bar(6:10, OxySigFrac(6:10), 'b');
hold off;
ylim([0 1]);
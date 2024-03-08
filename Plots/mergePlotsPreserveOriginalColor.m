% Author: Atanu Giri
% Date: 08/08/2023

% This function overlays line plots
close all;

f1 = 'salApproachrate.fig';
f2 = 'ghrApproachrate.fig';

% Load the first figure and get the handles of the axes and children
fig1 = openfig(f1);
fig1ax = gca(fig1);
fig1axChildren = get(fig1ax, 'Children');

% Load the second figure and get the handles of the axes and children
fig2 = openfig(f2);
fig2ax = gca(fig2);
fig2axChildren = get(fig2ax, 'Children');

% Find the legend handle in the second figure
leg = findobj(fig2, 'Type', 'legend');

% Create a new figure for the combined plot
figFinal = figure();
ax = axes(figFinal);

% Copy the children (objects) from the first axes to the combined axes
h1 = copyobj(fig1axChildren, ax);

% Copy the children (objects) from the second axes to the combined axes
h2 = copyobj(fig2axChildren, ax);

% Get the original colors of the objects in the first figure
colors1 = getColorsFromObjects(fig1axChildren);

% Get the original colors of the objects in the second figure
colors2 = getColorsFromObjects(fig2axChildren);

% Combine the handles of the objects
h = [h1; h2];

% Set the original colors to the copied objects
if ~isequal(colors1, colors2)
    setColorsToObjects(h1, colors1);
    setColorsToObjects(h2, colors2);
else
    colors1{1} = [0 1 0]; colors1{2} = [0 1 0];
    colors2{1} = [0.5, 0, 0.5]; colors2{2} = [0.5, 0, 0.5];
    setColorsToObjects(h1, colors1);
    setColorsToObjects(h2, colors2);
end

% Adjust the legend, labels, and other settings
legend(ax, h, 'Location', leg.Location, 'Interpreter', 'latex');
xlabel(ax, fig2ax.XLabel.String, 'Interpreter', 'latex');
ylabel(ax, fig2ax.YLabel.String, 'Interpreter', 'latex');
set(ax, 'xticklabel', [0.5 "" 2 "" 5 "" 9], 'TickLabelInterpreter', 'latex');

% Save the combined figure as a new figure file
% savefig(figFinal, 'newS6e.fig');

% Close the figures to clean up
close(fig1);
close(fig2);

% Helper function to get the colors from objects
function colors = getColorsFromObjects(objects)
colors = cell(size(objects));
for i = 1:numel(objects)
    if isprop(objects(i), 'Color')
        colors{i} = objects(i).Color;
    elseif isprop(objects(i), 'MarkerEdgeColor')
        colors{i} = objects(i).MarkerEdgeColor;
    end
end
end

% Helper function to set the colors to objects
function setColorsToObjects(objects, colors)
for i = 1:numel(objects)
    if isprop(objects(i), 'Color')
        objects(i).Color = colors{i};
    elseif isprop(objects(i), 'MarkerEdgeColor')
        objects(i).MarkerEdgeColor = colors{i};
    end
end
end

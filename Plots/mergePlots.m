% Author: Atanu Giri
% Date: 10/11/2023

% This function overlays indefinite number of line plots

function mergePlots(varargin)
% Create a new figure for the combined plot
figFinal = figure();
ax = axes(figFinal);

for i = 1:numel(varargin)
    % Load the figure and get the handles of the axes and children
    fig = openfig(varargin{i});
    figAx = gca(fig);
    figAxChildren = get(figAx, 'Children');

    % Copy the children (objects) from the axes to the combined axes
    copyobj(figAxChildren, ax);
end
end
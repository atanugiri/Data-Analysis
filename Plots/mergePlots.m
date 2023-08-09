% Define the two figure files that are on the MATLAB path
% These are the only "inputs" to this script
close all; clc;
f1 = '2eBL.fig';
f2 = 'S7a.fig';

% Open the figures
fig1 = openfig(f1);
fig2 = openfig(f2);

% get axes handles - this assumes there is only 1 axes per figure!
fig1ax = gca(fig1);
fig2ax = gca(fig2);

leg = findobj(fig2,'Type','legend');

% Get axis children
fig1axChildren = get(fig1ax,'Children');
fig2axChildren = get(fig2ax,'Children');

% Create new fig, copy items from fig 1
% This will maintain set properties such as color
figFinal = figure();
ax = axes(figFinal);
h1 = copyobj(fig1axChildren, ax);

% delete undesirable objects
% h1ObjColors = cell2mat(get(h1,'color'));
% [~, h1Groups, h1GroupID] = unique(h1ObjColors,'rows');

% Copy items from fig 2
h2 = copyobj(fig2axChildren, ax);


% Generate a set of distinct colors
colors = distinguishable_colors(numel(h1)+numel(h2));

% Reset color but maintain color groups
colors = recolorgroups(h1,colors);
colors = recolorgroups(h2,colors);

% Add legend to same location as the legend in fig2 
% but only include objects with a defined DisplayName
h = [h1;h2];

hasDisplayName = ~cellfun('isempty',get(h,'DisplayName'));
legend(ax, h(hasDisplayName),'Location', leg.Location,'Interpreter','latex');
legendStrings = legend(ax, h(hasDisplayName)).String;

% Copy axis labels
xlabel(ax, fig2ax.XLabel.String,'Interpreter','latex')
ylabel(ax, fig2ax.YLabel.String,'Interpreter','latex')

% Reset x labels
label = [0.5 "" 2 "" 5 "" 9];
set(gca,'xticklabel',label,'TickLabelInterpreter','latex');
fig_name = 'approachavoid';
ylabel('approachavoid',"Interpreter","latex");

% ylim([2 11]);
hold on;
% Delete undesirable data
objColors = cell2mat(get(h,'color'));
[C, groups, groupID] = unique(objColors,'rows');

% find which group id to be deleted
% groupIDColor = objColors(find(groupID == 5,1),:);
% plot(linspace(1,10),linspace(1,10),'Color',groupIDColor,'LineWidth',2);
objects = findobj(h, 'Type', {'Line'}, 'Color', C(1,:));
% delete(objects);
% delete(h(groupID == 1));
% delete(h(groupID == 2));

% save figure
savefig(figFinal,sprintf('%s.fig',fig_name));
% print(figFinal,fig_name,'-dpng');


function colors = recolorgroups(objs,colors)
% objs is a vector of objects
% ax is the parent axes
% Group new objects by color
objColors = cell2mat(get(objs,'color'));
[~, groups, groupID] = unique(objColors,'rows');
% For each color group, set 1 member to use the next series index and set
% the other members to the same series index value.
for i = 1:numel(groups)
    hh = objs(groupID == groups(i));
    set(hh,'Color',colors(i,:));
    set(hh(2:end),'SeriesIndex', hh(1).SeriesIndex)
    set(hh,{'MarkerFaceColor'},get(hh,'color'));
end
colors = colors(numel(groups)+1:end,:);
end
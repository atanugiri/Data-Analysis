% Author: Atanu Giri
% Date: 04/20/2023
% This function looks for correlation of sigmoid fit for each session of
% animals.
%% Invokes psychometricFunPlotValues, sigmoid_fit, figureLimitFun

% oxyFemales = {'pepper','barbie','wanda','vision','bopeep','trixie'};
% oxyMales = {'captain','buzz','woody','rex','slinky','ken'};
% alcoholFemales = {'fiona','juana','kryssia','neftali','raven'};
% alcoholMales = {'aladdin','jafar','jimi','scar','simba'};
% boostFemales = {'alexis','harley','renata','sarah','shakira'};
% boostMales = {'carl','jr','kobe','mike','sully'};


function [fractionOfSigmoid, appRateFracGTthr] = sessionPlotLoop(feature)

% feature = 'approachavoid';
% connect to database
datasource = 'live_database';
conn = database(datasource,'postgres','1234');

%% Which animals do you want to plot
animalList = {'captain','buzz','woody','rex','slinky','ken'};
% Set Thresholds
minimumFit = 0.4;
minAppRate = 0.25;

fractionOfSigmoid = zeros(1,length(animalList));
appRateFracGTthr = zeros(1,length(animalList));
fitResult = cell(1,length(animalList));

for animal = 1:length(animalList)
    try
        liveTableQuery = sprintf("SELECT id, genotype, subjectid, health, referencetime, " + ...
            "gender, feeder FROM live_table WHERE subjectid = '%s' ORDER BY id;", animalList{animal});
        liveTableData = fetch(conn,liveTableQuery);

        ids = sprintf('%d,',liveTableData.id); % convert array to string
        ids = ids(1:end-1); % remove last comma

        featuretableQuery = sprintf("SELECT id, tasktypedone, %s FROM featuretable2 WHERE id IN (%s) ORDER BY id;", ...
            feature,ids);
        featuretableData = fetch(conn,featuretableQuery);

        % Join two tables by id
        subjectData = innerjoin(liveTableData,featuretableData,'Keys','id');
        % drop the timestamps from referencetime for clustering
        subjectData.referencetime = datetime(subjectData.referencetime);
        subjectData.referencetime.Format = "MM/dd/yyyy";
        % convert all the oxyData to string (except for id)
        for columns = 2:size(subjectData,2)
            subjectData.(columns) = string(subjectData.(columns));
        end
        % determine if the feature is logical
        logicalFeature = any(ismember(subjectData.(feature),'true') | ismember(subjectData.(feature),'false'));
        if ~logicalFeature
            % convert feature column from string to double
            subjectData.(feature) = str2double(subjectData.(feature));
        end
        % Get only desired tasktypetone
        uniqueTasktypedone = unique(subjectData.tasktypedone);
        fprintf('Unique tasktypedone:\n');
        fprintf('%s, ',uniqueTasktypedone);
        fprintf('\n');
        taskType = input('Enter tasktypedone (or enter "all" for all task types): ','s');
        if strcmpi(taskType, 'all')
        else
            % select a specific task type
            subjectData = subjectData(subjectData.tasktypedone == taskType,:);
        end

        uniqueDates = unique(subjectData.referencetime);
        fprintf('%s\n', animalList{animal});
        fprintf('Unique dates:\n');
        for i = 1:length(uniqueDates)
            fprintf('%d. %s\n',i,uniqueDates(i));
        end

        % Check the dates of range where the experiment was performed
        startIndex = input('Enter index of start date: ');
        stopIndex = input('Enter index of stop date: ');
        allGoodness = zeros(1,(stopIndex - startIndex + 1));
        appRateForMostAlcohol = zeros(1,length(allGoodness));
        for index = 1:length(allGoodness) % according to the health you want
            close all; clc;
            dataOnDate = subjectData(subjectData.referencetime == uniqueDates(startIndex+index-1),:);
            [~,avFeature,~] = psychometricFunPlotValues({dataOnDate},logicalFeature,feature);

            % Store the approach rate at highest alcohol concentration
            appRateForMostAlcohol(index) = avFeature{1}(1);
            %% invoke sigmoid_fit function for plot
            [h, ~, ~, goodness] = sigmoid_fit(cell2mat(avFeature));
            allGoodness(1,index) = goodness;
            hold on;
            %% invoke figureLimitFun function for limit
            figureLimit = figureLimitFun(feature);
            ylim([0 figureLimit]);

            %% Label the data
            ylabel(sprintf('%s',feature),"Interpreter",'latex','FontSize',15);
            dataLabel = sprintf('%s, %s, %s',dataOnDate.genotype(1),dataOnDate.tasktypedone(1), ...
                dataOnDate.health(1));
            sgtitle(dataLabel,'Interpreter','latex');

            label = sprintf('%s: %s, %d trials',animalList{animal},uniqueDates(startIndex+index-1), ...
                height(dataOnDate));
            text(2,0.9,label,'FontSize', 12, 'FontWeight', 'bold');
            fig_name = strrep(label, '/', '');
            fig_name = strrep(fig_name, ':', '_');
            fig_name = strrep(fig_name, ' ', '');
            %         print(h,fig_name,'-dpng','-r400');
            % savefig(h,sprintf('%s.fig',fig_name));
        end

        fitResult{animal} = allGoodness;
        % Count the number of entries between threshold and 1
        noOfSigmoid = sum(allGoodness >= minimumFit & allGoodness <= 1);
        fractionOfSigmoid(animal) = noOfSigmoid/length(allGoodness);
        appRateFracGTthr(animal) = ...
            sum(appRateForMostAlcohol >= minAppRate)/length(appRateForMostAlcohol);
        fprintf("%s done\n", animalList{animal});

    catch
        fprintf("%s done. Data not found\n", animalList{animal});
    end

end

end
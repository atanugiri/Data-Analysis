% Author: Atanu Giri
% Date: 12/15/2022
% This function returns average value, standard error, and p-values of
% features for control/baseline and healthtype for bar graph plot

function [healthFeatureForEachSubjectId,avFeatureOfHealthType,stdErrHealthType] ...
    = psychometricFunPlotValues(dataForHealthType,logicalFeature,feature)
% loadFile = load('dataForHealthType.mat');
% dataForHealthType = loadFile.dataForHealthType; logicalFeature = 0; feature = 'approachavoid';

% create a container for uniquesubjects
uniqueSubjectidInControlAndHealth = cell(length(dataForHealthType),1);
for health = 1:length(dataForHealthType)
    uniqueSubjectid = unique(dataForHealthType{health}.subjectid);
    uniqueSubjectidInControlAndHealth{health} = uniqueSubjectid;
end
% Only common subjectids will be cosidered for p-value calculation
refinedUniqueSubjectid = uniqueSubjectidInControlAndHealth{1};
for k = 2:numel(uniqueSubjectidInControlAndHealth)
    refinedUniqueSubjectid = intersect(refinedUniqueSubjectid,uniqueSubjectidInControlAndHealth{k});
end
% create a conatiner for all features needed for plot
healthFeatureForEachSubjectId = cell(length(dataForHealthType),1);
avFeatureOfHealthType = cell(length(dataForHealthType),1);
stdErrHealthType = cell(length(dataForHealthType),1);
allHealthFeature = cell(1,length(dataForHealthType));  % for test, you don't need this

for health = 1:length(dataForHealthType)
    dataForHealthType{health}.feeder = str2double(dataForHealthType{health}.feeder);
    for reward = 1:4
        if ~logicalFeature
            for thatSubjectid = 1:length(refinedUniqueSubjectid)
                allHealthFeatureForEachSubjectId = dataForHealthType{health}.(feature) ...
                    (dataForHealthType{health}.subjectid == refinedUniqueSubjectid(thatSubjectid) ...
                    & dataForHealthType{health}.feeder == (5-reward));
                nonInfData = ~isinf(allHealthFeatureForEachSubjectId);
                allHealthFeatureForEachSubjectId = allHealthFeatureForEachSubjectId(nonInfData);
                healthFeatureForEachSubjectId{health}{reward}(thatSubjectid) = ...
                    mean(allHealthFeatureForEachSubjectId,'omitnan');
                allHealthFeatureForEachSubjectIdTable = dataForHealthType{health} ...
                    (dataForHealthType{health}.subjectid == refinedUniqueSubjectid(thatSubjectid) ...
                    & dataForHealthType{health}.feeder == (5-reward),:);
                allHealthFeature{health}{reward}{thatSubjectid} = allHealthFeatureForEachSubjectIdTable; % for test, you don't need this

            end
        else
            for thatSubjectid = 1:length(refinedUniqueSubjectid)
                allHealthFeatureForEachSubjectId = dataForHealthType{health}.(feature) ...
                    (dataForHealthType{health}.subjectid == refinedUniqueSubjectid(thatSubjectid) ...
                    & dataForHealthType{health}.feeder == (5-reward));
                totalTrials = length(allHealthFeatureForEachSubjectId);
                trueTrials = length(find(allHealthFeatureForEachSubjectId == 'true'));
                healthFeatureForEachSubjectId{health}{reward}(thatSubjectid) = ...
                    trueTrials/totalTrials;
                allHealthFeatureForEachSubjectIdTable = dataForHealthType{health} ...
                    (dataForHealthType{health}.subjectid == refinedUniqueSubjectid(thatSubjectid) ...
                    & dataForHealthType{health}.feeder == (5-reward),:);
                allHealthFeature{health}{reward}{thatSubjectid} = allHealthFeatureForEachSubjectIdTable; % for test, you don't need this
            end
        end
        avFeatureOfHealthType{health}(reward) = ...
            mean(healthFeatureForEachSubjectId{health}{reward},'omitnan');
        stdErrHealthType{health}(reward) = std(healthFeatureForEachSubjectId{health}{reward},'omitnan')/ ...
            sqrt(length(healthFeatureForEachSubjectId{health}{reward} ...
            (~isnan(healthFeatureForEachSubjectId{health}{reward}))));
    end
end
% check if any uniquesubjectid table is empty 
totalEntry = zeros(length(dataForHealthType),4,length(refinedUniqueSubjectid));
for health = 1:length(dataForHealthType)
    for reward = 1:4
        for thatSubjectid = 1:length(refinedUniqueSubjectid)
            totalEntry(health,reward,thatSubjectid) = height(allHealthFeature{health}{reward}{thatSubjectid});
        end
    end
end
noEntry = sum(nnz(totalEntry == 0));
end
% Author: Atanu Giri
% Date: 12/11/2022
% This function returns average value, standard error, and p-values of
% features for control/baseline and healthtype for bar graph plot

function [healthFeatureForEachSubjectId,avFeatureOfHealthType,stdErrHealthType,pValues] ... 
= barGrpahValues(dataForHealthType,feature,logicalFeature)

% Alternative Input Files
loadFile = load('maleBeforeAndAfter.mat');
dataForHealthType = loadFile.maleBeforeAndAfter;
feature = 'alcoholAmount';
logicalFeature = 0;

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

% create a conatiner for all features for each subjectid
healthFeatureForEachSubjectId = cell(length(dataForHealthType),1);
% create a conatiner for average feature for each dataForTaskType
avFeatureOfHealthType = ones(length(dataForHealthType),1);
% create a conatiner for standard error for each dataForTaskType
stdErrHealthType = ones(length(dataForHealthType),1);
for health = 1:length(dataForHealthType)
    % Get the all and average feature for task type for each subjectid
    allFeatureOfSubjectid = cell(length(refinedUniqueSubjectid),1);
    avFeatureOfSubjectid = ones(length(refinedUniqueSubjectid),1);
    for thatSubjectid = 1:length(refinedUniqueSubjectid)
        allFeatureOfSubjectid{thatSubjectid} = dataForHealthType{health}.(feature) ...
            (dataForHealthType{health}.subjectid == refinedUniqueSubjectid(thatSubjectid));
        % check if the feature is logical
        if ~logicalFeature
            nonInfData = ~isinf(allFeatureOfSubjectid{thatSubjectid});
            allFeatureOfSubjectid{thatSubjectid} = allFeatureOfSubjectid{thatSubjectid}(nonInfData);
            avFeatureOfSubjectid(thatSubjectid) = mean(allFeatureOfSubjectid{thatSubjectid},'omitnan');
        else
            totalTrials = length(allFeatureOfSubjectid{thatSubjectid});
            trueTrials = length(find(allFeatureOfSubjectid{thatSubjectid} == 'true'));
            avFeatureOfSubjectid(thatSubjectid) = trueTrials/totalTrials;
        end
    end
    % Get average feature of each subjectid
    healthFeatureForEachSubjectId{health} = avFeatureOfSubjectid;
    % Get average feature for task type for all subjectid
    avFeatureOfHealthType(health) = mean(avFeatureOfSubjectid,'omitnan');
    % Get standard error of task type
    stdErrHealthType(health) = std(healthFeatureForEachSubjectId{health},'omitnan')/sqrt(length(healthFeatureForEachSubjectId{health} ...
        (~isnan(healthFeatureForEachSubjectId{health}))));
end
% paired t-test between baseline and food deprivation
pValues = ones(length(dataForHealthType),1);
for thisP = 1:length(pValues)
    [~,pValues(thisP)] = ttest2(healthFeatureForEachSubjectId{1},healthFeatureForEachSubjectId{thisP});
end
end
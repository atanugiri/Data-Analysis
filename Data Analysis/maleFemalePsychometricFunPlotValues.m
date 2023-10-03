% Author: Atanu Giri
% Date: 01/31/2023
% This function returns average value, standard error, and p-values of
% features for control/baseline and healthtype for bar graph plot

function [whichManipulation,featureForEachSubjectId,avFeatureOfGender,stdErrofGender] ...
    = maleFemalePsychometricFunPlotValues(dataForHealthType,logicalFeature,feature)
% loadFile = load("dataForHealthType.mat");
% dataForHealthType = loadFile.dataForHealthType; feature = 'approachavoid'; logicalFeature = 0;
if isa(dataForHealthType,'cell')
    % User input
    whichManipulation = input('Which manipulation do want to analyze?');
    healthManipulation = dataForHealthType{whichManipulation};
else
    healthManipulation = dataForHealthType;
    whichManipulation = nan;
end

dataInGender = {'FemaleData','maleData'};
dataInGender{1} = healthManipulation(strcmpi(healthManipulation.gender,'Female'),:);
dataInGender{2} = healthManipulation(strcmpi(healthManipulation.gender,'Male'),:);

uniqueSubjectid = cell(length(dataInGender),1);
for i = 1:length(dataInGender)
    uniqueSubjectid{i} = unique(dataInGender{i}.subjectid);
end

% create a conatiner for all features needed for plot
featureForEachSubjectId = cell(length(dataInGender),1);
avFeatureOfGender = cell(length(dataInGender),1);
stdErrofGender = cell(length(dataInGender),1);
allFeatureOfGender = cell(1,length(dataInGender));  % for test, you don't need this

for gender = 1:length(dataInGender)
    genderData = dataInGender{gender};
    genderData.feeder= str2double(genderData.feeder);
    for reward = 1:4
        if ~logicalFeature
            for thatSubjectid = 1:length(uniqueSubjectid{gender})
                allHealthFeature = genderData(genderData.subjectid == uniqueSubjectid{gender}(thatSubjectid) ...
                    & genderData.feeder == (5-reward),:);
                idx = isfinite(allHealthFeature.(feature));
                allHealthFeature = allHealthFeature(idx,:);
                featureForEachSubjectId{gender}{reward}(thatSubjectid) = ...
                    mean(allHealthFeature.(feature),'omitnan');
                allFeatureOfGender{gender}{reward}{thatSubjectid} = allHealthFeature; % for test, you don't need this
            end
        else
            for thatSubjectid = 1:length(uniqueSubjectid{gender})
                allHealthFeature = genderData(genderData.subjectid == uniqueSubjectid{gender}(thatSubjectid) ...
                    & genderData.feeder == (5-reward),:);
                totalTrials = height(allHealthFeature);
                trueTrials = length(find(allHealthFeature.(feature) == 'true'));
                featureForEachSubjectId{gender}{reward}(thatSubjectid) = ...
                    trueTrials/totalTrials;
                allFeatureOfGender{gender}{reward}{thatSubjectid} = allHealthFeature; % for test, you don't need this
            end
        end
        avFeatureOfGender{gender}(reward) = ...
            mean(featureForEachSubjectId{gender}{reward},'omitnan');
        stdErrofGender{gender}(reward) = std(featureForEachSubjectId{gender}{reward},'omitnan')/ ...
            sqrt(length(featureForEachSubjectId{gender}{reward} ...
            (~isnan(featureForEachSubjectId{gender}{reward}))));
    end
end
end
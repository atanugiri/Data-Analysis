% Author: Atanu Giri
% Date: 06/08/2023
% This function returns indivividual approach rate, average value, standard
% error of the animals at different concentration
function [featureForEachSubjectId, meanValue, stdErr] = psychometricFunctionValues(data,animalList)
featureForEachSubjectId = cell(1,4);
meanValue = zeros(1,4);
stdErr = zeros(1,4);
for conc = 1:4
    featureForEachSubjectId{conc} = zeros(length(animalList),1);
end

% Collect approach rate data
for ratIndex = 1:length(animalList)
    for conc = 1:4
        subjectid = animalList(ratIndex);
        dataOfSubjectid = data(data.subjectid == subjectid & data.feeder == (5-conc), :);
        approachavoidData = dataOfSubjectid.approachavoid(isfinite(dataOfSubjectid.approachavoid));
        featureForEachSubjectId{conc}(ratIndex) = sum(approachavoidData)/length(approachavoidData);
    end
end

% Get mean approach rate at each concentration
for conc = 1:4
    approachVector = featureForEachSubjectId{conc}(isfinite(featureForEachSubjectId{conc}));
    meanValue(conc) = mean(approachVector);
    stdErr(conc) = std(approachVector)/sqrt(length(approachVector));
end
end
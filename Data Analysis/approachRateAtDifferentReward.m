% Author: Atanu Giri
% Date: 07/09/2023
% This function plots approach rate of males and females at different
% sucrose concentration

datasource = 'live_database';
conn = database(datasource,'postgres','1234');

%% Query for Data
lightIntensityQuery = "SELECT id, referencetime, gender, health, tasktypedone, subjectid, " + ...
    "lightlevel, approachavoid FROM live_table WHERE genotype = 'CRL: Long Evans' AND " + ...
    "health = 'N/A' AND (tasktypedone = 'P2L1' OR tasktypedone = 'P2 L1') ORDER BY id;";
lightIntensityData = fetch(conn,lightIntensityQuery);

% drop the timestamps from referencetime for clustering
lightIntensityData.referencetime = datetime(lightIntensityData.referencetime);
lightIntensityData.referencetime.Format = "MM/dd/yyyy";
% convert all table data to string (except for id)
for columns = 2:length(lightIntensityData.Properties.VariableNames)
    lightIntensityData.(columns) = string(lightIntensityData.(columns));
end

% Choose subjects
femaleSubjects = ["alexis", "andrea", "fiona", "harley", "juana", "kryssia", ...
    "neftali", "raissa", "raven", "renata", "sarah", "shakira"];
maleSubjects = ["aladdin", "carl", "jafar", "jimi", "johnny", "jr", "kobe", ...
    "mike", "scar", "simba", "sully"];
subjectFilter = ismember(lightIntensityData.subjectid, [femaleSubjects, maleSubjects]);
lightIntensityData = lightIntensityData(subjectFilter, :);
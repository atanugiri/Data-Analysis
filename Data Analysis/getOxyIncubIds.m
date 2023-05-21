% Author: Atanu Giri
% Date: 04/15/2023
% This function gets the id of Oxycodon and Incubation data

function [oxyId, incubationId] = getOxyIncubIds()
% connect to database
datasource = 'live_database';
conn = database(datasource,'postgres','1234');

oxyFemales = {'pepper','barbie','wanda','vision','bopeep','trixie'};
oxyFemales = sprintf('''%s'',', oxyFemales{:});
oxyFemales = oxyFemales(1:end-1); % Remove trailing comma
oxyFemaleQuery = sprintf("SELECT id, genotype, tasktypedone, subjectid, health, referencetime " + ...
    "FROM live_table WHERE subjectid IN (%s) ORDER BY id;",oxyFemales);
oxyFemaleData = fetch(conn,oxyFemaleQuery);
% drop the timestamps from referencetime for clustering
oxyFemaleData.referencetime = datetime(oxyFemaleData.referencetime);
oxyFemaleData.referencetime.Format = "MM/dd/yyyy";
for col = 2:size(oxyFemaleData,2)
    oxyFemaleData.(col) = string(oxyFemaleData.(col));
end


%% Seperate Oxy Data and store them together for male and female
% Female Oxy
oxyDataPepper = oxyFemaleData(((oxyFemaleData.referencetime >= "04/26/2022" & ...
    oxyFemaleData.referencetime <= "05/09/2022") & (oxyFemaleData.subjectid == "pepper")),:);
oxyDataBarbie = oxyFemaleData(((oxyFemaleData.referencetime >= "05/26/2022" & ...
    oxyFemaleData.referencetime <= "06/08/2022") & (oxyFemaleData.subjectid == "barbie")),:);
oxyDataWanda = oxyFemaleData(((oxyFemaleData.referencetime >= "06/03/2022" & ...
    oxyFemaleData.referencetime <= "06/16/2022") & (oxyFemaleData.subjectid == "wanda")),:);
oxyDataVision = oxyFemaleData(((oxyFemaleData.referencetime >= "06/03/2022" & ...
    oxyFemaleData.referencetime <= "06/16/2022") & (oxyFemaleData.subjectid == "vision")),:);
oxyDataBopeep = oxyFemaleData(((oxyFemaleData.referencetime >= "06/03/2022" & ...
    oxyFemaleData.referencetime <= "06/16/2022") & (oxyFemaleData.subjectid == "bopeep")),:);
oxyDataTrixie = oxyFemaleData(((oxyFemaleData.referencetime >= "05/26/2022" & ...
    oxyFemaleData.referencetime <= "06/08/2022") & (oxyFemaleData.subjectid == "trixie")),:);

% Concatenate oxyData for each female
oxyDataFemale = vertcat(oxyDataPepper,oxyDataBarbie,oxyDataWanda, ...
    oxyDataVision,oxyDataBopeep,oxyDataTrixie);

oxyMales = {'captain','buzz','woody','rex','slinky','ken'};
oxyMales = sprintf('''%s'',', oxyMales{:});
oxyMales = oxyMales(1:end-1); % Remove trailing comma
oxyMaleQuery = sprintf("SELECT id, genotype, tasktypedone, subjectid, health, referencetime " + ...
    "FROM live_table WHERE subjectid IN (%s) ORDER BY id;",oxyMales);
oxyMaleData = fetch(conn,oxyMaleQuery);
% drop the timestamps from referencetime for clustering
oxyMaleData.referencetime = datetime(oxyMaleData.referencetime);
oxyMaleData.referencetime.Format = "MM/dd/yyyy";
for col = 2:size(oxyMaleData,2)
    oxyMaleData.(col) = string(oxyMaleData.(col));
end

% Male Oxy
oxyDataCaptain = oxyMaleData(((oxyMaleData.referencetime >= "04/26/2022" & ...
    oxyMaleData.referencetime <= "05/09/2022") & (oxyMaleData.subjectid == "captain")),:);
oxyDataBuzz = oxyMaleData(((oxyMaleData.referencetime >= "05/19/2022" & ...
    oxyMaleData.referencetime <= "06/01/2022") & (oxyMaleData.subjectid == "buzz")),:);
oxyDataWoody = oxyMaleData(((oxyMaleData.referencetime >= "05/19/2022" & ...
    oxyMaleData.referencetime <= "06/01/2022") & (oxyMaleData.subjectid == "woody")),:);
oxyDataRex = oxyMaleData(((oxyMaleData.referencetime >= "05/19/2022" & ...
    oxyMaleData.referencetime <= "06/01/2022") & (oxyMaleData.subjectid == "rex")),:);
oxyDataSlinky = oxyMaleData(((oxyMaleData.referencetime >= "05/26/2022" & ...
    oxyMaleData.referencetime <= "06/08/2022") & (oxyMaleData.subjectid == "slinky")),:);
oxyDataKen = oxyMaleData(((oxyMaleData.referencetime >= "05/26/2022" & ...
    oxyMaleData.referencetime <= "06/08/2022") & (oxyMaleData.subjectid == "ken")),:);

% Concatenate oxyData for each male
oxyDataMale = vertcat(oxyDataCaptain,oxyDataBuzz,oxyDataWoody, ...
    oxyDataRex,oxyDataSlinky,oxyDataKen);

% All Oxy
oxyData = vertcat(oxyDataFemale,oxyDataMale);
oxyId = oxyData.id;

%% Seperate Incubation Data and store them together for male and female
% Female Incubation
incDataPepper = oxyFemaleData(((oxyFemaleData.referencetime >= "05/10/2022" & ...
    oxyFemaleData.referencetime <= "06/08/2022") & (oxyFemaleData.subjectid == "pepper")),:);
incDataBarbie = oxyFemaleData(((oxyFemaleData.referencetime >= "06/09/2022" & ...
    oxyFemaleData.referencetime <= "06/23/2022") & (oxyFemaleData.subjectid == "barbie")),:);
incDataWanda = oxyFemaleData(((oxyFemaleData.referencetime >= "06/17/2022" & ...
    oxyFemaleData.referencetime <= "07/01/2022") & (oxyFemaleData.subjectid == "wanda")),:);
incDataVision = oxyFemaleData(((oxyFemaleData.referencetime >= "06/17/2022" & ...
    oxyFemaleData.referencetime <= "07/01/2022") & (oxyFemaleData.subjectid == "vision")),:);
incDataBopeep = oxyFemaleData(((oxyFemaleData.referencetime >= "06/17/2022" & ...
    oxyFemaleData.referencetime <= "07/01/2022") & (oxyFemaleData.subjectid == "bopeep")),:);
incDataTrixie = oxyFemaleData(((oxyFemaleData.referencetime >= "06/09/2022" & ...
    oxyFemaleData.referencetime <= "06/23/2022") & (oxyFemaleData.subjectid == "trixie")),:);

% Concatenate incData for each female
incDataFemale = vertcat(incDataPepper,incDataBarbie,incDataWanda, ...
    incDataVision,incDataBopeep,incDataTrixie);

% Male Incubation
incDataCaptain = oxyMaleData(((oxyMaleData.referencetime >= "05/10/2022" & ...
    oxyMaleData.referencetime <= "06/08/2022") & (oxyMaleData.subjectid == "captain")),:);
incDataBuzz = oxyMaleData(((oxyMaleData.referencetime >= "06/02/2022" & ...
    oxyMaleData.referencetime <= "06/24/2022") & (oxyMaleData.subjectid == "buzz")),:);
incDataWoody = oxyMaleData(((oxyMaleData.referencetime >= "06/02/2022" & ...
    oxyMaleData.referencetime <= "06/24/2022") & (oxyMaleData.subjectid == "woody")),:);
incDataRex = oxyMaleData(((oxyMaleData.referencetime >= "06/02/2022" & ...
    oxyMaleData.referencetime <= "06/24/2022") & (oxyMaleData.subjectid == "rex")),:);
incDataSlinky = oxyMaleData(((oxyMaleData.referencetime >= "06/09/2022" & ...
    oxyMaleData.referencetime <= "06/24/2022") & (oxyMaleData.subjectid == "slinky")),:);
incDataKen = oxyMaleData(((oxyMaleData.referencetime >= "06/09/2022" & ...
    oxyMaleData.referencetime <= "06/24/2022") & (oxyMaleData.subjectid == "ken")),:);

% Concatenate incData for each male
incDataMale = vertcat(incDataCaptain,incDataBuzz,incDataWoody, ...
    incDataRex,incDataSlinky,incDataKen);

% All Incubation
incubationData = vertcat(incDataFemale,incDataMale);
incubationId = incubationData.id;
close(conn);
end
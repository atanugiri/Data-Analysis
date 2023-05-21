% connect to database
datasource = 'live_database';
conn = database(datasource,'postgres','1234');

% How many unique subjects are there?
subjectidQuery = "SELECT subjectid FROM live_table ORDER BY id;";
allSubjectid = fetch(conn,subjectidQuery);
allSubjectid.subjectid = string(allSubjectid.subjectid);
uniqueSubjectid = unique(allSubjectid.subjectid);

% How many unique dates are there?
dateQuery = "SELECT referencetime FROM live_table ORDER BY id;";
allReferencetime = fetch(conn,dateQuery);
allReferencetime.referencetime = string(datetime(allReferencetime.referencetime, ...
    'Format','MM/dd/uuuu'));
uniqueDates = unique(allReferencetime.referencetime);

% How many unique tasktypedone are there?
tasktypedoneQuery = "SELECT tasktypedone FROM featuretable ORDER BY id;";
allTasktypedone = fetch(conn,tasktypedoneQuery);
allTasktypedone.tasktypedone = string(allTasktypedone.tasktypedone);
uniqueTasktypedone = unique(allTasktypedone.tasktypedone);
taskOfInetrest = {'P2L1';'P2L1L3'};

% How many unique health are there
healthQuery = "SELECT health FROM live_table;";
allHealth = fetch(conn,healthQuery);
allHealth.health = string(allHealth.health);
uniqueHealth = unique(allHealth.health);

% How many unique rewardComposition are there?
rewardCompositionQuery = "SELECT rewardComposition FROM featuretable ORDER BY id;";
allRewardComposition = fetch(conn,rewardCompositionQuery);
allRewardComposition.rewardcomposition = string(allRewardComposition.rewardcomposition);
uniqueRewardComposition = unique(allRewardComposition.rewardcomposition);

% How many unique intensityofcostType are there?
intensityofcostTypeQuery = "SELECT intensityofcosttype FROM featuretable ORDER BY id;";
allIntensityofcostType = fetch(conn,intensityofcostTypeQuery);
allIntensityofcostType.intensityofcosttype = string(allIntensityofcostType.intensityofcosttype);
uniqueIntensityofcostType = unique(allIntensityofcostType.intensityofcosttype);

% How many unique gender are there?
genderQuery = "SELECT gender FROM live_table ORDER BY id;";
allGender = fetch(conn,genderQuery);
allGender.gender = string(allGender.gender);
uniqueGender = unique(allGender.gender);
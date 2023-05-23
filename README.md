# Data-Analysis
Data analysis of live_database data
Figure 2a: From “Data Analysis” directory run the function, 
masterPsychometricFunctionPlot(‘approachavoid’).
For user inputs please enter the following inputs:
i) Enter genotype: CRL: Long Evans
ii) Do you want to analyze only approach trials? (y/n) n
iii) Enter tasktypedone (or enter "all" for all task types): P2L1
iv) Which health types do you want to analyze?
(enter multiple values separated by comma and a space or type 'all' for all types): N/A
v) Start date? 06/16/2022
vi) End date? 06/23/2022
vii) Do you want to split the graph by gender? (y/n) y

Figure 2d: From “Data Analysis” directory run the function, 
masterPsychometricFunctionPlot(‘entrytime’).
For user inputs please enter the following inputs:
i) Enter genotype: CRL: Long Evans
ii) Do you want to analyze only approach trials? (y/n) y
For rest of the user inputs please enter the same inputs as in Figure 2a

Figure 2e: From “Data Analysis” directory run the function, 
masterPsychometricFunctionPlot(‘distanceaftertoneuntillimitingtimestamp’). 
For user inputs please enter the same inputs as Figure 2a

Figure 2f: From “Data Analysis” directory run the function, 
masterPsychometricFunctionPlot(‘stoppingpts_per_unittravel_method6’). 
For user inputs please enter the same inputs as Figure 2a

Figure 2g: From “Data Analysis” directory run the function, 
masterPsychometricFunctionPlot(‘bigaccelerationperunittravel’). 
For user inputs please enter the same inputs as Figure 2a

Figure 2h: From “Data Analysis” directory run the function, 
masterPsychometricFunctionPlot(‘passingcentralzonerejectinitialpresence’). 
For user inputs please enter the same inputs as Figure 2a



Figure 5a: 
Step 1: Get ‘Sans food dep’ figure.
For ‘Sans food dep’ From “Data Analysis” directory run the function, 
masterPsychometricFunctionPlot(‘approachavoid’). 
For user inputs please enter the following inputs:
i) Enter genotype: CRL: Long Evans
ii) Do you want to analyze only approach trials? (y/n) n
iii) Enter tasktypedone (or enter "all" for all task types): P2L1
iv) Which health types do you want to analyze?
(enter multiple values separated by comma and a space or type 'all' for all types): N/A
v) Start date? 06/16/2022
vi) End date? 06/23/2022
vii) Do you want to split the graph by gender? (y/n) n
viii) Do you want to a graph for specific animal? (y/n) n

Step2: Get ‘Food dep’ figure.
For ‘Food dep’ From “Data Analysis” directory run the function, 
masterPsychometricFunctionPlot(‘approachavoid’). 
For user inputs please enter the following inputs:
i) Enter genotype: CRL: Long Evans
ii) Do you want to analyze only approach trials? (y/n) n
iii) Enter tasktypedone (or enter "all" for all task types): P2L1
iv) Which health types do you want to analyze?
(enter multiple values separated by comma and a space or type 'all' for all types): Food Deprivation
v) Start date? 08/23/2022
vi) End date? 08/25/2022
vii) Do you want to split the graph by gender? (y/n) n
viii) Do you want to a graph for specific animal? (y/n) n

Step3: Overlay ‘Sans food dep’ and ‘Food dep’ figures.
i) Open mergePlots.m from ‘Plots’ directory
ii) Paste the figures obtained in step 1 and 2 for ‘f1’ and ‘f2’
iii) Comment out rest of the figure names since we don’t want to overlay more
iv) Run the script


Figure 5c: 
Step 1: Get ‘Sans food dep’ figure.
For ‘Sans food dep’ From “Data Analysis” directory run the function, 
masterPsychometricFunctionPlot(‘entrytime’). 
For user inputs please enter the following inputs:
i) Enter genotype: CRL: Long Evans
ii) Do you want to analyze only approach trials? (y/n) y
For rest of the user inputs please enter the same inputs as Step1 in Figure 5a

Step2: Get ‘Food dep’ figure.
For ‘Food dep’ From “Data Analysis” directory run the function, 
masterPsychometricFunctionPlot(‘entrytime’). 
For user inputs please enter the following inputs:
i) Enter genotype: CRL: Long Evans
ii) Do you want to analyze only approach trials? (y/n) y
For rest of the user inputs please enter the same inputs as Step2 in Figure 5a

Step3: Overlay ‘Sans food dep’ and ‘Food dep’ figures.
Please follow the same steps as Step3 in Figure 5a


Figure 5d: 
Step 1: Get ‘Sans food dep’ figure.
For ‘Sans food dep’ From “Data Analysis” directory run the function, 
masterPsychometricFunctionPlot(‘distanceaftertoneuntillimitingtimestamp’). 
For user inputs please enter the same inputs as Step1 in Figure 5a

Step2: Get ‘Food dep’ figure.
For ‘Food dep’ From “Data Analysis” directory run the function, 
masterPsychometricFunctionPlot(‘distanceaftertoneuntillimitingtimestamp’). 
For user inputs please enter the same inputs as Step2 in Figure 5a

Step3: Overlay ‘Sans food dep’ and ‘Food dep’ figures.
Please follow the same steps as Step3 in Figure 5a


Figure 5e: 
Step 1: Get ‘Sans food dep’ figure.
For ‘Sans food dep’ From “Data Analysis” directory run the function, 
masterPsychometricFunctionPlot(‘stoppingpts_per_unittravel_method6’). 
For user inputs please enter the same inputs as Step1 in Figure 5a

Step2: Get ‘Food dep’ figure.
For ‘Food dep’ From “Data Analysis” directory run the function, 
masterPsychometricFunctionPlot(‘stoppingpts_per_unittravel_method6’). 
For user inputs please enter the same inputs as Step2 in Figure 5a

Step3: Overlay ‘Sans food dep’ and ‘Food dep’ figures.
Please follow the same steps as Step3 in Figure 5a



Figure 5f: 
Step 1: Get ‘Sans food dep’ figure.
For ‘Sans food dep’ From “Data Analysis” directory run the function, 
masterPsychometricFunctionPlot(‘bigaccelerationperunittravel’).
For user inputs please enter the same inputs as Step1 in Figure 5a

Step2: Get ‘Food dep’ figure.
For ‘Food dep’ From “Data Analysis” directory run the function, 
masterPsychometricFunctionPlot(‘bigaccelerationperunittravel’).
For user inputs please enter the same inputs as Step2 in Figure 5a

Step3: Overlay ‘Sans food dep’ and ‘Food dep’ figures.
Please follow the same steps as Step3 in Figure 5a



Figure 5g: 
Step 1: Get ‘Sans food dep’ figure.
For ‘Sans food dep’ From “Data Analysis” directory run the function, 
masterPsychometricFunctionPlot(‘passingcentralzonerejectinitialpresence’).
For user inputs please enter the same inputs as Step1 in Figure 5a

Step2: Get ‘Food dep’ figure.
For ‘Food dep’ From “Data Analysis” directory run the function, 
masterPsychometricFunctionPlot(‘passingcentralzonerejectinitialpresence’).
For user inputs please enter the same inputs as Step2 in Figure 5a

Step3: Overlay ‘Sans food dep’ and ‘Food dep’ figures.
Please follow the same steps as Step3 in Figure 5a




Figure 6b (Left): From “Data Analysis” directory run the function, alcoholPsychometricFunctionPlot(‘approachavoid’)
For user inputs please enter the following inputs:
i) Enter genotype: CRL: Long Evans
ii) Do you want to analyze only approach trials? (y/n) n
iii) Enter tasktypedone (or enter "all" for all task types): P2A
iv) Which health types do you want to analyze?
(enter multiple values separated by comma and a space or type 'all' for all types): N/A
v) Start date? 09/16/2022
vi) End date? 10/03/2022
vii) Do you want to split the graph by gender? (y/n) y


Figure 6b (Right): From “Data Analysis” directory run the function, alcoholPsychometricFunctionPlot(‘approachavoid’)
For user inputs please enter the following inputs:
i) Enter genotype: lg_boost, lg_etoh
ii) Do you want to analyze only approach trials? (y/n) n
iii) Enter tasktypedone (or enter "all" for all task types): P2A
iv) Which health types do you want to analyze?
(enter multiple values separated by comma and a space or type 'all' for all types): N/A
v) Start date? 11/02/2022
vi) End date? 12/01/2022
vii) Do you want to split the graph by gender? (y/n) y

Figure 6d (Left): From “Data Analysis” directory run the function, alcoholPsychometricFunctionPlot(‘entrytime’)
For user inputs please enter the following inputs:
i) Enter genotype: CRL: Long Evans
ii) Do you want to analyze only approach trials? (y/n) y
For rest of the user inputs please enter the same inputs as in Figure 6b (Left)

Figure 6d (Right): From “Data Analysis” directory run the function, alcoholPsychometricFunctionPlot(‘entrytime’)
For user inputs please enter the following inputs:
i) Enter genotype: lg_boost, lg_etoh
ii) Do you want to analyze only approach trials? (y/n) y
For rest of the user inputs please enter the same inputs as in Figure 6b (Right)

Figure 6e: From “Data Analysis” directory run the function, 
oxyPsychometricFunctionPlot(‘approachavoid’). 
For user inputs please enter the following inputs:
i) Which data do you want to analyze? Print "Oxycodon" or "Incubation"
Oxycodon
ii) Do you want to analyze only approach trials? (y/n) n
iii) Do you want to split the graph by gender? (y/n) y

Figure 6f: From “Data Analysis” directory run the function, 
oxyPsychometricFunctionPlot(‘stoppingpts_per_unittravel_method6’). 
For user inputs please enter the same inputs as Figure 6e

Figure 6g: From “Data Analysis” directory run the function, 
oxyPsychometricFunctionPlot(‘approachavoid’). 
For user inputs please enter the following inputs:
i) Which data do you want to analyze? Print "Oxycodon" or "Incubation"
Incubation 
ii) Do you want to analyze only approach trials? (y/n) n
iii) Do you want to split the graph by gender? (y/n) y

Figure 6h: From “Data Analysis” directory run the function, 
oxyPsychometricFunctionPlot(‘stoppingpts_per_unittravel_method6’). 
For user inputs please enter the same inputs as Figure 6g
	
Figure 6k: From “Data Analysis” directory run the function, barPlotOfOxy.



Supplemental Figure 6a: From “Data Analysis” directory run the function, 
masterPsychometricFunctionPlot(‘approachavoid’).
For user inputs please enter the following inputs:
i) Enter genotype: CRL: Long Evans
ii) Do you want to analyze only approach trials? (y/n) n
iii) Enter tasktypedone (or enter "all" for all task types): P2L1
iv) Which health types do you want to analyze?
(enter multiple values separated by comma and a space or type 'all' for all types): Food Deprivation
v) Start date? 08/23/2022
vi) End date? 08/25/2022
vii) Do you want to split the graph by gender? (y/n) y

Supplemental Figure 6b: From “Data Analysis” directory run the function, 
masterPsychometricFunctionPlot(‘distanceaftertoneuntillimitingtimestamp’).
For user inputs please enter the same inputs as Supplemental Figure 6a.

Supplemental Figure 6c: From “Data Analysis” directory run the function, 
masterPsychometricFunctionPlot(‘stoppingpts_per_unittravel_method6’).
For user inputs please enter the same inputs as Supplemental Figure 6a.

Supplemental Figure 6d: From “Data Analysis” directory run the function, 
masterPsychometricFunctionPlot(‘bigaccelerationperunittravel’).
For user inputs please enter the same inputs as Supplemental Figure 6a.

Supplemental Figure 6e: From “Data Analysis” directory run the function, 
masterPsychometricFunctionPlot(‘passingcentralzonerejectinitialpresence’).
For user inputs please enter the same inputs as Supplemental Figure 6a.





Supplemental Figure 7a (Left): From “Data Analysis” directory run the function, 
alcoholPsychometricFunctionPlot(‘bigaccelerationperunittravel’).
For user inputs please enter the same inputs as Figure 6b (Left).

Supplemental Figure 7a (Right): From “Data Analysis” directory run the function, 
alcoholPsychometricFunctionPlot(‘bigaccelerationperunittravel’).
For user inputs please enter the same inputs as Figure 6b (Right).

Supplemental Figure 7b (Left): From “Data Analysis” directory run the function, 
alcoholPsychometricFunctionPlot(‘distanceaftertoneuntillimitingtimestamp’).
For user inputs please enter the same inputs as Figure 6b (Left).

Supplemental Figure 7b (Right): From “Data Analysis” directory run the function, 
alcoholPsychometricFunctionPlot(‘distanceaftertoneuntillimitingtimestamp’).
For user inputs please enter the same inputs as Figure 6b (Right).

Supplemental Figure 7d: From “Data Analysis” directory run the function, 
oxyPsychometricFunctionPlot(‘entrytime’).
For user inputs please enter the following inputs:
i) Which data do you want to analyze? Print "Oxycodon" or "Incubation"
Oxycodon
ii) Do you want to analyze only approach trials? (y/n) y
iii) Do you want to split the graph by gender? (y/n) y

Supplemental Figure 7e: From “Data Analysis” directory run the function, 
oxyPsychometricFunctionPlot(‘passingcentralzonerejectinitialpresence’).
For user inputs please enter the same inputs as Figure 6e.

Supplemental Figure 7f: From “Data Analysis” directory run the function, 
oxyPsychometricFunctionPlot(‘bigaccelerationperunittravel’).
For user inputs please enter the same inputs as Figure 6e.

Supplemental Figure 7g: From “Data Analysis” directory run the function, 
oxyPsychometricFunctionPlot(‘distanceaftertoneuntillimitingtimestamp’).
For user inputs please enter the same inputs as Figure 6e.

Supplemental Figure 7h: From “Data Analysis” directory run the function, 
oxyPsychometricFunctionPlot(‘entrytime’).
For user inputs please enter the following inputs:
i) Which data do you want to analyze? Print "Oxycodon" or "Incubation"
Incubation 
ii) Do you want to analyze only approach trials? (y/n) y
iii) Do you want to split the graph by gender? (y/n) y

Supplemental Figure 7i: From “Data Analysis” directory run the function, 
oxyPsychometricFunctionPlot(‘bigaccelerationperunittravel’).
For user inputs please enter the same inputs as Figure 6g.

Supplemental Figure 7j: From “Data Analysis” directory run the function, 
oxyPsychometricFunctionPlot(‘distanceaftertoneuntillimitingtimestamp’).
For user inputs please enter the same inputs as Figure 6g.

Supplemental Figure 7k: From “Data Analysis” directory run the function, 
oxyPsychometricFunctionPlot(‘passingcentralzonerejectinitialpresence’).
For user inputs please enter the same inputs as Figure 6g.


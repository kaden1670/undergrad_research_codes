%% OAB pathway analysis
%3/26/21


%%
[num_OAB_data, txt_OAB_data, both_OAB_data] = xlsread('ALL_OAB_DATA.xlsx','All Data');
colnames = {'patient ID' 'DOB' 'Age' 'Sex' 'Invited' 'Pathway start date'...
    'Date reached satisfaction'	'Days to satisfaction'	'Last date contacted'...
    'Total f/u'	'Cysto date'	'UDS date'	'UROflow'	'Stage 1 satisfied'	...
    'Anticholinergic type'	'Myrbetriq'	'Total meds tried'	'Phone calls encouraging to use Doctella'...
    'Care call'	'Phone calls for drug issues'	'Other phone calls'	'Total phone calls'...
    'Long term folloup'	'PTFT'	'Stage success'	'Drug insurance denial'	'drug notes'...
    'PTNS booster'	'Conditions excluding from OAB dx'	'Telephone only'	'retention'...
    'PNE'	'No f/u appt'	'Advanced type'	'Date of advanced procedure' 'index'};
tAll_OAB_data = cell2table(both_OAB_data,'VariableNames',colnames);
tAll_OAB_data(1,:) = [];
All_OAB_data = table2struct(tAll_OAB_data);



        

%% satisfaction times
%twdb_keylookup(OutputCol,searchcol_n,searchvalue_n,...)

%below loop eliminates bad satisfaction data
count = 0;
badIdx = [];
for i = 1:length(All_OAB_data)
    if ischar(All_OAB_data(i).DaysToSatisfaction)
        count = count+1;
        badIdx(count) = i;
    elseif All_OAB_data(i).DaysToSatisfaction < 0
        count = count+1;
        badIdx(count) = i;
    elseif All_OAB_data(i).DaysToSatisfaction == 0
        count = count+1;
        badIdx(count) = i;
    end
end
Sat_OAB_data = All_OAB_data;
Sat_OAB_data(badIdx) = [];

%% satisfaction rate data
%below loop will label DaysToSatisfaction to -0.01 in pts without satisfaction
%must not be run more than once
SatRateData = All_OAB_data;

for i = 1:length(SatRateData)
    if ischar(SatRateData(i).DaysToSatisfaction)
        SatRateData(i).DaysToSatisfaction = -0.01;
    end
end

for i = 1:length(SatRateData)
    if strcmp(SatRateData(i).AdvancedType,'Botox')
        SatRateData(i).AdvancedType = 1;
    elseif strcmp(SatRateData(i).AdvancedType,'SNS')
        SatRateData(i).AdvancedType = 2;
    elseif strcmp(SatRateData(i).AdvancedType,'PTNS')
        SatRateData(i).AdvancedType = 3;
    end
end

%%
satisfactionTimeStage1 = cell2mat(twdb_keylookup(Sat_OAB_data,'DaysToSatisfaction','StageSuccess',1));
%avgSatTimeS1 = mean(cell2mat(satisfactionTimeStage1));

satisfactionTimeStage2 = cell2mat(twdb_keylookup(Sat_OAB_data,'DaysToSatisfaction','StageSuccess',2));
%avgSatTimeS2 = mean(cell2mat(satisfactionTimeStage2));

satisfactionTimeStage4 = cell2mat(twdb_keylookup(Sat_OAB_data,'DaysToSatisfaction','StageSuccess',4));
%avgSatTimeS4 = nanmean(cell2mat(satisfactionTimeStage4));

data = {satisfactionTimeStage1;satisfactionTimeStage2;satisfactionTimeStage4};

xnames1 = {'Stage 1 success' 'Stage 2 success' 'Stage 4 success'};
xnames2 = {sprintf('n = %d',length(satisfactionTimeStage1)) sprintf('n = %d',length(satisfactionTimeStage2))...
    sprintf('n = %d',length(satisfactionTimeStage4))};

yname= ['Days to satisfaction'];
colors = [0 0.4470 0.7410; 0.8500 0.3250 0.0980;0.9290 0.6940 0.1250];

plotbars(data,xnames1,xnames2,yname,colors,'tips')
[~, p1_2] = ttest2(satisfactionTimeStage1, satisfactionTimeStage2);
[~, p1_4] = ttest2(satisfactionTimeStage1, satisfactionTimeStage4);
[~, p2_4] = ttest2(satisfactionTimeStage2, satisfactionTimeStage4);


%% how many with pt

%turn NaN into No for PTFT
for i = 1:length(All_OAB_data)
    if isnan(All_OAB_data(i).PTFT)
        All_OAB_data(i).PTFT = 0;
    elseif strcmp(All_OAB_data(i).PTFT,'No')
        All_OAB_data(i).PTFT = 0;
    elseif strcmp(All_OAB_data(i).PTFT,'Yes')
        All_OAB_data(i).PTFT = 1;
    end
end

PT_Stage1 = cell2mat(twdb_lookup(All_OAB_data,'PTFT','key', 'StageSuccess',1));
PT_Stage2 = cell2mat(twdb_lookup(All_OAB_data,'PTFT','key', 'StageSuccess',2));
PT_Stage4 = cell2mat(twdb_lookup(All_OAB_data,'PTFT','key', 'StageSuccess',4));

data = {PT_Stage1; PT_Stage2; PT_Stage4};
xnames1 = {'Stage 1 success' 'Stage 2 success' 'Stage 4 success'};
xnames2 = {sprintf('n = %d',length(PT_Stage1)) sprintf('n = %d',length(PT_Stage2))...
    sprintf('n = %d',length(PT_Stage4))};
yname= ['Proportion of patients who chose supplimental PT'];
colors = [0 0.4470 0.7410; 0.8500 0.3250 0.0980;0.9290 0.6940 0.1250];

plotbars(data,xnames1,xnames2,yname,colors,'tips','nodots')


[~, p1_2] = ttest2(PT_Stage1, PT_Stage2);
[~, p1_4] = ttest2(PT_Stage1, PT_Stage4);
[~, p2_4] = ttest2(PT_Stage2, PT_Stage4);

%% number of phone calls
%Nan into 0
for i = 1:length(All_OAB_data)
    if isnan(All_OAB_data(i).TotalPhoneCalls)
        All_OAB_data(i).TotalPhoneCalls = 0;
    end
end

phoneStage1 = cell2mat(twdb_keylookup(All_OAB_data,'TotalPhoneCalls','StageSuccess',1));

phoneStage2 = cell2mat(twdb_keylookup(All_OAB_data,'TotalPhoneCalls','StageSuccess',2));

phoneStage4 = cell2mat(twdb_keylookup(All_OAB_data,'TotalPhoneCalls','StageSuccess',4));

DocPhoneS1 = cell2mat(twdb_keylookup(All_OAB_data,'PhoneCallsEncouragingToUseDoctella','StageSuccess',1));

DocPhoneS2 = cell2mat(twdb_keylookup(All_OAB_data,'PhoneCallsEncouragingToUseDoctella','StageSuccess',2));

DocPhoneS4 = cell2mat(twdb_keylookup(All_OAB_data,'PhoneCallsEncouragingToUseDoctella','StageSuccess',4));

NonDoctellaCallsS1 = phoneStage1 - DocPhoneS1;
NonDoctellaCallsS2 = phoneStage2 - DocPhoneS2;
NonDoctellaCallsS4 = phoneStage4 - DocPhoneS4;

data = {NonDoctellaCallsS1 NonDoctellaCallsS2 NonDoctellaCallsS4};
xnames1 = {'Stage 1 success' 'Stage 2 success' 'Stage 4 success'};
xnames2 = {sprintf('n = %d', length(NonDoctellaCallsS1)) sprintf('n = %d',length(NonDoctellaCallsS2))...
    sprintf('n = %d',length(NonDoctellaCallsS4))};

yname= ['Number of non-doctella related phone calls'];
colors = [0 0.4470 0.7410; 0.8500 0.3250 0.0980;0.9290 0.6940 0.1250];
plotbars(data,xnames1,xnames2,yname,colors,'tips')

[~, p1_2] = ttest2(NonDoctellaCallsS1, NonDoctellaCallsS2);
[~, p1_4] = ttest2(NonDoctellaCallsS1, NonDoctellaCallsS4);
[~, p2_4] = ttest2(NonDoctellaCallsS2, NonDoctellaCallsS4);

%% doctella-related phone calls
data = {DocPhoneS1; DocPhoneS2; DocPhoneS4};
xnames1 = {'Stage 1 success' 'Stage 2 success' 'Stage 4 success'};
xnames2 = {sprintf('n = %d', length(DocPhoneS1)) sprintf('n = %d',length(DocPhoneS2))...
    sprintf('n = %d',length(DocPhoneS4))};

yname= ['Number of doctella-related phone calls'];
colors = [0 0.4470 0.7410; 0.8500 0.3250 0.0980;0.9290 0.6940 0.1250];
plotbars(data,xnames1,xnames2,yname,colors,'tips')

[~, p1_2] = ttest2(DocPhoneS1, DocPhoneS2);
[~, p1_4] = ttest2(DocPhoneS1, DocPhoneS4);
[~, p2_4] = ttest2(DocPhoneS2, DocPhoneS4);


%% Non-doctella calls per day until satisfied
%Nan into 0
for i = 1:length(Sat_OAB_data)
    if isnan(Sat_OAB_data(i).TotalPhoneCalls)
        Sat_OAB_data(i).TotalPhoneCalls = 0;
    end
end

phoneStage1 = cell2mat(twdb_keylookup(Sat_OAB_data,'TotalPhoneCalls','StageSuccess',1));

phoneStage2 = cell2mat(twdb_keylookup(Sat_OAB_data,'TotalPhoneCalls','StageSuccess',2));

phoneStage4 = cell2mat(twdb_keylookup(Sat_OAB_data,'TotalPhoneCalls','StageSuccess',4));

DocPhoneS1 = cell2mat(twdb_keylookup(Sat_OAB_data,'PhoneCallsEncouragingToUseDoctella','StageSuccess',1));

DocPhoneS2 = cell2mat(twdb_keylookup(Sat_OAB_data,'PhoneCallsEncouragingToUseDoctella','StageSuccess',2));

DocPhoneS4 = cell2mat(twdb_keylookup(Sat_OAB_data,'PhoneCallsEncouragingToUseDoctella','StageSuccess',4));

NonDoctellaCallsS1 = phoneStage1 - DocPhoneS1;
NonDoctellaCallsS2 = phoneStage2 - DocPhoneS2;
NonDoctellaCallsS4 = phoneStage4 - DocPhoneS4;




nonDCperDayS1 = NonDoctellaCallsS1./ satisfactionTimeStage1;
nonDCperDayS2 = NonDoctellaCallsS2./ satisfactionTimeStage2;
nonDCperDayS4 = NonDoctellaCallsS4./ satisfactionTimeStage4;

data = {nonDCperDayS1; nonDCperDayS2; nonDCperDayS4};
xnames1 = {'Stage 1 success' 'Stage 2 success' 'Stage 4 success'};
xnames2 = {sprintf('n = %d', length(nonDCperDayS1)) sprintf('n = %d',length(nonDCperDayS2))...
    sprintf('n = %d',length(nonDCperDayS4))};

yname= ['Number of non-doctella-related phone calls per day'];
colors = [0 0.4470 0.7410; 0.8500 0.3250 0.0980;0.9290 0.6940 0.1250];
plotbars(data,xnames1,xnames2,yname,colors,'tips')

[~, p1_2] = ttest2(nonDCperDayS1, nonDCperDayS2);
[~, p1_4] = ttest2(nonDCperDayS1, nonDCperDayS4);
[~, p2_4] = ttest2(nonDCperDayS2, nonDCperDayS4);


%% group 4 treatment comparison
Treatment_sat_data = Sat_OAB_data;

for i = 1:length(Sat_OAB_data)
    if strcmp(Sat_OAB_data(i).AdvancedType,'Botox')
        Treatment_sat_data(i).AdvancedType = 1;
    elseif strcmp(Sat_OAB_data(i).AdvancedType,'SNS')
        Treatment_sat_data(i).AdvancedType = 2;
    elseif strcmp(Sat_OAB_data(i).AdvancedType,'PTNS')
        Treatment_sat_data(i).AdvancedType = 3;
    end
end


BotoxSat_times = cell2mat(twdb_lookup(Treatment_sat_data,'DaysToSatisfaction','key','AdvancedType',1));
SNSsat_times = cell2mat(twdb_lookup(Treatment_sat_data,'DaysToSatisfaction','key','AdvancedType',2));
PTNSsat_times = cell2mat(twdb_lookup(Treatment_sat_data,'DaysToSatisfaction','key','AdvancedType',3));

data = {BotoxSat_times; SNSsat_times; PTNSsat_times};
xnames1 = {'Botox treatment' 'SNS treatment' 'PTNS treatment'};
xnames2 = {sprintf('n = %d', length(BotoxSat_times)) sprintf('n = %d',length(SNSsat_times))...
    sprintf('n = %d',length(PTNSsat_times))};

yname= ['Days to satisfaction'];
colors = [0 0.4470 0.7410; 0.8500 0.3250 0.0980;0.9290 0.6940 0.1250];
plotbars(data,xnames1,xnames2,yname,colors,'tips')

[~, pB_S] = ttest2(BotoxSat_times, SNSsat_times);
[~, pB_P] = ttest2(BotoxSat_times, PTNSsat_times);
[~, pS_P] = ttest2(SNSsat_times, PTNSsat_times);

%% Satisfaction Rates
group1Total = cell2mat(twdb_lookup(SatRateData,'Age','key', 'StageSuccess',1));
group1UnSat = cell2mat(twdb_lookup(SatRateData,'Age','key', 'StageSuccess',1,...
    'key', 'DaysToSatisfaction', -0.01));

group2Total = cell2mat(twdb_lookup(SatRateData,'Age','key', 'StageSuccess',2));
group2UnSat = cell2mat(twdb_lookup(SatRateData,'Age','key', 'StageSuccess',2,...
    'key', 'DaysToSatisfaction', -0.01));

group4Total = cell2mat(twdb_lookup(SatRateData,'Age','key', 'StageSuccess',4));
group4UnSat = cell2mat(twdb_lookup(SatRateData,'Age','key', 'StageSuccess',4,...
    'key', 'DaysToSatisfaction', -0.01));

PTNS_total = cell2mat(twdb_lookup(SatRateData,'Age','key', 'AdvancedType',3));
PTNS_unsat = cell2mat(twdb_lookup(SatRateData,'Age','key', 'AdvancedType',3,...
    'key', 'DaysToSatisfaction', -0.01));

Botox_total = cell2mat(twdb_lookup(SatRateData,'Age','key', 'AdvancedType',1));
Botox_unsat = cell2mat(twdb_lookup(SatRateData,'Age','key', 'AdvancedType',1,...
    'key', 'DaysToSatisfaction', -0.01));

SNS_total = cell2mat(twdb_lookup(SatRateData,'Age','key', 'AdvancedType',2));
SNS_unsat = cell2mat(twdb_lookup(SatRateData,'Age','key', 'AdvancedType',2,...
    'key', 'DaysToSatisfaction', -0.01));

SatRateG4 = (length(group4Total)-length(group4UnSat))/(length(group4Total));

PTNS_RateG4 = (length(PTNS_total)-length(PTNS_unsat))/(length(PTNS_total));

Botox_RateG4 = (length(Botox_total)-length(Botox_unsat))/(length(Botox_total));

SNS_RateG4 = (length(SNS_total)-length(SNS_unsat))/(length(SNS_total));

data = {SatRateG4; PTNS_RateG4; Botox_RateG4;SNS_RateG4};
xnames1 = {'Advanced treatment' 'Botox treatment' 'SNS treatment' 'PTNS treatment'};
xnames2 = {sprintf('%d total patients', length(group4Total)) sprintf('%d total patients',length(PTNS_total))...
    sprintf('%d total patients',length(Botox_total)) sprintf('%d total patients',length(SNS_total))};

yname= ['Satisfaction rate'];
colors = [0 0.4470 0.7410; 0.8500 0.3250 0.0980;0.9290 0.6940 0.1250; 0.4660 0.6740 0.1880];
plotbars(data,xnames1,xnames2,yname,colors,'tips','nodots','noXnames2')
legend(xnames2,"location", "best")

%Tttest data
PTNS_binary = horzcat(zeros(1,length(PTNS_unsat)),ones(1,(length(PTNS_total)...
    - length(PTNS_unsat))));

Botox_binary = horzcat(zeros(1,length(Botox_unsat)),ones(1,(length(Botox_total)...
    - length(Botox_unsat))));

SNS_binary = horzcat(zeros(1,length(SNS_unsat)),ones(1,(length(SNS_total)...
    - length(SNS_unsat))));


[~, pB_S] = ttest2(Botox_binary, SNS_binary);
[~, pB_P] = ttest2(Botox_binary, PTNS_binary);
[~, pS_P] = ttest2(SNS_binary, PTNS_binary);


%% TotalMedsTried


%% ttest function

function p = ttest2p(dat1, dat2, varargin)
[~, p] = ttest2(dat1, dat2, varargin{:});
end

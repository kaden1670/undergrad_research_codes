%% Purpose: Compare number of procedures and outcome scores by Doctor
%6/23/21 
%

procedureData = table2struct(UroLiftandTURP2021Spreadsheet2S1);

%% Doctor names
docInitials = {'DH';'JW';'MJ';'CK';'DD';'JL';'RM';'BW';'MC';'TK';'BM';'DE'};
docIdentifiers = {"Hoff MD, Douglas G";"Woolsey MD, Jeffrey B";"Johnson MD, Michael";...
    "Kyle MD MPH, Christopher C";"DiMarco MD, David S";"Lloyd MD, Jessica C";...
    "McKimmy MD, Roger M";"Walker MD, Brady R";"Carson MD, Mark R";...
    "Kollmorgen MD, Thomas A";"Mehlhaff MD, Bryan  A";"Esrig MD, David"};


%% Raw tasks
rawTasks = {"index","SurgeryDate","AUAPrior","AUAPriorDate","FirstAUAPostSurgery",...
    "FirstAUAPostSurgeryDate","SecondAUAPostSurgery","SecondAUAPostSurgeryDate",...
    "ThirdAUAPostSurgery","ThirdAUAPostSurgeryDate"};

%for UroLift
for index = 1 : length(docInitials)
    %looking at each doctor
    docIdentifier = docIdentifiers{index};
    if index == 10
        disp("hi")
    end
    for j = 1:length(rawTasks)
        %completing each task
        s.(rawTasks{j}) = twdb_lookup(procedureData,...
        rawTasks{j},'key','SurgeryType','UroLift','key','Provider',...
        docIdentifier);
    end

    
    uroLiftStruct.(docInitials{index}) = s;  % Assign index to s.fred, s.sam, and s.al
end

%for TURP
for index = 1 : length(docInitials)
    %looking at each doctor
    docIdentifier = docIdentifiers{index};
        
    for j = 1:length(rawTasks)
        %completing each task
        s.(rawTasks{j}) = twdb_lookup(procedureData,...
        rawTasks{j},'key','SurgeryType','TURP','key','Provider',...
        docIdentifier);
    end

    
    TURPstruct.(docInitials{index}) = s;  % Assign index to s.fred, s.sam, and s.al
end

%% tasks to prepare graphing data
tasks = {"PriorScore","PriorScoreDateDifference","FirstScore","FirstScoreDateDifference",...
    "SecondScore","SecondScoreDateDifference",...
    "ThirdScore","ThirdScoreDateDifference","AvgPostScore"};

%uroLift
for i = 1:length(docInitials)
    docInitial = docInitials{i};
    st = [];
    for ii = 1:length(tasks)
        
        if strcmp(tasks{ii},"PriorScore")
            currentTask = cell2mat(getfield(uroLiftStruct,docInitial,'AUAPrior'));
            if ~(isempty(currentTask))
                if std(currentTask,'omitnan')~=0
                    [h,p] = kstest((rmmissing(currentTask)-mean(currentTask,'omitnan'))./std(currentTask,'omitnan'));
                    st.(tasks{ii}) = {currentTask; mean(currentTask,'omitnan');...
                        std(currentTask,'omitnan');[h,p];(length(currentTask)-sum(isnan(currentTask)))};
                else
                    st.(tasks{ii}) = {currentTask; mean(currentTask,'omitnan');...
                        std(currentTask,'omitnan');[];(length(currentTask)-sum(isnan(currentTask)))};
                end
                
            else 
                st.(tasks{ii}) = currentTask;
            end
        end
        
        if strcmp(tasks{ii}, "PriorScoreDateDifference")
            A = getfield(uroLiftStruct,docInitial,'SurgeryDate');
            A = vertcat(A{:});  
            B = getfield(uroLiftStruct,docInitial,'AUAPriorDate');
            B = vertcat(B{:});
            st.(tasks{ii}) = zeros(1,length(B));
        end
        
        if strcmp(tasks{ii},"FirstScore")
            st.(tasks{ii}) = cell2mat(getfield(uroLiftStruct,docInitial,...
                'FirstAUAPostSurgery'));
        end
            
        if strcmp(tasks{ii},"FirstScoreDateDifference")
            B = getfield(uroLiftStruct,docInitial,'FirstAUAPostSurgeryDate');
            B = vertcat(B{:});
            st.(tasks{ii}) = days(minus(B,A));
        end
        
        if strcmp(tasks{ii},"SecondScore")
            st.(tasks{ii}) = cell2mat(getfield(uroLiftStruct,docInitial,...
                'SecondAUAPostSurgery'));
        end

        if strcmp(tasks{ii},"SecondScoreDateDifference")
            B = getfield(uroLiftStruct,docInitial,'SecondAUAPostSurgeryDate');
            B = vertcat(B{:});
            st.(tasks{ii}) = days(minus(B,A));
        end
       
        if strcmp(tasks{ii},"ThirdScore")
            st.(tasks{ii}) = cell2mat(getfield(uroLiftStruct,docInitial,...
                'ThirdAUAPostSurgery'));
        end

        if strcmp(tasks{ii},"ThirdScoreDateDifference")
            B = getfield(uroLiftStruct,docInitial,'ThirdAUAPostSurgeryDate');
            B = vertcat(B{:});
            st.(tasks{ii}) = days(minus(B,A));
        end
        
        if strcmp(tasks{ii},"AvgPostScore")
            if ~isempty(st.FirstScore)
                AUAimprovementScores = [st.ThirdScore;st.SecondScore;...
                    st.FirstScore];

                avgAUAimprovement = zeros(1,size(AUAimprovementScores,2));

                counter = 1;
                for iii = 1:size(AUAimprovementScores,2)
                    for j = 1:3
                        if ~isnan(AUAimprovementScores(j,iii))

                            avgAUAimprovement(counter) = AUAimprovementScores(j,iii);
                            counter = counter +1;
                            break

                        elseif j ==3
                            avgAUAimprovement(counter) = NaN;
                            counter = counter +1;
                        end
                    end
                end
                currentTask = avgAUAimprovement;
                if ~isempty(currentTask)
                    [h,p] = kstest((rmmissing(currentTask)-mean(currentTask,'omitnan'))./std(currentTask,'omitnan'));
                    st.("AvgPostScore") = {currentTask; mean(currentTask,'omitnan');...
                            std(currentTask,'omitnan');[h,p];(length(currentTask)-sum(isnan(currentTask)))};
                end
            else
                st.("AvgPostScore") = [];
            end
        end
            
            
            
    end
    uroLiftStructGraphData.(docInitials{i}) = st;
end


%TURP
for i = 1:length(docInitials)
    docInitial = docInitials{i};
    st = [];
    for ii = 1:length(tasks)
        
        if strcmp(tasks{ii},"PriorScore")
            currentTask = cell2mat(getfield(TURPstruct,docInitial,'AUAPrior'));
            if ~(isempty(currentTask))
                if std(currentTask,'omitnan')~=0
                    [h,p] = kstest((rmmissing(currentTask)-mean(currentTask,'omitnan'))./std(currentTask,'omitnan'));
                    st.(tasks{ii}) = {currentTask; mean(currentTask,'omitnan');...
                        std(currentTask,'omitnan');[h,p];(length(currentTask)-sum(isnan(currentTask)))};
                else
                    st.(tasks{ii}) = {currentTask; mean(currentTask,'omitnan');...
                        std(currentTask,'omitnan');[];(length(currentTask)-sum(isnan(currentTask)))};
                end
                
            else 
                st.(tasks{ii}) = currentTask;
            end
        
        end
        
        if strcmp(tasks{ii}, "PriorScoreDateDifference")
            A = getfield(TURPstruct,docInitial,'SurgeryDate');
            A = vertcat(A{:});  
            B = getfield(TURPstruct,docInitial,'AUAPriorDate');
            B = vertcat(B{:});
            st.(tasks{ii}) = zeros(1,length(B));
        end  
        
        if strcmp(tasks{ii},"FirstScore")
            st.(tasks{ii}) = cell2mat(getfield(TURPstruct,docInitial,...
                'FirstAUAPostSurgery'));
        end
            
        if strcmp(tasks{ii},"FirstScoreDateDifference")
            A = getfield(TURPstruct,docInitial,'SurgeryDate');
            A = vertcat(A{:});
            B = getfield(TURPstruct,docInitial,'FirstAUAPostSurgeryDate');
            B = vertcat(B{:});
            st.(tasks{ii}) = days(minus(B,A));
        end
        
        if strcmp(tasks{ii},"SecondScore")
            st.(tasks{ii}) = cell2mat(getfield(TURPstruct,docInitial,...
                'SecondAUAPostSurgery'));
        end

        if strcmp(tasks{ii},"SecondScoreDateDifference")
            B = getfield(TURPstruct,docInitial,'SecondAUAPostSurgeryDate');
            B = vertcat(B{:});
            st.(tasks{ii}) = days(minus(B,A));
        end
       
        if strcmp(tasks{ii},"ThirdScore")
            st.(tasks{ii}) = cell2mat(getfield(TURPstruct,docInitial,...
                'ThirdAUAPostSurgery'));
        end

        if strcmp(tasks{ii},"ThirdScoreDateDifference")
            B = getfield(TURPstruct,docInitial,'ThirdAUAPostSurgeryDate');
            B = vertcat(B{:});
            st.(tasks{ii}) = days(minus(B,A));
        end
        

        if strcmp(tasks{ii},"AvgPostScore")
            if ~isempty(st.FirstScore)
                AUAimprovementScores = [st.ThirdScore;st.SecondScore;...
                    st.FirstScore];

                avgAUAimprovement = zeros(1,size((AUAimprovementScores),2));

                counter = 1;
                for iii = 1:size(AUAimprovementScores,2)
                    for j = 1:3
                        if ~isnan(AUAimprovementScores(j,iii))

                            avgAUAimprovement(counter) = AUAimprovementScores(j,iii);
                            counter = counter +1;
                            break

                        elseif j ==3
                            avgAUAimprovement(counter) = NaN;
                            counter = counter +1;
                        end
                    end
                end
                currentTask = avgAUAimprovement;
                if ~isempty(currentTask)
                    [h,p] = kstest((rmmissing(currentTask)-mean(currentTask,'omitnan'))./std(currentTask,'omitnan'));
                    st.("AvgPostScore") = {currentTask; mean(currentTask,'omitnan');...
                            std(currentTask,'omitnan');[h,p];(length(currentTask)-sum(isnan(currentTask)))};
                end
            else
                st.("AvgPostScore") = [];
            end
        end
        
    end
    TURPstructGraphData.(docInitials{i}) = st;
end

%% produce plots
%urolift
for i = 1:length(docInitials)
    docInitial = docInitials{i};
    
    PriorScore = getfield(uroLiftStructGraphData,docInitial,...
        'PriorScore');
    if iscell(PriorScore)
        PriorScore = PriorScore{1,1};
    end
    FirstScore = getfield(uroLiftStructGraphData,docInitial,...
        'FirstScore');
    SecondScore = getfield(uroLiftStructGraphData,docInitial,...
        'SecondScore');
    ThirdScore = getfield(uroLiftStructGraphData,docInitial,...
        'ThirdScore');
    
    date1 = getfield(uroLiftStructGraphData,docInitial,...
        'PriorScoreDateDifference');
    date2 = getfield(uroLiftStructGraphData,docInitial,...
        'FirstScoreDateDifference');
    date3 = getfield(uroLiftStructGraphData,docInitial,...
        'SecondScoreDateDifference');
    date4 = getfield(uroLiftStructGraphData,docInitial,...
        'ThirdScoreDateDifference');
    
    pt_x_scores = zeros(1,4);
    pt_x_dates = zeros(1,4);
    figure(i)
    for ii = 1:length(PriorScore)
        pt_x_scores(1:4) = [PriorScore(ii),FirstScore(ii),SecondScore(ii),ThirdScore(ii)];
        pt_x_dates(1:4) = [date1(ii),date2(ii),date3(ii),date4(ii)];
        
        plot(pt_x_dates,pt_x_scores.','-*k')
        hold on
    end
    title(strcat("2021 UroLift Patient Outcomes ", docInitial))
    xlabel("Days after surgery")
    ylabel("AUA Score")
    hold off
    
%     mkdir(strcat("DataPerDoc/", docInitial))
     a = strcat("DataPerDoc/", docInitial);
     b = strcat('UroLift ',docInitial);
     c = strcat(b,'.jpg');
     saveas(figure(i),fullfile(a,c),'jpeg')
end

close all
%TURP
for i = 1:length(docInitials)
    docInitial = docInitials{i};
    
    PriorScore = getfield(TURPstructGraphData,docInitial,...
        'PriorScore');
    if iscell(PriorScore)
        PriorScore = PriorScore{1,1};
    end
    
    FirstScore = getfield(TURPstructGraphData,docInitial,...
        'FirstScore');
    SecondScore = getfield(TURPstructGraphData,docInitial,...
        'SecondScore');
    ThirdScore = getfield(TURPstructGraphData,docInitial,...
        'ThirdScore');
    
    date1 = getfield(TURPstructGraphData,docInitial,...
        'PriorScoreDateDifference');
    date2 = getfield(TURPstructGraphData,docInitial,...
        'FirstScoreDateDifference');
    date3 = getfield(TURPstructGraphData,docInitial,...
        'SecondScoreDateDifference');
    date4 = getfield(TURPstructGraphData,docInitial,...
        'ThirdScoreDateDifference');
    
    pt_x_scores = zeros(1,4);
    pt_x_dates = zeros(1,4);
    figure(i)
    for ii = 1:length(PriorScore)
        pt_x_scores(1:4) = [PriorScore(ii),FirstScore(ii),SecondScore(ii),ThirdScore(ii)];
        pt_x_dates(1:4) = [date1(ii),date2(ii),date3(ii),date4(ii)];
        
        plot(pt_x_dates,pt_x_scores.','-*k')
        hold on
    end
    title(strcat("2021 TURP Patient Outcomes ", docInitial))
    xlabel("Days after surgery")
    ylabel("AUA Score")
    hold off
    
     a = strcat("DataPerDoc/", docInitial);
     b = strcat('TURP ',docInitial);
     c = strcat(b,'.jpg');
     saveas(figure(i),fullfile(a,c),'jpeg')
end
        
    
%% Practice Data

tableTasks = {"AUAPrior","FirstAUAPostSurgery","SecondAUAPostSurgery",...
    "ThirdAUAPostSurgery"};

%urolift
for l = 1:length(tableTasks)
    currentTask = cell2mat(twdb_lookup(procedureData,tableTasks{l},"key",...
    'SurgeryType','UroLift'));
    [h1,p1] = swtest(rmmissing(currentTask));
    [h,p] = kstest((rmmissing(currentTask)-mean(currentTask,'omitnan'))./std(currentTask,'omitnan'));
    generalUroLiftData.(tableTasks{l}) = {currentTask; mean(currentTask,'omitnan');...
        std(currentTask,'omitnan');[h,p];[h1,p1];(length(currentTask)-sum(isnan(currentTask)))};
end

%TURP
for l = 1:length(tableTasks)
    currentTask = cell2mat(twdb_lookup(procedureData,tableTasks{l},"key",...
    'SurgeryType','TURP'));
    [h,p] = kstest((rmmissing(currentTask)-mean(currentTask,'omitnan'))./std(currentTask,'omitnan'));
    [h1,p1] = swtest(rmmissing(currentTask));
    generalTURPData.(tableTasks{l}) = {currentTask; mean(currentTask,'omitnan');...
        std(currentTask,'omitnan');[h,p];[h1,p1,];length(currentTask)-sum(isnan(currentTask))};
end

%uroLift avg improvement
AUAimprovementScoresUroLift = [generalUroLiftData.ThirdAUAPostSurgery{1,1};...
    generalUroLiftData.SecondAUAPostSurgery{1,1};...
    generalUroLiftData.FirstAUAPostSurgery{1,1}];

avgAUAimprovementUroLift = zeros(1,length(AUAimprovementScoresUroLift));

counter = 1;
for i = 1:size(AUAimprovementScoresUroLift,2)
    for j = 1:3
        if ~isnan(AUAimprovementScoresUroLift(j,i))
            
            avgAUAimprovementUroLift(counter) = AUAimprovementScoresUroLift(j,i);
            counter = counter +1;
            break
        
        elseif j ==3
            avgAUAimprovementUroLift(counter) = NaN;
            counter = counter +1;
        end
    end
end
currentTask = avgAUAimprovementUroLift;
[h1,p1] = swtest(rmmissing(currentTask));
[h,p] = kstest((rmmissing(currentTask)-mean(currentTask,'omitnan'))./std(currentTask,'omitnan'));
generalUroLiftData.("AvgAUAimprovement") = {currentTask; mean(currentTask,'omitnan');...
        std(currentTask,'omitnan');[h,p];[h1,p1];(length(currentTask)-sum(isnan(currentTask)))};


%Turp Avg improvement
AUAimprovementScoresTURP = [generalTURPData.ThirdAUAPostSurgery{1,1};...
    generalTURPData.SecondAUAPostSurgery{1,1};...
    generalTURPData.FirstAUAPostSurgery{1,1}];

avgAUAimprovementTURP = zeros(1,length(AUAimprovementScoresTURP));

counter = 1;
for i = 1:size(AUAimprovementScoresTURP,2)
    for j = 1:3
        if ~isnan(AUAimprovementScoresTURP(j,i))
            
            avgAUAimprovementTURP(counter) = AUAimprovementScoresTURP(j,i);
            counter = counter +1;
            break
        
        elseif j ==3
            avgAUAimprovementTURP(counter) = NaN;
            counter = counter +1;
        end
    end
end
currentTask = avgAUAimprovementTURP;
[h1,p1] = swtest(rmmissing(currentTask));
[h,p] = kstest((rmmissing(currentTask)-mean(currentTask,'omitnan'))./std(currentTask,'omitnan'));
generalTURPData.("AvgAUAimprovement") = {currentTask; mean(currentTask,'omitnan');...
        std(currentTask,'omitnan');[h,p];[h1,p1];(length(currentTask)-sum(isnan(currentTask)))};

[~,p_PriorScore] = ttest2(generalTURPData.AUAPrior{1, 1},generalUroLiftData.AUAPrior{1, 1});
[~,p_PostScore] = ttest2(generalUroLiftData.AvgAUAimprovement{1, 1},...
    generalTURPData.AvgAUAimprovement{1, 1});

for k = 1:length(docInitials)

    priorScoreUroLift = getfield(uroLiftStructGraphData,docInitials{k},...
        'PriorScore');
    priorScoreTURP = getfield(TURPstructGraphData,docInitials{k},...
        'PriorScore');
    
    if isempty(priorScoreUroLift)
        continue
    elseif isempty(priorScoreTURP)
        continue
    else
        priorScoreUroLift = priorScoreUroLift{1,1};
        priorScoreTURP =priorScoreTURP{1,1};
        
        [~,prior_p] = ttest2(priorScoreTURP,priorScoreUroLift);
        uroLiftStructGraphData.(docInitials{k}).("prior_p") = prior_p;
        
    end
    
    AvgScoreUroLift = getfield(uroLiftStructGraphData,docInitials{k},...
        'AvgPostScore');
    AvgScoreTURP = getfield(TURPstructGraphData,docInitials{k},...
        'AvgPostScore');

    if isempty(AvgScoreUroLift)
        break
    elseif isempty(AvgScoreTURP)
        break
    else
        AvgScoreUroLift = AvgScoreUroLift{1,1};
        AvgScoreTURP = AvgScoreTURP{1,1};
        
        [~,post_p] = ttest2(AvgScoreUroLift,AvgScoreTURP);
        uroLiftStructGraphData.(docInitials{k}).("post_p") = post_p;
    end
    
end
        
        
%% Table making for doctor data

TableInformation = ["Number of procedures", "Pre-treatment AUA score",...
    "Post-treatment AUA score"];

Columns = {"UroLift","TURP","P"};

for idx = 1:length(docInitials)
    UroLift_priorData = getfield(uroLiftStructGraphData,docInitials{idx},'PriorScore');
    TURP_priorData = getfield(TURPstructGraphData,docInitials{idx},'PriorScore');
    
    if ~isempty(UroLift_priorData) && ~isempty(TURP_priorData)
        UroLift_procedures = length(UroLift_priorData{1,1});

        UroLift_prior_mean = UroLift_priorData{2,1};
        UroLift_prior_std = UroLift_priorData{3,1};
        UroLift_prior_n = UroLift_priorData{5,1};

        UroLift_postData = getfield(uroLiftStructGraphData,docInitials{idx},'AvgPostScore');
        UroLift_post_mean = UroLift_postData{2,1};
        UroLift_post_std = UroLift_postData{3,1};
        UroLift_post_n = UroLift_postData{5,1};

        TURP_procedures = length(TURP_priorData{1,1});

        TURP_prior_mean = TURP_priorData{2,1};
        TURP_prior_std = TURP_priorData{3,1};
        TURP_prior_n = TURP_priorData{5,1};

        TURP_postData = getfield(TURPstructGraphData,docInitials{idx},'AvgPostScore');
        TURP_post_mean = TURP_postData{2,1};
        TURP_post_std = TURP_postData{3,1};
        TURP_post_n = TURP_postData{5,1};

        prior_p = round(getfield(uroLiftStructGraphData,docInitials{idx},'prior_p'),4);
        post_p = round(getfield(uroLiftStructGraphData,docInitials{idx},'post_p'),4);

        intermediate_cell = {UroLift_procedures TURP_procedures []; ...
            sprintf("%.2f ± %.2f (n = %d)",UroLift_prior_mean,UroLift_prior_std,UroLift_prior_n) ...
            sprintf("%.2f ± %.2f (n = %d)",TURP_prior_mean,TURP_prior_std,TURP_prior_n) ...
            prior_p; sprintf("%.2f ± %.2f (n = %d)",UroLift_post_mean,UroLift_post_std,UroLift_post_n) ...
            sprintf("%.2f ± %.2f (n = %d)",TURP_post_mean,TURP_post_std,TURP_post_n) ...
            post_p};

        T = cell2table(intermediate_cell);
        T.Properties.VariableNames = ["UroLift","TURP","P"];
        T.Properties.RowNames = TableInformation;

        writetable(T,strcat("DataPerDoc/", docInitials{idx},"/",docInitials{idx},".csv"),...
            "WriteRowNames",true)
    end
    
    if isempty(UroLift_priorData) && ~isempty(TURP_priorData)
        TURP_procedures = length(TURP_priorData{1,1});

        TURP_prior_mean = TURP_priorData{2,1};
        TURP_prior_std = TURP_priorData{3,1};
        TURP_prior_n = TURP_priorData{5,1};

        TURP_postData = getfield(TURPstructGraphData,docInitials{idx},'AvgPostScore');
        TURP_post_mean = TURP_postData{2,1};
        TURP_post_std = TURP_postData{3,1};
        TURP_post_n = TURP_postData{5,1};
        
        intermediate_cell = {TURP_procedures; ...
            sprintf("%.2f ± %.2f (n = %d)",TURP_prior_mean,TURP_prior_std,TURP_prior_n);...
            sprintf("%.2f ± %.2f (n = %d)",TURP_post_mean,TURP_post_std,TURP_post_n)};

        T = cell2table(intermediate_cell);
        T.Properties.VariableNames = ["TURP"];
        T.Properties.RowNames = TableInformation;
        writetable(T,strcat("DataPerDoc/", docInitials{idx},"/",docInitials{idx},".csv"),...
            "WriteRowNames",true)
    end
    
    if ~isempty(UroLift_priorData) && isempty(TURP_priorData)
        UroLift_procedures = length(UroLift_priorData{1,1});

        UroLift_prior_mean = UroLift_priorData{2,1};
        UroLift_prior_std = UroLift_priorData{3,1};
        UroLift_prior_n = UroLift_priorData{5,1};

        UroLift_postData = getfield(uroLiftStructGraphData,docInitials{idx},'AvgPostScore');
        UroLift_post_mean = UroLift_postData{2,1};
        UroLift_post_std = UroLift_postData{3,1};
        UroLift_post_n = UroLift_postData{5,1};
        
        intermediate_cell = {UroLift_procedures; ...
            sprintf("%.2f ± %.2f (n = %d)",UroLift_prior_mean,UroLift_prior_std,UroLift_prior_n);...
            sprintf("%.2f ± %.2f (n = %d)",UroLift_post_mean,UroLift_post_std,UroLift_post_n)};

        T = cell2table(intermediate_cell);
        T.Properties.VariableNames = ["UroLift"];
        T.Properties.RowNames = TableInformation;
        writetable(T,strcat("DataPerDoc/", docInitials{idx},"/",docInitials{idx},".csv"),...
            "WriteRowNames",true)
    end
    
   

    
    
end

%% total procedure graph
figure(1)
for i = 1:length(docInitials)
    docInitial = docInitials{i};
    
    PriorScore = getfield(uroLiftStructGraphData,docInitial,...
        'PriorScore');
    if iscell(PriorScore)
        PriorScore = PriorScore{1,1};
    end
    FirstScore = getfield(uroLiftStructGraphData,docInitial,...
        'FirstScore');
    SecondScore = getfield(uroLiftStructGraphData,docInitial,...
        'SecondScore');
    ThirdScore = getfield(uroLiftStructGraphData,docInitial,...
        'ThirdScore');

    date1 = getfield(uroLiftStructGraphData,docInitial,...
        'PriorScoreDateDifference');
    date2 = getfield(uroLiftStructGraphData,docInitial,...
        'FirstScoreDateDifference');
    date3 = getfield(uroLiftStructGraphData,docInitial,...
        'SecondScoreDateDifference');
    date4 = getfield(uroLiftStructGraphData,docInitial,...
        'ThirdScoreDateDifference');
    
    pt_x_scores = zeros(1,4);

    for ii = 1:length(PriorScore)
        pt_x_scores(1:4) = [PriorScore(ii),FirstScore(ii),SecondScore(ii),ThirdScore(ii)];
        pt_x_dates(1:4) = [date1(ii),date2(ii),date3(ii),date4(ii)];
        
        plot(pt_x_dates,pt_x_scores.','-*k')
        hold on
    end
    title("2021 UroLift Patient Outcomes ")
    xlabel("Days after surgery")
    ylabel("AUA Score")
end
hold off

figure(2)
for i = 1:length(docInitials)
    docInitial = docInitials{i};
    
    PriorScore = getfield(TURPstructGraphData,docInitial,...
        'PriorScore');
    if iscell(PriorScore)
        PriorScore = PriorScore{1,1};
    end
    FirstScore = getfield(TURPstructGraphData,docInitial,...
        'FirstScore');
    SecondScore = getfield(TURPstructGraphData,docInitial,...
        'SecondScore');
    ThirdScore = getfield(TURPstructGraphData,docInitial,...
        'ThirdScore');
 
    
        
    date1 = getfield(TURPstructGraphData,docInitial,...
        'PriorScoreDateDifference');
    date2 = getfield(TURPstructGraphData,docInitial,...
        'FirstScoreDateDifference');
    date3 = getfield(TURPstructGraphData,docInitial,...
        'SecondScoreDateDifference');
    date4 = getfield(TURPstructGraphData,docInitial,...
        'ThirdScoreDateDifference');
    
    pt_x_scores = zeros(1,4);
    for ii = 1:length(PriorScore)
        pt_x_scores(1:4) = [PriorScore(ii),FirstScore(ii),SecondScore(ii),ThirdScore(ii)];
        pt_x_dates(1:4) = [date1(ii),date2(ii),date3(ii),date4(ii)];
        
        if date1(ii) < 0 || date2(ii)< 0 || date3(ii)< 0||date4(ii)< 0
            disp("wait")
        end
        
        plot(pt_x_dates,pt_x_scores.','-*k')
        hold on
    end
    title("2021 TURP Patient Outcomes ")
    xlabel("Days after surgery")
    ylabel("AUA Score")
end
hold off

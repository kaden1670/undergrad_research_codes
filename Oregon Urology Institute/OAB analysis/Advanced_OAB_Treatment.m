%% Kaden DiMarco
%6/14/2021

%Objective: Evaluate percentage of all OAB patients that progress to 3rd
%degree treatment. Two groups of doctors are evaluated, those who recommend
%pts to use electronic treatmentGPS OAB pathway and those who have highest
%number of 3rd degree procedures

time = [0:10];
time = time.';

linModelfun= @(k,t)(k(1)*t +k(2));
linGuess = [0.1, 0.5];

expModelfun = @(k,t)(k(1)*(1+k(2)).^t);

linCoef1 = nlinfit(vertcat(time(1:7),time(1:7),time(1:7)),vertcat(GF_pct(1:7),BW_pct(1:7),RM_pct(1:7)),...
    linModelfun,linGuess);
linCoef2 = nlinfit(vertcat(time(7:11),time(7:11),time(7:11)),vertcat(GF_pct(7:11),BW_pct(7:11),RM_pct(7:11)),...
    linModelfun,linGuess);

linLine1 = linCoef1(1)*time(1:7) +linCoef1(2);
linLine2 = linCoef2(1)*time(7:11) +linCoef2(2);

linCoefGPS1 = nlinfit(vertcat(time(1:7),time(1:7),time(1:7)),vertcat(JL_pct(1:7),DSD_pct(1:7),CSD_pct(1:7)),...
    linModelfun,linGuess);
linCoefGPS2 = nlinfit(vertcat(time(7:11),time(7:11),time(7:11)),vertcat(JL_pct(7:11),DSD_pct(7:11),CSD_pct(7:11)),...
    linModelfun,linGuess);

expCoefGPS = nlinfit(vertcat(time,time,time),vertcat(JL_pct,DSD_pct,CSD_pct),...
    expModelfun,linGuess);
expLineGPS = expCoefGPS(1)*(1+expCoefGPS(2)).^time;

GPSline1 = linCoefGPS1(1)*time(1:7) +linCoefGPS1(2);
GPSline2 = linCoefGPS2(1)*time(7:11) +linCoefGPS2(2);


close all
figure()
plot(time, CSD_pct, '*',"MarkerSize", 9,"LineWidth", 1.2, 'Color',[0.4660 0.6740 0.1880])
hold on
plot(time, DB_pct, '*k',"MarkerSize", 9,"LineWidth", 1.2)
hold on
plot(time,total_pct, '-',"LineWidth", 2,"Color", [0.6350 0.0780 0.1840])
hold on
%plot(time,BW_pct, '*b',"MarkerSize", 12,"LineWidth", 1)
%hold on
%xline(7, ':', "Electronic OAB pathway pilot", "FontSize", 12)
xline(6, ':')
hold on
plot(time, linLine, "-.k")
%plot(time(1:7), linLine1, "-.k")
%hold on
%plot(time(7:11), linLine2, "-.k")

hold on
plot(time, expLineGPS,'-.',"Color", [0.4660 0.6740 0.1880])
%plot(time(1:7), GPSline1, '-.',"Color", [0.4660 0.6740 0.1880])
%hold on
%plot(time(7:11), GPSline2, '-.',"Color", [0.4660 0.6740 0.1880])
hold on
plot(time, DSD_pct, '*',"MarkerSize", 9,"LineWidth", 1.2,"Color", [0.4660 0.6740 0.1880])
hold on
plot(time(2:11), GF_pct(2:11), '*k',"MarkerSize", 9,"LineWidth", 1.2)
hold on
plot(time(9:11), JL_pct(9:11), '*',"MarkerSize", 9,"LineWidth", 1.2, "Color", [0.4660 0.6740 0.1880])
hold on
plot(time, RM_pct, '*k',"MarkerSize", 9,"LineWidth", 1.2)

xticklabels({"2010",'','2012','','2014','','2016','','2018','', "2020"})
xtickangle(45)

ylabel("Percent advanced OAB treatment", "FontSize", 12) 

legend({"Three doctors most active on electronic pathway",...
    "Three doctors with the highest 10-year advanced treatment rates", "OUI average"})
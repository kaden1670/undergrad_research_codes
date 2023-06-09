function plot_example_traces_and_licks(twdb,mouseID,bin_size,bin_traces,trace_strings,arrow_coords, yLim_lo, yLim_hi)

    %Matrix Example: plot_example_traces_and_licks(twdb,'3758',100,[15 16 6 21 34],{'Very High Licking','Very High Licking','Low Licking, No Discrimination','High Licking, No Discrimination','High Licking, Discrimination'},{[0.24 0.44 0.7 0.61],[0.51 0.47 0.7 0.63],[0.255 0.24 0.405 0.36],[0.57 0.52 0.405 0.36],[0.84 0.8 0.405 0.36]})
    [bin_fluorRewardTrials,bin_fluorCostTrials,bin_lickRewardTrials,bin_lickCostTrials]...
        = get_fluorescence_mouse_sta(twdb, mouseID, bin_size,'all',0,1);
    
    figure
    if length(bin_traces) == 4
        plot_nums = [5 6 7 8];
    elseif length(bin_traces) == 5
        plot_nums = [6 7 8 9 10];
    elseif length(bin_traces) == 3
        plot_nums = [4 5 6];
    elseif length(bin_traces) == 2
        plot_nums = [3 4];
    end
    
    for n = 1:length(bin_traces)
        fluor_rewardTrials = bin_fluorRewardTrials{bin_traces(n)};
        fluor_costTrials = bin_fluorCostTrials{bin_traces(n)};
        
        subplot(2,length(bin_traces),plot_nums(n))
        xReward = (1:size(fluor_rewardTrials,2));
        [mReward, lowCLReward, highCLReward] = get_dist_stats(fluor_rewardTrials);
        dg_plotShadeCL(gca, [xReward' lowCLReward' highCLReward' mReward'], 'Color', [0 0 1]);
        hold on;
        xCost = (1:size(fluor_costTrials,2));
        [mCost, lowCLCost, highCLCost] = get_dist_stats(fluor_costTrials);
        dg_plotShadeCL(gca, [xCost' lowCLCost' highCLCost' mCost'], 'Color', [1 0 0]);
        ylim([yLim_lo yLim_hi]);
        hold on;

        yLim = ylim;
        textY = yLim(1) + abs(yLim(1) / 10);
        hold on;
        plot([22.72 22.72], ylim, 'k', 'LineWidth',3);
        hold on;
        text(27.72, textY, 'T');
        hold on;
        plot([38.87 38.87], ylim, 'k', 'LineWidth',3);
        hold on;
        text(40.72, textY, 'R');
        hold on;
        plot([46.44 46.44], ylim, 'k', 'LineWidth',3);
        hold on;
        text(51.72, textY, 'O & ITI');
        
        x = arrow_coords{n}(1:2);
        y = arrow_coords{n}(3:4);
        arh=annotation('arrow', x,y );
        arh.LineWidth = 5;
        arh.Color = [0,0,0];
        
        title({trace_strings{n},['Bin #', num2str(bin_traces(n))]})
        hold off
    end

    mean_rewardTone_licks_bin = cellfun(@mean,bin_lickRewardTrials);
    mean_costTone_licks_bin = cellfun(@mean,bin_lickCostTrials);
%     numBins = 11;
    numBins = length(mean_rewardTone_licks_bin);
    
    subplot(2,length(bin_traces),1:length(bin_traces))
    hold on
%     plot([learning_bins learning_bins],[0 max([mean_costTone_licks_bin mean_rewardTone_licks_bin])],'k','LineWidth',3)
    bar([mean_rewardTone_licks_bin',mean_costTone_licks_bin'])
    xlabel(['Bins of ' num2str(bin_size) ' trials over Time'])
    ylabel(['Mean Response Lick Frequency'])
    xlim([0 numBins+0.5])
    ylim([0 max([mean_costTone_licks_bin(1:numBins) mean_rewardTone_licks_bin(1:numBins)])])
    legend('Reward Tone','Cost Tone')
    hold off
    
    session_idx = get_mouse_sessions(twdb,mouseID,1,0,1,0);
    
    intended_strio_str = twdb(session_idx).intendedStriosomality;
    histology_strio_str = num2str(twdb(session_idx).histologyStriosomality);
    health_str = twdb(session_idx).Health;
    firstSessionAge = twdb(session_idx).firstSessionAge;
    if firstSessionAge <= 12
        age_str = 'Young';
    else
        age_str = 'Old';
    end
    supertitle({[health_str ':' mouseID ' / Age: ' age_str], ['Intended Striosomality: ',intended_strio_str,' / Histology: ',histology_strio_str],'','',''})
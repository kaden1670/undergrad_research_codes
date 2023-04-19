function plotbars(dat, xnames1,xnames2, yname, colors, varargin)
jitterIdx = find(strcmp('jitter', varargin));
n = length(dat);
hold on;
for i = 1:n
    datum = dat{i};
    datum = datum(datum ~= Inf);
    
    if ~isempty(jitterIdx)
        a = varargin{jitterIdx + 1};
        b = -a;
        datum = datum + a + (b-a).*rand(length(datum),1);
        xs = -0.25 + (0.5).*rand(length(datum),1);
    else
        xs = zeros(length(datum),1);
    end
        
    hB = bar(i, nanmean(datum), 'FaceColor',  colors(i,:));
    if ~contains(varargin, 'nodots')
       % x = xs' + ones(1,length(datum))*i;
    %    y = datum;
        scatter(xs' + ones(1,length(datum))*i,datum, '*', 'MarkerEdgeColor','#7F7F7F',...
             'MarkerFaceColor','#7F7F7F');
    end
    if ~contains(varargin, 'notips')
        hT = [];
        for ii=1:length(hB)  % iterate over number of bar objects
            
            hT=[hT text(hB(ii).XData+hB(ii).XOffset-.24,hB(ii).YData,num2str(hB(ii).YData.','%.2f'), ...
                          'VerticalAlignment','bottom','horizontalalign','center')];
        end
    end
    
end

%ploterr(1:n, cellfun(@nanmean, dat), [], cellfun(@std_error, dat) , 'k.', 'abshhxy', 0);
if ~contains(varargin,'noXnames2')
    
    labelArray = [xnames1; xnames2];
    xtickLabels = strtrim(sprintf('%s\\newline%s\n', labelArray{:}));
else
    xtickLabels = xnames1;
end

set(gca, 'xtick', 1:n, 'xticklabel', xtickLabels);
ylabel(yname)




end

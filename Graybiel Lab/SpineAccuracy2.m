Animals = ManualSpineData.Animal;
ManualData = ManualSpineData.Density;

CompData = {};
for i = 1:length(Animals)
    for j = 1:height(SpineData)
        if strcmp([cell2mat(SpineData.ID(j)), cell2mat(SpineData.slice(j)), cell2mat(SpineData.Experiment(j))], [num2str(Animals(i)), cell2mat(ManualSpineData.slice(i)), cell2mat(ManualSpineData.Experiment(i))]) 
            CompData{end+1} = SpineData.VarName7(i)/SpineData.VarName6(i);
        end
    end
end

% CompData = unique(cell2mat(CompData));
% ManualData = unique(cell2mat(ManualData));


plotregression(ManualData, CompData, 'regression')


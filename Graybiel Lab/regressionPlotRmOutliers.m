
[ytest, removed] = rmoutliers(cell2mat(CompPvMsnDataNotLearned));
removed = removed - 1;
xtest = [];
xtest = cell2mat(dPrimeLstNotLearned) .* removed;
xtest = xtest .* -1;
rmIdx = [];
for i = 1:length(xtest)
    if xtest(i) == 0
        rmIdx = [rmIdx, i];
    end
end
xtest(rmIdx) = [];


fitpoly2 = fit(xtest.', ytest.', 'poly1')
        
plot(fitpoly2, xtest.', ytest.')

regression(xtest, ytest)



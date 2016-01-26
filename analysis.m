data_1 = [];
data_2 = [];
data_3 = [];
data_4 = [];

for i = 1:numTrials
    if respMat(3, i) == 1
       data_1 = [data_1, respMat(:, i)];
    end
    if respMat(3, i) == 2
       data_2 = [data_2, respMat(:, i)];
    end
    if respMat(3, i) == 3
       data_3 = [data_3, respMat(:, i)];
    end
    if respMat(3, i) == 4
       data_4 = [data_4, respMat(:, i)];
    end
end

subplot(3, 2, 1)
scatter(data_1(1, :), data_1(2, :))
title('1 beep 1 flash')
subplot(3, 2, 2)
scatter(data_2(1, :), data_2(2, :))
title('2 beep 1 flash')
subplot(3, 2, 3)
scatter(data_3(1, :), data_3(2, :))
title('1 beep 2 flash')
subplot(3, 2, 4)
scatter(data_4(1, :), data_4(2, :))
title('2 beep 2 flash')

edges = [.00, .01, .02, .03, .04, .05, .06, .07, .08, .09, .1, .11, .12, .13, .14, .15, .16, .17, .18, .19, .2];

bins = discretize(data_2(2, :), edges);

for i = 1:length(edges)
    data.correct(i) = 0;
    data.incorrect(i) = 0;
end

for i = 1:length(bins)
    if data_2(1, i) == 1
        data.correct(bins(i)) = data.correct(bins(i)) + data_2(3, i);
    end
    if data_2(1, i) == 2
        data.incorrect(bins(i)) = data.incorrect(bins(i)) + data_2(3, i);
    end
end

psychCurve2 = nan([2, length(edges)]);
psychCurve2(1, :) = edges;

for i = 1:length(edges)
    psychCurve2(2, i) = data.correct(i) / (data.correct(i) + data.incorrect(i));
end

subplot(3, 2, 5)
scatter(psychCurve2(1, :), psychCurve2(2, :));
title('% correct vs. ISI, FISION (1 flash correct)')

bins = discretize(data_3(2, :), edges);

for i = 1:length(edges)
    data3.correct(i) = 0;
    data3.incorrect(i) = 0;
end

for i = 1:length(bins)
    if data_3(1, i) == 2
        data3.correct(bins(i)) = data3.correct(bins(i)) + data_3(3, i);
    end
    if data_3(1, i) == 1
        data3.incorrect(bins(i)) = data3.incorrect(bins(i)) + data_3(3, i);
    end
end

psychCurve3 = nan([2, length(edges)]);
psychCurve3(1, :) = edges;

for i = 1:length(edges)
    psychCurve3(2, i) = data3.correct(i) / (data3.correct(i) + data3.incorrect(i));
end

subplot(3, 2, 6)
scatter(psychCurve3(1, :), psychCurve3(2, :));
title('% correct vs. ISI FUSION (2 flash correct)')





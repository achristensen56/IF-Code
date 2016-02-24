mv_av = [];
%figure(1)
%hold on;
for i = 11:trial - 10
    mv_av(i) = sum(mrespMat(i-5:i+5, 1) == mrespMat(i-5:i+5, 2)) / 10 ; 
 %   plot(i, mv_av(i), 'r-') 
 %   pause(.5)
end

figure(1)
plot(mv_av)

%check go - nogo

num1 = sum((mrespMat(:, 1) == 2) & (mrespMat(:, 2) == 2));
num2 = sum((mrespMat(:, 1) == 1) & (mrespMat(:, 2) == 0));
num3 = sum((mrespMat(:, 1) == 1) & (mrespMat(:, 2) == 1));

(num1+num2+num3)/trial
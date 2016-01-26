mv_av = []

for i = 11:trial - 10
    mv_av(i) = sum(mrespMat(i-5:i+5, 1) == mrespMat(i-5:i+5, 2)) / 10
        
end

figure(1)
plot(mv_av)
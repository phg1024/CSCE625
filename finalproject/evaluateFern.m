function output = evaluateFern(val, fern)
F = length(fern.thresholds);
binidx = 1;
for i=1:F
    if val(i) >= fern.thresholds(i)
        binidx = binidx + 2^(i-1);
    end
end
output = fern.outputs(binidx,:);
end
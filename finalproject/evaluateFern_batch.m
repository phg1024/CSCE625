function output = evaluateFern_batch(diffvecs, fern)
F = length(fern.thresholds);
[nsamples, ~] = size(diffvecs);
for i=1:F
    di = diffvecs(:,i);
    lset = find(di < fern.thresholds(i));
    rset = setdiff(1:nsamples, lset);
    diffvecs(lset, i) = 0;
    diffvecs(rset, i) = 1;
end

wvec = 2.^[0:F-1]';

idxvec = diffvecs * wvec + 1;    

output = fern.outputs(idxvec,:);
end
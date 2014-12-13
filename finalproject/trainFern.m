function fern = trainFern(features, Y, Mrho, beta)
F = numel(features);
% compute thresholds for ferns
thresholds = rand(F, 1);
for f=1:F
    fdiff = features{f}.rho_m - features{f}.rho_n;
    maxval = max(fdiff); minval = min(fdiff);
    meanval = mean(fdiff);
    range = min(maxval-meanval, meanval-minval);
    thresholds(f) = (thresholds(f)-0.5)*0.2*range + meanval;
end

% partition the samples into 2^F bins
bins = partitionSamples(Mrho, features, thresholds);

% compute the outputs of each bin
outputs = computeBinOutputs(bins, Y, beta);

fern.thresholds = thresholds;
fern.outputs = outputs;
end

function bins = partitionSamples(Mrho, features, thresholds)
F = numel(features);
bins = cell(2^F, 1);
[nsamples, ~] = size(Mrho);
diffvecs = zeros(nsamples, F);
for i=1:F
    diffvecs(:,i) = Mrho(:, features{i}.m) - Mrho(:, features{i}.n);
end

for i=1:F
    di = diffvecs(:,i);
    lset = find(di < thresholds(i));
    rset = setdiff(1:nsamples, lset);
    diffvecs(lset, i) = 0;
    diffvecs(rset, i) = 1;
end

wvec = 2.^[0:F-1]';

idxvec = diffvecs * wvec + 1;

for i=1:2^F
    bins{i} = find(idxvec==i);
end
end

function outputs = computeBinOutputs(bins, Y, beta)
[~, Lfp] = size(Y);
nbins = numel(bins);
outputs = zeros(nbins, Lfp);
for i=1:nbins
    if isempty(bins{i})
        continue;
    end
    
    outputs(i,:) = sum(Y(bins{i}, :));
    ni = length(bins{i});
    factor = 1.0 / ((1 + beta/ni)*ni);
    outputs(i,:) = outputs(i,:) * factor;
end
end
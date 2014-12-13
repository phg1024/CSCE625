function trainset = updateGuessShapes(trainset, Mnorm, regressor)
nsamples = numel(trainset);
Lfp = length(trainset{1}.truth);Nfp = Lfp/2;
maxError = 0;
F = length(regressor.ferns{1}.thresholds);
K = numel(regressor.ferns);
rho_diff = zeros(nsamples, F);
Mds = zeros(nsamples, Lfp);
for k=1:K
    for f=1:F
        rho_diff(:,f) = regressor.features{k}{f}.rho_m - regressor.features{k}{f}.rho_n;
    end
    
    Mds = Mds + evaluateFern_batch(rho_diff, regressor.ferns{k});    
end

for i=1:nsamples
    ds = Mds(i,:);
    ds = reshape(ds, Nfp, 2)';
    ds = Mnorm{i}.invM * ds;
    ds = reshape(ds', 1, Lfp);
    trainset{i}.guess = trainset{i}.guess + ds;
    maxError = max(maxError, norm(trainset{i}.truth - trainset{i}.guess));
end

maxError
end
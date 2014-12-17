function regressor = learnStageRegressor(trainset, Y, Mnorm, opts)
Lfp = length(trainset{1}.truth); Nfp = Lfp/2;
P = opts.params.P; T = opts.params.T; F = opts.params.F; K = opts.params.K;
beta = opts.params.beta; kappa = opts.params.kappa;

% generate local coordinates
disp('generate local coordinates...');
localCoords = zeros(P, 3);  % fpidx, x, y
for i=1:P
    localCoords(i, 1) = randperm(Nfp, 1);
    localCoords(i, 2:3) = (rand(1, 2) - 0.5) * kappa;
end

% extract shape indexed pixels
disp('extract shape indexed pixels...');
tic;
nsamples = numel(trainset);
Mrho = zeros(nsamples, P);
for i=1:nsamples
    Minv = Mnorm{i}.invM;
   
    dp = Minv * localCoords(:,2:3)';
    dp = dp';
    
    fpPos = reshape(trainset{i}.guess, Nfp, 2);
    pixPos = fpPos(ind2sub([Nfp 2],localCoords(:,1)), :) + dp;
    [rows, cols] = size(trainset{i}.image);
    pixPos = round(pixPos);
    pixPos(:,1) = min(max(pixPos(:,1), 1), cols);
    pixPos(:,2) = min(max(pixPos(:,2), 1), rows);
    Mrho(i,:) = trainset{i}.image(sub2ind(size(trainset{i}.image), pixPos(:,2)', pixPos(:,1)'));
end
% compute pixel-pixel covariance
covRho = cov(Mrho);

Mrho_centered = Mrho - repmat(mean(Mrho), size(Mrho, 1), 1);

diagCovRho = diag(covRho);
varRhoDRho = -2.0 * covRho + repmat(diagCovRho, 1, P) + repmat(diagCovRho', P, 1);
inv_varRhoDRho = 1.0 ./ varRhoDRho;
toc;

% compute all ferns
disp('construct ferns...');
ferns = cell(K,1);
features = cell(K, 1);
for k=1:K
    features{k} = correlationBasedFeatureSelection(Y, Mrho, Mrho_centered, inv_varRhoDRho, F);
    ferns{k} = trainFern(features{k}, Y, Mrho, beta);
    
    % update the normalized target
    Mdiff_rho = zeros(nsamples, F);
    for f=1:F
        Mdiff_rho(:,f) = features{k}{f}.rho_m - features{k}{f}.rho_n;
    end
    updateMat = evaluateFern_batch(Mdiff_rho, ferns{k});
    fprintf('fern(%d)\tmax(Y) = %.6g, min(Y) = %.6g\n', k, max(max(Y)), min(min(Y)));
    Y = Y - updateMat;
end

regressor.localCoords = localCoords;
regressor.ferns = ferns;
regressor.features = features;
end
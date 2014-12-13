function [Y, Mnorm] = normalizedShapeTargets(trainset, meanShape)
nsamples = numel(trainset);
Lfp = length(meanShape); Nfp = Lfp/2;
Mnorm = cell(nsamples, 1);
Y = zeros(nsamples, Lfp);
for i=1:nsamples
    [s, R, ~] = estimateTransform(reshape(trainset{i}.guess, Nfp, 2), ...
        reshape(meanShape, Nfp, 2));
    Mnorm{i}.M = s*R;
    Mnorm{i}.invM = inv(Mnorm{i}.M);
    diff = trainset{i}.truth - trainset{i}.guess;
    tdiff = Mnorm{i}.M * reshape(diff, Nfp, 2)';
    Y(i,:) = reshape(tdiff', 1, Lfp);
end
end
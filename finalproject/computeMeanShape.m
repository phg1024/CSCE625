function meanshape = computeMeanShape(dataset)
refshape = dataset{1}.guess;
npts = length(refshape)/2;
% align all other shapes to this shape
nshapes = numel(dataset);
alignedShapes = zeros(nshapes, npts*2);
for i=1:nshapes
    alignedShapes(i, :) = dataset{i}.guess;
end
refshape = alignedShapes(1,:);

iters = 0; diff = realmax; maxIters = 4;
while diff > 1e-2 && iters < maxIters
    iters = iters + 1;
    for i=1:nshapes
        alignedShapes(i,:) = alignShape(alignedShapes(i,:), refshape);
    end
    
    refshape_new = mean(alignedShapes);
    diff = norm(refshape - refshape_new, inf);
    refshape = refshape_new;
end

fprintf('finished in %d iterations.\n', iters);
meanshape = refshape;
end
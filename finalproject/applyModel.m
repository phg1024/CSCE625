function [box, points] = applyModel(img, model)

%% Load a face detector and an image
cascade_filepath = 'C:\Users\Peihong\Desktop\Code\Libraries\opencv\sources\data\haarcascades';
detector = cv.CascadeClassifier([cascade_filepath, '\', 'haarcascade_frontalface_alt.xml']);

% Preprocess
[h, w, channels] = size(img);
if channels > 1
    img = rgb2gray(img);
end
gr = cv.equalizeHist(img);

% Detect bounding box
boxes = detector.detect(gr, 'ScaleFactor',  1.3, ...
    'MinNeighbors', 2, ...
    'MinSize',      [30, 30]);

if isempty(boxes)
    return;
end

% Scale it properly
boxSize = boxes{1}(3);
sfactor = 160.0 / boxSize;

img = imresize(img, sfactor);
boxes{1} = boxes{1} * sfactor;

ntrials = 5;
Lfp = 136; Nfp = Lfp/2;
results = zeros(ntrials, Lfp);
T = numel(model.stages); F = numel(model.stages{1}.ferns{1}.thresholds);
K = numel(model.stages{1}.ferns);
meanshape = model.meanshape;
for i=1:ntrials
    % get an initial guess
    idx = randperm(numel(model.init_shapes), 1);
    guess = cell2mat(model.init_shapes(idx));
    
    % align the guess to the bounding box
    guess = alignShapeToBox(guess, boxes{1});
    
    % find the points using the model
    for t=1:T
        [s, R, ~] = estimateTransform(reshape(guess, Nfp, 2), reshape(meanshape, Nfp, 2));
        M = s*R;
        lc = model.stages{t}.localCoords;
        [P,~] = size(lc);
        dp = M \ lc(:,2:3)';
        dp = dp';
        fpPos = reshape(guess, Nfp, 2);
        pixPos = fpPos(ind2sub([Nfp 2],lc(:,1)), :) + dp;
        [rows, cols] = size(img);
        pixPos = round(pixPos);
        pixPos(:,1) = min(max(pixPos(:,1), 1), cols);
        pixPos(:,2) = min(max(pixPos(:,2), 1), rows);
        pix = img(sub2ind(size(img), pixPos(:,2)', pixPos(:,1)'));
        
        ds = 0;
        for k=1:K
            rho = zeros(F, 1);
            for f=1:F
                m = model.stages{t}.features{k}{f}.m;
                n = model.stages{t}.features{k}{f}.n;
                rho(f) = pix(m) - pix(n);
            end
            ds = ds + evaluateFern(rho, model.stages{t}.ferns{k});
        end
        
        ds = reshape(ds, Nfp, 2)';
        ds = M\ds;
        ds = reshape(ds', 1, Lfp);
        guess = guess + ds;
    end
    results(i,:) = guess;
end

box = boxes(1);
points = median(results);
points = reshape(points, Nfp, 2) / sfactor;
end
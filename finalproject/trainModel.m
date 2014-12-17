function model = trainModel(opts)

%% Load a face detector and an image
cascade_filepath = 'C:\Users\Peihong\Desktop\Code\Libraries\opencv\sources\data\haarcascades';
detector = cv.CascadeClassifier([cascade_filepath, '\', 'haarcascade_frontalface_alt.xml']);

%% Load all valid input images
if isfield(opts, 'inputfiles')
    ninputs = size(opts.inputfiles, 1);
else
    ninputs = opts.nimgs;
end

trainset_size = 0;
init_trainset = cell(ninputs, 1);
init_shapes = cell(ninputs, 1);
init_boxes = cell(ninputs, 1);
tic;
for t=1:ninputs
    if mod(t, 100) == 0
        fprintf('processed %d images ...\n', t);
    end
    
    if isfield(opts, 'inputfiles')
        imgfile = opts.inputfiles{t, 1};
        ptsfile = opts.inputfiles{t, 2};
    else
        imgfile = [opts.path, opts.prefix, num2index(t, opts.digits), opts.imgext];
        ptsfile = [opts.path, opts.prefix, num2index(t, opts.digits), opts.ptsext];
    end
    
    if ~exist(imgfile, 'file') || ~exist(ptsfile, 'file')
        continue;
    end
    
    boxfile = regexprep(imgfile, '\.\w+$', '.box');
    
    try
        im = imread(imgfile);
        [h, w, channels] = size(im);
        if channels > 1
            im = rgb2gray(im);
        end
        I0 = im;
        gr = cv.equalizeHist(im);
        
        % Detect face
        if exist(boxfile, 'file')
            boxes = loadBoxes(boxfile);
        else
            boxes = detector.detect(gr, 'ScaleFactor',  1.3, ...
                'MinNeighbors', 2, ...
                'MinSize',      [30, 30]);   
            boxes = reshape(boxes, numel(boxes), 1);
            boxes = cell2mat(boxes);
            saveBoxes(boxes, boxfile);
        end

        % Load the annotations and find the correct box
        points = loadPoints(ptsfile, opts.npts);
        
        % Find the valid box
        box = findValidBox(boxes, points);
        
        % Scale the image for faster process        
        scalingFactor = 1.0;
        maxAllowedSize = 3200;
        if max(h, w) > maxAllowedSize
            scalingFactor = maxAllowedSize / max(h, w);
            I0 = imresize(I0, scalingFactor);
        end
        
        points = points * scalingFactor;
        box = box * scalingFactor;
        
        if length(box) == 4
            % Draw results
            if 0
                clf; showImageWithPoints(gr, box, points); pause;
            end
            
            % Scale it again, make the box
            boxSize = box(3);
            sfactor = opts.params.window_size / boxSize;
            if sfactor == 0.0
                sfactor = 1.0;
            end
            
            I0 = imresize(I0, sfactor);
            points = points * sfactor;
            box = (box) * sfactor;
            
            trainset_size = trainset_size + 1;
            npts = size(points, 1);
            init_trainset{trainset_size} = struct('image', I0, 'box', box, 'truth', reshape(points, 1, npts*2));
            init_shapes{trainset_size} = reshape(points, 1, npts*2);
            init_boxes{trainset_size} = box;
        else
            % not a valid training image
        end
    catch err
        disp(imgfile);
        disp(ptsfile);
        rethrow(err);
    end
end
toc;

init_trainset = init_trainset(~cellfun('isempty',init_trainset));
init_shapes = init_shapes(~cellfun('isempty',init_shapes));
fprintf('%d valid training images found.\n', trainset_size);

% Train the model
model = struct();

%% Augment the training set first
oversamples = opts.params.G;
trainset = cell(trainset_size*oversamples, 1);

idx = 0;
for t=1:trainset_size
    % randomly choose some shapes as initial shapes
    indices = randperm(trainset_size, oversamples);
    for j=1:oversamples
        idx = idx + 1;
        trainset{idx} = init_trainset{t};
        trainset{idx}.guess = init_trainset{indices(j)}.truth;
        
        % align the guess shape with the box
        trainset{idx}.guess = alignShapeToBox(trainset{idx}.guess, init_trainset{indices(j)}.box, trainset{idx}.box);
        
        if 0
            clf;showTrainingSample(trainset{idx});pause;
        end
    end
end
fprintf('training data augmentation finished. %d training samples in total.\n', numel(trainset));

%% estimate mean shape
disp('computing mean shape ...');
meanshape = computeMeanShape(trainset);

N = trainset_size;
P = opts.params.P; T = opts.params.T; F = opts.params.F; K = opts.params.K;
Lfp = length(meanshape); Nfp = Lfp/2;

% T stages
stages = cell(T, 1);
for t=1:T
    disp(['stage ', num2str(t)]);
    % compute normalized shape targets
    tic;
    [Y, Mnorm] = normalizedShapeTargets(trainset, meanshape);
    toc;
    % learn stage regressor
    tic;
    opts.params.kappa = opts.params.max_kappa + (opts.params.min_kappa-opts.params.max_kappa)*(t/T);
    stages{t} = learnStageRegressor(trainset, Y, Mnorm, opts);
    toc;
    % update guess shapes
    tic;
    trainset = updateGuessShapes(trainset, Mnorm, stages{t});
    toc;
    
    % clean up the stage structure
    for k=1:numel(stages{t}.features)
        for f=1:numel(stages{t}.features{k})
            stages{t}.features{k}{f}.rho_m = {};
            stages{t}.features{k}{f}.rho_n = {};
        end
    end
end

model.meanshape = meanshape;
model.init_shapes = init_shapes;
model.init_boxes = init_boxes;
model.stages = stages;
model.window_size = opts.params.window_size;
end

function idxstr = num2index(v, digits)
idxstr = num2str(v);
while length(idxstr)<digits
    idxstr = ['0', idxstr];
end
end

function points = loadPoints(filename, npts)
fid = fopen(filename, 'r');
textscan(fid, '%s', 3, 'Delimiter', '\n');
points = textscan(fid, '%f %f', npts, 'Delimiter', '\n');
points = cell2mat(points);
fclose(fid);
end

function boxes = loadBoxes(filename)
fid = fopen(filename, 'r');
nboxes = fscanf(fid, '%d', 1);
boxes = zeros(nboxes, 4);
for i=1:nboxes
boxes(i,:) = fscanf(fid, '%d', [1, 4]);
end
fclose(fid);
end

function saveBoxes(boxes, filename)
[nboxes, ~] = size(boxes);
fid = fopen(filename, 'w');
fprintf(fid, '%d\n', nboxes);
for i=1:nboxes
    fprintf(fid, '%d %d %d %d\n', boxes(i,1), boxes(i,2), boxes(i,3), boxes(i,4));
end
fclose(fid);
end
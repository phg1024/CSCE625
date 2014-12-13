%% driver routine for explicit shape regression
clear all; close all;

if 0
    tropts.path = 'C:\Users\Peihong\Desktop\Data\Detection\lfpw\trainset\';
    tropts.prefix = 'image_';
    tropts.imgext = '.png';
    tropts.ptsext = '.pts';
    tropts.digits = 4;
    tropts.npts = 68;
    tropts.nimgs = 871;
else
    trainset_path = 'C:\Users\Peihong\Desktop\Data\Detection\complete\trainingset\';
    listings = dir(trainset_path);
    inputfiles = cell((numel(listings)-2)/2, 2);
    ninputs = 0;
    for i=1:numel(listings)
        if listings(i).isdir
            continue;
        end
        if strfind(listings(i).name, '.pts')
            continue;
        end
        ninputs = ninputs + 1;
        inputfiles{ninputs, 1} = [trainset_path, listings(i).name];
        inputfiles{ninputs, 2} = regexprep(inputfiles{ninputs, 1}, '\.\w+$', '.pts');
    end   
    tropts.inputfiles = inputfiles;
    tropts.nimgs = size(inputfiles, 1);
    tropts.npts = 68;
end

tropts.params.F = 5;    % features in each fern
tropts.params.K = 500;  % number of ferns per stage
tropts.params.P = 400;  % number of samples per image
tropts.params.T = 10;   % number of stages
tropts.params.G = 20;    % oversample rate
tropts.params.beta = 1000.0; % 
tropts.params.kappa = 12.5; % 

% train model
tic;
model = trainModel(tropts);
toc;

model_to_save = cleanupModel(model);
filename = sprintf('model_%d_kappa_%d.mat', tropts.nimgs, tropts.params.kappa);
save(filename, '-mat', '-v7.3', '-struct', 'model_to_save');

% apply model to test data
[filename, pathname] = uigetfile({'*.jpg; *.png; *.gif; *.bmp'; '*.*'}, 'Choose Image');
img = imread([pathname, filename]);
[box, points] = applyModel(img, model);
showImageWithPoints(img, box, points);
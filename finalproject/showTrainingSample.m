function showTrainingSample(sample)
img = sample.image; box = sample.box; 
pts = sample.truth; guess = sample.guess;
imshow(img);
rectangle('Position',  box, 'EdgeColor', 'r');
hold on;
plot(pts(:,1), pts(:,2), 'og');
plot(guess(:,1), guess(:,2), 'xr');
end
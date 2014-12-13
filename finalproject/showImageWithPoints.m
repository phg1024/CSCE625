function showImageWithPoints(img, box, pts)
imshow(img);
%rectangle('Position', box, 'EdgeColor', 'r');
hold on;
plot(pts(:,1), pts(:,2), 'og', 'MarkerSize', 4);
if 0
    for i=1:size(pts,1)
        text(pts(i,1), pts(i,2), num2str(i));
    end
end
end
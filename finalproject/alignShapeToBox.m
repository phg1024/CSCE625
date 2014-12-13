function shape = alignShapeToBox(shape, box)
center = [box(1) + 0.5 * box(3), box(2) + 0.5*box(4)];
npts = length(shape)/2;
shape = reshape(shape, npts, 2);
extent = max(shape) - min(shape);
scale = max(extent) / box(3);
shape = shape - repmat(shape(29,:), npts, 1);
shape = shape ./ scale;
shape = shape + repmat(center, npts, 1);
shape = reshape(shape, 1, npts*2);
end
function ds = applyRegressor(rho_diff, i, regressor)
ds = 0;
K = numel(regressor.ferns);
F = numel(regressor.features{1});
for k=1:K
    rho = rho_diff{k}(i,:);
    ds = ds + evaluateFern(rho, regressor.ferns{k});
end
end
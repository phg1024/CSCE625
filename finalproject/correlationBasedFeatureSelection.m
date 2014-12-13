function features = correlationBasedFeatureSelection(Y, Mrho, Mrho_centered, varRhoDRho, F)
[~, Lfp] = size(Y); Nfp = Lfp/2;
[n, P] = size(Mrho);
features = cell(F, 1);

for i=1:F
    nu = randn(Lfp, 1);
    Yprob = Y * nu;
    
    covYprob_rho = (sum(bsxfun(@times, Yprob-mean(Yprob), Mrho_centered)))/(n-1);
    covYprob_rho = covYprob_rho';
    %covYprob_rho = covVM(Yprob, Mrho_centered);    
    
    varYprob = var(Yprob);

    covRhoMcovRho = repmat(covYprob_rho, 1, P) - repmat(covYprob_rho', P, 1);
    
    corrYprob_rhoDrho = covRhoMcovRho ./ sqrt(varYprob .* varRhoDRho);
    corrYprob_rhoDrho(logical(eye(size(corrYprob_rhoDrho)))) = -10000.0;
    
    [maxCorr_perCol, rowIdx] = max(corrYprob_rhoDrho);
    [maxCorr, colIdx] = max(maxCorr_perCol);
    
    f.m = rowIdx(colIdx); f.n = colIdx;
    f.rho_m = Mrho(:,f.m); f.rho_n = Mrho(:,f.n);
    f.coor_rhoDiff = maxCorr;
    features{i} = f;
end

end

function res = covVM(v, M_centered)
[n, ~] = size(M_centered);

mu_v = mean(v);
res = sum( bsxfun(@times, v-mu_v, M_centered) ) / (n-1);
res = res';

end
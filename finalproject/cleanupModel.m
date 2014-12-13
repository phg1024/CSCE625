function m = cleanupModel(model)
m = model;
for t=1:numel(m.stages)
    for k=1:numel(m.stages{t}.features)
        for f=1:numel(m.stages{t}.features{k})
            m.stages{t}.features{k}{f}.rho_m = {};
            m.stages{t}.features{k}{f}.rho_n = {};
        end
    end
end
end
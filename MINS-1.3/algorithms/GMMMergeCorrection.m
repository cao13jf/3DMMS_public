function seeds = GMMMergeCorrection(seeds, varargin)

kMax = arg(varargin, 'k_max', 3);
verbose = arg(varargin, 'verbose', 0);

stats = regionprops(seeds, 'boundingbox');
seedIdMax = max(seeds(:));
cvRelativeAreas = zeros(size(stats));
for i = 1:length(stats)
    bb = stats(i).BoundingBox;
    bb = [ceil(bb([2, 1, 3])), floor(bb([2, 1, 3]) + bb([5, 4, 6]))];
    if bb(6) - bb(3) < 2, continue; end
    Vpatch = uint8(seeds(bb(1):bb(4), bb(2):bb(5), bb(3):bb(6)) == i);

    % fill holes in Vpatch
    Vpatch = stack2vol(FillHoles(vol2stack(Vpatch ~= 0)))*i;

    % compute convex hull area
    [X, Y, Z]=ind2sub(size(Vpatch), find(Vpatch ~= 0));
    cvRelativeAreas(i) = volume_area_3d([X(:), Y(:), Z(:)]) ./ nnz(Vpatch);

    if cvRelativeAreas(i) < 1, continue, end

    println(verbose, 'GMMMergeCorrection: Running split test for object %d', i);
    split = false;
    for k = 1:kMax
        [X, Y, Z] = ind2sub(size(Vpatch), find(Vpatch ~= 0));
        Data = [X, Y, Z]';
        nbVar = size(Data,2);
        [Priors, Mu, Sigma] = EM_init_kmeans(Data, k);
%         [Priors, Mu, Sigma] = EM(Data, Priors, Mu, Sigma);

        P = zeros(length(Data), k);
        for j = 1:k
            P(:, j) = Gaussian(Data', Mu(:, j), Sigma(:, :, j));
        end

        % compute likelihood
        L = sum(log(P * Priors')) ./ nbVar;
    %     MC = (numel(Priors)-1 + numel(Mu) + numel(Sigma))*log(length(Data));
    %     MC = (numel(Priors)-1 + numel(Mu) + numel(Sigma));
        MC = k * 0.125;
        BIC = L - MC;
        println(verbose, '\tnbStats=%g; log-likelihood: %g; complexity: %g; BIC: %g', k, L, MC, BIC);

        if k == 1
            BICmax = BIC;
        else
            if BIC > BICmax
                BICmax = BIC;
                split = true;
                [Y, C] = max(P, [], 2); % C is the new clustering
                Vpatch(Vpatch ~= 0) = C;
            end
        end
    end

    if split
        for k = 1:max(Vpatch(:))
            if k == 1
                Vpatch(Vpatch == k) = i;
            else
                seedIdMax = seedIdMax + 1;
                Vpatch(Vpatch == k) = seedIdMax;
                println(verbose, '\tadd object id %d', seedIdMax);
            end
        end
        Vpatch = ctRemoveTouchingBoundary(Vpatch);
        tmp = seeds(bb(1):bb(4), bb(2):bb(5), bb(3):bb(6));
        tmp(tmp == i) = Vpatch(tmp == i);
        seeds(bb(1):bb(4), bb(2):bb(5), bb(3):bb(6)) = tmp;

        println(verbose, '\tsplit object %d', i);
    end
end

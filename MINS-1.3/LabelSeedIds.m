function masked = LabelSeedIds(seg, cellsEmbryoId, cellsInlier, cellsTE, varargin)
% function masked = LabelSeedIds(seg, cellsEmbryoId, cellsInlier, cellsTE, varargin)
% 
% centers = round(GetSeedCenter(seg));
% overlay = arg(varargin, 'overlay', []);
% flip = arg(varargin, 'flip', false);
% color = arg(varargin, 'color', [196, 196, 196]);
% span = arg(varargin, 'span', size(seg, 3));
% highlight = arg(varargin, 'highlight', false(max(seg(:)), 1));

if nargin == 1
    cellsEmbryoId = [];
    cellsInlier = [];
    cellsTE = [];
end

% centers = arg(varargin, 'centers', round(GetSeedCenter(seg)));
centers = round(GetSeedCenter(seg));
overlay = arg(varargin, 'overlay', []);
flip = arg(varargin, 'flip', false);
color = arg(varargin, 'color', [196, 196, 196]);
span = arg(varargin, 'span', size(seg, 3));
highlight = arg(varargin, 'highlight', false(max(seg(:)), 1));
scale = arg(varargin, 'scale', 1);

skip_outlier = arg(varargin, 'skip_outlier', true);

masked = zeros(size(seg), 'uint8');
for i = 1:size(seg, 3)
    labelsInLayer = setdiff(unique(seg(:, :, i)), 0);
    for c = labelsInLayer'
        if size(centers, 2) == 3
            if abs(i - centers(c, 3)) > span, continue; end
        end
        tl = centers(c, [1, 2]);
        if ~isempty(cellsEmbryoId) && ~isempty(cellsInlier) && ~isempty(cellsTE)
            if cellsEmbryoId(c) == 0 || cellsInlier(c) == 0
                if skip_outlier
                    continue ;
                else
%                 str = sprintf('%d-%d-%s', 0, c, GetTEText(cellsTE(c)));
                    str = sprintf('%d-%d-%s', 0, c, 'OL');
                end
            elseif cellsTE(c) ~= 0
                str = sprintf('%d-%d-%s', cellsEmbryoId(c), c, GetTEText(cellsTE(c)));
            else
                str = sprintf('%d-%d', cellsEmbryoId(c), c);
            end
        else
            str = num2str(c);
        end
        tmp = 1 - RemoveBlankMargin(text2image(str, scale));
        if flip
            tmp = flipud(tmp);
        end
        img = ones(size(tmp) + [4, 4], 'uint8');
        img(2:end-1, 2:end-1) = 0;
        img(3:size(tmp, 1)+2, 3:size(tmp, 2)+2) = tmp;
        br = tl + size(img);

        sft = [max(0, br(1) - size(seg, 1)), max(0, br(2) - size(seg, 2))];
        tl = tl - sft; br = br - sft;

        masked(tl(1):br(1)-1, tl(2):br(2)-1, i) = img * (highlight(c) + 1);
    end
end

if ~isempty(overlay)
    if ndims(seg) == 2
        tmp = reshape(overlay, [size(overlay, 1)*size(overlay, 2), size(overlay, 3)]);
        tmp(masked(:) == 1, :) = repmat(color, [sum(masked(:) == 1), 1]);
        tmp(masked(:) == 2, :) = repmat([0, 255, 0], [sum(masked(:) == 2), 1]);
        masked = reshape(tmp, size(overlay));
    else
        tmp = reshape(overlay, [size(overlay, 1)*size(overlay, 2)*size(overlay, 3), size(overlay, 4)]);
        tmp(masked(:) == 1, :) = repmat(color, [sum(masked(:) == 1), 1]);
        tmp(masked(:) == 2, :) = repmat([0, 255, 0], [sum(masked(:) == 2), 1]);
        masked = reshape(tmp, size(overlay));
    end
end

end


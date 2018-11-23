function boundary = segmentation2boundary(segments)
% boundary = segmentation2boundary(segments, connectivity) converts the
% segmentation to boundaries.

sz = size(segments);
boundary = zeros(sz, 'int8');

% +1: x
boundary(2:end-1, 2:end-1, 2:end-1) = segments(2:end-1, 2:end-1, 2:end-1) ~= segments(3:end, 2:end-1, 2:end-1);

% -1: x
boundary(2:end-1, 2:end-1, 2:end-1) = ...
    boundary(2:end-1, 2:end-1, 2:end-1) | segments(2:end-1, 2:end-1, 2:end-1) ~= segments(1:end-2, 2:end-1, 2:end-1);

% +1: y
boundary(2:end-1, 2:end-1, 2:end-1) = ...
    boundary(2:end-1, 2:end-1, 2:end-1) | segments(2:end-1, 2:end-1, 2:end-1) ~= segments(2:end-1, 3:end, 2:end-1);


% -1: y
boundary(2:end-1, 2:end-1, 2:end-1) = ...
    boundary(2:end-1, 2:end-1, 2:end-1) | segments(2:end-1, 2:end-1, 2:end-1) ~= segments(2:end-1, 1:end-2, 2:end-1);

% +1: z
boundary(2:end-1, 2:end-1, 2:end-1) = ...
    boundary(2:end-1, 2:end-1, 2:end-1) | segments(2:end-1, 2:end-1, 2:end-1) ~= segments(2:end-1, 2:end-1, 3:end);


% -1: y
boundary(2:end-1, 2:end-1, 2:end-1) = ...
    boundary(2:end-1, 2:end-1, 2:end-1) | segments(2:end-1, 2:end-1, 2:end-1) ~= segments(2:end-1, 2:end-1, 1:end-2);



% if length(sz) == 3
%     for idxX = 1:sz(1)
%         for idxY = 1:sz(2)
%             for idxZ = 1:sz(3)
%                 [subsX, subsY, subsZ] = ctCheckBounds(sz, idxX-window(1):idxX+window(1), ...
%                     idxY-window(2):idxY+window(2), idxZ-window(3):idxZ+window(3));
%                 data = segments(subsX, subsY, subsZ);
%                 if sum(data(:) ~= segments(idxX, idxY, idxZ)) > 0
%                     boundary(idxX, idxY, idxZ) = 1;
%                 end
%             end
%         end
%     end 
% end
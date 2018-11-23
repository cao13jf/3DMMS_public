function cc = RemoveTouchingBoundary(cc)
% function cc = RemoveTouchingBoundary(cc)

if size(cc, 3) > 1

[X, Y, Z] = ndgrid(-1:1, -1:1, -1:1);
N = [X(:), Y(:), Z(:)];

mask = false(size(cc));
for i = 1:size(cc, 1)
    for j = 1:size(cc, 2)
        for k = 1:size(cc, 3)
            l = cc(i, j, k);
            if l == 0, continue; end
            for n = 1:size(N, 1)
                p = [i, j, k] + N(n, :);
                if ~InsideWindow(p, size(cc)), continue; end
                
                if cc(p(1), p(2), p(3)) ~= 0 && cc(p(1), p(2), p(3)) ~= l
                    mask(i, j, k) = true;
                    break;
                end
            end
        end
    end
end

cc(mask) = 0;

else
%     cc(:, [1, size(cc, 2)]) = 0;
%     cc([1, size(cc, 1)], :) = 0;
    mask = true(size(cc));
    mask(2:end-1, 2:end-1) = false;
    for x = 2:size(cc, 1)-1
        for y = 2:size(cc, 2)-1
            if cc(x, y) == 0, continue; end
            
            if cc(x-1, y) ~= 0 && cc(x-1, y) ~= cc(x, y)
                mask(x, y) = true; 
                continue; 
            end
            
            if cc(x+1, y) ~= 0 && cc(x+1, y) ~= cc(x, y)
                mask(x, y) = true; 
                continue; 
            end
            
            if cc(x, y-1) ~= 0 && cc(x, y-1) ~= cc(x, y)
                mask(x, y) = true; 
                continue; 
            end
            
            if cc(x, y+1) ~= 0 && cc(x, y+1) ~= cc(x, y)
                mask(x, y) = true; 
                continue; 
            end
        end
    end
    
    cc(mask) = 0;
end

% 
% for i = 2:size(cc, 1)-1
%     for j = 2:size(cc, 2)-1
%         if ndims(cc) == 3
%             ks = 2:size(cc, 3) - 1;
%         else
%             ks = 1;
%         end
%         for k = ks
%             if cc(i, j, k) == 0
%                 continue;
%             end
%             
%             if cc(i, j, k) ~= cc(i+1, j, k) && cc(i+1, j, k) ~= 0
%                 cc(i, j, k) = 0;
%                 continue;
%             end
%             
%             if cc(i, j, k) ~= cc(i-1, j, k) && cc(i-1, j, k) ~= 0
%                 cc(i, j, k) = 0;
%                 continue;
%             end
%             
%             if cc(i, j, k) ~= cc(i, j+1, k) && cc(i, j+1, k) ~= 0
%                 cc(i, j, k) = 0;
%                 continue;
%             end
%             
%             if cc(i, j, k) ~= cc(i, j-1, k) && cc(i, j-1, k) ~= 0
%                 cc(i, j, k) = 0;
%                 continue;
%             end
%             
%             if cc(i, j, k) ~= cc(i+1, j+1, k) && cc(i+1, j+1, k) ~= 0
%                 cc(i, j, k) = 0;
%                 continue;
%             end
%             
%             if cc(i, j, k) ~= cc(i+1, j-1, k) && cc(i+1, j-1, k) ~= 0
%                 cc(i, j, k) = 0;
%                 continue;
%             end
%             
%             if cc(i, j, k) ~= cc(i-1, j+1, k) && cc(i-1, j+1, k) ~= 0
%                 cc(i, j, k) = 0;
%                 continue;
%             end
%             
%             if cc(i, j, k) ~= cc(i-1, j-1, k) && cc(i-1, j-1, k) ~= 0
%                 cc(i, j, k) = 0;
%                 continue;
%             end
%         end
%     end
% end

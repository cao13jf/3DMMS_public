function imOut = ConvexImage(imIn)
% Create a convex image using a binary mask image. Works for 2d and 3d
% images.
% 
% Input:
%       imIn:       input image
%       
% Output:
%       imOut:      output convex image/volume
% 
  
% We use the DelaunayTri and pointLocation functions. The code is
% modified from http://stackoverflow.com/questions/2769138/converting-convex-hull-to-binary-mask
if ndims(imIn) == 2
    [I, J] = ind2sub(size(imIn), find(imIn));
    if length(unique(I)) == 1 || length(unique(J)) == 1     % a single line
        imOut = imIn;
        return ;
    end
    
    dt = DelaunayTri([I, J]);    % Create a Delaunay triangulation
    [X, Y] = ind2sub(size(imIn), find(true(size(imIn))));
    simplexIndex = pointLocation(dt, X(:), Y(:));  % Find index of simplex that
                                                    %   each point is inside
    imOut = ~isnan(simplexIndex);    % Points outside the convex hull have a
                                %   simplex index of NaN
    imOut = reshape(imOut, size(imIn));   % Reshape the mask to 101-by-101-by-10

elseif ndims(imIn) == 3 % For 3d, we use the DelaunayTri and pointLocation functions
    [I, J, K] = ind2sub(size(imIn), find(imIn));
    if length(unique(I)) == 1 || length(unique(J)) == 1 || length(unique(K)) == 1     % a single line
        imOut = imIn;
        return ;
    end
    
    dt = DelaunayTri([I, J, K]);    % Create a Delaunay triangulation
    [X, Y, Z] = ind2sub(size(imIn), find(true(size(imIn))));
    simplexIndex = pointLocation(dt, X(:), Y(:), Z(:));  % Find index of simplex that
                                                    %   each point is inside
    imOut = ~isnan(simplexIndex);    % Points outside the convex hull have a
                                %   simplex index of NaN
    imOut = reshape(imOut, size(imIn));   % Reshape the mask to 101-by-101-by-10
else
    error('Input data must be 2d or 3d');
end
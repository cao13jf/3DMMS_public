function im = FillHoles(im)
% function FillHoles(im)
%       fills holes in image im
%           im: a binary image or a stack of binary images

if iscell(im)
    for i = 1:length(im)
        im(i) = {FillHoles(im{i})};
    end
else
    im = imfill(im, 'holes');
end
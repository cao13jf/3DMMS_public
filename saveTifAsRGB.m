function RGBStack = saveTifAsRGB(varargin)
%SAVETIFASRGB save 3D matrix as color stack image. This can be also implemented
%with saveTif by set 'opt.color = true';

%INPUT
% varargin{1}:              3D matrix need to be saved
% varargin{2}:              target file name 
% varargin{3}:(optional)    colormap

%OUTPUT
% RGBStack:                 saved RGB image

%NOTES: color specification is just useful for uint8.


%%
fileName = varargin{2};
[filepath, ~, ~] = fileparts(fileName);
mkdir(filepath);
if exist(fileName, 'file')
    delete(fileName);               %delete file if it already exists
end

if nargin == 3
    stack = varargin{1};
    disorderMap = varargin{3};
elseif nargin == 2
    stack = varargin{1};
    warning('use the pre-saved disordered colormap!');
    load('./data/aceNuc/colorMap.mat', 'disorderMap');
end
    %the colormap can only have maximum 256 entries,so index should be
    %rescaled for correct colormap index.
colorFix =rem(stack, 256);
LF = zeros(size(colorFix));
LF(colorFix == 0) = 1;
LF(stack == 0 ) = 0;
colorFix(LF ~= 0) = 3;
stack = uint8(colorFix);
    %if the stack includes time lapsed image.
tempSize = size(stack);
if length(tempSize) == 4
    for i = 1 : tempSize(4)
        for j = 1 : tempSize(3)
            oneStack = stack(:,:,j,i);
            imwrite(oneStack, disorderMap, fileName, 'WriteMode','append');
        end
    end
end

    %if the stack just includes images at one point.
if length(tempSize) == 3
    for i = 1 : tempSize(3)
        oneStack = stack(:,:,i);
        
        imwrite(oneStack, disorderMap, fileName, 'WriteMode','append');
    end
end


%%
    %produce the RGB image with the index
[R, G, B] = ind2rgb(stack, disorderMap);
RGBStack = cat(4, R, G, B);
function ViewItkSnap(V, M, varargin)
% View the volume with (or w/o) mask using itksnap
%           V:  3D volume
%           M:  segmentation/detection mask

if nargin == 1
    M = [];
end

T = arg(varargin, 'threshold', max(V(:)));
V(V > T) = T;

fileV = 'tmpV.img';
fileM = 'tmpM.img';

ctSaveVolume(V, fileV);
if ~isempty(M)
    ctSaveVolume(M, fileM);
end

if ~isempty(M)
    system(sprintf('start insightsnap -g %s -s %s', fileV, fileM));
else
    system(sprintf('start insightsnap -g %s', fileV));
end

% delete('fileV');
% delete('fileM');
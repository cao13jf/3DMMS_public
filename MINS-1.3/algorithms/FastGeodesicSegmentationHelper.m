function res = FastGeodesicSegmentationHelper(varargin)

println('processing %s', varargin{1});
clear vol seeds
load(varargin{1});
load(varargin{2});
res = FastGeodesicSegmentation(vol, seeds, varargin{3:end});
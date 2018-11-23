function res = convert(data, varargin)
% function res = convert(varargin)

if isempty(varargin)
    targetType = class(data);
else
    targetType = varargin{1};
end

data = double(data);

if ~isempty(strfind(targetType, 'int'))
    vMax = double(intmax(targetType));
    vMin = double(intmin(targetType));
else
    vMax = double(realmax(targetType));
    vMin = double(realmin(targetType));
end

res = (data - min(data(:))) / range(data(:)) * (vMax - vMin) + vMin;

cmd = sprintf('res = %s(res);', targetType);
eval(cmd);
function res = normalize(data, method)

if nargin < 2
    method = 'minmax';
end

data = double(data);
if strcmpi(method, 'minmax')
    minV = min(data(:));
    maxV = max(data(:));

    if maxV == minV
        res = zeros(size(data));
        return ;
    end

    res = (data - minV) ./ (maxV - minV);
elseif strcmpi(method, 'max')
    maxV = max(data(:));
    if maxV ~= 0
        res = data ./ maxV;
    else
        res = data;
    end
elseif strcmpi(method, 'sum')
    sumV = sum(data(:));
    if sumV ~= 0
        res = data ./ sumV;
    else
        res = data;
    end
else
    error('Unknow normalization: %s', method);
end


end

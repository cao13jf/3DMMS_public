function contours = contourd(varargin)
%
% This function takes the same parameters as contourc
%

c = contourc(varargin{:});
contours = cell(0);

N = size(c,2);

K = 1;

idx = 1;

while idx < N
	level = c(1,idx);
	len = c(2,idx);
	
	contours{K} = c(:,(1:len)+idx);
	
	idx = idx + 1 + len;
	K = K+1;
end

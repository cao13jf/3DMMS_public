function [value varargin_] = varargfind(varargin_, key, default_value)

value = [];
for n = 1:(length(varargin_)-1)
    v = varargin_{n};
    if strcmpi(v, key)
        value = varargin_{n+1}; 
        if nargout == 2, varargin_ = varargremove(varargin_, key); end
        return ; 
    end
end

if nargin == 3, value = default_value; end
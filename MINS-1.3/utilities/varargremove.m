function varargin_ = varargremove(varargin_, key)

for n = 1:(length(varargin_)-1)
    v = varargin_{n};
    if strcmpi(v, key)
        varargin_(n:end-2) = varargin_(n+2:end);
        varargin_ = varargin_(1:end-2);
        return ; 
    end
end
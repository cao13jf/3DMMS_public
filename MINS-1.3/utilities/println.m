function println(verbose, varargin)

if ischar(verbose)       % no indication of verbose
    varargin = {verbose, varargin{:}};
elseif verbose ~= 1
    return ;
end
varargin(1) = {sprintf('%s\n', varargin{1})};
fprintf(1, varargin{:});
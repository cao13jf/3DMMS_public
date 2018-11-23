function c = unionCell(c1, c2, type)

if nargin < 3
    type = 'columns';
end

if strcmpi(type, 'rows')
    c = [c1; c2];
elseif strcmpi(type, 'columns')
    c = [c1 c2];
else
    printf('usage: unionCell(cell #1, cell #2, [''rows'' or ''columns'']');
end
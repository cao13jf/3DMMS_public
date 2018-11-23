function s = unionStruct(s1, s2)

fields = fieldnames(s1);

c1 = struct2cell(s1); c1 = c1';
c2 = struct2cell(s2); c2 = c2';

c = unionCell(c1, c2, 'rows');

s = cell2struct(c, fields, 2);
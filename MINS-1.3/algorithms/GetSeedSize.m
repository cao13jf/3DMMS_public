function sizes = GetSeedSize(cc)
% function sizes = GetSeedSize(cc)

sizes = regionprops(cc, 'area');
sizes = cell2mat((struct2cell(sizes))');

function I = FindFileInDir(files, name)

I = false(size(files));
for i = 1:length(files)
    I(i) = strcmpi(files(i).name, name);
end
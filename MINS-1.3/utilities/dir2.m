function ret = dir2(p)

files = dir(p);

ret = cell(size(files));
I = true(size(files));
for i = 1:length(files)
    if strcmp(files(i).name, '.') || strcmp(files(i).name, '..')
        I(i) = false;
        continue;
    end
    ret(i) = {sprintf('%s/%s', p, files(i).name)};
end

ret = ret(I);

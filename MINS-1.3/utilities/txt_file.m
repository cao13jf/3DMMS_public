function res = txt_file(text, filename)

if ~strcmpi(filename((end-3):end), '.txt'), filename = [filename, '.txt']; end

fid = fopen(filename, 'wt');
res = true;

if iscellstr(text)
    for i = 1:length(text)
        fprintf(fid, text{i});
        fprintf(fid, '\n');
    end
elseif ischar(text)
    for i = 1:size(text, 1)
        fprintf(fid, text(i, :));
        fprintf(fid, '\n');
    end
else
    printf('unknown input format of text\n');
    res = false;
end

fclose(fid);
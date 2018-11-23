function C = cellstrread(filename)

fid = fopen(filename);
if fid == -1
    error('unable to open file');
end

C = textscan(fid, '%s');
C = C{1};
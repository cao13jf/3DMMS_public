function rm(files)
% delte files

if strcmpi(computer, 'pcwin')   % windows
    files(files == '/') = '\';
    dos(sprintf('del "%s"', files));
else                            % linux/unix
    files = strrep(files, '[', '\[');
    files = strrep(files, ']', '\]');
    cmd = ['!(', sprintf('rm -rf %s', files), ')'];
    printf('execute command: %s\n', cmd);
    eval(cmd)
end

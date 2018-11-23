%FILE_LIST Create list of files
%   [FILES,TOTAL_FILES] = FILE_LIST(TOPLEVEL,FILE_EXTENSION,DEPTH,FILENAME_SEARCH) will
%   recurse through subdirectories of TOPLEVEL to a depth of DEPTH looking
%   for files that have the same extension as FILE_EXTENSION and partially matching
%   FILENAME_SEARCH. Useful 
%
%   FILE_LIST(TOPLEVEL,FILE_EXTENSION) will search all subdirectories (to a
%   depth of infinity)
%
%   FILE_LIST(TOPLEVEL) will search for all files in a folder and sub
%   folders
%
%   FILE_LIST will prompt the user to select the path. The above defaults are
%   applied
%
%   TOPLEVEL and FILE_EXTENSION can also be cell arrays of multiple top
%   level directories or file extensions
%
%   FILE_LIST is a cell array of all the file found
%   TOTAL_FILES is the total number of files found
%
%   If an absolute path is used for TOPLEVEL list, FILE_LIST will be an
%   absolute path. If TOPLEVEL is a relative path to where file_list is
%   called, then FILE_LIST will be a list relative to that path
%
%   Example:
%   [files,total]=file_list(pwd)
%   [files,total]=file_list(pwd,{'m','mat'})
%   [files,total]=file_list({'C:'},'.txt')
%   [files,total]=file_list({'C:'},{'m','mat'})
%   [files,total]=file_list({'C:'},'',inf,'NTUSER')
%
%   [files,total]=file_list(pwd,'*.mat',1);
%   for i=1:total
%       data=load(files{i});
%       % Do stuff with file
%   end

% Author: Jedediah Frey
% Created: Dec 2006
% Copyright 2006,2007,2008,2009

% Updated Jan 3, 2007
%   Added functionality for cell top level folders and file extensions
%   Will not fail on folder not existing

function [files,total_files] = dirr(toplevel,file_extension,depth,filename_search)
%%
if nargin < 1
    toplevel = uigetdir(cd,'Select the top level folder to process');
end
% If the top level is not a cell and just passed as a string, turn it into
% a cell
if ~iscell(toplevel)
    tmp=toplevel;clear toplevel;
    toplevel{1}=tmp;
    clear tmp;
end
% If no file type is specified, search for all files
if nargin < 2 || isempty(file_extension)
    file_extension = '.*';
end
% If the requested file_extension is not a cell, turn it into one
if ~iscell(file_extension)
    file_extension={file_extension};
end

% If depth is specified, recurse to the end
if nargin < 3 || isempty(depth)
    depth=inf;
end

% If no file name search is specified, leave it blank
if nargin < 4 || isempty(filename_search)
    filename_search='';
end

%% Sanity Checks
i=1;
while i<=numel(toplevel)
    if ~exist(toplevel{i},'dir')
        warning('FILE_LIST:FOLDERDNE',['Top level directory ' toplevel{i} ' does not exist']);
        toplevel(i)='';
        continue
    end
    % If the top level is not passed with a trailing file separator, add it
    if ~strcmp(toplevel{i}(length(toplevel{i})),filesep);
        toplevel{i}=[toplevel{i} filesep];
    end
    i=i+1;
end
if numel(toplevel)==0
   files='';
   total_files=0;
   error('FILE_LIST:NOVALIDFOLDERS','No top level directories found');
   return
end

for n=1:numel(file_extension)
    % If the user puts a wildcard (*) before the file type extension remove
    % it
    if ~strcmp(file_extension{n},'*')
        if strcmp(file_extension{n}(1),'*');
            file_extension{n}(1)='';
        end
    end
    % If the user does not preappend the file type extension with a dot
    % insert it
    if ~strcmp(file_extension{n}(1),'.')
        for i=length(file_extension{n})+1:-1:2
            file_extension{n}(i)=file_extension{n}(i-1);
        end
        file_extension{n}(1)='.';
    end
end

%%
level=1;
total_files=0;
files=cell(1,1);
for i=1:numel(toplevel)
    for j=1:numel(file_extension)
        [files,total_files]=dig(toplevel{i},file_extension{j},files,total_files,level,depth,filename_search);
    end
end
if iscell(files)&&numel(files)>0
    if ischar(files{1})
        files=sort(files);
    end
end

files = files';
%%

function [files,total_files]=dig(folder,file_extension,files,total_files,level,depth,filename_search)
% temp_file_list = dir(folder);

temp_file_listA = dir([folder '*' file_extension ]); 

temp_file_listB = dir([folder '*.']); 

temp_file_list = [temp_file_listA;temp_file_listB];

for cur=1:size(temp_file_list)
    % If the file/folder is . or .. (current or previous folder)
    if strcmp(temp_file_list(cur).name,'.') || strcmp(temp_file_list(cur).name,'..')
        continue
    end
    temp_isdir= temp_file_list(cur).isdir;
    temp_name = [folder,temp_file_list(cur).name];
    % If the next depth is less than the limit, recurse into the directory.
    if temp_isdir&&(level+1<=depth)
        [files,total_files]=dig([temp_name filesep],file_extension,files,total_files,level+1,depth,filename_search);
        % If the file is not a directory.
    elseif ~temp_isdir
        % Explode the file name.
        [p, n, x] = fileparts(temp_name);
        % If a filename match isn't specified, just try to match the
        % extension
        name_match=(~isempty(findstr(n,filename_search))||isempty(filename_search));
        if (strcmpi(file_extension,x)||strcmpi(file_extension,'.*'))&&name_match
            % Increment the total number of files and the files array
            total_files = total_files + 1;
            files{total_files} = temp_name;
        end
    end
end
return

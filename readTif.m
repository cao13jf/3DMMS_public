function oimg = readTif(path)
%READTIF is used to read stack image data. Returned data is saved as a
%matrix.

%INPUT
% path:     the path of the tartget image to be read;

%OUTPUT
% oimg:     the returned data with matrix form.

%% Check directory and file existence
path_parent = pwd;
[pathstr, ~, ~] = fileparts(path);
if ~isempty(pathstr) && ~exist(pathstr, 'dir')
    error 'Directory is not exist.';
end
if ~exist(path, 'file')
    error 'File is not exist.';
end

%% Open file
file_opening_error_count = 0;
while ~exist('tiff', 'var')
    try
        tiff = Tiff(path, 'r');
    catch
        file_opening_error_count = file_opening_error_count + 1;
        pause(0.1);
        if file_opening_error_count > 5     % automatically retry to open for 5 times.
            reply = input('Failed to open the file. Do you wish to retry? Y/n: ', 's');
            if isempty(reply) || any(upper(reply) == 'Y')
                file_opening_error_count = 0;
            else
                error(['Failed to open the file ''' path '''.']);
            end
        end
    end
end

%% Load image information
tfl = 0;    % Total frame length
tcl = 1;    % Total cell length
while true
    tfl = tfl + 1; % Increase frame count
    iinfo(tfl).w       = tiff.getTag('ImageWidth');
    iinfo(tfl).h       = tiff.getTag('ImageLength');
    iinfo(tfl).spp     = tiff.getTag('SamplesPerPixel');
            % Grayscale: 1(real number) or 2(complex number), Color: 3(rgb), 
            %    4(rgba), 6(rgb, complex number), or 8(rgba, complex number)
    iinfo(tfl).color   = iinfo(tfl).spp > 2; 
    iinfo(tfl).complex = any(iinfo(tfl).spp == [2 6 8]);

    if tfl > 1
            % If tag information is changed, make a new cell
        if iinfo(tfl-1).w ~= iinfo(tfl).w || ...
            iinfo(tfl-1).h ~= iinfo(tfl).h || ...
            iinfo(tfl-1).spp ~= iinfo(tfl).spp || ...
            iinfo(tfl-1).color ~= iinfo(tfl).color || ...
            iinfo(tfl-1).complex ~= iinfo(tfl).complex
            tcl = tcl + 1;      % Increase cell count
            iinfo(tfl).fid = 1; % First frame of this cell
        else
            iinfo(tfl).fid = iinfo(tfl-1).fid + 1;
        end
    else
        iinfo(tfl).fid = 1;     % Very first frame of this file
    end
    iinfo(tfl).cid = tcl;       % Cell number of this frame
    
    if tiff.lastDirectory(), break; end;
    tiff.nextDirectory();
end

%% Load image data
if tcl == 1                     % simple image (no cell)
    for tfl = 1:tfl
        tiff.setDirectory(tfl);
        temp = tiff.read();
        if iinfo(tfl).complex
            temp = temp(:,:,1:2:end-1,:) + temp(:,:,2:2:end,:)*1i;
        end
        if ~iinfo(tfl).color
            oimg(:,:,iinfo(tfl).fid) = temp;    % Grayscale image
        else
            oimg(:,:,:,iinfo(tfl).fid) = temp;  % Color image
        end
    end
else % multiple image (multiple cell)
    oimg = cell(tcl, 1);
    for tfl = 1:tfl
        tiff.setDirectory(tfl);
        temp = tiff.read();
        if iinfo(tfl).complex
            temp = temp(:,:,1:2:end-1,:) + temp(:,:,2:2:end,:)*1i;
        end
        if ~iinfo(tfl).color
            oimg{iinfo(tfl).cid}(:,:,iinfo(tfl).fid) = temp;    % Grayscale image
        else
            oimg{iinfo(tfl).cid}(:,:,:,iinfo(tfl).fid) = temp;  % Color image
        end
    end
end

%% Close file
tiff.close();
cd(path_parent);
end

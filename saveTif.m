function res=saveTif(outPath, data, options)
%SAVETIF is used to save tiff stack image according to the bio-formats
%standard. It can save gray image or color image according to the options

%INPUT 
% data:     stack image data  ([height, width, depth, frames] = size(data));
% outPath:  path for saving data;
% options:  set options.color = true to save color image;

%OUTPUT
% res:      return debug number.


errcode = 0;
try
    %% Init options parameter    
    if nargin < 3 % Use default options
        options.color = false;
        options.compress = 'no';
        options.message = true;
        options.append = false;
        options.overwrite = false;
    end
    if ~isfield(options, 'message'),   options.message   = true; end
    if ~isfield(options, 'append'),    options.append    = false; end
    if ~isfield(options, 'compress'),  options.compress  = 'no';  end
    if ~isfield(options, 'color'),     options.color     = false; end
    if ~isfield(options, 'overwrite'), options.overwrite = true; end
    if  isfield(options, 'big') == 0,  options.big       = false; end

    if isempty(data), errcode = 1; assert(false); end
    if ndims(data) ~= 3
        errcode = 1; 
    end
    %%
    [height, width, depth, frames] = size(data);
    description = strcat('ImageJ=1.50i',...
        '\nimages=',num2str(depth*frames),...
        '\nslices=',num2str(depth),...
        '\nframes=',num2str(frames),...
        '\nhyperstack=true',...
        '\nloop=false',... 
        '\nchannels=1');
    tagstruct.ImageLength = height;
    tagstruct.ImageWidth = width;
    tagstruct.BitsPerSample = 8;
    tagstruct.Compression = Tiff.Compression.None;
    tagstruct.PlanarConfiguration = Tiff.PlanarConfiguration.Chunky;
    tagstruct.ImageDescription = sprintf(description);
    
    %%
    data = reshape(data, height, width, depth*frames);
    if ~options.color
        tagstruct.Photometric = Tiff.Photometric.MinIsBlack;
    else
        load('./data/aceNuc/colorMap.mat', 'disorderMap');
        tagstruct.Photometric = Tiff.Photometric.Palette;
        tagstruct.ColorMap = disorderMap;
    end
    %%
    switch class(data)
        case {'uint8', 'uint16', 'uint32'}
            tagstruct.SampleFormat = Tiff.SampleFormat.UInt;
        case {'int8', 'int16', 'int32'}
            tagstruct.SampleFormat = Tiff.SampleFormat.Int;
            if options.color
                errcode = 4; assert(false);
            end
        case {'single', 'double', 'uint64', 'int64'}
            tagstruct.SampleFormat = Tiff.SampleFormat.IEEEFP;
        otherwise
            % (Unsupported)Void, ComplexInt, ComplexIEEEFP
            errcode = 5; assert(false); 
    end

    %%
    switch class(data)
        case {'uint8', 'int8'}
            tagstruct.BitsPerSample = 8;
        case {'uint16', 'int16'}
            tagstruct.BitsPerSample = 16;
        case {'uint32', 'int32'}
            tagstruct.BitsPerSample = 32;
        case {'single'}
            tagstruct.BitsPerSample = 32;
        case {'double', 'uint64', 'int64'}
            tagstruct.BitsPerSample = 64;
        otherwise
            errcode = 5; assert(false);
    end
    
    %% Rows per strip
    maxstripsize = 8*1024;
    tagstruct.RowsPerStrip = ceil(maxstripsize/(width*(tagstruct.BitsPerSample/8)*size(data,3))); % http://www.awaresystems.be/imaging/tiff/tifftags/rowsperstrip.html
    if tagstruct.Compression == Tiff.Compression.JPEG
        tagstruct.RowsPerStrip = max(16,round(tagstruct.RowsPerStrip/16)*16);
    end
    
    %% Write image data to file
    path_parent = pwd;
    [pathstr, fname, fext] = fileparts(outPath);
    if ~isempty(pathstr)
        if ~exist(pathstr, 'dir')
            mkdir(pathstr);
        end
        cd(pathstr);
    end

    file_opening_error_count = 0;
    while ~exist('tfile', 'var')
        try
            if ~options.append % Make a new file
                s=whos('data');
                if s.bytes > 2^32-1 || options.big
                    tfile = Tiff([fname, fext], 'w8'); % Big Tiff file
                else
                    tfile = Tiff([fname, fext], 'w');
                end
            else
                if ~exist([fname, fext], 'file') % Make a new file
                    s=whos('data');
                    if s.bytes > 2^32-1 || options.big
                        tfile = Tiff([fname, fext], 'w8'); % Big Tiff file
                    else
                        tfile = Tiff([fname, fext], 'w');
                    end
                else % Append to an existing file
                    tfile = Tiff([fname, fext], 'r+');
                    while ~tfile.lastDirectory(); % Append a new image to the last directory of an exiting file
                        tfile.nextDirectory();
                    end
                    tfile.writeDirectory();
                end
            end
        catch
            file_opening_error_count = file_opening_error_count + 1;
            pause(0.1);
            if file_opening_error_count > 5 % automatically retry to open for 5 times.
                reply = input('Failed to open the file. Do you wish to retry? Y/n: ', 's');
                if isempty(reply) || any(upper(reply) == 'Y')
                    file_opening_error_count = 0;
                else
                    errcode = 7;
                    assert(false);
                end
            end
        end
    end
    
    for f = 1:frames
        for d = 1:depth
            tfile.setTag(tagstruct);
            tfile.write(data(:, :, d+(f - 1)*depth));
            if d ~= depth*frames
               tfile.writeDirectory();
            end
        end
    end
    tfile.close();
catch exception
    if exist('tfile', 'var'), tfile.close(); end
    if exist('path_parent', 'var'), cd(path_parent); end
    error('Saving data failed')
end
if exist('path_parent', 'var'), cd(path_parent); end
res = errcode;
end


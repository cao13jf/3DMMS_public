% function [data, seg, settings, g_settings, status] = ModuleDetectNuclei(data, seg, settings, g_settings, command)
function varargout = ModuleClassifyNuclei(varargin)

% settings_struct = {...
%     'Remove outlier and detect multiple embryos', 'detect_embryo', true, 'on'; ...
%     'Number of embryos', 'num_embryo', 1, 'on';...
%     'Classify TE/ICM for each embryo', 'classify_te_icm', true, 'on'; ...
%     };

settings_struct = {...
    'Skip this step', 'skip', true, 'on'; ...
    'Number of embryos to detect', 'num_embryo', 1, 'on';...
    'Average radius of embryos (in pixels)', 'radius_embryo', 50, 'on';...
    'Detect and remove outliers', 'remove_outlier', false, 'on'; ...
    'Classify TE/ICM for each embryo', 'classify_te', true, 'on'; ...
    };

if nargin == 0
    varargout{1} = settings_struct;
    return ;
elseif nargin == 1
    if strcmpi(varargin{1}, 'name')
        varargout{1} = 'Classify Nuclei';
    end
    return ;
else
    data = varargin{1};
    seg = varargin{2};
    settings = varargin{3};
    g_settings = varargin{4};
    command = varargin{5};
end

status = 'ok';
if strcmpi(command, 'open')
    % show settings dialog
    settings.z_ratio = g_settings.z_ratio;
    cDialogInputs = PrepareSettingDialog('Classify Nuclei', settings_struct, settings);
    [settings, status] = settingsdlg(cDialogInputs{:});
    if strcmpi(status, 'cancel')
        data = []; settings = []; status = 'cancel'; 
    end
elseif strcmpi(command, 'run')
    if isempty(data) || isempty(seg)
        msgbox('Missing input data! Make sure previous steps have been completed.', 'Error', 'Error');
        status = 'erroneous';
    else
        cellsEmbryoId = ones([max(seg(:)), 1], 'uint16');
        cellsInlier = ones(size(cellsEmbryoId), 'uint16');
        cellsTE = zeros(size(cellsEmbryoId), 'uint16');
        if ~settings.skip
            cellsEmbryoId = DetectMultipleEmbryos(data, seg, settings.num_embryo, settings.radius_embryo);
    %         tmp = [0; cellsEmbryoId]; ctSliceExplorer(tmp(seg+1));

            if settings.remove_outlier
                cellsInlier = RemoveOutlierCells(data, seg, cellsEmbryoId, ...
                    'threshold', .99);
    %             cellsInlier = ones(size(cellsEmbryoId));
    %             tmp = [0; cellsEmbryoId .* cellsInlier]; ctSliceExplorer(tmp(seg+1));
            end

            if settings.classify_te
                cellsTE = ClassifyTECells(data, seg, cellsEmbryoId, cellsInlier, ...
                    'threshold', 0.98, 'verbose', false);
    %         tmp = [0; cellsInlier .* cellsTE]; ctSliceExplorer(tmp(seg+1));
            end
        end

        seg = struct('seg', seg, 'cellsEmbryoId', cellsEmbryoId, ...
            'cellsInlier', cellsInlier, 'cellsTE', cellsTE);
    end
elseif strcmpi(command, 'view')
    if ~isempty(data) && ~isempty(seg)
        if isstruct(seg)
            cellsEmbryoId = seg.cellsEmbryoId;
            cellsInlier = seg.cellsInlier;
            cellsTE = seg.cellsTE;
            labelMap = 2 * (cellsEmbryoId .* cellsInlier);
            labelMap = labelMap - (cellsTE - 1);
            labelMap = [0; labelMap];
            
%             % generate colormap
%             num_embryo = double(max(cellsEmbryoId(:)));
%             cmap = zeros([2*num_embryo, 3]);
%             cmap(1:2:2*num_embryo, :) = jet(num_embryo);
%             cmap(2:2:2*num_embryo, :) = cmap(1:2:2*num_embryo, :);
%             cmap = [0, 0, 0; cmap];
            
            % labelMap            
            seg_ = labelMap(seg.seg+1);
            h = VisualizeImage(data, seg_, ...
                'name', [g_settings.path, g_settings.file]);
            maximize(h);
        elseif ismatrix(seg)
            h = VisualizeImage(data, seg, 'name', [g_settings.path, g_settings.file]);
            maximize(h);
        end
    end
else
    error('Unknown command: %s', command);
end

varargout{1} = data;
varargout{2} = seg;
varargout{3} = settings;
varargout{4} = g_settings;
varargout{5} = status;

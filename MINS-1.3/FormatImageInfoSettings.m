function [settings, g_settings] = FormatImageInfoSettings(varargin)

if nargin == 2
    % prepare settings
    settings.path = varargin{1};
    settings.file = varargin{2};
    settings.size = '';
    settings.dim = '';
%     settings.max_series = 1;
    settings.max_frame = 1;
    settings.format = '';
    settings.max_channel = 1;
    settings.z_ratio = 1;
%     settings.series = 1;
    settings.frame = 1;
    settings.channel = 1;

    % update the gloabl settings
    g_settings.file = settings.file;
    g_settings.path = settings.path;
    g_settings.z_ratio = 1;
%     g_settings.series = 1;
    g_settings.frame = 1;
    g_settings.channel = 1;
else
    imginfo = varargin{1};
    
    % prepare settings
    settings.file = [imginfo.name imginfo.format];
    settings.path = imginfo.path;
    settings.size = imginfo.size;
    settings.dim = imginfo.dim;
%     settings.max_series = imginfo.series;
    settings.max_frame = imginfo.frames;
    settings.format = imginfo.format;
    settings.max_channel = imginfo.channels;
    settings.z_ratio = 1;
%     settings.series = 1;
    settings.frame = 1;
    settings.channel = 1;

    % update the gloabl settings
    g_settings.file = settings.file;
    g_settings.path = settings.path;
    g_settings.z_ratio = 1;
%     g_settings.series = 1;
    g_settings.frame = 1;
    g_settings.channel = 1;
end

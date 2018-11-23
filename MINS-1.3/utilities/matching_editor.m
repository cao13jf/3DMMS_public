function [ptsL, ptsR, labels, go_next] = matching_editor(imgL, imgR, ptsL, ptsR, varargin)
% function P = matching_editor(imgL, imgR, ptsL, ptsR)
%
% Input arguments:

    resourcePath = which('matching_editor.m');
    resourcePath = resourcePath(1:end-length('matching_editor.m')-1);

    go_next = true;

    edit_modes = {'adjust', 'add', 'remove'};
    mode_cursors = {'arrow', 'hand', 'cross'};

    marker_off = arg(varargin, 'marker_off', false);
    markers = {'o', '<', '>', '^', 'v', 's', 'd', 'p', 'h'};
    line_styles = arg(varargin, 'line_styles', {'none', '--', ':', '-.'});
    line_colors = arg(varargin, 'line_colors', {'y', 'r', 'b', 'c'});
    line_width = arg(varargin, 'line_width', 1);
    
    cmap = hsv(256);
    
    ui_wait = arg(varargin, 'ui_wait', true);
    
    if nargin < 4
        error('Incorrect inputs. Type ''help matching_editor'' for more information.');
    else
        validateattributes(imgL, {'double'}, {'nonnegative'});
        validateattributes(imgR, {'double'}, {'nonnegative'});
        if size(ptsL, 1) ~= size(ptsR, 1)
            error('The size of ptsL does not match ptsR.');
        end
    end

    fig = figure( ...
        'Name', 'Matching Editor', ...
        'NumberTitle', 'off', ...
        'ToolBar','none');
    maximize(fig);
    axLegend = sp(6, 2, 1:2, 0, 0); axis off;
    
    % 
    % initialize figure GUI
    %
    
    % initialize label buttons on the toolbar
    ht = uitoolbar(fig);
    label_names = arg(varargin, 'label_names', {'Label 1', 'Label 2', 'Label 3', 'Label 4'});
    icons = get_toolbar_button_icons();
    for idx = 1:size(icons, 4)
        icon = double(imread(sprintf('%s/toolbar_buton_label_%d.png', resourcePath, idxI)));
        icon = icon ./ max(icon(:));
        tooltip = sel2(isempty(label_names), sprintf('Label %d', idx), label_names{idx});
        buttons(idx) = uitoggletool(ht, 'CData', icon, ...
            'TooltipString', tooltip, ...
            'OnCallback', @matching_editor_gui_toolbar_label_on, ...
            'OffCallback', @matching_editor_gui_toolbar_label_off);
        
        % create a invisible line for legend only
        line([0; 0], [0; 0], ...
            'visible', 'off', 'Parent', axLegend, 'Marker', 'none', ...
             'linestyle', line_styles{idx}, 'color', line_colors{idx});
    end
    curLabel = 0;
    legend_off = arg(varargin, 'legend_off', false);
    if ~legend_off
        legend(axLegend, label_names{:}, 'orientation', 'horizontal', 'location', 'south');
    end
    
    % initialize navigation buttons on the toolbar
    icon = double(imread(sprintf('%s/toolbar_buton_previous.png', resourcePath)));
    icon = repmat(icon ./ max(icon(:)), [1, 1, 3]);
    button_nav(1) = uipushtool(ht, 'CData', icon, ...
        'TooltipString', 'Previous Frame', ...
        'ClickedCallback', @matching_editor_gui_on_toolbar_previous);
    
    icon = double(imread(sprintf('%s/toolbar_buton_next.png', resourcePath)));
    icon = repmat(icon ./ max(icon(:)), [1, 1, 3]);
    button_nav(2) = uipushtool(ht, 'CData', icon, ...
        'TooltipString', 'Next Frame', ...
        'ClickedCallback', @matching_editor_gui_on_toolbar_next);

    % draw images
    ax = sp(6, 2, 3:10, 0, 0);
    segL = arg(varargin, 'segL', []);
    segR = arg(varargin, 'segR', []);
    modeIdx = 1;
    set(ax, 'DrawMode', 'fast');
    imgL(:, end) = 1; imgR(:, 1) = 1;
    if isempty(segL) || isempty(segR)
        imagesc([imgL, imgR]); colormap gray; axis image; axis off;
    else
        if ~iscell(segL) && ~iscell(segR)
            ctPlotSegmentationBoundary([imgL, imgR], [segL, segR], ...
                'linewidth', 0.5, 'linestyle', '-', 'color', 'g', 'markeredgecolor', 'none');
        else
            for idx = 1:length(segR)
                tmp = segR{idx}; tmp(:, 2) = tmp(:, 2) + size(imgL, 2);
                segR(idx) = {tmp};
            end
            ctPlotSegmentationBoundary([imgL, imgR], [segL; segR], ...
                'linewidth', 0.5, 'linestyle', '-', 'color', 'g', 'markeredgecolor', 'none');
        end
    end
    ptsR(:, 2) = size(imgL, 2) + ptsR(:, 2); % change it back later

    % note the matlab figure maps X to first value in pts, so we swap them here
    % and swap it back later

    % labels associated with lines
    labels = arg(varargin, 'labels', ones([size(ptsL, 1), 1]));
    
    % draw lines
    lines = zeros([size(ptsL, 1), 1], 'double');
    for idx = 1:size(ptsL, 1)
        lines(idx) = matching_editor_add_line(ptsL(idx, :), ptsR(idx, :), labels(idx));
        if marker_off
            set(lines(idx), 'marker', 'none');
        end
    end
    
    % indicator line
    lineInd = matching_editor_add_line([0; 0], [0; 0], 0);
    set(lineInd, 'Visible', 'off', 'color', [0.9, 0.9, 0.9], ...
        'Marker', 'x', 'linestyle', ':');
    
    % initialize
    selIdx = 0;
    selHeader = 1;
    dragToPt = [0, 0];
    minD = 8;
    pt1ToAdd = []; 
    pt2ToAdd = [];

    try
        set(fig, 'WindowButtonDownFcn', @matching_editor_gui_onmousedown);
        set(fig, 'WindowButtonUpFcn', @matching_editor_gui_onmouseup);
        set(fig, 'WindowButtonMotionFcn', @matching_editor_gui_onmousemove);
        if ui_wait
            uiwait(fig);
        end
        
        ptsR(:, 2) = ptsR(:, 2) - size(imgL, 2); % change it back
    catch ex
        switch ex.identifier
            case 'MATLAB:ginput:FigureDeletionPause'
                % preserve values for x and y
            otherwise
                rethrow(ex);
        end
    end
    
    function h = matching_editor_add_line(pt1, pt2, label)
        % average intensity
        inten = imgL(floor(pt1(1))+1, floor(pt1(2))+1);
        color = cmap(round((1-inten)*0.75*(size(cmap, 1)-2)+1), :);
        
        % flip coordinates for plotting
        pt1 = fliplr(pt1); 
        pt2 = fliplr(pt2);    
        
        X = [pt1(1); pt2(1)]; 
        Y = [pt1(2); pt2(2)];
        marker = markers{max(1, floor(rand * length(markers)))};
%         color = [rand*0.5+0.5, rand*0.25+0.75, rand*0.75+0.25];
%         color = [rand*0.5+0.25, rand*0.5+0.25, rand*0.5+0.25];
%         color = [rand*(1-inten)*0.75+0.25, rand*(1-inten)*0.75+0.25, rand*(1-inten)*0.75+0.25];
%         color = [(1-inten)*0.25+0.75, (1-inten)*0.75+0.25, (1-inten)*0.25+0.75];
        h = line(X, Y, ...
             'Parent', ax, ...
             'MarkerFaceColor', color, ...
             'MarkerEdgeColor', 'none', ...
             'Marker', marker, ...
             'linewidth', line_width);
        
        % set line styles
        if label ~= 0
            set(h, 'linestyle', line_styles{label}, ...
                'color', line_colors{label}, ...
                'visible', 'on');
        end
        
        set(get(get(h,'Annotation'),'LegendInformation'), 'IconDisplayStyle','off'); % Exclude line from legend
    end

    function matching_editor_update_indicator(pt1, pt2)
        pt1 = fliplr(pt1); pt2 = fliplr(pt2);
        X = get(lineInd, 'XData');
        Y = get(lineInd, 'YData');
        if ~isempty(pt1)
            X(1) = pt1(1); Y(1) = pt1(2);
        end
        if ~isempty(pt2)
            X(2) = pt2(1); Y(2) = pt2(2);
        end
        set(lineInd, 'XData', X, 'YData', Y, 'Visible', 'on');
    end

    function matching_editor_update_line(idxL, pt, header, style, color)
        X = get(lines(selIdx), 'XData');
        Y = get(lines(selIdx), 'YData');
        pt = fliplr(pt);    % caution: need to flip to coord for plotting
        X(header) = pt(1); Y(header) = pt(2);
        
        if isempty(style)
            style = get(lines(idxL), 'linestyle');
        end
        if isempty(color)
            color = get(lines(idxL), 'color');
        end
        
        set(lines(idxL), 'XData', X, 'YData', Y, ...
            'linestyle', style, ...
            'color', color);
    end

    function matching_editor_gui_onmousedown(fig, event) %#ok<INUSD>
        if modeIdx == 1
            if strcmpi(get(gcf, 'SelectionType'), 'alt')    % right click, switch mode
                return ;
            end
            % find the closest point
            pt = matching_editor_get_current_point();
            [idxL, isHeader, d] = find_closest_point(pt);
            if d > minD
                selIdx = 0;
                return ;
            end
            selIdx = idxL;
            selHeader = 2-isHeader;

            % draw
            matching_editor_update_line(selIdx, pt, selHeader, ':', []);
        end
    end

    function matching_editor_gui_onmouseup(fig, event) %#ok<INUSD>
        % get mouse click type
        clickType = get(gcf, 'SelectionType');
        if strcmpi(clickType, 'alt')    % right click, switch mode
            modeIdx = mod(modeIdx, length(edit_modes))+1;
            matching_editor_initialize_mode();
        elseif strcmpi(clickType, 'normal')    % left click\\
            switch modeIdx
                case 1      % adjust mode
                    if selIdx ~= 0          % mouse up after moving
                        % fired when the user releases the mouse button.
                        dragToPt = matching_editor_get_current_point();

                        % save results
                        if matching_editor_validate_adjustment(selHeader, dragToPt)
                            if selHeader == 1
                                ptsL(selIdx, :) = dragToPt;
                            else
                                ptsR(selIdx, :) = dragToPt;
                            end
                            if curLabel ~= 0
                                labels(selIdx) = curLabel;
                            end
                            matching_editor_update_line(selIdx, dragToPt, selHeader, ...
                                line_styles{labels(selIdx)}, line_colors{labels(selIdx)});
                        else
                            if selHeader == 1
                                matching_editor_update_line(selIdx, ptsL(selIdx, :), selHeader, ...
                                    line_styles{labels(selIdx)}, line_colors{labels(selIdx)});
                            else
                                matching_editor_update_line(selIdx, ptsR(selIdx, :), selHeader, ...
                                    line_styles{labels(selIdx)}, line_colors{labels(selIdx)});
                            end
                        end

                        % clear the selection
                        selIdx = 0;
                    end
                case 2      % add mode
                    if isempty(pt1ToAdd)    % fix the first point, show indicator line
                        pt1ToAdd = matching_editor_get_current_point();
                        matching_editor_auto_set_cursor();
                    else                    % fix the second point, show indicator line
                        pt2ToAdd = matching_editor_get_current_point();
                        set(lineInd, 'Visible', 'off');
                        
                        % validate user inputs
                        if pt1ToAdd(2) > pt2ToAdd(2)
                            tmp = pt1ToAdd;
                            pt1ToAdd = pt2ToAdd;
                            pt2ToAdd = tmp;
                        end
                        if matching_editor_validate_adjustment(1, pt1ToAdd) && matching_editor_validate_adjustment(2, pt2ToAdd)
                            % store new line
                            ptsL(size(ptsL, 1)+1, :) = pt1ToAdd;
                            ptsR(size(ptsR, 1)+1, :) = pt2ToAdd;
                            labels(length(labels)+1) = sel2(curLabel == 0, 1, curLabel);
                            lines(length(lines)+1) = matching_editor_add_line(pt1ToAdd, pt2ToAdd, labels(end));
                        end
                        matching_editor_initialize_mode();
                    end
                case 3      % remove mode
                    % find the closest point
                    pt = matching_editor_get_current_point();
                    [idxL, isHeader, d] = find_closest_point(pt);
                    if d < minD
                        delete(lines(idxL));
                        I = true(length(lines), 1); I(idxL) = false;
                        % remove: update lines and labels and points
                        lines = lines(I); labels = labels(I); 
                        ptsL = ptsL(I, :); ptsR = ptsR(I, :);
                    end
                    matching_editor_initialize_mode();
            end
        end
    end

    function matching_editor_gui_onmousemove(fig, event)
        switch modeIdx
            case 1
                % Fired when the user moves the mouse.
                if selIdx == 0  % no point selected (not in drag mode)
                    return;
                end
                dragToPt = matching_editor_get_current_point();
                matching_editor_update_line(selIdx, dragToPt, selHeader, ':', []);
            case 2
                if isempty(pt1ToAdd)
                    return ;
                end
                pt2ToAdd = matching_editor_get_current_point();
                matching_editor_update_indicator(pt1ToAdd, pt2ToAdd)
            case 3
        end
    end

    function matching_editor_initialize_mode()
        set(lineInd, 'Visible', 'off');
        set(gcf, 'Pointer', mode_cursors{modeIdx});
        
        switch modeIdx
            case 1
            case 2
                pt1ToAdd = []; 
                pt2ToAdd = [];
            case 3
        end
    end

    function res = matching_editor_validate_adjustment(header, pt)
        res = true;
        if header == 1 && (pt(1) < 1 || pt(1) > size(imgL, 1) || pt(2) < 1 || pt(2) > size(imgL, 2))
            res = false;
        elseif header == 2 && (pt(1) < 1 || pt(1) > size(imgL, 1) || pt(2) < size(imgR, 2)+1 || pt(2) > size(imgR, 2)+size(imgR, 2))
            res = false;
        end
    end

    function pt = matching_editor_get_current_point()
        pt = get(ax, 'CurrentPoint');
        pt = fliplr(pt(1, 1:2));
    end

    function matching_editor_auto_set_cursor()
        pt = matching_editor_get_current_point();
        rectSys = getpixelposition(gcf);
        ptCur = get(0, 'PointerLocation');
        if pt(2) < size(imgR, 2)+1
            ptCur(1) = ptCur(1) + rectSys(3)/2;
        else
            ptCur(1) = ptCur(1) - rectSys(3)/2;
        end
        set(0, 'pointerlocation', ptCur);
    end

    function [idxL, isHeader, minD] = find_closest_point(p)
        d1 = dist(p, ptsL);
        d2 = dist(p, ptsR);
        if min(d1) < min(d2)
            minD = min(d1);
            idxL = find(d1 == minD, 1, 'first');
            isHeader = true;
        else
            minD = min(d2);
            idxL = find(d2 == minD, 1, 'first');
            isHeader = false;
        end
    end

    function matching_editor_gui_toolbar_label_on(h, event) 
        if curLabel ~= 0 && curLabel ~= find(buttons == h)
            set(buttons(curLabel), 'state', 'off');
        end
        curLabel = find(buttons == h);
    end

    function matching_editor_gui_toolbar_label_off(h, event) 
        curLabel = 0;
    end

    function matching_editor_gui_on_toolbar_next(h, event) 
        go_next = true;
        close(fig);
    end

    function matching_editor_gui_on_toolbar_previous(h, event) 
        go_next = false;
        close(fig);
    end

    function icons = get_toolbar_button_icons()
        for idxI = 1:4
            fileIcon = sprintf('%s/toolbar_buton_label_%d.png', resourcePath, idxI);
            icons(:, :, :, idxI) = imread(fileIcon);
        end
    end

    function out = sel2(cond, in1, in2)
        out = sel(cond, in1, in2);
    end
end
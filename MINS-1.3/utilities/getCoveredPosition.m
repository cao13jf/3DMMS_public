function rect = getCoveredPosition(hFig)
% 
% rect = getCoveredPosition(hFig)
% Parameters:
%   hFig is the handle to a figure object
% 

hAxes = findobj(hFig, 'type', 'axes');
if isempty(hAxes)
    rect = [0, 0, 0, 0];
    
    return ;
end

xMin = 1.0; yMin = 1.0; xMax = 0.0; yMax = 0.0;
for idxH = 1:length(hAxes)
    set(hAxes(idxH), 'units', 'pixels');
    r = get(hAxes(idxH), 'position');
    xMin = min(xMin, r(1));
    yMin = min(yMin, r(2));
    xMax = max(xMax, r(1)+r(3));
    yMax = max(yMax, r(2)+r(4));
end

rect = [xMin, yMin, xMax-xMin, yMax-yMin];
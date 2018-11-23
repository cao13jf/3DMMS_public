function subStr = getStringBetween(str, marker)

subStr = str;
markerPos = find(str==marker);
if length(markerPos) == 2
    subStr = str((markerPos(1)+1):(markerPos(2)-1));
end

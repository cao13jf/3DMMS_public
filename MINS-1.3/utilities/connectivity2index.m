function idx = connectivity2index(sz, conn)
% function idx = connectivity2index(sz, conn) computes the index of
% connected voxel given a certain type of connectivity (conn)

if length(sz) == 4      % 4d
    idxSpatialConn = connectivity2index(sz(1:3));
    
    % include the spatial conn
    idx = idxSpatialConn;
    
    % include the temporal conn to the left
    idx = [idx, repmat(-prod(sz(1:3)), 1, length(idxSpatialConn)+1) + [0, idxSpatialConn]]; 
    
    % include the temporal conn to the right
    idx = [idx, repmat(prod(sz(1:3)), 1, length(idxSpatialConn)+1) + [0, idxSpatialConn]];
elseif length(sz) == 3      % 3d
    if nargin < 2
        conn = 6;
    end
    
    idx = [+1, -1, +sz(1), -sz(1), +sz(1)*sz(2), -sz(1)*sz(2)]; % basis 6-conn
    
    if conn == 26   % 26-conn
        
    end
else                    % 2d
    if nargin < 2
        conn = 4;
    end
end
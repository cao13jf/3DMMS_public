function C = GraphColoring(V, E, method)
% C = GraphColoring(V, E, method) performs graph C on graph (V, E) using 
%       1. the greedy dsatur coloring algorithm or
%       2. ...
% 
% Input:
%       V:      a vector of nodes
%       E:      a vector of edges (pairs of indices of nodes)
%       method: graph coloring algorithm, default = 'dsatur'
%
% Output:
%       C:      indices of colors for nodes
%
% Acknowledgement:
%      The dsatur implementation is from
%      http://arman.boyaci.ca/a-matlab-implementation-of-greedy-dsatur-coloring-algorithm/.
% 

if nargin < 3
    method = 'dsatur';
end

switch lower(method)
case 'dsatur',
    C = dsatur(V, E);
otherwise,
    error('Unknown graph coloring algorithm: %s', method);
end

end

function C = dsatur(V, E)

n = size(V,1);
C = zeros(n,1);
available_colors = 1;

% Start with the node that has the maximum degree.
% Color the current node with the lowest available color.
% Select the next node by selecting the node with the maximum degree of saturation.
% This means that you have to select the node that has the most number of unique neighboring colors.
% In case of a tie, use the node with the largest degree.
% Goto step 2. until all nodes are colored.

% Degrees
for i=1:n
    v = i;
    Degrees(i,1) = size([E(find(E(:,1)==v),2); E(find(E(:,2)==v),1)],1);
end

% Degrees of saturation
Degrees_of_saturation = zeros(n,1);

% Coloring
for i=1:n
    if i == 1
        [value index] = max(Degrees);
        v = index(1);
        C(v) = 1;
        assigned_color_v = 1;
    else
        Uncolored = find(C==0);
        index_temp = find(Degrees_of_saturation(Uncolored)==max(Degrees_of_saturation(Uncolored)));
        index = Uncolored(index_temp);
        if(size(index,1)>1)
            [value1 index1] = max(Degrees(index));
            v = index(index1);
        else
            v = index;
        end

        % Assign first available color to v
        neighbors = [E(find(E(:,1)==v),2); E(find(E(:,2)==v),1)];
        for j=1:available_colors
            if size(find(C(neighbors)==j),1)==0
                C(v) = j;
                assigned_color_v = j;
                break;
            end
        end
        if C(v) == 0
            available_colors = available_colors + 1;
            C(v) = available_colors;
            assigned_color_v = available_colors;
        end
    end

    % Update Degrees of saturation
    neighbors_v = [E(find(E(:,1)==v),2); E(find(E(:,2)==v),1)];
    for j=1:size(neighbors_v,1)
       u = neighbors_v(j);
       neighbors_u = [E(find(E(:,1)==u),2); E(find(E(:,2)==u),1)];
       if size(find(C(neighbors_u)==assigned_color_v),1) == 1
           Degrees_of_saturation(u,1) = Degrees_of_saturation(u,1) + 1;
       end
    end

end

end
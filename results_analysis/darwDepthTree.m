function [] = darwDepthTree(Tree, depthTree)
%DARWDEPTHTREE used to draw tree structure with specific depth

%INPUT
% tree:         tree structure which includes cell lineage relationship
% depthTree:     tree structure whose nodes length stands for the depth of one

%%
depth = depthTree.treefun(@numel);

figure; Tree.plot(depth,'YLabel', {'Division time' '(min)'});
H=findobj(gca,'Type','text');
set(H,'Rotation',90, 'FontSize', 8); 
end


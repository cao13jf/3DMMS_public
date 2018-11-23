function isoStack = isotropicSample(stack, resXY, resZ, reduceRatio)
%ISOTROPICSAMPLE uniform the resolution in x-y plane and z direction. 
%Resolutions on x-axis and y-axis are usually equal, so this programs
%concentrates on resampling on z-axis.

%INPUT
% stack:        membrane stack image
% resXY:        resolution on x-y plane
% reduction:    the ratio by which the stack is reduced for computational
%               efficiency

%OUTPUT
% isoStack:     stack image with uniform resolution.


%%
    %first reduce the size of each layer
stack = imresize(stack, [round(reduceRatio*size(stack,1)),round(reduceRatio*size(stack,2))],'bilinear');
    %xy_resolution reduced for the size change.
resXY = resXY/reduceRatio;
xy_z_ratio = resZ/resXY;
    %change the size of xz based on the new resolution ratio.
if xy_z_ratio > 1
    if ndims(stack)==4
        [SR,SC,SZ,t]=size(stack);
        newZnum = round(xy_z_ratio * SZ);      
            %change [x,y,z,t] demensions into [z,x,y,t] for 'imresize'
        zxyStack = permute(stack, [3,1,2,4]);
        tempStack = imresize(zxyStack, [newZnum, SR], 'bilinear');
        isoStack = permute(tempStack, [2,3,1,4]);
    end
    if ndims(stack)== 3
        [SR,SC,SZ]=size(stack);
        newZnum = round(xy_z_ratio * SZ);       
            %change [x,y,z,t] demensions into [z,x,y,t] for 'imresize'
        zxyStack = permute(stack, [3,1,2]);
        tempStack = imresize(zxyStack, [newZnum, SR], 'bilinear');
        isoStack = permute(tempStack, [2,3,1]);
    end
    
else
    isoStack = stack;
end

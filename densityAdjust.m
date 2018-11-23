function [ adjusted_memb ] = densityAdjust( membStack )
%DENSITY_ADJUST adjust the density on each slice based on statistic
%intensity distribution

%INPUT:
%   membStack:      the raw membstack image
%OUTPUT:
%   adjuested_memb: image stack after density adjuestment


%% get the density distribution on each image slice
temMemb = membStack;
[~, ~, sz] = size(temMemb);

[count, ~] = imhist(uint8(temMemb(:,:,1)));
density_distris = count';
for i = 2 : sz
    [density_distri, ~] = imhist(uint8(temMemb(:,:,i))); 
    density_distris = [density_distris;density_distri'];
end
density_distris(:,1) = NaN;%set den=0 as 0 for display
density_distris_filterd = imgaussfilt(density_distris, 3);

%% find the density boundary at each slice
threholded_hist = density_distris_filterd < 10; %number of density lower than 10 is ignored
[~, threholded_cuvre] = max(threholded_hist, [], 2, 'omitnan');
threholded_cuvre = smooth(threholded_cuvre);
% figure;mesh(density_distris_filterd(end:-1:1,:));hold on;
% plot3(threholded_cuvre, sz:-1:1, 13*ones(sz,1), 'r','LineWidth',2);
% colorbar

%% adjust intensity slice-by-slice
tem_ratio = threholded_cuvre(end:-1:1) ./ threholded_cuvre;
adjust_ratio = ones(sz, 1);
adjust_ratio(1:floor(end/2)) = tem_ratio(1:floor(end/2));

adjusted_memb = membStack;
for i = 1:sz
    adjusted_memb(:,:,i) = membStack(:,:,i)*adjust_ratio(i);
end


%%
% plot for comparsion
% [count, ~] = imhist(uint8(adjusted_memb(:,:,1)));
% density_distris = count';
% for i = 2 : sz
%     [density_distri, ~] = imhist(uint8(adjusted_memb(:,:,i))); 
%     density_distris = [density_distris;density_distri'];
% end
% density_distris(:,1) = NaN;%set den=0 as 0 for display
% density_distris_filterd = imgaussfilt(density_distris, 3);
% threholded_hist = density_distris_filterd < 10; %number of density lower than 10 is ignored
% [~, threholded_cuvre0] = max(threholded_hist, [], 2, 'omitnan');
% threholded_cuvre0 = smooth(threholded_cuvre0);


%% figure;mesh(density_distris_filterd(end:-1:1,:));hold on;
% plot3(threholded_cuvre, sz:-1:1, 13*ones(sz,1)+35, 'r', 'LineWidth',2);hold on;
% plot3(threholded_cuvre0, sz:-1:1, 13*ones(sz,1)+30, 'g','LineWidth',2)
% colorbar

end


%This is used to draw cell lineage pictures whose branch points and length
%represent cell and cell's life cycle, respectively.

%% display cell-volume
figure();
load('./data/aceNuc/colorMap.mat');
names = single_cell_features.name;
series = single_cell_features.series;
volume = single_cell_features.volume;
for i = 1 : size(single_cell_features.label)
    time_points = series{i};
    volumes = volume{i};
    text(i, 0, names{i}, 'HorizontalAlignment', 'center');hold on;
    flag = 1;
    for j = 1 : numel(time_points)
        time_point = time_points(j);
        if volumes(j) > 100
            plot([i, i], [time_point-0.5, time_point+0.5], 'LineWidth', 2, 'Color', disorderMap(i+1,:));hold on;
            if flag
                text(i, double(time_point), num2str(i));hold on;
                flag = 0;
            end
        end
    end
end
grid on;
axis([0 256 0 100]);
set(gca,'xticklabel',{[]});
H=findobj(gca,'Type','text');
set(H,'Rotation',90, 'FontSize', 8); % tilt
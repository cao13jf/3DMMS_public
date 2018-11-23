function [handle] = subplot_fah(nr_rows, nr_columns, actual_graph, ...
			 x_span, y_span, x_spacing, y_spacing)
% this is a function which uses the space more efficiently than the 
% standard matlab subplot does; 
% x_span        how much of the space in X direction is used 
% y_span        how much of the space in Y direction is used 
% x_spacing     horizontal space between axes
% y_spacing     vertical space between axes

if nargin <= 3
    x_span = 0.96; y_span = 0.96;
    x_spacing = 0.08; y_spacing = 0.08;
end

width = (x_span - (nr_columns - 1) * x_spacing) / nr_columns;
height = (y_span - (nr_rows - 1) * y_spacing) / nr_rows;

left = (1 - x_span) / 2 + ...
       (mod(actual_graph - 1, nr_columns)) * (width + x_spacing);

row = ceil(actual_graph / nr_columns - 0.0000001); % the last number for
						   % numerical stability

bottom = (1 - y_span) / 2 + ...
	 (nr_rows - row) * (height + y_spacing);

handle = subplot('Position',[left bottom width height]);

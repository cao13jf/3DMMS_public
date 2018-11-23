function filename = write_image(img, prompt)

if( ~exist('filename','var') | isempty(filename) )
	[filename, pathname,filteridx] = uiputfile({'*.jpg;*.gif;*.png;','All image files (*.jpg;*.gif;*.png)';...
		'*.mat','MATLAB files (*.mat)';}, prompt);

	if( filename == 0 )
		img = [];
		return;
	end
	
	filename = [pathname,filename];
end

[pathstr,name,ext,versn] = fileparts(filename);
switch lower(ext)
	case {'.jpg','.png','.fig'}
		imwrite(img,filename);
	case '.mat'
		save(filename,'img');
end


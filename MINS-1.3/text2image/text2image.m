%TEXT2IMAGE    Convert Text files into Images.
%   Syntax: att2 = text2image(tline)

function att2 = text2image(tline, scale)

if nargin < 2
    scale = 1;
end

load data_all.mat
load char_array_all.mat
load index_array_all.mat

% input a string, not a file - by xlou
strh=[];
congo=[];
comt=[];
str= tline;
for dion=1:length(str)
    got=strfind(char_array_all,str(dion));
    com=data_all(:,sum(index_array_all(1:got-1))+1:sum(index_array_all(1:got-1))+index_array_all(got));
    comt=[comt com];
end
congo=[congo comt];
strh=[strh size(comt,2)];

% fid=fopen(y1);
% while 1
%     comt=[];
%     tline = fgetl(fid);
%     if ~ischar(tline), break, end
%     str= tline;
%     for dion=1:length(str)
%         got=strfind(char_array_all,str(dion));
%         com=data_all(:,sum(index_array_all(1:got-1))+1:sum(index_array_all(1:got-1))+index_array_all(got));
%         comt=[comt com];
%     end
%     congo=[congo comt];
%     strh=[strh size(comt,2)];
% end
% fclose(fid);

att2=ones(size(data_all,1)*length(strh),max(strh));
for i=1:length(strh)
    att=[congo(:,sum(strh(1:i-1))+1:sum(strh(1:i-1))+strh(i)) ones(15,max(strh)-strh(i))];
    att2(size(data_all,1)*(i-1)+1:size(data_all,1)*(i),:)=att;
end
att2=[ones(size(att2,1),2) att2];

% output an image, not an image file
att2 = uint8(att2.*255);

att2 = imresize(att2, scale, 'nearest');

% imwrite(uint8(att2.*255),y2);
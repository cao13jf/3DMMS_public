function [] = parallel_saveInfor(out_mat_file, membStack0, membSeg, divRelationMatrix)
% PARALLEL_SAVEINFOR is used to save data during parallel information
% becuase parallel computing cannot calculate and save variable at the same
% time;

%INPUT
% out_mat_file:     file used to save these variables;
% membStack0:       stack image after iso-sampling;
% membSeg:          initial segmentation results without fusion of dividing
%                   cells
%divRelationMatrix: division matrix of cells in this embryo

%%
evExpression = strcat('save(out_mat_file,','''membStack0'',''membSeg'',''divRelationMatrix'')');
eval(evExpression);
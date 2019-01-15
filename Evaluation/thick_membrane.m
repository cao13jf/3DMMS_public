function GT_membrane = thick_membrane(ground_truth)
%% THICK_MEMBRANE is used to return ground truth with thick membrane

background = ground_truth==0;
SE = strel('sphere', 3);  %  Membrane thick approximately equals to 7 pixels

background_dilated = imdilate(background, SE);
GT_membrane = background_dilated ~= background;

Readme for View3dgui tool
By: Deshan Yang, PhD
	Department of radiation oncology, School of Medicine
	Washington University in Saint Louis
	dyang @ radonc . wustl . edu
	
I programmed this 3D volumetric data slice viewer tool a few years ago for my 3D CT image processing research projects. People have found it is very useful to view 3D medical image data in MATLAB. I decide to publish it so that the MATLAB user community can use it for various purposes.

Main features:
1. 3D viewing
a. In axial, coronal or saggittal views
b. Allow flipping the display
c. With correct aspect ratio (pixel size parameter should be given in the command line)
d. Allow images be displayed in higher resolution (automatic tri-linear resampling, with delay to avoid sluggish performance)
e. Window level control with presets
f. Zoom in/out
g. Save the current display into an image file
h. Display the parameter name in the figure window title

2. User interactive graphic interface
a. Use arrow keys to change slice
b. ‘1’,’2’,’3’ keys to change view
c. Right mouse click for menu of options
d. Left mouse click/hold to window level adjustment
i. Left-right to change window center
ii. Up-down to change window width
e. ‘+’ for zoom in, image will be recentered at the last mouse click. The correct ways to use zoom are 
i. Click the image with mouse, then press the ‘+’ key
ii. Or right click the image with mouse, then pick the zoom function from the popup menu
f. ‘-‘ for zoom out, ‘*’ for zoom reset
g. Slice number control with slider bar

3. Options
a. In color or in grayscale
b. Image information on/off
c. Colorbar on/off

4. Features that are not useful for most people
a. Deformable vector field (DVF) can be loaded and visualized on top of the image (If you know what are DVF for deformable image registration)
b. Can load structure masks and display structure contours
c. Can be used to define landmarks

5. Usage:
a. view3dgui(img3d);		% Assuming pixel size is [1 1 1]
b. view3dgui(img3d,[dx dy dz]);		% Giving pixel size
c. view3dgui(img3d,dicom_info_struct);		% Giving pixel size in a DICOM info structure
d. Please see the view3dgui.m about how to pass structure masks, DVFs, etc.

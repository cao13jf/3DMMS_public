3DMMS
=================
This program implements the 3DMMS algorithm proposed in 3DMMS: from nucleus to membrane morphological segmentation. 

![segmentation00](example_pictures/segmentation_results.gif "segmentation results comparison")

![3Dsegmentation](example_pictures/3DSegmentation_half.gif "segmentation result in 3D")

******

|Author|Jianfeng CAO|
|---|---|
|E-mail|jfcao3-c@my.cityu.edu.hk

*****
# Usage
## **Platform dependency** 

This program is developed in Matlab 2017b. For computational efficiency, parallel computing is adopted in 3DMMS.
## **Data preparation**
  
  All datasets are saved in `.\data` file. `.\data\170704plc1p2\aceNuc` includes the original file got from [AceTree](https://www.ncbi.nlm.nih.gov/pmc/articles/PMC1501046/); `.\data\170704plc1p2\membrane` includes embryonic membrane stack images as `*.mat` at different time points. *170704plc1p2* corresponds to the dataset name. If you want to import other data, you can use `originDataTransform.m` to assemble slices into stack images.
  
  Remember to run `startup.m` first to add all files into the working space.
  
## **Parameters settting**

If you want to analyze your own dataset, you might need to change parameters according to your own dataset. `DTWatershed.m` function includs all the parameters you need to tune. They are listed as following:

| **Parameter name** | **Meaning**                           |
|---------------:|:------------------------------------------|
|      data_name | membrane image dataset name               |
|       max_Time | maximal time point of the embryo stack    |
|       prescale | downsample ratio on each slice            |
|    reduceRatio | downsample ratio on the whole embryo      |
|  xy_resolution | resolution on each slice                  |
|   z_resolution | distance of each slices                   |

## **Segmentation**
  
Run `DWatershed.m` to implement 3DMMS segmentation on the dataset. Example results are saved in `.\results\resultsWithMerge\merged_membrane`, `.\results_analysis\interCellFeatures` and `.\results_analysis\singleCellFeatures`. The first one shows the segmentation results on every time points(max t=95); the second one includes the external features between neighboring cells as [tree](http://tinevez.github.io/matlab-tree/) structure; the last file includes the internal features on each single cell, which is also save as [tree](http://tinevez.github.io/matlab-tree/) structue.
  
`.\example_pictures` file also includes the segmentation result at t=46 for your quick reference. 
  
## **Note**

1. [ImageJ](https://fiji.sc/) can be used to view `*.tif` files.

2. 3DMMS aims to segment cells in 3D, where cells closely contact to each other. Raw membrane stack images can comes from *C. elegans*,  *Arabidopsis thaliana* and *Drosophila*, but not individual cells, like cells in the blood. 
  
  

README
==================
This program implements the 3DMMS algorithm proposed in 3DMMS: from nucleus to membrane morphological segmentation. 


******

|Author|Jianfeng CAO|
|---|---
|E-mail|jfcao3-c@my.cityu.edu.hk

*****
## Usage
* **Platform dependency** 

  This program is written with Matlab 2017b. For computational efficiency, parallel computing is adopted in 3DMMS.

* **Data preparation**
  
  All dataSets are saved in `.\data` file. `.\data\170704plc1p2\aceNuc` includes the original file got from [AceTree](https://www.ncbi.nlm.nih.gov/pmc/articles/PMC1501046/); `.\data\170704plc1p2\membrane` includes embryonic membrane stacks images 
  as `*.mat` at different time points. *170704plc1p2* corresponds the dataset name. If you want to import other data, you can use
  `originDataTransform.m` to assemble slices into stack images.
  
  Remember to run `startup.m` to add all files into the working place.
  
* **Parameters settting**

	Example dataset is included in . If you want to analyze your own dataset, you might need to change parameters
	according to your own dataset. `DTWatershed` function includs all the parameters you need to tune. They are
	 listed as following:
	 
	| **Parameter name** | **Meaning**                                       |
	|---------------:|-----------------------------------------------|
	|      data_name | Dataset name                                  |
	|       max_Time | The maximal time point of the embryo stack    |
	|       prescale | The downsample ratio of each slice            |
	|    reduceRatio | The ratio of downsampling on the whole embryo |
	|  xy_resolution | The resolution on each slice                  |
	|   z_resolution | The distance of each slices                   |

* **Example results**
  
  Example results are saved in `.\results\resultsWithMerge\merged_membrane`, `.\results_analysis\interCellFeatures` and `.\results_analysis\singleCellFeatures`. The first one shows the segmentation results on every time points(max t=95); the second
  one includes the external features between neighboring cells as [@tree](http://tinevez.github.io/matlab-tree/) structure; the 
  last file includes the internal features on each single cell, which is also save as [@tree](http://tinevez.github.io/matlab-tree/)
  structue.
  
  '.\example' file also includes partial segmentation results for your quick reference. 
  
* **Note**

  1. [ImageJ](https://fiji.sc/) can be used to view `*.tif` files.
  
  2. 3DMMS aims to segment cells in 3D, where cells are closely contacted to each other. Raw membrane stack images can comes from
  *C. elegans*,  *Arabidopsis thaliana* and *Drosophila*, but not individual cells, like cells in the blood. 
  
  

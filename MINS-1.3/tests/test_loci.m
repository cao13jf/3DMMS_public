%% test loaindg bio-imaging data using the loci tool
addpath('../loci-tools/');


r = bfopen('C:/Users/loux/Data/Panos/leica-wetransfer-b4984d/180313 TDT14 emb9-16.lif');
% C:/Users/loux/Data/Panos/leica-wetransfer-b4984d/180313 TDT14 emb9-16.lif; series 1/8; plane 101/108; Z=26/27; C=1/4


r = bfopen('C:/Users/loux/Data/Panos/Image3.lsm');
% C:/Users/loux/Data/Panos/Image3.lsm; plane 100/530; Z?=20/106; C?=5/5

r = bfopen('C:/Users/loux/Data/Min/062212H2BGFP/062212H2BGFP.lsm');
% C:/Users/loux/Data/Min/062212H2BGFP/062212H2BGFP.lsm; plane 100/3696; Z?=6/28; C?=1/3; T?=2/44

r = bfopen('C:/Users/loux/Data/DCellIQ/8-bit/0001.tiff');

%% test parsing
[imgs, imginfo] = bioimread('C:/Users/loux/Data/Panos/leica-wetransfer-b4984d/180313 TDT14 emb9-16.lif', 5);

[imgs, imginfo] = bioimread('C:/Users/loux/Data/Min/062212H2BGFP/062212H2BGFP.lsm', 1);

[imgs, imginfo] = bioimread('C:/Users/loux/Data/DCellIQ/8-bit/0001.tiff');

[imgs, imginfo] = bioimread('C:/Users/loux/Data/Panos/Image3.lsm');

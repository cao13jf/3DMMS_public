function c = getRandomColor()
colorSet = 'ymrgbk';
c = colorSet(ceil(rand()*length(colorSet)));
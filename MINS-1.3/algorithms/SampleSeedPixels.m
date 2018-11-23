function I = SampleSeedPixels(seeds, seedsSet, varargin)
% function [I, X, L] = SampleSeedPixels(seeds, seedsSet)

num_sample = arg(varargin, 'num_samples', 10000);

I = find(seeds ~= 0);
I = I(ismember(seeds(I), seedsSet));
I = sort(randomsample(I, min(num_sample, length(I))))';

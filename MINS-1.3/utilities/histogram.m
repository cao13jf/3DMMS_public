function [value count] = histogram(x)
% function [value count] = histogram(x) computes the value distribution (histogram) of input
% vector x

x=sort(x);
[value m_ n_] = unique(x, 'first');
[value m n] = unique(x, 'last');
count = m-m_+1;


function [filtered_im] = sobelFilter(im)
% Function implements the Sobel Filter to accentuate edges in an image
%
hh = fspecial('sobel');
hv = hh';
filtered_im = sqrt(imfilter(im, hh).^2 + imfilter(im, hv).^2);
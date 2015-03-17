function [ aligned_mosaic ] = align( mosaic, slope )
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here

cols = size(mosaic, 2);
for i = 1: cols
    shift = round((i-1)*slope);
    mosaic(:, i, :) = circshift(mosaic(:, i, :), [shift,0]);
end

aligned_mosaic = mosaic;


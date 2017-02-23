%   calculate heat capacity for crust
%
%       after Whittington pers comm, 16/6/2010 
%   
%   T in Kelvin 
%
%   David healy 
%   June 2010 

function [cp] = getcpWhitto(T) 

%   in J per kg per K
cp = 1538.39 - 3.224e5 / T + 2.714e7 / T^2 ; 

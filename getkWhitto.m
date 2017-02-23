%   calculate temperature-dependent thermal conductivity  
%
%       after Whittington, pers comm  
%   
%   T in Kelvin 
%
%   David Healy 
%   May 2009 

function [k] = getkWhitto(T)

rho = 2700 ; 

D = 1.214 * exp( -( T - 273 ) / 285.2 ) + 0.319 ;  

cp = getcpWhitto(T) ; 

k = rho * D * 1e-6 * cp ; 

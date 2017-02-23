%   calculate temperature-dependent thermal conductivity  
%
%       after Mottaghy et al., 2008. IJES. 
%   
%   T in Kelvin 
%
%   David Healy 
%   May 2009 

function [k] = getkMantle(T)

k = getkOlivine(T) ; 

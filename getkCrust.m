%   calculate temperature-dependent thermal conductivity  
%
%       after Mottaghy et al., 2008. IJES. 
%   
%   T in Kelvin 
%
%   David Healy 
%   May 2009 

function [k] = getkCrust(T)

k = getkTran(T) ; 
%k = getkKola(T) ; 


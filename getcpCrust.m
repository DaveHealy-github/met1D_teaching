%   calculate heat capacity for crust
%   
%   T in Kelvin 
%
%   David healy 
%   November 2009 

function [cp] = getcpCrust(T) 

cp = getcpWhittington(T) ; 

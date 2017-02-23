%   calculate heat capacity for crust
%
%       after Mottaghy et al., 2008. IJES. 
%   
%   T in Kelvin 
%
%   David healy 
%   May 2009 

function [cp] = getcpKola(T) 

TC = T - 273 ; 

A = [ 718.5, 1.32, -0.002 ] ; 

cp = 0 ; 
for i = 1:3 
    
    cp = cp + ( A(i) * TC^(i-1) ) ; 
    
end ; 

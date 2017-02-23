%   calculate density
%
%   David healy 
%   May 2009 

function [rho] = getrho(z, zMoho)

if z <= zMoho 
    rho = 2700 ; 
else 
    rho = 3300 ; 
end ; 
 
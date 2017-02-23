%   calculate modified heat capacity, cmod, to account for latent heat
%   of melting
%
%       after Stuwe, 1995. Tectonophysics. 
%   
%   T in Kelvin 
%
%   David healy 
%   November 2009 

function [cmod] = getcmod(z, zMoho, T, cp) 

L = 3.2e5 ;             %   Joule per kg  
a = 0.01 ;            %   no idea, just guessing really
Tmeltmax = 900 + 273 ;  %   tea-room pers. comm. from Clark and Fitzsimons
Tmeltmin = 650 + 273 ;  %   ditto 

if z <= zMoho 
    
    %   in the melt 'window'... 
    if T > Tmeltmin && T < Tmeltmax 
        cmod = cp + ( ( L * a ) * exp(a * T) ...
                      / ( exp(a * Tmeltmax) - exp(a * Tmeltmin) ) ) ; 
    else
        cmod = cp ; 
    end ; 

else 
    
    cmod = cp ; 
    
end ; 

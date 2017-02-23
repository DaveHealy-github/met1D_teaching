%   calculate modified heat capacity, cmod, to account for latent heat
%   of melting
%
%       after Stuwe, 1995. Tectonophysics. 
%   
%   T in Kelvin 
%
%   David healy 
%   May 2009 

function [cp] = getcp(z, zMoho, T) 

if z <= zMoho    
    %   in the crust...
    cp = getcpCrust(T) ; 
else 
    %   in the mantle... 
    cp = getcpMantle(T) ; 
end ; 

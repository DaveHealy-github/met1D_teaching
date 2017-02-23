%   calculate heat capacity for mantle, assumed all olivine 
%
%   T in Kelvin 
%
%   David healy 
%   May 2009 

function [cp] = getcpmantle(T) 

%   in g per mole  
molarmassFo = 111.694 ; 
molarmassFa = 140.692 ; 

%   forsterite
k0 = 233.18 ; 
k1 = -1801.6 ; 
k3 = -26.794e7 ; 
cpFo = ( k0 + ( k1 * T^-0.5 ) + ( k3 * T^-3 ) ) / molarmassFo ; 

%   fayalite
k0 = 252.0 ; 
k1 = -2013.7 ; 
k3 = -6.219e7 ; 
cpFa = ( k0 + ( k1 * T^-0.5 ) + ( k3 * T^-3 ) ) / molarmassFa ; 

%   mantle olivine assumed as Fo89
cp = ( ( 0.89 * cpFo ) + ( 0.11 * cpFa ) ) * 1e3 ;  

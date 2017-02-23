%   function to calculate integral of temperature-dependent thermal conductivity
%
%       after McKenzie et al., 2005 EPSL
%
%   David Healy
%   May 2009 

function [G] = getG2(z, zMoho, T)

b = 5.3 ; 
c = 0.0015 ; 

d = [ 1.753e-2, -1.0365e-4, 2.2451e-7, -3.4071e-11 ] ; 

T = T - 273 ; 

%   McKenzie et al., 2005 EPSL - eqn 4 
sumdm = 0 ; 
for m = 1:4 
    sumdm = sumdm + ( d(m) * (T + 273)^m / m ) ;
end ; 

G = ( ( b * log( 1 + ( c * T ) ) ) / c ) + sumdm ; 

if z <= zMoho 
    G = G / 2 ; 
end ; 

function [G] = getGKola(T)

%   T in Kelvin

Tc = T - 273 ; 

kAmbient = 2.5 ; 
kZero = 0.52 * kAmbient ...
            + ( 0.5 * sqrt( ( 1.09 * kAmbient^2 ) - ( 0.36 * kAmbient ) ) ) ; 
        
a = 0.0017 ; 
b = 0.0036 ; 

G = ( kZero / ( a - ( b / kZero ) ) ) * log( 1.0 + Tc * ( a - ( b / kZero ) ) ) ;

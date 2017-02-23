function [G] = getGTran(T)

%   T in Kelvin

Tc = T - 273 ; 

kAmbient = 2.5 ; 
kZero = 0.53 * kAmbient ...
            + ( 0.5 * sqrt( ( 1.13 * kAmbient^2 ) - ( 0.42 * kAmbient ) ) ) ; 
        
a = 0.0030 ; 
b = 0.0042 ; 

G = ( kZero / ( a - ( b / kZero ) ) ) * log( 0.99 + Tc * ( a - ( b / kZero ) ) ) ;

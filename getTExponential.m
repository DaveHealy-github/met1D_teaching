function [T] = getTExponential(zkm, ASurfaceWm3, zSkinkm, zLithkm, k, Tbase) 
    
T = ( ( zkm / zLithkm ) * Tbase ) + ( zSkinkm^2 * ASurfaceWm3 / k ) ...
        * ( ( 1 - exp( -zkm / zSkinkm ) ) - ( 1 - exp( -zLithkm / zSkinkm ) ) * ( zkm / zLithkm ) ) ;           
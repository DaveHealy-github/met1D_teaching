function [G] = getGWhitto(T)

%   T in Kelvin

rho = 2700 ; 

G = rho * ( exp(-0.00350631 * T) * (-1.38724e6 - 8.58114e7 / T) - ...  
 8.65766e6 / T + 490.746 * T - 1.32025e6 * expint(-0.00350631 * T) - 102846 * log(T) ) ; 

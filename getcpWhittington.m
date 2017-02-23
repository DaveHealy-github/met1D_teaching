%   calculate heat capacity for crust
%
%       after Whittington et al., 2009. Nature. 
%           NB corrigendum for their eqn 3
%           last term on RHS has -5.0e6, not -5e-6
%   
%   T in Kelvin 
%
%   David healy 
%   May 2009 

function [cp] = getcpWhittington(T) 

%   in g per mole  
avgmolarmass = 221.78 ; 

if T < 846 
    %   upper crust 
    cp = ( 199.5 + ( 0.0857 * T ) - ( 5e6 / T^2 ) ) / avgmolarmass ; 
else 
    %   lower crust 
    cp = ( 229.32 + ( 0.0323 * T ) - ( 47.9e-6 / T^2 ) ) / avgmolarmass ; 
end ; 

%   in J per kg per K
cp = cp * 1e3 ; 
%   calculate integral of k (temperature-dependent thermal conductivity) 
%
%   T in Kelvin 
%
%   David healy 
%   May 2009 

function [G] = getG(z, zMoho, T)

if z <= zMoho 

%    G = getGKola(T) ; 
    G = getGTran(T) ; 
%    G = getGWhitto(T) ; 
    
else

    G = getGOlivine(T) ;

end ; 

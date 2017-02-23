%   calculate temperature-dependent thermal conductivity  
%
%       after Mottaghy et al., 2008. IJES. 
%       after McKenzie et al., 2005. EPSL. 
%   
%   T in Kelvin 
%
%   David healy 
%   May 2009 

function [k] = getk(z, zMoho, T)

if z <= zMoho 
    
%    k = getkKola(T) ; 
    k = getkTran(T) ; 
%    k = getkWhitto(T) ; 
     
else
    
    k = getkOlivine(T) ;

end ;

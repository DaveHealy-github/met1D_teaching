%   function to calculate integral of temperature-dependent thermal conductivity
%
%       after McKenzie et al., 2005 EPSL
%
%   David Healy
%   May 2009 

function [G] = getGMantle(T)

G = getGOlivine(T) ;

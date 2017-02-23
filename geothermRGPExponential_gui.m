%   radgen profile for exponential HPE distribution  
%       and fixed basal temperature 
%           after Stuwe, 2004 
%
%   David Healy
%   November 2009 

function [Ainit, Athick, Tinit, Tthick] = geothermRGPExponential_gui(z, Tbaselith, k, factor, thickFlag, zCrust, zLith, zSkin, ASurface)

numz = size(z, 2) ; 
Ainit = zeros(1, numz) ; 
Athick = zeros(1, numz) ; 
Tinit = zeros(1, numz) ; 
Tthick = zeros(1, numz) ; 

%   define heat production profile 
% disp(' ') ;
% zSkin = input('Enter skin depth (depth to 1/e of surface heat, km): ') ; 
% disp(' ') ; 
% 
% disp(' ') ;
% ASurface = input('Enter surface volumetric heat production (µW m^-3): ') ; 
% disp(' ') ; 

zkm = z .* 1e3 ;
zCrustkm = zCrust * 1e3 ; 
zLithkm = zLith * 1e3 ; 
zSkinkm = zSkin * 1e3 ; 
ASurfaceWm3 = ASurface / 1e6 ; 

%   define initial geotherm 
for i = 1:numz   

    if zkm(i) <= zCrustkm
        Ainit(i) = ASurfaceWm3 * exp( -zkm(i) / zSkinkm ) * 1e6 ; 
    end ; 

    Tinit(i) = getTExponential(zkm(i), ASurfaceWm3, zSkinkm, zLithkm, k, Tbaselith) ; 
        
end ; 

%   homogeneous thickening... 
if thickFlag > 0 
    
    %   define thickened geotherm 
    zkmCrustThick = zkm ./ factor ; 
    zkmMantleThick = zkm - ( ( factor - 1 ) * zCrustkm ) ; 

    for i = 1:numz
        
        if zkm(i) <= zCrustkm * factor 
            Athick(i) = ASurfaceWm3 * exp( -zkm(i) / ( zSkinkm * factor ) ) * 1e6 ; 
        end ; 

        if zkmCrustThick(i) <= zCrustkm
            Tthick(i) = getTExponential(zkmCrustThick(i), ASurfaceWm3, zSkinkm, ...
                                        zLithkm, k, Tbaselith) ; 
        else
            Tthick(i) = getTExponential(zkmMantleThick(i), ASurfaceWm3, zSkinkm, ...
                                        zLithkm, k, Tbaselith) ; 
        end ; 
        
    end ; 

%   thrust thickening... 
else 
    
    endzCrust = find(z == zCrust) ; 
    
    Athick(1:endzCrust) = Ainit(1:endzCrust) ; 
    Athick(endzCrust+1:endzCrust*factor) = Ainit(1:endzCrust) ; 
    Athick((endzCrust*factor)+1:numz) = 0 ; 
    
    Tthick = Tinit ; 
    
end ; 

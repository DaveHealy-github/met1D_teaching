%   radgen profile for constant heat production in 1 layer 
%
%       thickFlag = 0 => crust only, thrust thickening
%       thickFlag = 1 => crust only, homogeneous thickening
%       thickFlag = 2 => whole lithosphere, homogeneous thickening
%
%   David Healy
%   November 2009 

function [Ainit, Athick, Tinit, Tthick] ...
        = geothermRGPLayered(z, Tbaselith, factor, thickFlag, zCrust, zLith, k)

numz = size(z, 2) ; 
Ainit = zeros(1, numz) ; 
Athick = zeros(1, numz) ; 
Tinit = zeros(1, numz) ; 
Tthick = zeros(1, numz) ; 

%   define heat production profile 
disp(' ') ;
zthislayer1 = input('Enter base depth of heat producing layer (km): ') ; 
Athislayer1 = input('Enter constant volumetric heat production (µW m^-3): ') ; 
disp(' ') ; 

zkm = z * 1e3 ; 
zLithkm = zLith * 1e3 ; 
zthislayer1km = zthislayer1 * 1e3 ; 
Athislayer1Wm3 = Athislayer1 / 1e6 ; 

startz = 1 ; 
endz = find(z == zthislayer1) ; 
    
%   define initial geotherm 
for i = 1:numz
    Tinit(i) = getT1Layer(zkm(i), zthislayer1km, zLithkm, Athislayer1Wm3, Tbaselith, k) ; 
end ; 
    
%   define initial radgen distribution 
for j = startz:1:endz + 1 
    Ainit(j) = Athislayer1 ;
end ; 

%   homogeneous thickening... 
if thickFlag > 0 
    
    %   define thickened crust radgen distribution 
    for j = startz:1:(endz*factor) + 1 
        Athick(j) = Athislayer1 ;
    end ; 

    %   define thickened crust geotherm
    zkmCrustThick = zkm ./ factor ; 
    zCrustkm = zCrust * 1e3 ; 
    zkmMantleThick = zkm - ( ( factor - 1 ) * zCrustkm ) ; 

    for i = 1:numz
        
        if zkmCrustThick(i) <= zCrustkm || thickFlag == 2 
            Tthick(i) = getT1Layer(zkmCrustThick(i), zthislayer1km, zLithkm, ...
                                    Athislayer1Wm3, Tbaselith, k) ;
        else
            Tthick(i) = getT1Layer(zkmMantleThick(i), zthislayer1km, zLithkm, ...
                                    Athislayer1Wm3, Tbaselith, k) ; 
        end ; 
        
    end ;
    
%   thrust thickening... 
else 
    
    endz2 = find(z == zCrust) ; 
    
    Athick(1:endz) = Athislayer1 ;
    Athick(endz+1:endz2) = 0 ; 
    Athick(endz2:endz2+endz) = Athislayer1 ; 
    Athick(endz2+endz+1:numz) = 0 ; 
    
    Tthick(1:endz2) = Tinit(1:endz2) ; 
    for i = endz2+1:1:numz
        Tthick(i) = Tinit(i-endz2) ; 
    end ; 
    
end ; 

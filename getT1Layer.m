function [T] = getT1Layer(zkm, zlayerkm, zlithkm, A, Tlith, k)
        
if zkm <= zlayerkm 
    
    T = ( ( A * zlithkm * zkm ) / ( 2 * k ) ) ...
        * ( 2 * ( zlayerkm / zlithkm ) - ( zlayerkm^2 / zlithkm^2 ) - ( zkm / zlithkm ) ) ...
        + Tlith * ( zkm / zlithkm ) ; 
        
else
    
    T = ( ( A * zlayerkm^2 ) / ( 2 * k ) ) ...
        * ( 1 - ( zkm / zlithkm ) ) ... 
        + Tlith * ( zkm / zlithkm ) ; 

end ;
        

%   function to evolve diffusion equation by CrankNicolson in 1D   
%       taken from Computational Physics, Richard Fitzpatrick
%   
%   includes terms for:
%       heat source (e.g. radgen)
%       advection (e.g. erosion/uplift)
%   
%   function evolves T by one time step, assumed to be of extent N+2
%   C = D dt / dz^2, where dt is time step and dz is grid spacing 
%   
%   David Healy
%   December 2009
%
function [T] = CN1Dmerge_gui(T, Hradgen, Hshear, ...
                            alpha_l, beta_l, gamma_l, ...
                            alpha_h, beta_h, gamma_h, ...
                            dz, dt, u, e, z, zM, ...
                            Lmelt, amelt, Tmeltmin, Tmeltmax)

%   size local arrays
N = size(T,2) - 2 ; 
a = zeros(N+2) ; 
b = zeros(N+2) ; 
c = zeros(N+2) ; 
w = zeros(N+2) ; 

%   useful values 
delta = dt / dz ; 
C = delta / ( 2 * dz ) ; 
iMoho = find(z >= zM, 1) ; 

%   initialise tridiagonal matrix 
for i = 3:N+1
    
    if i <= iMoho 
        k = getkCrust(T(i-1)) ; 
        cp = getcpCrust(T(i)) ; 
        rho = getrhoCrust(T(i)) ;
    else
        k = getkMantle(T(i-1)) ; 
        cp = getcpMantle(T(i)) ; 
        rho = getrhoMantle(T(i)) ;
    end ; 
    
    cmod = getcmod_gui(z(i), zM, T(i), cp, Lmelt, amelt, Tmeltmin, Tmeltmax) ; 
    
    a(i) = ( -C * k ) / ( rho * cmod ) ; 

end ; 

for i = 2:N+1

    if i <= iMoho 
        k = getkCrust(T(i)) ; 
        cp = getcpCrust(T(i)) ; 
        rho = getrhoCrust(T(i)) ;
    else
        k = getkMantle(T(i)) ; 
        cp = getcpMantle(T(i)) ; 
        rho = getrhoMantle(T(i)) ;
    end ; 
    
    cmod = getcmod_gui(z(i), zM, T(i), cp, Lmelt, amelt, Tmeltmin, Tmeltmax) ; 
    
    b(i) = 1 + ( 2 * C * k ) / ( rho * cmod ) ;
    
end ; 

k = getkCrust(T(2)) ; 
cp = getcpCrust(T(2)) ; 
rho = getrhoCrust(T(2)) ;
cmod = getcmod_gui(z(2), zM, T(2), cp, Lmelt, amelt, Tmeltmin, Tmeltmax) ; 
b(2) = b(2) + ( C * k * beta_l ) / ( ( rho * cmod ) * ( alpha_l * dz - beta_l ) ) ;

k = getkMantle(T(N+1)) ; 
cp = getcpMantle(T(N+1)) ; 
rho = getrhoMantle(T(N+1)) ;
cmod = getcmod_gui(z(N+1), zM, T(N+1), cp, Lmelt, amelt, Tmeltmin, Tmeltmax) ; 
b(N+1) = b(N+1) - ( C * k * beta_h ) / ( ( rho * cmod ) * ( alpha_h * dz + beta_h ) ) ; 

for i = 2:N

    if i <= iMoho 
        k = getkCrust(T(i+1)) ; 
        cp = getcpCrust(T(i)) ; 
        rho = getrhoCrust(T(i)) ;
    else
        k = getkMantle(T(i+1)) ; 
        cp = getcpMantle(T(i)) ; 
        rho = getrhoMantle(T(i)) ;
    end ; 
    
    cmod = getcmod_gui(z(i), zM, T(i), cp, Lmelt, amelt, Tmeltmin, Tmeltmax) ; 

    c(i) = ( -C * k ) / ( rho * cmod ) ; 

end ; 

%   initialise RHS vector 
for i = 2:N+1

    if ( i + e ) > N + 1 
        index = N + 1 ; 
    else 
        index = i + e ; 
    end ; 
    
    if i <= iMoho 
        
        cp = getcpCrust(T(i)) ; 
        rho = getrhoCrust(T(i)) ;

        cmod = getcmod_gui(z(i), zM, T(i), cp, Lmelt, amelt, Tmeltmin, Tmeltmax) ; 
        
        w(i) = T(i) ...
                + ( ( 2 * C ) / ( rho * cmod ) ) ...
                    * ( getGCrust(T(i-1)) - 2 * getGCrust(T(i)) + getGCrust(T(i+1)) ) ...
                - ( C / ( rho * cmod ) ) ...
                    * ( getkCrust(T(i-1)) * T(i-1) - 2 * getkCrust(T(i)) * T(i) + getkCrust(T(i+1)) * T(i+1) ) ... 
                - ( delta * u * ( T(i) - T(i-1) ) * cp / cmod ) ... 
                + ( ( Hradgen(index) + Hshear(index) ) * dt ) / ( rho * cmod ) ;
    
    else
        
        cp = getcpMantle(T(i)) ;
        rho = getrhoMantle(T(i)) ;
    
        cmod = getcmod_gui(z(i), zM, T(i), cp, Lmelt, amelt, Tmeltmin, Tmeltmax) ; 
        
        w(i) = T(i) ...
                + ( ( 2 * C ) / ( rho * cmod ) ) ...
                    * ( getGMantle(T(i-1)) - 2 * getGMantle(T(i)) + getGMantle(T(i+1)) ) ...
                - ( C / ( rho * cmod ) ) ...
                    * ( getkMantle(T(i-1)) * T(i-1) - 2 * getkMantle(T(i)) * T(i) + getkMantle(T(i+1)) * T(i+1) ) ... 
                - ( delta * u * ( T(i) - T(i-1) ) * cp / cmod ) ... 
                + ( ( Hradgen(index) + Hshear(index) ) * dt ) / ( rho * cmod ) ;
                
    end ; 
            
end ; 

k = getkCrust(T(1)) ; 
cp = getcpCrust(T(2)) ; 
rho = getrhoCrust(T(2)) ;
cmod = getcmod_gui(z(2), zM, T(2), cp, Lmelt, amelt, Tmeltmin, Tmeltmax) ; 
w(2) = w(2) + ( C * k * gamma_l * dz ) / ( ( rho * cmod ) * ( alpha_l * dz - beta_l ) ) ; 

k = getkMantle(T(N+2)) ; 
cp = getcpMantle(T(N+1)) ; 
rho = getrhoMantle(T(N+1)) ;
cmod = getcmod_gui(z(N+1), zM, T(N+1), cp, Lmelt, amelt, Tmeltmin, Tmeltmax) ; 
w(N+1) = w(N+1) + ( C * k * gamma_h * dz ) / ( ( rho * cmod ) * ( alpha_h * dz + beta_h ) ) ;

%   invert tridiagonal matrix equation
T = Tridiagonal(a, b, c, w) ; 

%   calculate end values
T(1) = ( gamma_l * dz - beta_l * T(2) ) / ( alpha_l * dz - beta_l ) ; 
T(N+2) = ( gamma_h * dz + beta_h * T(N+1) ) / ( alpha_h * dz + beta_h ) ; 

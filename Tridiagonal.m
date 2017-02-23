%   function to invert a tridiagonal matrix equation 
%   
%       taken from Computational Physics, Richard Fitzpatrick
%   
%   a, b and c are left, centre and right diagonals
%   w is RHS
%   solution written to u 
%
%   matrix is N x N
%   a, b, c, w and u are of extent N+2 with redundant 1 and N+2 elements
%   
%   David Healy
%   May 2009
%
function [u] = Tridiagonal(a, b, c, w)

N = size(a,2) - 2 ; 

x = zeros(N) ; 
y = zeros(N) ; 

%   scan up diagonal from i = N to 1 
x(N) = -a(N+1) / b(N+1) ; 
y(N) = w(N+1) / b(N+1) ; 
for i = N-1:-1:2
    x(i) = -a(i+1) / ( b(i+1) + c(i+1) * x(i+1) ) ; 
    y(i) = ( w(i+1) - c(i+1) * y(i+1) ) / ( b(i+1) + c(i+1) * x(i+1) ) ; 
end ; 
x(1) = 0 ;
y(1) = ( w(2) - c(2) * y(2) ) / ( b(2) + c(2) * x(2) ) ;

%   scan down diagonal from 1 to N
u(2) = y(1) ; 
for i = 2:N
    u(i+1) = x(i) * u(i) + y(i) ;
end ; 
    
function plotMeltingCurves(Tmin, Tmax, alphaMelt, axMelt)

hold(axMelt, 'on') ; 
for a = [-0.1, -0.01, 0.01, 0.1 ]   
    i = 0 ; 
    for Tmelt = Tmin:2:Tmax
        i = i + 1 ;  
        vmelt(i) = ( exp(a*Tmelt) - exp(a*Tmin) ) / ( exp(a*Tmax) - exp(a*Tmin) ) ; 
    end ; 
    plot(axMelt, Tmin:2:Tmax, vmelt*100, '-b', 'LineWidth', 0.5) ; 
end ; 
a = alphaMelt ; 
i = 0 ; 
for Tmelt = Tmin:2:Tmax
    i = i + 1 ;  
    vmelt(i) = ( exp(a*Tmelt) - exp(a*Tmin) ) / ( exp(a*Tmax) - exp(a*Tmin) ) ; 
end ; 
plot(axMelt, Tmin:2:Tmax, vmelt*100, '-g', 'LineWidth', 2) ; 
plot(axMelt, [Tmin, Tmin], [0, 100], 'r', 'LineWidth', 0.5) ; 
plot(axMelt, [Tmax, Tmax], [0, 100], 'r', 'LineWidth', 0.5) ; 
hold(axMelt, 'off') ; 
xlabel(axMelt, 'Temperature, ºC') ;
ylabel(axMelt, 'Melt fraction, %') ; 
xlim(axMelt, [Tmin-50 Tmax+50]) ; 
ylim(axMelt, [0 100]) ; 
axis(axMelt, 'on', 'square') ; 
grid(axMelt, 'on') ; 
box(axMelt, 'on') ; 

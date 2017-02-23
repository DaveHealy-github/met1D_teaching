function plotRadgenCurves(Ainit, z, zmax, axRadgen) 

% hold(axRadgen, 'on') ; 
plot(axRadgen, Ainit, z, '-r', 'LineWidth', 0.5) ; 
% plot(axRadgen, Athick, z, '-b', 'LineWidth', 0.5) ; 
% hold(axRadgen, 'off') ; 

set(axRadgen, 'XAxisLocation', 'top') ; 
set(axRadgen, 'YDir', 'reverse') ; 
xlabel(axRadgen, 'Heat production, µW m^{-3}') ;
ylabel(axRadgen, 'Depth, km') ; 
xlim(axRadgen, [0 max(Ainit)*1.2]) ; 
ylim(axRadgen, [0 zmax]) ; 

grid(axRadgen, 'on') ; 
box(axRadgen, 'on') ; 

legend(axRadgen, 'Initial', 'Location', 'south') ; 
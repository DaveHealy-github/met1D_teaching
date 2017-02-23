age = [ 20, 40, 60, 80, 100, 120 ] ; 

qsLow = [16.1784, 25.6247, 30.1444, 24.5619, 22.5528, 21.8648] ; 
qsMedium = [ 44.1423, 70.2365, 77.5587, 58.1473, 53.3341, 52.0573] ; 
qsHigh = [ 68.852, 105.7996, 115.2883, 89.8317, 82.903, 80.8656 ] ; 

figure(1) ; 

hold on ; 
plot(age, qsLow, '-r') ; 
plot(age, qsMedium, '-g') ; 
plot(age, qsHigh, '-b') ; 
hold off ; 

box on ; 

xlabel('Time, My') ; 
ylabel('Surface heat flow, mW m^-2') ; 
ylabel('Surface heat flow, mW m^{-2}') ; 
xlim([0 120]) ; 
xlim([20 120]) ; 
legend('A = 0.3 {mu}Wm^{-3}', 'A = 1.5 {mu}Wm^{-3}', 'A = 2.7 {mu}Wm^{-3}') ; 
legend('A = 0.3 \muWm^{-3}', 'A = 1.5 \muWm^{-3}', 'A = 2.7 \muWm^{-3}') ;

print -dtiff -r300 'surfaceheatflowVersusage.tiff' ; 
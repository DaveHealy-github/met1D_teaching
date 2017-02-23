
clear all ; 

for i = 1:1:1500 

    kTran(i) = getkTran(i) ; 
    kKola(i) = getkKola(i) ; 
    
    GTran(i) = getGTran(i) ; 
    GKola(i) = getGKola(i) ; 
    
    km(i) = getk(100, 70, i) ; 
    kc(i) = getk(40, 70, i) ; 
    
    Gm(i) = getG(100, 70, i) ; 
    Gc(i) = getG(40, 70, i) ; 
    
    kmMc(i) = calck(i) ; 
    kcMc(i) = kmMc(i) / 2 ; 
    
    GmMc(i) = getG2(100, 70, i) ; 
    GcMc(i) = getG2(40, 70, i) ; 
    
    T(i) = i ; 

end ; 

figure ; 

subplot(3,2,1) ; 
hold on ; 
plot(T, kTran, '-r') ;
plot(T, kKola, '-b') ;
hold off ; 
xlim([273 1250]) ; 
ylim([0 10]) ; 
xlabel('T, Kelvin') ;
ylabel('k, W per m per K') ; 
title('Mottaghy et al., 2008 - IJES') ;

subplot(3,2,2) ; 
hold on ; 
plot(T, GTran/1e3, '-r') ;
plot(T, GKola/1e3, '-b') ;
hold off ; 
xlim([273 1250]) ; 
ylim([0 10]) ; 
xlabel('T, Kelvin') ;
ylabel('G') ; 
title('Healy') ;

subplot(3,2,3) ; 
hold on ; 
plot(T, kcMc, '-r') ;
plot(T, kmMc, '-b') ;
hold off ; 
xlim([273 1250]) ; 
ylim([0 10]) ; 
xlabel('T, Kelvin') ;
ylabel('k, W per m per K') ; 
title('McKenzie et al., 2005 - EPSL') ; 

subplot(3,2,4) ; 
hold on ; 
plot(T, GcMc/1e3, '-r') ;
plot(T, GmMc/1e3, '-b') ;
hold off ; 
xlim([273 1250]) ; 
ylim([0 10]) ; 
xlabel('T, Kelvin') ;
ylabel('G') ; 
title('McKenzie et al., 2005 - EPSL') ; 

subplot(3,2,5) ; 
hold on ; 
plot(T, kc, '-r') ;
plot(T, km, '-b') ;
hold off ; 
xlim([273 1250]) ; 
ylim([0 10]) ; 
xlabel('T, Kelvin') ;
ylabel('k, W per m per K') ; 
title('Whittington et al., 2009 - Nature') ; 

subplot(3,2,6) ; 
hold on ; 
plot(T, Gc/1e3, '-r') ;
plot(T, Gm/1e3, '-b') ;
hold off ; 
xlim([273 1250]) ; 
ylim([0 10]) ; 
xlabel('T, Kelvin') ;
ylabel('G') ; 
title('Healy') ; 

%   calculate geothermal gradients over time 
%       solved by finite difference method (Crank-Nicolson)
%
%   after England & Thompson, 1984. Journal of Petrology. 
%       but using a fixed base lithosphere temperature
%
%   includes:
%       erosion/uplift
%       temperature dependence of k and cp
%       latent heat of melting 
%       shear heating (if thickened by thrust stacking)
%       
%   David Healy 
%   December 2009 

clear all ; 

disp(' ') ; 
disp('*** Started HC10merge.m...') ; 
disp(' ') ; 

%   initialise...
tau = 30 ;                          %   shear zone stress, MPa
vel = 3 ;                           %   shear zone velocity, cm per year
width = 3 ;                         %   shear zone width, km 
zShear = 35 ;                       %   shear zone depth, km  
tShear = 50 ;                       %   shear zone duration, My

erosion = 35 ;                      %   amount of uplift, km
t_erosion = 120 ;                    %   duration of uplift, My 
delay_erosion = 60 ;                %   delay before uplift starts, My

deltaz = 0.5 ;                      %   depth increment, km
maxz = 150 ;                        %   depth to base lithosphere 
numz = maxz / deltaz ;              %   number of depths  
z = 0:deltaz:maxz ;                 %   array of depths 

deltat = 0.1 ;                      %   time increment, My
maxt = 120 ;                        %   time to end of model run, My
numt = maxt / deltat ;              %   time to end of model run, My
t = 0:deltat:maxt ;                 %   array of times 

Tbaselith = 1300 + 273 ;            %   fixed T at base lithosphere, deg K 
k = 2.25 ;                          %   Watts per metre per K
zCrust = 35 ;                       %   initial thickness of crust, km
zLith = maxz ;                      %   thickness of lithosphere, km 
rho = 2700 ;                        %   density, kg per cu metre 
cp = 1000 ;                         %   specific heat capacity, J per kg per K

%   boundary conditions for finite difference 
alpha_low = 1 ; 
beta_low = 0 ; 
gamma_low = 273 ;                   %   top lithosphere at 0 deg C
alpha_high = 1 ; 
beta_high = 0 ; 
gamma_high = Tbaselith ;            %   base lithosphere at 1280 deg C

%   plot geotherms for these times
plotTimes = [ 20, 40, 60, 80, 100, 120 ] ; 
plotGeotherms = zeros(size(plotTimes,2), numz+1) ; 

%   tracked P-T-t paths
trackDepths = [ 35, 50, 70 ] ;      %   initial depths of points to track, km

%   for lines 
trackInterval = 5 ;                 %   time interval to track P-T, Myr 
trackDepth1 = zeros(1, (maxt/trackInterval)+1) ; 
trackDepth2 = zeros(1, (maxt/trackInterval)+1) ; 
trackDepth3 = zeros(1, (maxt/trackInterval)+1) ; 
trackT1 = zeros(1, (maxt/trackInterval)+1) ; 
trackT2 = zeros(1, (maxt/trackInterval)+1) ; 
trackT3 = zeros(1, (maxt/trackInterval)+1) ; 

%   for points 
trackIntervalp = 20 ;                %   time interval to track P-T, Myr 
trackDepth1p = zeros(1, (maxt/trackIntervalp)+1) ; 
trackDepth2p = zeros(1, (maxt/trackIntervalp)+1) ; 
trackDepth3p = zeros(1, (maxt/trackIntervalp)+1) ; 
trackT1p = zeros(1, (maxt/trackIntervalp)+1) ; 
trackT2p = zeros(1, (maxt/trackIntervalp)+1) ; 
trackT3p = zeros(1, (maxt/trackIntervalp)+1) ; 

%   mode of thickening
disp('*** Thickening mode') ; 
thickFlag = input('Choose 0 (crustal thrust sheet), 1 (homogeneous, crust only) or 2 (homogeneous, whole lithosphere) for thickening mode: ') ; 
if thickFlag > 0 
    thickFactor = input('Enter homogeneous thickening factor: ') ; 
else 
    thickFactor = 2 ; 
end ; 

%   calculate steady-state geotherms, initial and thickened (T in deg C)
disp(' ') ; 
HPEFlag = input('Choose 1 (single layer, constant) or 2 (exponential) for HPE distribution: ') ; 
if HPEFlag == 1 
    [Ainitial, Athickened, Tinitial, Tthickened] ...
                = geothermRGPLayered(z, Tbaselith-273, thickFactor, thickFlag, zCrust, zLith, k) ; 
else 
    [Ainitial, Athickened, Tinitial, Tthickened] ...
            = geothermRGPExponential(z, Tbaselith-273, k, thickFactor, thickFlag, zCrust, zLith) ; 
end ; 

%   set-up before loop through time
T = Tthickened + 273 ;              %   deg C to Kelvin
My2seconds = 1e6 * 365 * 24 * 60 * 60 ; 
A = Athickened ./ 1e6 ;     
zMoho = zCrust * thickFactor ; 
Ashearmax = ( tau * 1e6 ) * ( vel / ( 1e2 * 365 * 24 * 60 * 60 ) ) / ( width * 1e3 ) ; 
Ashear = Ashearmax .* exp(-( ( z .* 1e3 ) - ( zShear * 1e3 ) ).^2 / ( width * 1e3 )^2 ) ; 

%   before the run, display settings
disp('*** Default settings for this run') ; 
disp(strcat('Crustal thickness, km: ', num2str(zCrust))) ; 
disp(strcat('Thermal conductivity, W m^-1 K^-1: ', num2str(k))) ; 
disp(strcat('Density, kg m^-3: ', num2str(rho))) ;
disp(strcat('Specific heat capacity, J kg^-1 K^-1: ', num2str(cp))) ; 
disp(strcat('Depth increment, km: ', num2str(deltaz))) ; 
disp(strcat('Time increment, Myr: ', num2str(deltat))) ; 
disp(strcat('Total erosion, km: ', num2str(erosion))) ; 
disp(strcat('Duration of erosion, Myr: ', num2str(t_erosion))) ; 
disp(strcat('Pause before erosion, Myr: ', num2str(delay_erosion))) ; 
disp('*** Boundary conditions') ; 
disp(strcat('Surface temperature, degC: 0')) ; 
disp(strcat('Base lithosphere temperature, degC: ', num2str(Tbaselith-273))) ; 
disp(' ') ; 

trackIndex = 1 ; 
trackIndexp = 1 ; 

%   no shear heating for homogeneous thickening 
if thickFlag > 0 
    Ashear = zeros(numz) ; 
end ; 

%   main loop through time increments 
for tcalc = 0:deltat:maxt
    
    %   are we in the 'erosion window'?
    if t_erosion ~= 0 && erosion ~= 0 
        if tcalc > delay_erosion && tcalc < ( delay_erosion + t_erosion )
            v_erosion = -( erosion * 1e3 ) / ( t_erosion * My2seconds ) ;
            sum_erosion = round( ( erosion / t_erosion ) * ( tcalc - delay_erosion ) ) ;
            %   disp(strcat( 'At ', num2str(tcalc), 'My, erosion = ', num2str(sum_erosion), ' km') ) ; 
        elseif tcalc < delay_erosion 
            v_erosion = 0 ; 
            sum_erosion = 0 ; 
        elseif tcalc > ( delay_erosion + t_erosion ) 
            v_erosion = 0 ; 
            sum_erosion = erosion ;
        end ; 
    else 
        v_erosion = 0 ; 
        sum_erosion = 0 ;
    end ; 
    
    %   switch off shear heating after tShear My
    if tcalc > tShear 
        Ashear = zeros(numz) ; 
    end ; 
    
    %   calc geotherm using Crank-Nicolson method for this time...
    T = CN1Dmerge(T, A, Ashear, ...
                    alpha_low, beta_low, gamma_low, ...
                        alpha_high, beta_high, gamma_high, ...
                            deltaz * 1e3, deltat * My2seconds, v_erosion, sum_erosion, z, zMoho) ; 

    %   check if we need to save this one...
    for i = 1:size(plotTimes,2)
        if tcalc == plotTimes(i)
            disp( strcat( 'Saving geotherm at: ', num2str(tcalc), ' My' ) ) ; 
            plotGeotherms(i, 1:numz+1) = T - 273 ; %  plot in deg C
            qs = k * ( T(2) - 273  ) / ( z(2) * 1e3 ) ; 
            disp( strcat( '*** Surface heat flow = ', num2str(qs*1e3), ' mW m^-2' ) ) ; 
            disp(' ') ; 
            break ;
        end ; 
    end ;  
    
    %   update tracked P-T loops 
    if rem(tcalc, trackInterval) == 0 
        
        trackDepth1(trackIndex) = trackDepths(1) - sum_erosion ; 
        trackDepth2(trackIndex) = trackDepths(2) - sum_erosion ; 
        trackDepth3(trackIndex) = trackDepths(3) - sum_erosion ; 
        
        trackT1(trackIndex) = T(find(z > round(trackDepth1(trackIndex)), 1)) - 273 ;  
        trackT2(trackIndex) = T(find(z > round(trackDepth2(trackIndex)), 1)) - 273 ;  
        trackT3(trackIndex) = T(find(z > round(trackDepth3(trackIndex)), 1)) - 273 ;  
        
        trackIndex = trackIndex + 1 ; 
        
    end ; 
    
    %   update tracked P-T points 
    if rem(tcalc, trackIntervalp) == 0 
        
        trackDepth1p(trackIndexp) = trackDepths(1) - sum_erosion ; 
        trackDepth2p(trackIndexp) = trackDepths(2) - sum_erosion ; 
        trackDepth3p(trackIndexp) = trackDepths(3) - sum_erosion ; 
        
        trackT1p(trackIndexp) = T(find(z > round(trackDepth1p(trackIndexp)), 1)) - 273 ;  
        trackT2p(trackIndexp) = T(find(z > round(trackDepth2p(trackIndexp)), 1)) - 273 ;  
        trackT3p(trackIndexp) = T(find(z > round(trackDepth3p(trackIndexp)), 1)) - 273 ;  
        
        trackIndexp = trackIndexp + 1 ; 
        
    end ; 
    
end ; 

%   display the results 
scrsz = get(0, 'ScreenSize') ;
figure('Position', [1 scrsz(4)/2 scrsz(3)/2 scrsz(4)/2]) ; 

%   plot radgen profile 
subplot(2,3,1) ; 
hold on ; 
plot(Ainitial, z, '-r', 'LineWidth', 1.5) ; 
plot(Athickened, z, '-b', 'LineWidth', 1.5) ; 
hold off ; 
set(gca, 'XAxisLocation', 'top') ; 
set(gca, 'YDir', 'reverse') ; 
xlabel('Heat production, µWm^{-3}') ;
ylabel('Depth, km') ; 
xlim([0 10]) ; 
ylim([0 maxz]) ; 
set(gca,'XTick', [0 2.5 5 7.5 10]) ;
grid on ; 
box on ; 
axis square ; 

%   plot geotherm 
subplot(2,3,2) ; 
hold on ; 
plot(Tinitial, z, '-r', 'LineWidth', 1.5) ; 
plot(Tthickened, z, '-b', 'LineWidth', 1.5) ; 
for i = 1:size(plotTimes,2)
    plot(plotGeotherms(i, 1:numz+1), z, '-k', 'LineWidth', 1) ;
end ; 
hold off ; 
set(gca, 'XAxisLocation', 'top') ; 
set(gca, 'YDir', 'reverse') ; 
xlabel('Temperature, ºC') ;
ylabel('Depth, km') ; 
xlim([0 1500]) ; 
ylim([0 maxz]) ; 
set(gca,'XTick', [0 500 1000 1500]) ;
grid on ; 
box on ; 
axis square ; 

%   plot P-T-t paths 
g = 9.81 ; 
trackP1 = trackDepth1 .* ( 1e3 * rho * g ) ./ 1e9 ; 
trackP2 = trackDepth2 .* ( 1e3 * rho * g ) ./ 1e9 ; 
trackP3 = trackDepth3 .* ( 1e3 * rho * g ) ./ 1e9 ; 
subplot(2,3,3) ; 
hold on ; 
plot(trackT1, trackP1, '-r', 'LineWidth', 1.5) ; 
plot(trackT2, trackP2, '-b', 'LineWidth', 1.5) ; 
plot(trackT3, trackP3, '-g', 'LineWidth', 1.5) ; 
hold off ; 
set(gca, 'XAxisLocation', 'top') ; 
set(gca, 'YDir', 'reverse') ; 
xlabel('Temperature, ?C') ;
ylabel('Pressure, GPa') ; 
xlim([0 1500]) ; 
ylim([0 maxz*rho*g*1e3/1e9]) ; 
set(gca,'XTick', [0 500 1000 1500]) ;
grid on ; 
box on ; 
axis square ; 

%   plot radgen profile, zoomed 
subplot(2,3,4) ; 
hold on ; 
plot(Ainitial, z, '-r', 'LineWidth', 1.5) ; 
plot(Athickened, z, '-b', 'LineWidth', 1.5) ; 
hold off ; 
set(gca, 'XAxisLocation', 'top') ; 
set(gca, 'YDir', 'reverse') ; 
xlabel('Heat production, µWm^{-3}') ;
ylabel('Depth, km') ; 
xlim([0 10]) ; 
ylim([0 zCrust*thickFactor]) ; 
set(gca,'XTick', [0 2.5 5 7.5 10]) ;
grid on ; 
box on ; 
axis square ; 

%   plot geotherm, zoomed  
subplot(2,3,5) ; 
hold on ; 
plot(Tinitial, z, '-r', 'LineWidth', 1.5) ; 
plot(Tthickened, z, '-b', 'LineWidth', 1.5) ; 
for i = 1:size(plotTimes,2)
    plot(plotGeotherms(i, 1:numz+1), z, '-k', 'LineWidth', 1) ;
end ; 
hold off ; 
set(gca, 'XAxisLocation', 'top') ; 
set(gca, 'YDir', 'reverse') ; 
xlabel('Temperature, ºC') ;
ylabel('Depth, km') ; 
xlim([0 1000]) ; 
ylim([0 zCrust*thickFactor]) ; 
set(gca,'XTick', [0 200 400 600 800 1000]) ;
grid on ; 
box on ; 
axis square ; 

%   plot P-T-t paths 
subplot(2,3,6) ; 
hold on ; 
plot(trackT1, trackP1, '-r', 'LineWidth', 1.5) ; 
plot(trackT2, trackP2, '-b', 'LineWidth', 1.5) ; 
plot(trackT3, trackP3, '-g', 'LineWidth', 1.5) ; 
hold off ; 
set(gca, 'XAxisLocation', 'top') ; 
set(gca, 'YDir', 'reverse') ; 
xlabel('Temperature, ?C') ;
ylabel('Pressure, GPa') ; 
xlim([0 1000]) ; 
ylim([0 zCrust*thickFactor*1e3*rho*g/1e9]) ; 
set(gca,'XTick', [0 200 400 600 800 1000]) ;
grid on ; 
box on ; 
axis square ; 

%   print 
print -dtiff -r300 'HC10merge.tiff' ; 

%   figures for AGU 2009 poster 
figure('Position', [1 scrsz(4)/2 scrsz(3)/2 scrsz(4)/2]) ; 

%   UHT conditions box 
g = 9.81 ; 
Tuht = [ 900, 1100, 1100, 900, 900 ] ; 
Puht = [ 7, 7, 13, 13, 7 ] ; 
zuht = ( ( Puht .* 1e8 ) ./ ( g * rho ) ) ./ 1e3 ; 

%   plot geotherm, zoomed  
subplot(1,2,1) ; 
hold on ; 
plot(Tinitial, z, '-g', 'LineWidth', 1.5) ; 
plot(Tthickened, z, '-.b', 'LineWidth', 1.5) ; 
for i = 1:size(plotTimes,2)
    plot(plotGeotherms(i, 1:numz+1), z, '-k', 'LineWidth', 1.5) ;
end ; 
plot(Tuht, zuht, '-k', 'LineWidth', 1) ; 
hold off ; 
set(gca, 'XAxisLocation', 'top') ; 
set(gca, 'YDir', 'reverse') ; 
xlabel('Temperature, ºC') ;
ylabel('Depth, km') ; 
xlim([0 1200]) ; 
ylim([0 zCrust*thickFactor]) ; 
set(gca,'XTick', [0 300 600 900 1200]) ;
grid on ; 
box on ; 
axis square ; 
legend('Steady-state - Initial', ...
       'Steady-state - Thickened', ...
       'Transient - Every 20 My', ...
       'Location', 'SouthOutside') ; 

%   plot P-T-t paths 
trackP1 = trackDepth1 .* ( 1e3 * rho * g ) .* 1e-8 ; 
trackP2 = trackDepth2 .* ( 1e3 * rho * g ) .* 1e-8 ; 
trackP3 = trackDepth3 .* ( 1e3 * rho * g ) .* 1e-8 ; 
trackP1p = trackDepth1p .* ( 1e3 * rho * g ) .* 1e-8 ; 
trackP2p = trackDepth2p .* ( 1e3 * rho * g ) .* 1e-8 ; 
trackP3p = trackDepth3p .* ( 1e3 * rho * g ) .* 1e-8 ; 
subplot(1,2,2) ; 
hold on ; 
plot(trackT1p, trackP1p, 'sr', 'LineWidth', 1.5, ...
                               'MarkerEdgeColor', 'r', ...
                               'MarkerFaceColor', 'r', ...
                               'MarkerSize', 7) ; 
plot(trackT2p, trackP2p, 'ob', 'LineWidth', 1.5, ...
                               'MarkerEdgeColor', 'b', ...
                               'MarkerFaceColor', 'b', ...
                               'MarkerSize', 7) ; 
plot(trackT3p, trackP3p, '^g', 'LineWidth', 1.5, ...
                               'MarkerEdgeColor', 'g', ...
                               'MarkerFaceColor', 'g', ...
                               'MarkerSize', 7) ; 
plot(trackT1, trackP1, '-r', 'LineWidth', 1.5) ; 
plot(trackT2, trackP2, '-b', 'LineWidth', 1.5) ; 
plot(trackT3, trackP3, '-g', 'LineWidth', 1.5) ; 
plot(Tuht, Puht, '-k', 'LineWidth', 1) ; 
hold off ; 
set(gca, 'XAxisLocation', 'top') ; 
set(gca, 'YDir', 'reverse') ; 
xlabel('Temperature, ºC') ;
ylabel('Pressure, kbar') ; 
xlim([0 1200]) ; 
ylim([0 zCrust*thickFactor*1e3*rho*g*1e-8]) ; 
set(gca,'XTick', [0 300 600 900 1200]) ;
grid on ; 
box on ; 
axis square ; 
legend('PTt for initial depth 35 km', ...
       'PTt for initial depth 50 km', ...
       'PTt for initial depth 70 km', ...
       'Location', 'SouthOutside') ; 

%   print 
print -dtiff -r300 'HC10mergeAGU.tiff' ; 

disp(' ') ; 
disp('*** ...finished HC10merge.m') ; 
disp(' ') ; 
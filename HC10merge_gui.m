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
%   
%   Modified December 2016 
%   separate figures 

function rc = HC10merge_gui(tau, vel, width, zShear, tShear, ... 
                            erosion, t_erosion, delay_erosion, ...
                            deltaz, maxz, deltat, maxt, ... 
                            TbaselithC, k, zCrust, rho, cp, ...
                            plotTimes, trackDepths, ...
                            thickFlag, thickFactor, ...
                            HPEFlag, zthislayer1, Athislayer1, zSkin, ASurface, ...
                            Lmelt, amelt, Tmeltmin, Tmeltmax, ... 
                            Pbox, Tbox)
%   arguments & units 
% tau           shear zone stress, MPa
% vel           shear zone velocity, cm per year
% width         shear zone width, km 
% zShear        shear zone/thrust depth, km  
% tShear        shear zone duration, My
% 
% erosion       amount of uplift, km
% t_erosion     duration of uplift, My 
% delay_erosion delay before uplift starts, My
% 
% deltaz        depth increment, km
% maxz          depth to base lithosphere 
%
% deltat        time increment, My
% maxt          time to end of model run, My
% k             Watts per metre per K
% zCrust        initial thickness of crust, km
% rho           density, kg per cu metre 
% cp            specific heat capacity, J per kg per K
%
% plotTimes     plot geotherms for these times 
% trackDepths   initial depths of points to track in P-T-t, km
%
% thickFlag     0 (crustal thrust sheet), 1 (homogeneous, crust only) or 2 (homogeneous, whole lithosphere) for thickening mode
% thickFactor   homogeneous thickening factor
%
% HPEFlag       1 (single layer, constant) or 2 (exponential) for HPE distribution 
%
% Tbox          T limits of tracked P-T box  
% Pbox          P limits of tracked P-T box  

disp(' ') ; 
disp('*** Started HC10merge_gui.m...') ; 
disp(' ') ; 

numz = maxz / deltaz ;              %   number of depths  
z = 0:deltaz:maxz ;                 %   array of depths 
 
numt = maxt / deltat ;              %   time to end of model run, My
t = 0:deltat:maxt ;                 %   array of times 
 
Tbaselith = TbaselithC + 273 ;      %   fixed T at base lithosphere, deg K 
zLith = maxz ;                      %   thickness of lithosphere, km 

%   boundary conditions for finite difference 
alpha_low = 1 ; 
beta_low = 0 ; 
gamma_low = 273 ;                   %   top lithosphere at 0 deg C
alpha_high = 1 ; 
beta_high = 0 ; 
gamma_high = Tbaselith ;            %   base lithosphere at 1280 deg C

%   plot geotherms for these times
plotTimes = plotTimes' ; 
trackDepths = trackDepths' ; 
plotGeotherms = zeros(size(plotTimes,2), numz+1) ; 

%   for lines 
trackInterval = 5 ;                 %   time interval to track P-T, Myr 
trackDepthPTt = zeros((maxt/trackInterval)+1, length(trackDepths)) ; 
trackT = zeros((maxt/trackInterval)+1, length(trackDepths)) ; 

%   for points 
trackDepthPTtP = zeros(length(plotTimes), length(trackDepths)) ; 
trackTP = zeros(length(plotTimes), length(trackDepths)) ; 

%   calculate steady-state geotherms, initial and thickened (T in deg C)
if HPEFlag == 1 
    [Ainitial, Athickened, Tinitial, Tthickened] ...
                = geothermRGPLayered_gui(z, Tbaselith-273, thickFactor, thickFlag, zCrust, zLith, k, zthislayer1, Athislayer1, zShear) ; 
else 
    [Ainitial, Athickened, Tinitial, Tthickened] ...
            = geothermRGPExponential_gui(z, Tbaselith-273, k, thickFactor, thickFlag, zCrust, zLith, zSkin, ASurface) ; 
end ; 

%   set-up before loop through time
T = Tthickened + 273 ;              %   deg C to Kelvin
My2seconds = 1e6 * 365 * 24 * 60 * 60 ; 
A = Athickened ./ 1e6 ;     
zMoho = zCrust * thickFactor ; 
if tShear > 0 
    Ashearmax = ( tau * 1e6 ) * ( vel / ( 1e2 * 365 * 24 * 60 * 60 ) ) / ( width * 1e3 ) ; 
else
    Ashearmax = 0 ; 
end ;     
Ashear = Ashearmax .* exp(-( ( z .* 1e3 ) - ( zShear * 1e3 ) ).^2 / ( width * 1e3 )^2 ) ; 

%   before the run, display settings
disp('*** Parameters for this run:') ; 
disp(['Crustal thickness, km: ', num2str(zCrust)]) ; 
disp(['Thermal conductivity, W m^-1 K^-1: ', num2str(k)]) ; 
disp(['Density, kg m^-3: ', num2str(rho)]) ;
disp(['Specific heat capacity, J kg^-1 K^-1: ', num2str(cp)]) ; 
disp(' ') ; 
disp(['Total uplift & erosion, km: ', num2str(erosion)]) ; 
disp(['Duration of uplift & erosion, Myr: ', num2str(t_erosion)]) ; 
disp(['Pause before uplift & erosion, Myr: ', num2str(delay_erosion)]) ; 
disp(' ') ; 
disp(['Latent heat of melting, J kg^-1: ', num2str(Lmelt)]) ; 
disp(['Melting parameter, alpha: ', num2str(amelt)]) ; 
disp(' ') ; 

disp('*** Boundary conditions and finite difference settings:') ; 
disp(['Surface temperature, degC: 0']) ; 
disp(['Base lithosphere temperature, degC: ', num2str(Tbaselith-273)]) ; 
disp(['Depth increment, km: ', num2str(deltaz)]) ; 
disp(['Time increment, Myr: ', num2str(deltat)]) ; 
disp(' ') ; 

trackIndex = 1 ; 
trackIndexp = 1 ; 

%   no shear heating for homogeneous thickening 
if thickFlag > 0 
    Ashear = zeros(numz) ; 
end ; 

%   main loop through time increments 
it = 0 ; 
iqs = 0 ;
Tsave = zeros(numz+1, numt) ; 

for tcalc = 0:deltat:maxt
    
    it = it + 1 ; 
    
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
    T = CN1Dmerge_gui(T, A, Ashear, ...
                        alpha_low, beta_low, gamma_low, ...
                            alpha_high, beta_high, gamma_high, ...
                                deltaz * 1e3, deltat * My2seconds, ...
                                    v_erosion, sum_erosion, z, zMoho, ...
                                        Lmelt, amelt, Tmeltmin, Tmeltmax) ; 

    %   check if we need to save this one...
    for i = 1:size(plotTimes,2)
        if tcalc == plotTimes(i)
            disp( strcat( 'Saving geotherm at: ', num2str(tcalc), ' My' ) ) ; 
            plotGeotherms(i, 1:numz+1) = T - 273 ; %  plot in deg C
            iqs = iqs + 1 ; 
            qs(iqs) = k * ( T(2) - 273  ) / ( z(2) * 1e3 ) ; 
            disp( strcat( '*** Surface heat flow = ', num2str(qs(iqs)*1e3), ' mW m^-2' ) ) ; 
            disp(' ') ; 
            break ;
        end ; 
    end ;  
    
    %   update tracked P-T loops 
    if rem(tcalc, trackInterval) == 0 
        
%         trackDepth1(trackIndex) = trackDepths(1) - sum_erosion ; 
%         trackDepth2(trackIndex) = trackDepths(2) - sum_erosion ; 
%         trackDepth3(trackIndex) = trackDepths(3) - sum_erosion ; 
%         
%         trackT1(trackIndex) = T(find(z > round(trackDepth1(trackIndex)), 1)) - 273 ;  
%         trackT2(trackIndex) = T(find(z > round(trackDepth2(trackIndex)), 1)) - 273 ;  
%         trackT3(trackIndex) = T(find(z > round(trackDepth3(trackIndex)), 1)) - 273 ;  
        
        trackDepthPTt(trackIndex,:) = trackDepths - sum_erosion ; 
%         trackDepthPTt(trackIndex,:) = trackDepths ; 
        for i = 1:length(trackDepths)
            trackT(trackIndex,i) = T(find(z > round(trackDepths(i) - sum_erosion), 1)) - 273 ;  
        end ; 

        trackIndex = trackIndex + 1 ; 
        
    end ; 
    
    %   update tracked P-T points 
    if tcalc <= plotTimes(end)
        
        if tcalc == plotTimes(trackIndexp) 

    %         trackDepth1p(trackIndexp) = trackDepths(1) - sum_erosion ; 
    %         trackDepth2p(trackIndexp) = trackDepths(2) - sum_erosion ; 
    %         trackDepth3p(trackIndexp) = trackDepths(3) - sum_erosion ; 
    %         
    %         trackT1p(trackIndexp) = T(find(z > round(trackDepth1p(trackIndexp)), 1)) - 273 ;  
    %         trackT2p(trackIndexp) = T(find(z > round(trackDepth2p(trackIndexp)), 1)) - 273 ;  
    %         trackT3p(trackIndexp) = T(find(z > round(trackDepth3p(trackIndexp)), 1)) - 273 ;  

            trackDepthPTtP(trackIndexp,:) = trackDepths - sum_erosion ; 
    %         trackDepthPTtP(trackIndexp,:) = trackDepths ; 
            for i = 1:length(trackDepths)
                trackTP(trackIndexp,i) = T(find(z > round(trackDepths(i) - sum_erosion), 1)) - 273 ;  
            end ; 

            trackIndexp = trackIndexp + 1 ; 

        end ; 
        
    end ; 
    
    Tsave(:, it) = T - 273 ; 
    
end ; 

%   UHT conditions box 
g = 9.81 ; 
zbox = ( ( Pbox .* 1e8 ) ./ ( g * rho ) ) ./ 1e3 ; 

%   Al2SiO5 polymorph phase boundaries
AndT = [ 200, 520 ] ; 
AndD = [ 0, 15 ] ; 
KyaT = [ 520, 800 ] ; 
KyaD = [ 15, 40 ]; 
SilT = [ 520, 750 ]; 
SilD = [ 15, 0 ] ; 

%   display the results 
scrsz = get(0, 'ScreenSize') ;
hfig1 = figure('OuterPosition', [1 scrsz(4)/2 scrsz(4)/2 scrsz(4)/2], 'Name', 'Heat production, lithosphere') ; 
set(gcf, 'PaperPositionMode', 'manual') ; 
set(gcf, 'PaperUnits', 'inches') ; 
set(gcf, 'PaperPosition', [ 0.25 0.25 5 5 ]) ; 

%   plot radgen profile 
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
legend('Initial', ...
       'Thickened', ...
       'Location', 'Southwest') ; 
guiPrint(hfig1, 'met1Dheatprodlith') ; 
   
%   plot geotherm 
hfig2 = figure('OuterPosition', [1 scrsz(4)/2 scrsz(4)/2 scrsz(4)/2], 'Name', 'Geotherms, lithosphere') ; 
set(gcf, 'PaperPositionMode', 'manual') ; 
set(gcf, 'PaperUnits', 'inches') ; 
set(gcf, 'PaperPosition', [ 0.25 0.25 5 5 ]) ; 

hold on ; 
plot(Tinitial, z, '-r', 'LineWidth', 1) ; 
plot(Tthickened, z, '-b', 'LineWidth', 1) ; 
plotTimesStr = {'Initial', 'Thickened'} ; 
for i = 1:size(plotTimes,2)
    plot(plotGeotherms(i, 1:numz+1), z, 'LineWidth', 1) ;
    plotTimesStr(i+2) = cellstr([ num2str(plotTimes(i)), ' Myr' ]) ;  
end ; 
plot(Tbox, zbox, '-k', 'LineWidth', 1) ; 
hold off ; 
set(gca, 'XAxisLocation', 'top') ; 
set(gca, 'YDir', 'reverse') ; 
xlabel('Temperature, ºC') ;
ylabel('Depth, km') ; 
xlim([0 1200]) ; 
ylim([0 maxz]) ; 
set(gca,'XTick', [0 500 1000 1500]) ;
yyaxis right ; 
set(gca, 'YDir', 'reverse') ;
ax = gca ; 
ax.YColor = 'k' ; 
ylabel('Pressure, kilobar') ; 
ylim([0 rho*g*maxz*1e3/1e8]) ; 
grid on ; 
box on ; 
axis square ; 
legend(plotTimesStr, 'Location', 'Southwest') ; 
guiPrint(hfig2, 'met1Dgeothermlith') ; 

%   plot P-T-t paths 
hfig3 = figure('OuterPosition', [1 scrsz(4)/2 scrsz(4)/2 scrsz(4)/2], 'Name', 'P-T-t tracks, lithosphere') ; 
set(gcf, 'PaperPositionMode', 'manual') ; 
set(gcf, 'PaperUnits', 'inches') ; 
set(gcf, 'PaperPosition', [ 0.25 0.25 5 5 ]) ; 
plotDepthsStr = {'Thickened geotherm'} ; 
hold on ; 
plot(Tthickened, z, '-b', 'LineWidth', 1) ; 
for i = 1:length(trackDepths)
    plot(trackT(:,i), trackDepthPTt(:,i), '-', 'LineWidth', 1) ; 
    plotDepthsStr(i+1) = cellstr([ 'Initial depth ', num2str(trackDepths(i)), ' km' ]) ;  
end ; 
ax = gca ; 
co = ax.ColorOrder ; 
for i = 1:length(trackDepths)
    plot(trackTP(:,i)', trackDepthPTtP(:,i)', 's', 'LineWidth', 1, ...
                'MarkerSize', 7, 'MarkerEdgeColor', co(i,:), 'MarkerFaceColor', co(i,:)) ; 
end ; 
plot(Tbox, zbox, '-k', 'LineWidth', 1) ; 
hold off ; 
set(gca, 'XAxisLocation', 'top') ; 
set(gca, 'YDir', 'reverse') ; 
xlabel('Temperature, ºC') ;
set(gca,'XTick', [0 500 1000 1500]) ;
xlim([0 1200]) ; 
ylabel('Depth, km') ; 
ylim([0 maxz]) ; 
yyaxis right ; 
ylabel('Pressure, kilobar') ; 
ylim([0 maxz*1e3*rho*g*1e-8]) ; 
set(gca, 'YDir', 'reverse') ; 
ax = gca ; 
ax.YColor = 'k' ; 
grid on ; 
box on ; 
axis square ; 
legend(plotDepthsStr, 'Location', 'Southwest') ; 
guiPrint(hfig3, 'met1DPTtlith') ; 
   
hfig4 = figure('OuterPosition', [1 scrsz(4)/2 scrsz(4)/2 scrsz(4)/2], 'Name', 'Heat production, crust') ; 
set(gcf, 'PaperPositionMode', 'manual') ; 
set(gcf, 'PaperUnits', 'inches') ; 
set(gcf, 'PaperPosition', [ 0.25 0.25 5 5 ]) ; 

%   plot radgen profile, zoomed 
hold on ; 
plot(Ainitial, z, '-r', 'LineWidth', 1.5) ; 
plot(Athickened, z, '-b', 'LineWidth', 1.5) ; 
hold off ; 
set(gca, 'XAxisLocation', 'top') ; 
set(gca, 'YDir', 'reverse') ; 
xlabel('Heat production, µWm^{-3}') ;
ylabel('Depth, km') ; 
xlim([0 10]) ; 
ylim([0 zCrust*thickFactor*1.1]) ; 
set(gca,'XTick', [0 2.5 5 7.5 10]) ;
grid on ; 
box on ; 
axis square ; 
legend('Initial', ...
       'Thickened') ; 
guiPrint(hfig4, 'met1Dheatprodcrust') ; 

%   plot geotherm, zoomed  
hfig5 = figure('OuterPosition', [1 scrsz(4)/2 scrsz(4)/2 scrsz(4)/2], 'Name', 'Geotherms, crust') ; 
set(gcf, 'PaperPositionMode', 'manual') ; 
set(gcf, 'PaperUnits', 'inches') ; 
set(gcf, 'PaperPosition', [ 0.25 0.25 5 5 ]) ; 
hold on ; 
plot(Tinitial, z, '-r', 'LineWidth', 1) ; 
plot(Tthickened, z, '-b', 'LineWidth', 1) ; 
for i = 1:size(plotTimes,2)
    plot(plotGeotherms(i, 1:numz+1), z, 'LineWidth', 1) ;
end ; 
plot(Tbox, zbox, '-k', 'LineWidth', 1) ; 
plot(AndT, AndD, ':k', 'LineWidth', 0.75) ; 
plot(KyaT, KyaD, ':k', 'LineWidth', 0.75) ; 
plot(SilT, SilD, ':k', 'LineWidth', 0.75) ; 
hold off ; 
set(gca, 'XAxisLocation', 'top') ; 
set(gca, 'YDir', 'reverse') ; 
xlabel('Temperature, ºC') ;
ylabel('Depth, km') ; 
xlim([0 1000]) ; 
ylim([0 zCrust*thickFactor*1.2]) ; 
set(gca,'XTick', [0 300 600 900 1200]) ;
yyaxis right ; 
set(gca, 'YDir', 'reverse') ; 
ax = gca ; 
ax.YColor = 'k' ; 
ylabel('Pressure, kilobar') ; 
ylim([0 rho*g*zCrust*thickFactor*1.2*1e3/1e8]) ; 
grid on ; 
box on ; 
axis square ; 
legend(plotTimesStr, 'Location', 'Southeast', 'FontSize', 8) ; 
guiPrint(hfig5, 'met1Dgeothermcrust') ; 

%   plot P-T-t paths 
hfig6 = figure('OuterPosition', [1 scrsz(4)/2 scrsz(4)/2 scrsz(4)/2], 'Name', 'P-T-t tracks, crust') ; 
set(gcf, 'PaperPositionMode', 'manual') ; 
set(gcf, 'PaperUnits', 'inches') ; 
set(gcf, 'PaperPosition', [ 0.25 0.25 5 5 ]) ; 
plotDepthsStr = {'Thickened geotherm'} ; 
hold on ; 
plot(Tthickened, z, '-b', 'LineWidth', 1) ; 
for i = 1:length(trackDepths)
    plot(trackT(:,i), trackDepthPTt(:,i), '-', 'LineWidth', 1) ; 
    plotDepthsStr(i+1) = cellstr([ 'Initial depth ', num2str(trackDepths(i)), ' km' ]) ;  
end ; 
ax = gca ; 
co = ax.ColorOrder ; 
for i = 1:length(trackDepths)
    plot(trackTP(:,i)', trackDepthPTtP(:,i)', 's', 'LineWidth', 1, ...
                'MarkerSize', 7, 'MarkerEdgeColor', co(i,:), 'MarkerFaceColor', co(i,:)) ; 
end ; 
plot(Tbox, zbox, '-k', 'LineWidth', 1) ; 
plot(AndT, AndD, ':k', 'LineWidth', 0.75) ; 
plot(KyaT, KyaD, ':k', 'LineWidth', 0.75) ; 
plot(SilT, SilD, ':k', 'LineWidth', 0.75) ; 
hold off ; 
set(gca, 'XAxisLocation', 'top') ; 
set(gca, 'YDir', 'reverse') ; 
xlabel('Temperature, ºC') ;
xlim([0 1000]) ; 
set(gca,'XTick', [0 300 600 900 1200]) ;
ylabel('Depth, km') ; 
ylim([0 zCrust*thickFactor*1.2]) ; 
yyaxis right ; 
ylabel('Pressure, kilobar') ; 
ylim([0 zCrust*thickFactor*1.2*1e3*rho*g*1e-8]) ; 
set(gca, 'YDir', 'reverse') ; 
ax = gca ; 
ax.YColor = 'k' ; 
grid on ; 
box on ; 
axis square ; 
legend(plotDepthsStr, 'Location', 'Southeast', 'FontSize', 8) ; 
guiPrint(hfig6, 'met1DPTtcrust') ; 
   
hfig7 = figure('OuterPosition', [1 scrsz(4)/2 scrsz(4)/2 scrsz(4)/2], 'Name', 'Temperature in depth and time') ; 
set(gcf, 'PaperPositionMode', 'manual') ; 
set(gcf, 'PaperUnits', 'inches') ; 
set(gcf, 'PaperPosition', [ 0.25 0.25 5 5 ]) ; 

[tAge, zDepth] = meshgrid(0:deltat:maxt, 0:deltaz:maxz) ; 

[ C, h ] = contourf(tAge, zDepth, Tsave, 0:50:1300) ; 
clabel(C, h, [900,1100]) ; 
xlabel('Time, Myr') ;
ylabel('Depth, km') ; 
cmocean('thermal') ; 
c = colorbar('Location', 'SouthOutside') ; 
xlabel(c, 'Temperature, ºC') ; 
set(gca, 'XAxisLocation', 'top') ; 
set(gca, 'YDir', 'reverse') ; 
xlim([0 120]) ; 
ylim([0 zCrust*thickFactor*1.2]) ; 
yyaxis right ; 
set(gca, 'YDir', 'reverse') ; 
ax = gca ; 
ax.YColor = 'k' ; 
ylabel('Pressure, kilobar') ; 
ylim([0 rho*g*zCrust*thickFactor*1e3/1e8]) ; 
box on ; 
guiPrint(hfig7, 'met1DPTempdepthtimecrust') ; 

hfig8 = figure('OuterPosition', [1 scrsz(4)/2 scrsz(4)/2 scrsz(4)/2], 'Name', 'Surface heat flow over time') ; 
set(gcf, 'PaperPositionMode', 'manual') ; 
set(gcf, 'PaperUnits', 'inches') ; 
set(gcf, 'PaperPosition', [ 0.25 0.25 5 5 ]) ; 
% subplot(2,1,2) ; 
plot(plotTimes, qs*1e3, '-r', 'LineWidth', 1.5) ; 
xlabel('Time, Myr') ;
ylabel('Surface heat flow, mW m^{-2}') ; 
grid on ; 
box on ; 
xlim([0 120]) ; 
ylim([0 max(qs*1e3)*1.2]) ; 
guiPrint(hfig8, 'met1DPSurfaceheatflowtime') ; 

if Lmelt > 0 
    hfig9 = figure('OuterPosition', [1 scrsz(4)/2 scrsz(4)/2 scrsz(4)/2], 'Name', 'Melting profiles') ; 
    set(gcf, 'PaperPositionMode', 'manual') ; 
    set(gcf, 'PaperUnits', 'inches') ; 
    set(gcf, 'PaperPosition', [ 0.25 0.25 5 5 ]) ; 

    hold on ; 
    for a = [-0.1, -0.01, 0.01, 0.1 ]   
        i = 0 ; 
        for Tmelt = Tmeltmin:2:Tmeltmax
            i = i + 1 ;  
            vmelt(i) = ( exp(a*Tmelt) - exp(a*Tmeltmin) ) / ( exp(a*Tmeltmax) - exp(a*Tmeltmin) ) ; 
        end ; 
        plot(Tmeltmin:2:Tmeltmax, vmelt*100, '-b', 'LineWidth', 1) ; 
    end ; 
    a = amelt ; 
    i = 0 ; 
    for Tmelt = Tmeltmin:2:Tmeltmax
        i = i + 1 ;  
        vmelt(i) = ( exp(a*Tmelt) - exp(a*Tmeltmin) ) / ( exp(a*Tmeltmax) - exp(a*Tmeltmin) ) ; 
    end ; 
    plot(Tmeltmin:2:Tmeltmax, vmelt*100, '-g', 'LineWidth', 2) ; 
    plot([Tmeltmin, Tmeltmin], [0, 100], 'r', 'LineWidth', 1) ; 
    plot([Tmeltmax, Tmeltmax], [0, 100], 'r', 'LineWidth', 1) ; 
    hold off ; 
    xlabel('Temperature, ºC') ;
    ylabel('Melt fraction, %') ; 
    xlim([Tmeltmin-50 Tmeltmax+50]) ; 
    ylim([0 100]) ; 
    grid on ; 
    box on ; 
    guiPrint(hfig9, 'met1Dmeltingcurve') ; 
end ; 

disp(' ') ; 
disp('*** ...finished HC10merge_gui.m') ; 
disp(' ') ; 

rc = 0 ; 
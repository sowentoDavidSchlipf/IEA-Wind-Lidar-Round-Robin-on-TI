% Make comparasion between the LOS and the Mast measurement

% Project: IEA Wind Task 32
% Initiative for Round Robin on turbulence estimates 
% from nacelle mounted Lidar systems

% by Feng Guo @ Flensburg University of Applied Sciences
% 30 Nov. 2021

clear all
close all
clc

addpath('functions')

LOS2_name = 'Lidar_20200903-20200904_1Hz_LOS2_178m.csv';
LOS3_name = 'Lidar_20200903-20200904_1Hz_LOS3_178m.csv';
Mast_N_name   = 'TMMN_20200903_20200904_1Hz_new.csv';
Mast_S_name   = 'TMMS_20200903_20200904_1Hz_new.csv';

% read in the data set
LOS2_data   = readtable(LOS2_name);
LOS3_data   = readtable(LOS3_name);
Mast_N_data = readtable(Mast_N_name);
Mast_S_data = readtable(Mast_S_name);


%% 1. Calculate the coordinate
% the coordinate of the towers in UTM 32U, obtained by Google Earth
Coordinate.Mast_N = [520372.04,6054570.53,30];   % easting, northing and height above ground
Coordinate.Mast_S = [520433.32,6054465.54,30];   % easting, northing and height above ground
Coordinate.Lidar  = [520556.20,6054609.75,30];   % easting, northing and height above ground

Coordinate.Mast_N = Coordinate.Mast_N-[520000,6054000.53,0];   % -[520000,6054000.53,0]  Just to reduce number digits
Coordinate.Mast_S = Coordinate.Mast_S-[520000,6054000.53,0];   % -[520000,6054000.53,0]  Just to reduce number digits
Coordinate.Lidar  = Coordinate.Lidar-[520000,6054000.53,0];    % -[520000,6054000.53,0]  Just to reduce number digits

% the mid point between two mast towers, assume the lidar aligns towards the middle perpendicular line of the two towers
Coordinate.MidOfMast = Coordinate.Mast_N+0.5*(Coordinate.Mast_S-Coordinate.Mast_N);
[Coordinate.LidarYaw,~,~]  =  cart2sph(Coordinate.MidOfMast(1)-Coordinate.Lidar(1),Coordinate.MidOfMast(2)-Coordinate.Lidar(2),Coordinate.MidOfMast(3)-Coordinate.Lidar(3));

% the coordinate of LOS position in Lidar coordinate system
VOH                     = deg2rad(5);
HOH                     = deg2rad(15);
Elevation               = [-1  -1]*atan(tan(VOH)/sqrt(1+tan(HOH)^2));
Azimuth                 = [1  -1]*HOH;
[Coordinate.LOS(1,:),~,~]= sph2cart(Azimuth,Elevation,[100 100]);   % get a rough x y z, assuming r = 100
[Coordinate.LOS(1,:),Coordinate.LOS(2,:),Coordinate.LOS(3,:)]         = sph2cart(Azimuth,Elevation,[178/Coordinate.LOS(1,1)*100 178/Coordinate.LOS(1,2)*100]);  % just to get the coordinate at gate 178m

% make a shift to convert it into the inertial system, so that the lidar stands at the position of lidar tower
Coordinate.LOS(:,1)     = Coordinate.LOS(:,1)+Coordinate.Lidar';
Coordinate.LOS(:,2)     = Coordinate.LOS(:,2)+Coordinate.Lidar';

% rotate according to the lidar orientation
Coordinate.LOS(:,1)    = AxelRot(Coordinate.LOS(:,1),-5, [0 1 0], Coordinate.Lidar);
Coordinate.LOS(:,2)    = AxelRot(Coordinate.LOS(:,2),-5, [0 1 0], Coordinate.Lidar);
Coordinate.LOS(:,1)    = AxelRot(Coordinate.LOS(:,1),rad2deg(Coordinate.LidarYaw), [0 0 1], Coordinate.Lidar);
Coordinate.LOS(:,2)    = AxelRot(Coordinate.LOS(:,2),rad2deg(Coordinate.LidarYaw), [0 0 1], Coordinate.Lidar);


% show the lidar and mast tower geometry
figure('Name','Coordinates')
plot3(Coordinate.Mast_N(1),Coordinate.Mast_N(2),Coordinate.Mast_N(3),'o')
hold on
scatter3(Coordinate.Mast_S(1),Coordinate.Mast_S(2),Coordinate.Mast_S(3),'o')
scatter3(Coordinate.Lidar(1), Coordinate.Lidar(2),Coordinate.Lidar(3),'^')
plot3([Coordinate.MidOfMast(1) Coordinate.Lidar(1)],[Coordinate.MidOfMast(2) Coordinate.Lidar(2)],[Coordinate.MidOfMast(3) Coordinate.Lidar(3)],'-')
plot3([Coordinate.Lidar(1) Coordinate.LOS(1,1)],[Coordinate.Lidar(2) Coordinate.LOS(2,1)],[Coordinate.Lidar(3) Coordinate.LOS(3,1)],'r:')
plot3([Coordinate.Lidar(1) Coordinate.LOS(1,2)],[Coordinate.Lidar(2) Coordinate.LOS(2,2)],[Coordinate.Lidar(3) Coordinate.LOS(3,2)],'r--')
axis equal
xlabel('x [m]')
ylabel('y [m]')
zlabel('z [m]')
legend('Mast N','Mast S','Lidar', 'Lidar Directon','LOS 3','LOS 2')


%% 2. Process the cup measurements at two towers and check the agreements

% first Convert the lidar recorded time to num based, so that it agrees with the mast
Time_MAST_N = datenum(Mast_N_data.TIMESTAMP);
Time_MAST_S = datenum(Mast_S_data.TIMESTAMP);

Time_LOS3   = zeros(length(LOS3_data.Timestamp),1);
%¡¡remove some unnecessary charactors from the string
for i = 1:length(LOS3_data.Timestamp)
    temp = strrep(LOS3_data.Timestamp(i),'T',' ');
    temp = temp{1}(1:end-6);
    Time_LOS3(i) = datenum(temp);
end

Time_LOS2   = zeros(length(LOS3_data.Timestamp),1);
for i = 1:length(LOS2_data.Timestamp)
    temp = strrep(LOS2_data.Timestamp(i),'T',' ');
    temp = temp{1}(1:end-6);
    Time_LOS2(i) = datenum(temp);
end


% before go to next step, check whe the two masts agree with each other
figure('Name','Mast Wind Direction')
subplot(2,2,1)
hold on
plot(sqrt(Mast_S_data.USA_U.^2+Mast_S_data.USA_V.^2))
plot(Mast_S_data.WS1)
title('South Mast: uv magnitude')
legend('Sonic','Cup')

subplot(2,2,2)
hold on
plot(sqrt(Mast_N_data.USA_U.^2+Mast_N_data.USA_V.^2))
plot(Mast_N_data.WS1)
title('North Mast: uv magnitude')
legend('Sonic','Cup')

subplot(2,2,3)
hold on
plot(Mast_S_data.USA_WD)
plot(Mast_S_data.WD1)
title('South Mast: direction')
legend('Sonic','Cup')

subplot(2,2,4)
hold on
plot(Mast_N_data.USA_WD)
plot(Mast_N_data.WD1)
title('North Mast: direction')
legend('Sonic','Cup')

% Convert wind speed to north-south  west-east based, the Wind direction is 0deg if it blows from north,
% and it is 180 deg if it belows from south
Mast_S_Sonic_WE        = -sqrt(Mast_S_data.USA_U.^2+Mast_S_data.USA_V.^2).*sind(Mast_S_data.USA_WD);  % the south cup wind component projected into WE direction (geographical)
Mast_S_Sonic_SN        = -sqrt(Mast_S_data.USA_U.^2+Mast_S_data.USA_V.^2).*cosd(Mast_S_data.USA_WD);  % the south cup wind component projected into SN direction (geographical)

Mast_N_Sonic_WE        = -sqrt(Mast_N_data.USA_U.^2+Mast_N_data.USA_V.^2).*sind(Mast_N_data.USA_WD);
Mast_N_Sonic_SN        = -sqrt(Mast_N_data.USA_U.^2+Mast_N_data.USA_V.^2).*cosd(Mast_N_data.USA_WD);

Mast_S_Cup30m_WE       = -Mast_S_data.WS1.*sind(Mast_S_data.WD1);
Mast_S_Cup30m_SN       = -Mast_S_data.WS1.*cosd(Mast_S_data.WD1);

Mast_N_Cup30m_WE       = -Mast_N_data.WS1.*sind(Mast_N_data.WD1);
Mast_N_Cup30m_SN       = -Mast_N_data.WS1.*cosd(Mast_N_data.WD1);


figure('Name','Mast Wind Speeds')
subplot(3,2,1)
hold on
plot(Mast_S_Sonic_WE)
plot(Mast_S_Cup30m_WE)
title('Mast S Sonic vs Cup  speed in WE direction')

subplot(3,2,2)
hold on
plot(Mast_N_Sonic_WE)
plot(Mast_N_Cup30m_WE)
title('Mast N Sonic vs Cup  speed in WE direction')

subplot(3,2,3)
hold on
plot(Mast_S_Sonic_SN)
plot(Mast_S_Cup30m_SN)
title('Mast S Sonic vs Cup  speed in SN direction')

subplot(3,2,4)
hold on
plot(Mast_N_Sonic_SN)
plot(Mast_N_Cup30m_SN)
title('Mast S Sonic vs Cup  speed in SN direction')

subplot(3,2,5)
hold on
plot(Mast_N_Cup30m_SN)
plot(Mast_S_Cup30m_SN)
title('Mast cup S vs Mast cup N  speed in SN direction')

subplot(3,2,6)
hold on
plot(Mast_N_Cup30m_WE)
plot(Mast_S_Cup30m_WE)
title('Mast cup S vs Mast cup N  speed in WE direction')


%% 3. Calculate LOS from Mast and make comparasion with Lidar
LOS2_data.RWS(LOS2_data.RWS>25)=nan;   % remove the strange values
LOS3_data.RWS(LOS3_data.RWS>25)=nan;

% the lida beam unit vectors 2 means beam 2...
LidarUnitVector2 = [-Coordinate.Lidar(1)+Coordinate.LOS(1,1) -Coordinate.Lidar(2)+Coordinate.LOS(2,1) -Coordinate.Lidar(3)+Coordinate.LOS(3,1)];
LidarUnitVector2 = -LidarUnitVector2'/norm(LidarUnitVector2);
LidarUnitVector3 = [-Coordinate.Lidar(1)+Coordinate.LOS(1,2) -Coordinate.Lidar(2)+Coordinate.LOS(2,2) -Coordinate.Lidar(3)+Coordinate.LOS(3,2)];
LidarUnitVector3 = -LidarUnitVector3'/norm(LidarUnitVector3);

% cup LOS
LOS_mast_Sonic_S       = [Mast_S_Sonic_WE,Mast_S_Sonic_SN,Mast_S_data.USA_W]*LidarUnitVector2;
LOS_mast_Sonic_N       = [Mast_N_Sonic_WE,Mast_N_Sonic_SN,Mast_N_data.USA_W]*LidarUnitVector3;
LOS_mast_Cup30m_S      = [Mast_S_Cup30m_WE,Mast_S_Cup30m_SN,zeros(size(Mast_S_Cup30m_WE))]*LidarUnitVector2;
LOS_mast_Cup30m_N      = [Mast_N_Cup30m_WE,Mast_N_Cup30m_SN,zeros(size(Mast_N_Cup30m_WE))]*LidarUnitVector3;


Time_LOS2                  = Time_LOS3;
LOS2_data.RWS(end+1:end+2) = nan;    % just to make the data same length

MastTimeStart_N          = find(Time_MAST_N>=datenum('2020-09-03 19:00:00'),1);
MastTimeEnd_N            = length(Time_MAST_N); %find(Time_MAST_N>=Time_LOS2(end),1);
MastTimeStart_S          = find(Time_MAST_S>=datenum('2020-09-03 19:00:00'),1);
MastTimeEnd_S            = length(Time_MAST_S)-1;  %find(Time_MAST_S>=Time_LOS2(end),1);

% remove some time steps that the lidar and cups are not working at the same time
Time_MAST_S              = Time_MAST_S(MastTimeStart_S:MastTimeEnd_S);
Time_MAST_N              = Time_MAST_N(MastTimeStart_N:MastTimeEnd_N);
LOS_mast_Sonic_S         = LOS_mast_Sonic_S(MastTimeStart_S:MastTimeEnd_S);
LOS_mast_Cup30m_S        = LOS_mast_Cup30m_S(MastTimeStart_S:MastTimeEnd_S);
LOS_mast_Sonic_N         = LOS_mast_Sonic_N(MastTimeStart_N:MastTimeEnd_N);
LOS_mast_Cup30m_N        = LOS_mast_Cup30m_N(MastTimeStart_N:MastTimeEnd_N);
WD_mast_Sonic_S          = Mast_S_data.USA_WD(MastTimeStart_S:MastTimeEnd_S);
WD_mast_Sonic_N          = Mast_N_data.USA_WD(MastTimeStart_N:MastTimeEnd_N);
WD_mast_Cup30m_S         = Mast_S_data.WD1(MastTimeStart_S:MastTimeEnd_S);
WD_mast_Cup30m_N         = Mast_N_data.WD1(MastTimeStart_N:MastTimeEnd_N);
Mast_S_Sonic_WE          = Mast_S_Sonic_WE(MastTimeStart_S:MastTimeEnd_S);
Mast_S_Sonic_SN          = Mast_S_Sonic_SN(MastTimeStart_S:MastTimeEnd_S);
Mast_N_Sonic_WE          = Mast_N_Sonic_WE(MastTimeStart_N:MastTimeEnd_N);
Mast_N_Sonic_SN          = Mast_N_Sonic_SN(MastTimeStart_N:MastTimeEnd_N);
Mast_S_Cup30m_WE         = Mast_S_Cup30m_WE(MastTimeStart_S:MastTimeEnd_S);
Mast_S_Cup30m_SN         = Mast_S_Cup30m_SN(MastTimeStart_S:MastTimeEnd_S);
Mast_N_Cup30m_WE         = Mast_N_Cup30m_WE(MastTimeStart_N:MastTimeEnd_N);
Mast_N_Cup30m_SN         = Mast_N_Cup30m_SN(MastTimeStart_N:MastTimeEnd_N);



figure('Name','Mast LOS')
subplot(2,2,1)
hold on
plot(Time_MAST_S,LOS_mast_Sonic_S)
plot(Time_LOS2,LOS2_data.RWS)
title('LOS by Sonic at South vs Lidar ')

subplot(2,2,2)
hold on
plot(Time_MAST_S,LOS_mast_Cup30m_S)
plot(Time_LOS2,LOS2_data.RWS)
title('LOS by Cup at South vs Lidar ')

subplot(2,2,3)
hold on
hold on
plot(Time_MAST_N,LOS_mast_Sonic_N)
plot(Time_LOS3,LOS3_data.RWS)
title('LOS by Sonic at North vs Lidar ')

subplot(2,2,4)
hold on
plot(Time_MAST_N,LOS_mast_Cup30m_N)
plot(Time_LOS3,LOS3_data.RWS)
title('LOS by Cup at North vs Lidar ')



%% 4.Now start processing 10min statistic

NumberofSet_10min_Lidar = unique([size(LOS2_data,1) size(LOS3_data,1)])/150; % 4s per measurement
NumberofSet_10min_Mast  = unique([size(LOS_mast_Cup30m_S,1) size(LOS_mast_Cup30m_N,1)])/600;  % 1 second per measurement


LOS2_10min_mean              = zeros(NumberofSet_10min_Lidar,1);
LOS3_10min_mean              = zeros(NumberofSet_10min_Lidar,1);
LOS2_10min_var               = zeros(NumberofSet_10min_Lidar,1);
LOS3_10min_var               = zeros(NumberofSet_10min_Lidar,1);

LOS_South_Cup_10min_mean     = zeros(NumberofSet_10min_Mast,1);
LOS_North_Cup_10min_mean     = zeros(NumberofSet_10min_Mast,1);
LOS_South_Sonic_10min_mean   = zeros(NumberofSet_10min_Mast,1);
LOS_North_Sonic_10min_mean   = zeros(NumberofSet_10min_Mast,1);
LOS_South_Cup_10min_var      = zeros(NumberofSet_10min_Mast,1);
LOS_North_Cup_10min_var      = zeros(NumberofSet_10min_Mast,1);
LOS_South_Sonic_10min_var    = zeros(NumberofSet_10min_Mast,1);
LOS_North_Sonic_10min_var    = zeros(NumberofSet_10min_Mast,1);

u_South_Cup_10min_mean       = zeros(NumberofSet_10min_Mast,1);
u_South_Sonic_10min_mean     = zeros(NumberofSet_10min_Mast,1);
v_North_Cup_10min_mean       = zeros(NumberofSet_10min_Mast,1);
v_North_Sonic_10min_mean     = zeros(NumberofSet_10min_Mast,1);
WD_South_Cup_10min_mean      = zeros(NumberofSet_10min_Mast,1);
WD_South_Sonic_10min_mean    = zeros(NumberofSet_10min_Mast,1);
WD_North_Cup_10min_mean      = zeros(NumberofSet_10min_Mast,1);
WD_North_Sonic_10min_mean    = zeros(NumberofSet_10min_Mast,1);
WD_Lidar_10min_mean          = zeros(NumberofSet_10min_Mast,1);

u_South_Cup_10min_std        = zeros(NumberofSet_10min_Mast,1);
u_South_Sonic_10min_std      = zeros(NumberofSet_10min_Mast,1);
v_South_Cup_10min_std        = zeros(NumberofSet_10min_Mast,1);
v_South_Sonic_10min_std      = zeros(NumberofSet_10min_Mast,1);

u_South_Cup                  = zeros(size(LOS_mast_Cup30m_S));
u_South_Sonic                = zeros(size(LOS_mast_Cup30m_S));
v_South_Cup                  = zeros(size(LOS_mast_Cup30m_S));
v_South_Sonic                = zeros(size(LOS_mast_Cup30m_S));



BufferLidar             = 1:150;
BufferMast              = 1:600;
for it = 1:NumberofSet_10min_Lidar
    LOS2_10min_mean(it) = nanmean(LOS2_data.RWS(BufferLidar));
    LOS3_10min_mean(it) = nanmean(LOS3_data.RWS(BufferLidar));
    LOS2_10min_var(it)  = nanvar(LOS2_data.RWS(BufferLidar));
    LOS3_10min_var(it)  = nanvar(LOS3_data.RWS(BufferLidar));
    BufferLidar = BufferLidar+150;
end

for it = 1:NumberofSet_10min_Mast
    LOS_South_Cup_10min_mean(it)   = nanmean(LOS_mast_Cup30m_S(BufferMast));
    LOS_North_Cup_10min_mean(it)   = nanmean(LOS_mast_Cup30m_N(BufferMast));
    LOS_South_Sonic_10min_mean(it) = nanmean(LOS_mast_Sonic_S(BufferMast));
    LOS_North_Sonic_10min_mean(it) = nanmean(LOS_mast_Sonic_N(BufferMast));
    LOS_South_Cup_10min_var(it)    = nanvar(LOS_mast_Cup30m_S(BufferMast));
    LOS_North_Cup_10min_var(it)    = nanvar(LOS_mast_Cup30m_N(BufferMast));
    LOS_South_Sonic_10min_var(it)  = nanvar(LOS_mast_Sonic_S(BufferMast));
    LOS_North_Sonic_10min_var(it)  = nanvar(LOS_mast_Sonic_N(BufferMast));
    WD_South_Cup_10min_mean(it)        = windir_avg(WD_mast_Cup30m_S(BufferMast));
    WD_South_Sonic_10min_mean(it)      = windir_avg(WD_mast_Sonic_S(BufferMast));
    WD_North_Cup_10min_mean(it)        = windir_avg(WD_mast_Cup30m_N(BufferMast));
    WD_North_Sonic_10min_mean(it)      = windir_avg(WD_mast_Sonic_N(BufferMast));
    u_South_Cup(BufferMast)            = -Mast_S_Cup30m_WE(BufferMast).*sind(WD_South_Cup_10min_mean(it))...
                                         -Mast_S_Cup30m_SN(BufferMast).*cosd(WD_South_Cup_10min_mean(it));

    v_South_Cup(BufferMast)            = Mast_S_Cup30m_WE(BufferMast).*cosd(WD_South_Cup_10min_mean(it))...
                                         -Mast_S_Cup30m_SN(BufferMast).*sind(WD_South_Cup_10min_mean(it));

    
    BufferMast = BufferMast+600;
end


% 2 for south  3 for north
figure('Name','LOS 10min mean Regression')
subplot(2,2,1)
hold on
scatter_kde(LOS_South_Cup_10min_mean,LOS2_10min_mean, 'filled', 'MarkerSize', 10)
range = [0 10];
plot(range,range,'k','linewidth',2)
[c,a,b,~,regression_string,...
    ~,N_string] = Goodness_Of_Fit_0(LOS_South_Cup_10min_mean,LOS2_10min_mean,'linear');
plot(range,a*range+b,'r','linewidth',2)
title('10min mean LOS by cup at South vs Lidar ')
text(5,1,['$R^2$ =' num2str(round(c,2))],'fontsize',12,'Interpreter','latex')
text(5,2,N_string,'fontsize',12)
legend('Scatter','y = x',regression_string,'location','northwest')
xlabel('cup South')
ylabel('lidar LOS2')


subplot(2,2,2)
hold on
scatter_kde(LOS_North_Cup_10min_mean,LOS3_10min_mean, 'filled', 'MarkerSize', 10)
range = [0 10];
plot(range,range,'k','linewidth',2)
[c,a,b,~,regression_string,...
    ~,N_string] = Goodness_Of_Fit_0(LOS_North_Cup_10min_mean,LOS3_10min_mean,'linear');
plot(range,a*range+b,'r','linewidth',2)
title('10min mean LOS by cup at North vs Lidar ')
text(5,1,['$R^2$ =' num2str(round(c,2))],'fontsize',12,'Interpreter','latex')
text(5,2,N_string,'fontsize',12)
legend('Scatter','y = x',regression_string,'location','northwest')
xlabel('cup North')
ylabel('lidar LOS3')

subplot(2,2,3)
hold on
scatter_kde(LOS_South_Sonic_10min_mean,LOS2_10min_mean, 'filled', 'MarkerSize', 10)
range = [0 10];
plot(range,range,'k','linewidth',2)
[c,a,b,~,regression_string,...
    ~,N_string] = Goodness_Of_Fit_0(LOS_South_Sonic_10min_mean,LOS2_10min_mean,'linear');
plot(range,a*range+b,'r','linewidth',2)
title('10min mean LOS by sonic at South vs Lidar ')
text(5,1,['$R^2$ =' num2str(round(c,2))],'fontsize',12,'Interpreter','latex')
text(5,2,N_string,'fontsize',12)
legend('Scatter','y = x',regression_string,'location','northwest')
xlabel('sonic South')
ylabel('lidar LOS2')

subplot(2,2,4)
hold on
scatter_kde(LOS_North_Sonic_10min_mean,LOS3_10min_mean, 'filled', 'MarkerSize', 10)
range = [0 10];
plot(range,range,'k','linewidth',2)
[c,a,b,~,regression_string,...
    ~,N_string] = Goodness_Of_Fit_0(LOS_North_Sonic_10min_mean,LOS3_10min_mean,'linear');
plot(range,a*range+b,'r','linewidth',2)
title('10min mean LOS by sonic at North vs Lidar ')
text(5,1,['$R^2$ =' num2str(round(c,2))],'fontsize',12,'Interpreter','latex')
text(5,2,N_string,'fontsize',12)
legend('Scatter','y = x',regression_string,'location','northwest')
xlabel('sonic South')
ylabel('lidar LOS3')


% 2 for south  3 for north
figure('Name','LOS 10min var Regression')
subplot(2,2,1)
hold on
scatter_kde(LOS_South_Cup_10min_var,LOS2_10min_var, 'filled', 'MarkerSize', 10)
range = [0 10];
plot(range,range,'k','linewidth',2)
[c,a,b,~,regression_string,...
    ~,N_string] = Goodness_Of_Fit_0(LOS_South_Cup_10min_var,LOS2_10min_var,'linear');
plot(range,a*range+b,'r','linewidth',2)
title('10min var LOS by cup at South vs Lidar ')
text(5,1,['$R^2$ =' num2str(round(c,2))],'fontsize',12,'Interpreter','latex')
text(5,2,N_string,'fontsize',12)
legend('Scatter','y = x',regression_string,'location','northwest')
xlabel('cup South')
ylabel('lidar LOS2')

subplot(2,2,2)
hold on
scatter_kde(LOS_North_Cup_10min_var,LOS3_10min_var, 'filled', 'MarkerSize', 10)
range = [0 10];
plot(range,range,'k','linewidth',2)
[c,a,b,~,regression_string,...
    ~,N_string] = Goodness_Of_Fit_0(LOS_North_Cup_10min_var,LOS3_10min_var,'linear');
plot(range,a*range+b,'r','linewidth',2)
title('10min var LOS by cup at North vs Lidar ')
text(5,1,['$R^2$ =' num2str(round(c,2))],'fontsize',12,'Interpreter','latex')
text(5,2,N_string,'fontsize',12)
legend('Scatter','y = x',regression_string,'location','northwest')
xlabel('sonic north')
ylabel('lidar LOS2')

subplot(2,2,3)
hold on
scatter_kde(LOS_South_Sonic_10min_var,LOS2_10min_var, 'filled', 'MarkerSize', 10)
range = [0 10];
plot(range,range,'k','linewidth',2)
[c,a,b,~,regression_string,...
    ~,N_string] = Goodness_Of_Fit_0(LOS_South_Sonic_10min_var,LOS2_10min_var,'linear');
plot(range,a*range+b,'r','linewidth',2)
title('10min var LOS by sonic at South vs Lidar ')
text(5,1,['$R^2$ =' num2str(round(c,2))],'fontsize',12,'Interpreter','latex')
text(5,2,N_string,'fontsize',12)
legend('Scatter','y = x',regression_string,'location','northwest')
xlabel('cup South')
ylabel('lidar LOS2')

subplot(2,2,4)
hold on
scatter_kde(LOS_North_Sonic_10min_var,LOS3_10min_var, 'filled', 'MarkerSize', 10)
range = [0 10];
plot(range,range,'k','linewidth',2)
[c,a,b,~,regression_string,...
    ~,N_string] = Goodness_Of_Fit_0(LOS_North_Sonic_10min_var,LOS3_10min_var,'linear');
plot(range,a*range+b,'r','linewidth',2)
title('10min var LOS by sonic at North vs Lidar ')
text(5,1,['$R^2$ =' num2str(round(c,2))],'fontsize',12,'Interpreter','latex')
text(5,2,N_string,'fontsize',12)
legend('Scatter','y = x',regression_string,'location','northwest')
xlabel('sonic North')
ylabel('lidar LOS3')



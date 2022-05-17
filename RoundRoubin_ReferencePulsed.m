% Calculate Reference TI
% Project: IEA Wind Task 32
% Round Robin on turbulence estimates from nacelle mounted lidar systems
% by Feng Guo and David Schlipf @ Flensburg University of Applied Sciences
% v6: 17-May-2022: projection using angles from optimization
% v5: 07-May-2022: projection using angles provided by DNV, not via
%                   coordinates, add TI, nicer comparison 
% v4: 11-Apr-2022: add new data
% v3: 10-Apr-2022: store data to speed up 2nd run 
% v2: 14-Mar-2022: modular setup
% v1: 30-Nov-2021: initial version

clearvars;clc;close all
addpath('functions')

%% Calculate and plot coordinates
Coordinate      =  CalculateCoordinate;
PlotCoordinate(Coordinate)

%% Load Data and compare Sonic Cup and Vane
if isfile('Data.mat') % datenum takes a while, so we better store the data
    load('Data.mat','Mast_N','Mast_S','Lidar_N','Lidar_S');
else 
    Mast_N          = readtable('TMMN_20200903_20200904_1Hz_new.csv'); % lines 14704-14707 with text removed 
    Mast_S          = readtable('TMMS_20200903_20200904_1Hz_new.csv'); % lines 14704-14707 with text removed 
    Lidar_N        	= readtable('Lidar_20200903-20200904_1Hz_LOS3_178m.csv');
    Lidar_S       	= readtable('Lidar_20200903-20200904_1Hz_LOS2_178m.csv');
    % remove double entries 
    [~,IdxUnique,~] = unique(Mast_S.TIMESTAMP);
    Mast_S          = Mast_S(IdxUnique,:);  
    % add numeric time
    Mast_N.t      	= datenum(Mast_N.TIMESTAMP);
    Mast_S.t     	= datenum(Mast_S.TIMESTAMP);
    Lidar_N.t     	= datenum(Lidar_N.Timestamp,'yyyy-mm-ddTHH:MM:SS.FFF');
    Lidar_S.t      	= datenum(Lidar_S.Timestamp,'yyyy-mm-ddTHH:MM:SS.FFF');
    save('Data.mat','Mast_N','Mast_S','Lidar_N','Lidar_S');
end

% Remove manually some outliers for cup and interpolate
GoodData            = [1:82155,82210:82260,82310:86400];% identified using cursor
Mast_N.WS1          = interp1(Mast_N.t(GoodData),Mast_N.WS1(GoodData),Mast_N.t);

% limits only for time plots
Tstart          = '2020-09-04 08:00:00'; 
Tend            = '2020-09-04 10:00:00';
CompareSonicToCupAndVane(Mast_S,Mast_N,Tstart,Tend);

%% Calculate reference U (wind in x: W->E), V (wind in y: S->N)
Yaw_N             	= 270-Mast_N.USA_WD;
Yaw_S              	= 270-Mast_S.USA_WD;
Reference.U_N    	= Mast_N.WS1.*cosd(Yaw_N);
Reference.V_N     	= Mast_N.WS1.*sind(Yaw_N);
Reference.U_S      	= Mast_S.WS1.*cosd(Yaw_S);
Reference.V_S     	= Mast_S.WS1.*sind(Yaw_S);
Reference.t         = Mast_N.t; % should be the same for N and S
Reference.WS_N      = Mast_N.WS1;
Reference.WS_S      = Mast_S.WS1;
Reference.WD_N      = Mast_N.USA_WD;
Reference.WD_S      = Mast_S.USA_WD;

%% Calculate reference LOS=-(xu+yv+zw)
% angles of lidar beams in inertial coordinate system, see BruteForceOptimizationLidarDirection.m 
Yaw_L_N             = 270-250.2; 
Yaw_L_S             = 270-221.8;
% measurement equation: ignoring w
Reference.LOS_N    	= cosd(Yaw_L_N)*Reference.U_N + sind(Yaw_L_N)*Reference.V_N;
Reference.LOS_S    	= cosd(Yaw_L_S)*Reference.U_S + sind(Yaw_L_S)*Reference.V_S;

%% get 10 min mean for reference 
Tstart          = '2020-09-03 19:00:00';
Tend            = '2020-09-04 19:00:00';
Reference_10min = Calculate10minStastics_Reference(Reference,Tstart,Tend);

%% get 10 min reference TI
Reference_10min.LOS_TI_N = Reference_10min.LOS_N_std./Reference_10min.LOS_N_mean;
Reference_10min.LOS_TI_S = Reference_10min.LOS_S_std./Reference_10min.LOS_S_mean;
Reference_10min.TI_N     = Reference_10min.WS_N_std./ Reference_10min.WS_N_mean;
Reference_10min.TI_S     = Reference_10min.WS_S_std./ Reference_10min.WS_S_mean;
WriteReferenceFile(Reference_10min,'ReferencePulsed.csv')
CompareNS(Reference_10min)

%% Calculate Statistics Lidar
% remove data with error code
BadData_N             	= Lidar_N.Distance==9999;
Lidar_N.RWS(BadData_N)  = interp1(Lidar_N.t(~BadData_N),Lidar_N.RWS(~BadData_N),Lidar_N.t(BadData_N));
BadData_S            	= Lidar_S.Distance==9999;
Lidar_S.RWS(BadData_S)	= interp1(Lidar_S.t(~BadData_S),Lidar_S.RWS(~BadData_S),Lidar_S.t(BadData_S));
% Calculate 10 min statistics
Lidar_10min             = Calculate10minStastics_Lidar(Lidar_N,Lidar_S,Tstart,Tend); 
% Calculate 10 min TI
Lidar_10min.LOS_TI_N    = Lidar_10min.LOS_N_std./Lidar_10min.LOS_N_mean;
Lidar_10min.LOS_TI_S    = Lidar_10min.LOS_S_std./Lidar_10min.LOS_S_mean;
% compare lidar vs Reference
CompareLOS(Reference_10min,Lidar_10min)
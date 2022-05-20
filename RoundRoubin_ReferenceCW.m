% Calculate Reference TI for CW lidar
% Project: IEA Wind Task 32
% Round Robin on turbulence estimates from nacelle mounted lidar systems
% by Feng Guo and David Schlipf @ Flensburg University of Applied Sciences
% v2: 20-May-2022, DS: improve lidar data processing 
% v1: 17-May-2022, DS: initial version based on pulsed code

clearvars;clc;close all
addpath('functions')

%% Calculate and plot coordinates
% nice to have

%% Load Data and compare Sonic Cup and Vane
if isfile('Data_CW_Period1.mat') % datenum takes a while, so we better store the data
    load('Data_CW_Period1.mat','Mast_N','Mast_S','Lidar_N_raw','Lidar_S_raw');
else 
    Mast_N          = readtable('T-MM-N_20170216_20170217_1Hz.csv'); 
    Mast_S          = readtable('T-MM-S_20170216_20170217_1Hz.csv'); 
    Lidar_N_raw   	= readtable('Raw_351@20170216_20170217_filtered_without_FFTbins_right_sector.csv');
    Lidar_S_raw   	= readtable('Raw_351@20170216_20170217_filtered_without_FFTbins_left_sector.csv');
    % add numeric time
    Mast_N.t      	= datenum(Mast_N.TIMESTAMP);
    Mast_S.t     	= datenum(Mast_S.TIMESTAMP);
    save('Data_CW_Period1.mat','Mast_N','Mast_S','Lidar_N_raw','Lidar_S_raw');
end

% Data correction
Mast_N.WD1        	= mod(Mast_N.WD1-34 , 360);
Mast_S.WD1      	= mod(Mast_S.WD1+148.1 , 360);
Mast_N.USA_WD       = mod(-(atan2(-Mast_N.USA_U,Mast_N.USA_V)*180/pi)+90+119.5,360);
Mast_S.USA_WD       = mod(-(atan2(-Mast_S.USA_U,Mast_S.USA_V)*180/pi)+90+298.1,360);

% limits only for time plots
Tstart          = '2017-02-16 04:00:00'; 
Tend            = '2017-02-17 04:00:00';
range_MEAN      = [0 20];
range_WD        = [160 300];
CompareSonicToCupAndVane(Mast_S,Mast_N,Tstart,Tend,range_MEAN,range_WD);

%% Calculate reference U (wind in x: W->E), V (wind in y: S->N)
Yaw_N             	= 270-Mast_N.USA_WD;
Yaw_S              	= 270-Mast_S.USA_WD;
Reference.U_N    	= Mast_N.WS1.*cosd(Yaw_N);
Reference.V_N     	= Mast_N.WS1.*sind(Yaw_N);
Reference.U_S      	= Mast_S.WS1.*cosd(Yaw_S);
Reference.V_S     	= Mast_S.WS1.*sind(Yaw_S);
Reference.t_N       = Mast_N.t; 
Reference.t_S       = Mast_S.t; 
Reference.WS_N      = Mast_N.WS1;
Reference.WS_S      = Mast_S.WS1;
Reference.WD_N      = Mast_N.USA_WD;
Reference.WD_S      = Mast_S.USA_WD;

%% Calculate reference LOS=-(xu+yv+zw)
% angles of lidar beams in inertial coordinate system, see BruteForceOptimizationLidarDirection.m 
Yaw_L_N             = 270-254.8; 
Yaw_L_S             = 270-232.2;
% measurement equation: ignoring w
Reference.LOS_N    	= cosd(Yaw_L_N)*Reference.U_N + sind(Yaw_L_N)*Reference.V_N;
Reference.LOS_S    	= cosd(Yaw_L_S)*Reference.U_S + sind(Yaw_L_S)*Reference.V_S;

%% get 10 min mean for reference 
Tstart          = '2017-02-16 04:00:00'; 
Tend            = '2017-02-17 04:00:00';
Reference_10min = Calculate10minStastics_Reference(Reference,Tstart,Tend);

%% get 10 min reference TI
Reference_10min.LOS_TI_N = Reference_10min.LOS_N_std./Reference_10min.LOS_N_mean;
Reference_10min.LOS_TI_S = Reference_10min.LOS_S_std./Reference_10min.LOS_S_mean;
Reference_10min.TI_N     = Reference_10min.WS_N_std./ Reference_10min.WS_N_mean;
Reference_10min.TI_S     = Reference_10min.WS_S_std./ Reference_10min.WS_S_mean;
WriteReferenceFile(Reference_10min,'ReferenceCW.csv')
range_MEAN  = [0 10];
range_STD   = [0 2.5];
range_TI    = [0 0.4];
range_WD    = [180 280];
CompareNS(Reference_10min,range_MEAN,range_STD,range_TI,range_WD)

%% Lidar Data processing
Phase_N                 = deg2rad( 90); %[rad]
Phase_S                 = deg2rad(270); %[rad]
t_offset_N              = -53;
t_offset_S              = -54;
Lidar_N                 = GetRWSatSpecificPhase(Lidar_N_raw,Phase_N,t_offset_N);
Lidar_S                 = GetRWSatSpecificPhase(Lidar_S_raw,Phase_S,t_offset_S);

%% Calculate Statistics Lidar
% Calculate 10 min statistics
Lidar_10min             = Calculate10minStastics_Lidar(Lidar_N,Lidar_S,Tstart,Tend); 
% Calculate 10 min TI
Lidar_10min.LOS_TI_N    = Lidar_10min.LOS_N_std./Lidar_10min.LOS_N_mean;
Lidar_10min.LOS_TI_S    = Lidar_10min.LOS_S_std./Lidar_10min.LOS_S_mean;
% compare lidar vs Reference
range_MEAN  = [0 12];
range_STD   = [0 2.5];
range_TI    = [0 0.4];
CompareLOS(Reference_10min,Lidar_10min,range_MEAN,range_STD,range_TI)
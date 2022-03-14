% Calculate Reference TI
% Project: IEA Wind Task 32
% Round Robin on turbulence estimates from nacelle mounted lidar systems
% by Feng Guo and David Schlipf @ Flensburg University of Applied Sciences
% v1: 30-Nov-2021
% v2: 14-Mar-2022

clearvars;clc;close all
addpath('functions')

%% Calculate and plot coordinates
Coordinate      =  CalculateCoordinate;
PlotCoordinate(Coordinate)

%% Load Data and compare Sonic Cup and Vane
Mast_N               = readtable('TMMN_20200903_20200904_1Hz_new.csv');
Mast_S               = readtable('TMMS_20200903_20200904_1Hz_new.csv');
Lidar_N              = readtable('Lidar_20200903-20200904_1Hz_LOS3_178m.csv');
Lidar_S              = readtable('Lidar_20200903-20200904_1Hz_LOS2_178m.csv');
CompareSonicToCupAndVane(Mast_S,Mast_N)

%% Calculate reference U (wind in x: W->E), V (wind in y: S->N)
Yaw_S              	= 270-Mast_S.USA_WD;
Yaw_N             	= 270-Mast_N.USA_WD;
Reference.U_S      	= Mast_S.WS1.*cosd(Yaw_S);
Reference.V_S     	= Mast_S.WS1.*sind(Yaw_S);
Reference.U_N    	= Mast_N.WS1.*cosd(Yaw_N);
Reference.V_N     	= Mast_N.WS1.*sind(Yaw_N);
Reference.Time_N    = Mast_N.TIMESTAMP;
Reference.Time_S    = Mast_S.TIMESTAMP;

%% Calculate reference LOS
% unit vectors
LidarVector_N    	= [Coordinate.Focus_N(1) Coordinate.Focus_N(2) Coordinate.Focus_N(3)];
LidarVector_S    	= [Coordinate.Focus_S(1) Coordinate.Focus_S(2) Coordinate.Focus_S(3)];
LidarUnitVector_N 	= LidarVector_N/norm(LidarVector_N);
LidarUnitVector_S  	= LidarVector_S/norm(LidarVector_S);
% measurement equation: ignoring w, convention LOS is positive if towards system
Reference.LOS_S    	= -(LidarUnitVector_S(1)*Reference.U_S + LidarUnitVector_S(2)*Reference.V_S);
Reference.LOS_N    	= -(LidarUnitVector_N(1)*Reference.U_N + LidarUnitVector_N(2)*Reference.V_N);

%% get 10 min mean for reference and lidar and compare it
Tstart          = '2020-09-03 19:00:00';
Tend            = '2020-09-04 19:00:00';
Reference_10min = Calculate10minStastics_Reference(Reference,Tstart,Tend);
Lidar_10min     = Calculate10minStastics_Lidar(Lidar_N,Lidar_S,Tstart,Tend); 
CompareLOS(Reference_10min,Lidar_10min)

%% get 10 min reference TI
Reference_10min.LOS_TI_N = Reference_10min.LOS_N_std./Reference_10min.LOS_N_mean;
Reference_10min.LOS_TI_S = Reference_10min.LOS_S_std./Reference_10min.LOS_S_mean;
WriteReferenceFile(Reference_10min,'ReferencePulsed.csv')
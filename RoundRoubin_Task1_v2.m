% Calculate Reference TI
% Project: IEA Wind Task 32
% Round Robin on turbulence estimates from nacelle mounted lidar systems
% by Feng Guo and David Schlipf @ Flensburg University of Applied Sciences
% v1: 30-Nov-2021
% v2: 14-Mar-2022

clearvars;clc;close all
addpath('functions')

%% Calculate coordinates
Coordinate      =  CalculateCoordinate;
PlotCoordinate(Coordinate)

%% Load Data
Mast_Raw_N               = readtable('TMMN_20200903_20200904_1Hz_new.csv');
Mast_Raw_S               = readtable('TMMS_20200903_20200904_1Hz_new.csv');
Lidar_Raw_N              = readtable('Lidar_20200903-20200904_1Hz_LOS3_178m.csv');
Lidar_Raw_S              = readtable('Lidar_20200903-20200904_1Hz_LOS2_178m.csv');

%% Compare Sonic Cup and Vane
CompareSonicToCupAndVane(Mast_Raw_S,Mast_Raw_N)

%% Calculate reference U (wind in x: W->E), V (wind in y: S->N)
Yaw_S                   = 270-Mast_Raw_S.USA_WD;
Yaw_N                   = 270-Mast_Raw_N.USA_WD;
Reference_Raw.U_S           = Mast_Raw_S.WS1.*cosd(Yaw_S);
Reference_Raw.V_S           = Mast_Raw_S.WS1.*sind(Yaw_S);
Reference_Raw.U_N           = Mast_Raw_N.WS1.*cosd(Yaw_N);
Reference_Raw.V_N           = Mast_Raw_N.WS1.*sind(Yaw_N);

%% Calculate reference LOS
% unit vectors
LidarVector_N           = [Coordinate.Focus_N(1) Coordinate.Focus_N(2) Coordinate.Focus_N(3)];
LidarVector_S           = [Coordinate.Focus_S(1) Coordinate.Focus_S(2) Coordinate.Focus_S(3)];
LidarUnitVector_N       = LidarVector_N/norm(LidarVector_N);
LidarUnitVector_S       = LidarVector_S/norm(LidarVector_S);
% measurement equation: ignoring w, convention LOS is positive if towards system
Reference_Raw.LOS_S         = -(LidarUnitVector_S(1)*Reference_Raw.U_S + LidarUnitVector_S(2)*Reference_Raw.V_S);
Reference_Raw.LOS_N         = -(LidarUnitVector_N(1)*Reference_Raw.U_N + LidarUnitVector_N(2)*Reference_Raw.V_N);

%% get 10 min mean for reference and lidar and compare it
Tstart          = '2020-09-03 19:00:00';
Tend            = '2020-09-04 19:00:00';
Reference_10min = Calculate10minStastic_Mast(Reference_Raw,Mast_Raw_N,Mast_Raw_S,Tstart,Tend);
Lidar_10min     = Calculate10minStastic_Lidar(Lidar_Raw_N,Lidar_Raw_S,Tstart,Tend); 
CompareLOS(Reference_10min,Lidar_10min) % TODO: simple script similar to CompareSonicToCupAndVane


%% get 10 min reference TI
Reference_10min.LOS_TI_N = Reference_10min.LOS_N_std./Reference_10min.LOS_N_mean;
Reference_10min.LOS_TI_S = Reference_10min.LOS_S_std./Reference_10min.LOS_S_mean;
WriteReferenceFile(Reference_10min,'Reference.xls')





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
Mast_N                  = readtable('TMMN_20200903_20200904_1Hz_new.csv');
Mast_S                  = readtable('TMMS_20200903_20200904_1Hz_new.csv');
% Lidar           = readtable... % TODO
CompareSonicToCupAndVane(Mast_S,Mast_N)

%% Calculate reference U (wind in x: W->E), V (wind in y: S->N)
Yaw_S                   = 270-Mast_S.USA_WD;
Yaw_N                   = 270-Mast_N.USA_WD;
Reference.U_S           = Mast_S.WS1.*cosd(Yaw_S);
Reference.V_S           = Mast_S.WS1.*sind(Yaw_S);
Reference.U_N           = Mast_N.WS1.*cosd(Yaw_N);
Reference.V_N           = Mast_N.WS1.*sind(Yaw_N);

%% Calculate reference LOS
% unit vectors
LidarVector_N           = [Coordinate.Focus_N(1) Coordinate.Focus_N(2) Coordinate.Focus_N(3)];
LidarVector_S           = [Coordinate.Focus_S(1) Coordinate.Focus_S(2) Coordinate.Focus_S(3)];
LidarUnitVector_N       = LidarVector_N/norm(LidarVector_N);
LidarUnitVector_S       = LidarVector_S/norm(LidarVector_S);
% measurement equation: ignoring w, convention LOS is positive if towards system
Reference.LOS_N         = -(LidarUnitVector_N(1)*Reference.U + LidarUnitVector_N(2)*Reference.V);
Reference.LOS_S         = -(LidarUnitVector_N(1)*Reference.U + LidarUnitVector_N(2)*Reference.V);

%% get 10 min mean for reference and lidar and compare it
% TODO: this could be the names of the 10 min mean time series
% Reference.LOS_N_mean
% Reference.LOS_S_mean
% Lidar.LOS_N_mean
% Lidar.LOS_S_mean
% Reference = CalculateMeanReference(Reference) % TODO
% Lidar     = CalculateMeanLidar(Lidar) % TODO

% CompareLOS(Reference,Lidar) % TODO: simple script similar to CompareSonicToCupAndVane

%% get 10 min reference TI
% Reference = CalculateTIReference(Reference) % TODO
% WriteReferenceFile(Reference) % TODO




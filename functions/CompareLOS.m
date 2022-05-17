function CompareLOS(Reference_10min,Lidar_10min,range_MEAN,range_STD,range_TI)
% Compares Lidar and Reference TI in LOS
% DS on 07-May-2022

% Reference-Lidar
m           = 2;
n           = 3;

figure('Name','Regression Reference-Lidar')
RegressionSubPlot(m,n,1,Reference_10min.LOS_N_mean,Lidar_10min.LOS_N_mean,...
    range_MEAN,'Reference N [m/s]','Lidar N [m/s]','MEAN LOS, North');
RegressionSubPlot(m,n,2,Reference_10min.LOS_N_std, Lidar_10min.LOS_N_std,...
    range_STD, 'Reference N [m/s]','Lidar N [m/s]','STD LOS, North');
RegressionSubPlot(m,n,3,Reference_10min.LOS_TI_N,  Lidar_10min.LOS_TI_N,...
    range_TI,  'Reference N [-]',  'Lidar N [-]',  'TI LOS, North');
RegressionSubPlot(m,n,4,Reference_10min.LOS_S_mean,Lidar_10min.LOS_S_mean,...
    range_MEAN,'Reference S [m/s]','Lidar S [m/s]','MEAN LOS, South');
RegressionSubPlot(m,n,5,Reference_10min.LOS_S_std, Lidar_10min.LOS_S_std,...
    range_STD ,'Reference S [m/s]','Lidar S [m/s]','STD LOS, South');
RegressionSubPlot(m,n,6,Reference_10min.LOS_TI_S,  Lidar_10min.LOS_TI_S,...
    range_TI  ,'Reference S [-]',  'Lidar S [-]',  'TI LOS, South');

end
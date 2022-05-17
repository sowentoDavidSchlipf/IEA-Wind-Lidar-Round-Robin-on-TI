function CompareNS(Reference_10min,range_MEAN,range_STD,range_TI,range_WD)
% Compares North and South Met mast
% DS on 07-May-2022

% Reference N - Reference S
m           = 2;
n           = 2;

figure('Name','Regression Reference North - South')
RegressionSubPlot(m,n,1,Reference_10min.WS_N_mean,Reference_10min.WS_S_mean,...
    range_MEAN,'Reference N [m/s]','Reference S [m/s]','MEAN WS');
RegressionSubPlot(m,n,2,Reference_10min.WS_N_std, Reference_10min.WS_S_std,...
    range_STD, 'Reference N [m/s]','Reference S [m/s]','STD WS');
RegressionSubPlot(m,n,3,Reference_10min.TI_N,     Reference_10min.TI_S,...
    range_TI,  'Reference N [-]',  'Reference S [-]',  'TI');
RegressionSubPlot(m,n,4,Reference_10min.WD_N_mean,Reference_10min.WD_S_mean,...
    range_WD,  'Reference N [deg]','Reference S [deg]','WD');

end
% Finds lidar beam direction
% Project: IEA Wind Task 32
% should be run after RoundRoubin_ReferenceCW.m/RoundRoubin_ReferencePulsed.m
% by David Schlipf @ Flensburg University of Applied Sciences
% v1: 17-May-2022: initial version

%% stuff we need for both optimizations
% build time vector
t1                          = datetime(Tstart); 
t2                          = datetime(Tend); 
t_vec                       = datenum(t1:minutes(10):t2); % create a ideal time vector 
% loop over the data and calculate the 10min statistic
n_10min                     = length(t_vec)-1;

%% Brute-force-optimization North Beam
WD_N_v      = [248.0:.2:256.0];
n_WD_N      = length(WD_N_v);
R2_N        = NaN(1,n_WD_N);

for i_WD_N=1:n_WD_N
    % Wind direction for this step
    WD_N                = WD_N_v(i_WD_N);
    % Calculate reference LOS=-(xu+yv+zw)
    Yaw_L_N             = 270-WD_N; 
    % measurement equation: ignoring w
    Reference.LOS_N    	= cosd(Yaw_L_N)*Reference.U_N + sind(Yaw_L_N)*Reference.V_N;
    
    % get statistics
    for i_10min= 1:n_10min
        Considered_N  	= Reference.t_N>=t_vec(i_10min) & Reference.t_N<t_vec(i_10min+1);   
        Reference_10min.LOS_N_mean(i_10min)   = nanmean(Reference.LOS_N(Considered_N));
    end
    
    % Calculate R^2
    x       = Reference_10min.LOS_N_mean;
    y       = Lidar_10min.LOS_N_mean;
    R       = corrcoef(x,y);
    R2_N(i_WD_N) = R(1,2);
    
end

[maxVal,maxIdx] = max(R2_N);

figure('Name','North Beam')
hold on;grid on; box on;
title(['North Beam: max at ',num2str(WD_N_v(maxIdx)),' deg'])
plot(WD_N_v,R2_N,'.-')
plot(WD_N_v(maxIdx),R2_N(maxIdx),'o')
xlabel('wind direction [deg]')
ylabel('R^2 [-]')

%% Brute-force-optimization South Beam
WD_S_v      = [220.0:.2:240.0];
n_WD_S      = length(WD_S_v);
R2_S        = NaN(1,n_WD_S);

for i_WD_S=1:n_WD_S
    % Wind direction for this step
    WD_S                = WD_S_v(i_WD_S);
    % Calculate reference LOS=-(xu+yv+zw)
    Yaw_L_S             = 270-WD_S; 
    % measurement equation: ignoring w
    Reference.LOS_S    	= cosd(Yaw_L_S)*Reference.U_S + sind(Yaw_L_S)*Reference.V_S;
    
    % get statistics
    for i_10min= 1:n_10min
        Considered_S 	= Reference.t_S>=t_vec(i_10min) & Reference.t_S<t_vec(i_10min+1);   
        Reference_10min.LOS_S_mean(i_10min)   = nanmean(Reference.LOS_S(Considered_S));
    end
    
    % Calculate R^2
    x       = Reference_10min.LOS_S_mean;
    y       = Lidar_10min.LOS_S_mean;
    R       = corrcoef(x,y);    
    R2_S(i_WD_S) = R(1,2);
    
end

[maxVal,maxIdx] = max(R2_S);

figure('Name','South Beam')
hold on;grid on; box on;
title(['South Beam: max at ',num2str(WD_S_v(maxIdx)),' deg'])
plot(WD_S_v,R2_S,'.-')
plot(WD_S_v(maxIdx),R2_S(maxIdx),'o')
xlabel('wind direction [deg]')
ylabel('R^2 [-]')

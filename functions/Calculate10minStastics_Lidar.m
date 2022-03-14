function data_10min  = Calculate10minStastics_Lidar(Lidar_Raw_N,Lidar_Raw_S,Tstart,Tend)
% function to calculate the 10min statistic for the lidar

% apply some selection criteria to filter some unexpected data
Lidar_Raw_N.RWS(Lidar_Raw_N.Distance~=178)  = nan;
Lidar_Raw_S.RWS(Lidar_Raw_S.Distance~=178)  = nan;
Lidar_Raw_N.RWS(Lidar_Raw_N.RWS>25)         = nan;   % remove the strange values
Lidar_Raw_S.RWS(Lidar_Raw_S.RWS>25)         = nan;

% Convert to numeric time
Time_LOS_N   = zeros(length(Lidar_Raw_N.Timestamp),1);
for i = 1:length(Lidar_Raw_N.Timestamp)
    temp = strrep(Lidar_Raw_N.Timestamp(i),'T',' ');
    temp = temp{1}(1:end-6);
    Time_LOS_N(i) = datenum(temp);
end
Time_LOS_S   = zeros(length(Lidar_Raw_S.Timestamp),1);
for i = 1:length(Lidar_Raw_S.Timestamp)
    temp = strrep(Lidar_Raw_S.Timestamp(i),'T',' ');
    temp = temp{1}(1:end-6);
    Time_LOS_S(i) = datenum(temp);
end

% build time vector
t1                       = datetime(Tstart); 
t2                       = datetime(Tend); 
t_vec                    = datenum(t1:minutes(10):t2); % create a ideal time vector 

% loop over the data and calculate the 10min statistic
for i= 1:length(t_vec)-1
    data_10min.LOS_N_mean(i) = nanmean(Lidar_Raw_N.RWS(Time_LOS_N>=t_vec(i)&Time_LOS_N<t_vec(i+1)));
    data_10min.LOS_S_mean(i) = nanmean(Lidar_Raw_S.RWS(Time_LOS_S>=t_vec(i)&Time_LOS_S<t_vec(i+1)));
    data_10min.LOS_N_std(i)  = nanstd (Lidar_Raw_N.RWS(Time_LOS_N>=t_vec(i)&Time_LOS_N<t_vec(i+1)));
    data_10min.LOS_S_std(i)  = nanstd (Lidar_Raw_S.RWS(Time_LOS_S>=t_vec(i)&Time_LOS_S<t_vec(i+1)));
end

% add time vector
data_10min.Time              = datestr(t_vec(1:end-1),31);

end
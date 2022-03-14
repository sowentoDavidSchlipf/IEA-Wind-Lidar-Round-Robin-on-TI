function data_10min = Calculate10minStastics_Reference(Reference,Tstart,Tend) 
% function to calculate the 10min statistic for the Mast

% Convert to numeric time
Time_MAST_N               = datenum(Reference.Time_N);
Time_MAST_S               = datenum(Reference.Time_S);

% build time vector
t1                        = datetime(Tstart); 
t2                        = datetime(Tend); 
t_vec                     = datenum(t1:minutes(10):t2); % create a ideal time vector 

% loop over the data and calculate the 10min statistic
for i= 1:length(t_vec)-1
    data_10min.LOS_N_mean(i) = nanmean(Reference.LOS_N(Time_MAST_N>=t_vec(i)&Time_MAST_N<t_vec(i+1)));
    data_10min.LOS_S_mean(i) = nanmean(Reference.LOS_S(Time_MAST_S>=t_vec(i)&Time_MAST_S<t_vec(i+1)));
    data_10min.LOS_N_std(i)  = nanstd (Reference.LOS_N(Time_MAST_N>=t_vec(i)&Time_MAST_N<t_vec(i+1)));
    data_10min.LOS_S_std(i)  = nanstd (Reference.LOS_S(Time_MAST_S>=t_vec(i)&Time_MAST_S<t_vec(i+1)));
end

% add time vector
data_10min.Time              = datestr(t_vec(1:end-1),31);

end
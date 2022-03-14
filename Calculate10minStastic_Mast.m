function data_10min = Calculate10minStastic_Mast(Data_Raw,Mast_Raw_N,Mast_Raw_S,Tstart,Tend) 

% function to calculate the 10min statistic for the Mast

% Convert the time to ISO calender to be numbers
Time_MAST_N               = datenum(Mast_Raw_N.TIMESTAMP);
Time_MAST_S               = datenum(Mast_Raw_S.TIMESTAMP);
t1                        = datetime(Tstart); 
t2                        = datetime(Tend); 
t_vec                     = datenum(t1:minutes(10):t2); % create a ideal time vector 

% loop over the data and calculate the 10min statistic
for i= 1:length(t_vec)-1
    data_10min.LOS_N_mean(i) = nanmean(Data_Raw.LOS_N(Time_MAST_N>=t_vec(i)&Time_MAST_N<t_vec(i+1)));
    data_10min.LOS_S_mean(i) = nanmean(Data_Raw.LOS_S(Time_MAST_S>=t_vec(i)&Time_MAST_S<t_vec(i+1)));
    data_10min.LOS_N_std(i)  = nanstd(Data_Raw.LOS_N(Time_MAST_N>=t_vec(i)&Time_MAST_N<t_vec(i+1)));
    data_10min.LOS_S_std(i)  = nanstd(Data_Raw.LOS_S(Time_MAST_S>=t_vec(i)&Time_MAST_S<t_vec(i+1)));
end

data_10min.Time              = cellstr(datestr(t_vec(1:end-1)));


end
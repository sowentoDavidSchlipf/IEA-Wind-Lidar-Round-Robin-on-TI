% Finds time offset
% Project: IEA Wind Task 32
% should be run after RoundRoubin_ReferenceCW.m/RoundRoubin_ReferencePulsed.m
% by David Schlipf @ Flensburg University of Applied Sciences
% v1: 20-May-2022: initial version

%% north beam
MyXlim = [datenum('2017-02-16 04:00:00'),datenum('2017-02-17 04:00:00')];
figure
subplot(211)
hold on;box on;grid on;
plot(Reference.t_N,Reference.LOS_N,'.-')
plot(Lidar_N.t,Lidar_N.RWS,'.-')
xlim(MyXlim)
datetick('x','keeplimits')
ylabel('RWS [m/s]')
subplot(212)
hold on;box on;grid on;
plot(Reference_10min.t,Reference_10min.LOS_N_mean,'o-')
plot(Lidar_10min.t,Lidar_10min.LOS_N_mean,'.-')
xlim(MyXlim)
datetick('x','keeplimits')
ylabel('RWS [m/s]')
xlabel('time')

x           = Reference.LOS_N-mean(Reference.LOS_N);
y_temp      = interp1(Lidar_N.t,Lidar_N.RWS,Reference.t_N);
y           = y_temp-nanmean(y_temp);
y(isnan(y)) = 0;           
[c,lags]    = xcorr(x,y,'coeff');

dt = 1;
figure
plot(lags*dt,c)
xlim([-1 1]*60)
ylabel('c [-]')
xlabel('t [s]')

[maxVal,maxIdx] = max(c);
t_offset = dt*lags(maxIdx);

%% south beam
MyXlim = [datenum('2017-02-16 04:00:00'),datenum('2017-02-17 04:00:00')];
figure
subplot(211)
hold on;box on;grid on;
plot(Reference.t_S,Reference.LOS_S,'.-')
plot(Lidar_S.t,Lidar_S.RWS,'.-')
xlim(MyXlim)
datetick('x','keeplimits')
ylabel('RWS [m/s]')
subplot(212)
hold on;box on;grid on;
plot(Reference_10min.t,Reference_10min.LOS_S_mean,'o-')
plot(Lidar_10min.t,Lidar_10min.LOS_S_mean,'.-')
xlim(MyXlim)
datetick('x','keeplimits')
ylabel('RWS [m/s]')
xlabel('time')


x           = Reference.LOS_S-mean(Reference.LOS_S);
y_temp      = interp1(Lidar_S.t,Lidar_S.RWS,Reference.t_S);
y           = y_temp-nanmean(y_temp);
y(isnan(y)) = 0;           
[c,lags]    = xcorr(x,y,'coeff');

dt = 1;
figure
plot(lags*dt,c)
xlim([-1 1]*60)
ylabel('c [-]')
xlabel('t [s]')

[maxVal,maxIdx] = max(c);
t_offset = dt*lags(maxIdx);
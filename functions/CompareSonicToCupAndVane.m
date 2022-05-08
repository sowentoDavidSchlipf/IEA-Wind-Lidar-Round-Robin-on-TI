function CompareSonicToCupAndVane(Mast_S,Mast_N,Tstart,Tend)

MyXlim = [datenum(Tstart),datenum(Tend)];

figure('Name','Comparison Sonic to Cup/Vane')

subplot(2,2,1)
hold on;box on;grid on
plot(Mast_N.t,Mast_N.USA_WShorizontal)
plot(Mast_N.t,Mast_N.WS1)
title('North Mast: horizontal wind speed')
ylabel('[m/s]')
legend('Sonic','Cup')
xlim(MyXlim);
datetick('x','keeplimits')

subplot(2,2,2)
hold on;box on;grid on
plot(Mast_S.t,Mast_S.USA_WShorizontal)
plot(Mast_S.t,Mast_S.WS1)
title('South Mast: horizontal wind speed')
ylabel('[m/s]')
legend('Sonic','Cup')
xlim(MyXlim);
datetick('x','keeplimits')

subplot(2,2,3)
hold on;box on;grid on
plot(Mast_N.t,Mast_N.USA_WD)
plot(Mast_N.t,Mast_N.WD1)
title('North Mast: wind direction')
ylabel('[deg]')
legend('Sonic','Vane')
xlim(MyXlim);
datetick('x','keeplimits')

subplot(2,2,4)
hold on;box on;grid on
plot(Mast_S.t,Mast_S.USA_WD)
plot(Mast_S.t,Mast_S.WD1)
title('South Mast: wind direction')
ylabel('[deg]')
legend('Sonic','Vane')
xlim(MyXlim);
datetick('x','keeplimits')


figure('Name','Comparison North to South')

subplot(2,2,1)
hold on;box on;grid on
plot(Mast_N.t,Mast_N.USA_WShorizontal)
plot(Mast_S.t,Mast_S.USA_WShorizontal)
title('Sonic: horizontal wind speed')
ylabel('[m/s]')
legend('North','South')
xlim(MyXlim);
datetick('x','keeplimits')

subplot(2,2,2)
hold on;box on;grid on
plot(Mast_N.t,Mast_N.WS1)
plot(Mast_S.t,Mast_S.WS1)
title('Cup: horizontal wind speed')
ylabel('[m/s]')
legend('North','South')
xlim(MyXlim);
datetick('x','keeplimits')

subplot(2,2,3)
hold on;box on;grid on
plot(Mast_N.t,Mast_N.USA_WD)
plot(Mast_S.t,Mast_S.USA_WD)
title('Sonic: wind direction')
ylabel('[deg]')
legend('North','South')
xlim(MyXlim);
datetick('x','keeplimits')

subplot(2,2,4)
hold on;box on;grid on
plot(Mast_N.t,Mast_N.WD1)
plot(Mast_S.t,Mast_S.WD1)
title('Vane: wind direction')
ylabel('[deg]')
legend('North','South')
xlim(MyXlim);
datetick('x','keeplimits')


% Sonic - Cup Regression
m           = 2;
n           = 2;
range_MEAN  = [0 15];
range_WD    = [100 400];

figure('Name','Regression Sonic-Cup')
RegressionSubPlot(m,n,1,Mast_N.USA_WShorizontal,Mast_N.WS1,...
    range_MEAN,'Sonic [m/s]','Cup [m/s]','North Mast: horizontal wind speed');
RegressionSubPlot(m,n,2,Mast_S.USA_WShorizontal,Mast_S.WS1,...
    range_MEAN,'Sonic [m/s]','Cup [m/s]','South Mast: horizontal wind speed');
RegressionSubPlot(m,n,3,Mast_N.USA_WD,          Mast_N.WD1,...
    range_WD,  'Sonic [deg]','Cup [deg]','North Mast: wind direction');
RegressionSubPlot(m,n,4,Mast_S.USA_WD,          Mast_S.WD1,...
    range_WD,  'Sonic [deg]','Cup [deg]','South Mast: wind direction');


end

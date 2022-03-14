function CompareSonicToCupAndVane(Mast_S_data,Mast_N_data)

figure('Name','Comparison over time')

subplot(2,2,1)
hold on;box on;grid on
plot(sqrt(Mast_S_data.USA_U.^2+Mast_S_data.USA_V.^2))
plot(Mast_S_data.WS1)
title('South Mast: horizontal wind speed')
ylabel('[m/s]')
legend('Sonic','Cup')

subplot(2,2,2)
hold on;box on;grid on
plot(sqrt(Mast_N_data.USA_U.^2+Mast_N_data.USA_V.^2))
plot(Mast_N_data.WS1)
title('North Mast: horizontal wind speed')
ylabel('[m/s]')
legend('Sonic','Cup')

subplot(2,2,3)
hold on;box on;grid on
plot(Mast_S_data.USA_WD)
plot(Mast_S_data.WD1)
title('South Mast: wind direction')
ylabel('[deg]')
xlabel('data point [-]')
legend('Sonic','Vane')

subplot(2,2,4)
hold on;box on;grid on
plot(Mast_N_data.USA_WD)
plot(Mast_N_data.WD1)
title('North Mast: wind direction')
ylabel('[deg]')
xlabel('data point [-]')
legend('Sonic','Vane')


figure('Name','Regression')

subplot(2,2,1)
hold on;box on;grid on
plot(sqrt(Mast_S_data.USA_U.^2+Mast_S_data.USA_V.^2),Mast_S_data.WS1,'.')
title('South Mast: horizontal wind speed')
xlabel('Sonic [m/s]')
ylabel('Cup [m/s]')

subplot(2,2,2)
hold on;box on;grid on
plot(sqrt(Mast_N_data.USA_U.^2+Mast_N_data.USA_V.^2),Mast_N_data.WS1,'.')
title('North Mast: horizontal wind speed')
xlabel('Sonic [m/s]')
ylabel('Cup [m/s]')

subplot(2,2,3)
hold on;box on;grid on
plot(Mast_S_data.USA_WD,Mast_S_data.WD1,'.')
title('South Mast: wind direction')
xlabel('Sonic [deg]')
ylabel('Cup [deg]')

subplot(2,2,4)
hold on;box on;grid on
plot(Mast_N_data.USA_WD,Mast_N_data.WD1,'.')
title('North Mast: wind direction')
xlabel('Sonic [deg]')
ylabel('Cup [deg]')

end

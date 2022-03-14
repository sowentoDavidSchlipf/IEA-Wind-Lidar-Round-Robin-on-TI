function CompareLOS(Reference_10min,Lidar_10min)



figure('Name','LOS mean and std. Regression')

subplot(2,2,1)
hold on;box on;grid on
pa=plot(Reference_10min.LOS_N_mean,Lidar_10min.LOS_N_mean,'.');
pb=plot([0 10],[0 10]);
title('Mean wind in LOS direction, North')
xlabel('Reference [m/s]')
ylabel('Lidar [m/s]')
legend([pa pb],'scatters','1:1 line')

subplot(2,2,2)
hold on;box on;grid on
plot(Reference_10min.LOS_S_mean,Lidar_10min.LOS_S_mean,'.')
plot([0 10],[0 10])
title('Mean wind in LOS direction, South')
xlabel('Reference [m/s]')
ylabel('Lidar [m/s]')

subplot(2,2,3)
hold on;box on;grid on
plot(Reference_10min.LOS_N_std,Lidar_10min.LOS_N_std,'.')
plot([0 2.5],[0 2.5])
title('Standard deviation of wind in LOS direction, North')
xlabel('Reference [m/s]')
ylabel('Lidar [m/s]')

subplot(2,2,4)
hold on;box on;grid on
plot(Reference_10min.LOS_S_std,Lidar_10min.LOS_S_std,'.')
plot([0 2.5],[0 2.5])
title('Standard deviation of wind in LOS direction, South')
xlabel('Reference [m/s]')
ylabel('Lidar [m/s]')


end
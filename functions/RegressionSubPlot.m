function RegressionSubPlot(m,n,p,x,y,MyRange,MyXlabel,MyYlabel,MyTitle)
InRange = x>=MyRange(1)&x<=MyRange(2)&y>=MyRange(1)&y<=MyRange(2);
x_r     = x(InRange);
y_r     = y(InRange);
% calculations
poly    = polyfit(x_r,y_r,1);
R       = corrcoef(x_r,y_r);

% plot
subplot(m,n,p)
hold on;box on;grid on
plot(x,y,'.');
plot(MyRange,polyval(poly,MyRange))
plot(MyRange,MyRange,'k');
title([MyTitle,', [',num2str(MyRange(1)),',',num2str(MyRange(2)),']'])
    
xlabel(MyXlabel)
ylabel(MyYlabel)
axis equal
xlim(MyRange)
ylim(MyRange)
text(MyRange(1)+0.1*diff(MyRange),MyRange(1)+0.9*diff(MyRange),...
    ['y=',num2str(poly(2),'%4.2f'),'+',num2str(poly(1),'%4.2f'),' x'])
text(MyRange(1)+0.1*diff(MyRange),MyRange(1)+0.8*diff(MyRange),...
    ['R^2=',num2str(R(1,2),'%5.3f')])
text(MyRange(1)+0.1*diff(MyRange),MyRange(1)+0.7*diff(MyRange),...
    ['n=',num2str(sum(InRange))])

end
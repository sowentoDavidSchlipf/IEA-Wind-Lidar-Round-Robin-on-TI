function RegressionSubPlot(m,n,p,x,y,Intercept,MyRange,MyXlabel,MyYlabel,MyTitle)
InRange = x>=MyRange(1)&x<=MyRange(2)&y>=MyRange(1)&y<=MyRange(2);
x_r     = x(InRange);
y_r     = y(InRange);
% calculations
if Intercept
    mdl     = fitlm(x,y,'intercept',true);
    poly    = [mdl.Coefficients.Estimate(2) mdl.Coefficients.Estimate(1)];
else
    mdl     = fitlm(x,y,'intercept',false);
    poly    = [mdl.Coefficients.Estimate(1) 0]; 
end
Rsquared    = mdl.Rsquared.Ordinary;

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
if Intercept
    text(MyRange(1)+0.1*diff(MyRange),MyRange(1)+0.9*diff(MyRange),...
        ['y=',num2str(poly(2),'%4.2f'),'+',num2str(poly(1),'%4.2f'),' x'])
else
    text(MyRange(1)+0.1*diff(MyRange),MyRange(1)+0.9*diff(MyRange),...
        ['y=',num2str(poly(1),'%4.2f'),' x'])    
end
text(MyRange(1)+0.1*diff(MyRange),MyRange(1)+0.8*diff(MyRange),...
    ['R^2=',num2str(Rsquared,'%5.3f')])
text(MyRange(1)+0.1*diff(MyRange),MyRange(1)+0.7*diff(MyRange),...
    ['n=',num2str(sum(InRange))])

end
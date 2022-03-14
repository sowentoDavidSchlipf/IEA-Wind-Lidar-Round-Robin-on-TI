function [LOSratio,Misalignment] = CalculateYawLUTbyLOS(OpeningAngle)

Uref = 10;

[Beam1(1),Beam1(2)] = pol2cart(deg2rad(OpeningAngle/2),Uref);

[Beam2(1),Beam2(2)] = pol2cart(deg2rad(-OpeningAngle/2),Uref);


Misalignment = -100:1:65;
LOSratio = zeros(length(Misalignment),1);
% figure()
% plot(misalignment,LOSratio)

for i=1:length(Misalignment)
    
%     figure(5)
%     hold off
% plot([0 Beam1(1)],[0 Beam1(2)])
% hold on
% plot([0 Beam2(1)],[0 Beam2(2)])


    [wind(1),wind(2)] = pol2cart(deg2rad(Misalignment(i)),Uref);
    
    plot([wind(1) 0],[wind(2) 0])
    LOS1 = dot(-wind,Beam1)/norm(Beam1);
    LOS2 = dot(-wind,Beam2)/norm(Beam2);
    
%     if LOS1 < 1e-10 || LOS2 < 1e-5
%        LOSratio(i) = nan;
%        
%     else
       LOSratio(i) = min(LOS1/LOS2,50); 
       
       if LOSratio(i)<0
          LOSratio(i) = max(LOSratio(i),-50) ;
       end
%     end
    
    
    
%     plot([0 Beam1(1)]/Uref*LOS1,[0 Beam1(2)]/Uref*LOS1)
%     plot([0 Beam2(1)]/Uref*LOS2,[0 Beam2(2)]/Uref*LOS2)
%     theta1 = OpeningAngle/2-misalignment;
%     theta2 = OpeningAngle/2+misalignment;
%     axis equal
    
% pause()
%     
end

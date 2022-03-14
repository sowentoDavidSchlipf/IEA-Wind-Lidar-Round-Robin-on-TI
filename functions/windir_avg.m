function [windir_avged] = windir_avg(windir)
    [x,y] = pol2cart(deg2rad(windir),ones(size(windir)));
    x=mean(x,'omitnan');
    y=mean(y,'omitnan');
    [windir_avged,~]=cart2pol(x,y);
    windir_avged = rad2deg(windir_avged);
end
function Lidar = GetRWSatSpecificPhase(Lidar_raw,SpecificPhase,t_offset)

% Parameters
BackScatterLB           = 0.0;

% signals from raw data
Valid                   = strcmp('Valid',Lidar_raw.RawLineOfSightValidity);
RangeOK                 = Lidar_raw.Range_m_==178;
NoRain                  = ~Lidar_raw.Raining;
BackScatterOK           = Lidar_raw.Backscatter__1_3e_6_m_sr_>BackScatterLB;
Uptime                  = Lidar_raw.Uptime_ms_;
LOS                     = Lidar_raw.LineOfSightVelocity_m_s_;
Phase                   = Lidar_raw.Phase_rad_;
Reference               = Lidar_raw.Reference;
n_Data                  = length(Phase);

% init
t_v         = NaN(3,1);
p_v         = NaN(3,1);
v_v         = NaN(3,1);
c_point     = 0;
c_scan      = 0;

% loop
for i_Data = 1:n_Data-1
    c_point             = c_point+1;
    if Valid(i_Data) && RangeOK(i_Data) && BackScatterOK(i_Data) && NoRain(i_Data)
        t_v(c_point)    = Uptime(i_Data);
        v_v(c_point)    = LOS(i_Data);
        p_v(c_point)    = Phase(i_Data);
    end
    % end of scan reached?
    if diff(Reference(i_Data+[0 1]))>1 
        NoNaN           = ~isnan(t_v);
        if sum(NoNaN) > 1
            % interpolate for this scan
            c_scan      = c_scan+1;            
            t(c_scan)   = interp1(p_v(NoNaN),t_v(NoNaN),SpecificPhase,'linear','extrap');
            v(c_scan)   = interp1(p_v(NoNaN),v_v(NoNaN),SpecificPhase,'linear','extrap');          
        end
        % reset            
        t_v         = NaN(3,1);
        p_v         = NaN(3,1);
        v_v         = NaN(3,1);
        c_point     = 0;                          
    end       
end
    
% build Lidar Struct
t_0     	= datenum(Lidar_raw.Timestamp_ISO8601_(1),'yyyy-mm-ddTHH:MM:SS.FFF');
Lidar.t     = t_0 + (t-t(1))/1000/60/60/24+ t_offset/60/60/24; % [days]
Lidar.RWS   = v;
end
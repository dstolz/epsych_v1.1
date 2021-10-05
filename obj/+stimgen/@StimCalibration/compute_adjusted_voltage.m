function v = compute_adjusted_voltage(obj,type,value,level)
% v = compute_adjusted_voltage(obj,type,value,level)
% 
% Input:
%   obj   ... stimgen.StimCalibration object
%   type  ... Calibration type: "tone" or "click"
%   value ... Frequency if "tone", or Duration if "click"
%   level ... Target sound level
%
% Output:
%   v ... voltage needed to produce the target sound level.
% 
% DJS 2021


x = obj.CalibrationData.(type)(:,1); % frequency
z = obj.CalibrationData.(type)(:,4); % normative value

n = makima(x,z,value); % interpolate to normative value

% compute requested voltage
v = 10.^((level-obj.NormativeValue)./20).*n;


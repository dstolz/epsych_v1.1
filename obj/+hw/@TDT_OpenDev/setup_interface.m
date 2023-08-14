function setup_interface(obj)
% DA = TDT_SetupDA(tank);
% DA = TDT_SetupDA(tank,server);
% 
% The TDT TDevAcc activex control is used to interface with running OpenEx
% 
% Initialize TDT TDevAcc activex control in invisible window and return
% handle to control (DA), registered tanks, and a handle to the invisible
% figure.  The invisible figure is named 'ODevFig' and can be found using: 
% h = findobj('Type','figure','-and','Name','ODevFig')
% 
% This figure should be closed when finished:
%   h = findobj('Type','figure','-and','Name','ODevFig')
%   close(h);
% 
% Input can be a string with a tank name. 
%   ex: DA = TDT_SetupDA('DEMOTANK2');
% 
% A server name can be additionally specified.  Default server is 'local'
%   ex: DA = TDT_SetupDA('DEMOTANK2','SomeServer');
% 
% See also TDT_SetupTT, TDT_SetupRP
% 
% Daniel.Stolzberg@gmail.com 2014



h = findobj('Type','figure','-and','Name','ODevFig');
if isempty(h)
    h = figure('Visible','off','Name','ODevFig');
end

obj.HW = actxcontrol('TDevAcc.X','parent',h);

obj.HW.ConnectServer(char(obj.Server));
if obj.Tank ~= "",   obj.HW.SetTankName(char(obj.Tank));     end


% Update system state.  Note: System set to Preview or Record in timer
% start function.
obj.HW.SetSysMode(1); pause(0.5); % Standby

obj.Tank = string(obj.HW.GetTankName); % retrieve data tank if specified in OpenEx

obj.hTDTfig = h;







function prepare(obj) % TDTActiveX
% prepare(obj)
%
% where mod is a valid module type: 'RZ5','RX6','RP2', etc..
%   modid is the module id.  default is 1.
%   ct is a connection type:  'GB' or 'USB'
%   rpfile is the full path to an RPvds file.
%
% returns RP which is the handle to the RPco.x control.  Also returns
% status which is a bitmask of the module status.  Use with bitget function
%   Bit# 0 = Connected
%   Bit# 1 = Circuit loaded
%   Bit# 2 = Circuit running
%   Bit# 3 = RA16BA Battery
% (see page 43 of ActiveX reference manual for more status values).
%
% Optionally specify the sampling frequency (Fs).  See "LoadCOFsf" in the
% TDT ActiveX manual for more info.
%   Fs = 0  for 6 kHz
%   Fs = 1  for 12 kHz
%   Fs = 2  for 25 kHz
%   Fs = 3  for 50 kHz
%   Fs = 4  for 100 kHz
%   Fs = 5  for 200 kHz
%   Fs = 6  for 400 kHz
%   Fs > 50 for arbitrary sampling rates (RX6)

if ~exist(obj.RPvdsFile,'file')
errordlg(sprintf('File does not exist: "%s"',obj.RPvdsFile), ...
    'File Does Not Exist', ...
    'modal');
return
end

if obj.Status == epsych.hw.Status.Running
fprintf('RPco.X already connected, loaded, and running.\n')
return
end

h = findobj('Name','RPfig');
if isempty(h)
h = figure('Visible','off','Name','RPfig');
end

for i = 1:length(obj.Module)
module = obj.Module{i};
if strcmp(module,'Undefined'), continue; end

modid  = obj.ModuleID(i);
rpfile = obj.RPvdsFile{i};

obj.handle(i) = actxcontrol('RPco.x','parent',h);

if ~eval(sprintf('obj.handle.Connect%s(''%s'',%d)',module,obj.ConnectionType,modid))
    errordlg(sprintf(['Unable to connect to %s_%d module via %s connection!\n\n', ...
        'Ensure all modules are powered on and connections are secured\n\n', ...
        'Ensure the module is recognized in the zBusMon program.'], ...
        module,modid,ct),'Connection Error','modal');
    CloseUp(obj.handle,h);
    return
    
else
    fprintf('%s_%d connected ... ',module,modid)
    obj.handle.ClearCOF;
    
    if obj.Fs >= 0
        e = obj.handle.LoadCOFsf(rpfile,obj.Fs);
    else
        e = obj.handle.LoadCOF(rpfile);
    end
    
    if ~e
        errordlg(sprintf(['Unable to load RPvds file to %s module!\n\n', ...
            'The RPvds file exists, but can not be loaded for some reason'], ...
            module),'Loading Error','modal');
        obj.cleanup;
        return
    end
end
end


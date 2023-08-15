function e = prepare(obj) % TDTActiveX
% e = prepare(obj)
%
% Returns e=true if an error occured and updates obj.ErrorME with a MException

if obj.Status == epsych.hw.enStatus.Running
    log_write('Verbose','RPco.X already connected, loaded, and running.\n')
    return
end

if isempty(obj.emptyFig) || ~isvalid(obj.emptyFig)
    obj.emptyFig = figure('Visible','off','Name','RPfig');
end
obj.handle = actxcontrol('RPco.x','parent',obj.emptyFig);

for i = 1:length(obj.Module)

    M = obj.Module(i);
    
    if ~isfile(M.RPvds)
        obj.ErrorME = MException('epsych:TDTActiveX:prepare:fileNotFound', ...
            'File does not exist: "%s"',M.RPvds);
        return
    end
    
    
    success = eval(sprintf('obj.handle.Connect%s(''%s'',%d)',char(M.Type),obj.ConnectionType,M.Index));

    if ~success
        obj.ErrorME = MException('epsych:TDTActiveX:prepare', ...
            ['Unable to connect to %s_%d module via %s connection!\n\n', ...
            'Ensure all modules are powered on and connections are secured\n\n', ...
            'Ensure the module is recognized in the zBusMon program.'], ...
            char(M.Type),M.Index,obj.ConnectionType);
        return
    end
    
    log_write('Verbose','%s_%d connected',char(M.Type),M.Index)
    obj.handle.ClearCOF;
    
    if M.Fs >= 0
        success = obj.handle.LoadCOFsf(M.RPvds,M.Fs);
    else
        success = obj.handle.LoadCOF(M.RPvds);
    end
    
    if ~success
        obj.ErrorME = MException('epsych:TDTActiveX:prepare', ...
            ['Unable to load RPvds file (%s) to %s module!\n', ...
            'The RPvds file exists, but can not be loaded.'], ...
            M.RPvds,char(M.Type));
        return
    end
    

    
    success = obj.Status == epsych.hw.enStatus.Ready;

    e = ~success;
    
    if e, break; end
end


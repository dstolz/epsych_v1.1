classdef (ConstructOnLoad) Psychtoolbox3 < epsych.hw.Hardware

    properties
        Alias = 'PsychTbx';
    end
    
    properties (Constant) % define constant abstract properties from superclass
        Name         = 'Psychtoolbox3';
        Type         = 'Psychtoolbox3';
        Vendor       = 'Psychtoolbox3';
        Description  = 'http://psychtoolbox.org';
        MaxNumInstances = 1;
    end
    
    properties (SetAccess = protected)
        isReady         % returns logical true if hardware is setup and configured properly
        Status          = epsych.hw.enStatus.InPrep;
        ErrorME         % MException error message object    
    end
    
    properties (SetAccess = private)
        hwSetup         % handle to configuration gui
    end
    
    
    
    
    properties (SetAccess = private,Transient)
        hScreen % handle to Screen element
    end


    methods
        h = setup(obj,parent);      % minimal gui to set custom parameters
        prepare(obj,varargin);      % complete any required tasks before run
        start(obj,varargin);        % establish connection to hardware (if not already connected) and run
        e = runtime(obj,varargin);  % called on each tick of the master clock
        stop(obj,varargin);         % stop running hardware

        write(obj,parameter,value); % write (update) parameter value
        v = read(obj,parameter);    % read current parameter value
        e = trigger(obj,parameter); % send a trigger


        function obj = Psychtoolbox3(hwSetup)
            if nargin == 0, hwSetup = []; end
            
            % call superclass constructor
            obj = obj@epsych.hw.Hardware; 
            
            obj.hwSetup = hwSetup;
        end
        
        
        
        function ready = get.isReady(obj)
            f = {'hScreen'};
            
            e = cellfun(@(a) isempty(obj.(a)),f);
            
            cellfun(@(a,b) log_write('Verbose','Hardware "%s" - "%s" ready = %s', ...
                obj.Alias,a,mat2str(b)),f,num2cell(~e));
                
                        
            e(end+1) = obj.Status ~= epsych.hw.enStatus.InPrep;
            
            ready = ~any(e);
        end
        
        
%         function status = get.Status(obj)
%             status = epsych.hw.enStatus.Ready;
%         end
    end
end







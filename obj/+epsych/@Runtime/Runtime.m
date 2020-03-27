classdef Runtime < handle & dynamicprops
    
    properties
        Subject     (:,1) epsych.Subject
        DataDir     (1,:) char

        ErrorMException (:,1) MException
    end

    properties (Access = protected)
        Log    (1,1) Log

        % TODO: Default timer functions need to be revamped for new object format
        StartFcn = @ep_TimerFcn_Start;
        TimerFcn = @ep_TimerFcn_RunTime;
        StopFcn  = @ep_TimerFcn_Stop;
        ErrorFcn = @ep_TimerFcn_Error;
    end
    
    properties (Dependent)
        nSubjects
    end
    
    properties (Transient)
        Timer
        State   (1,1) epsych.State = epsych.State.Prep;
    end
    
    properties (SetAccess = immutable)
        Hardware   % wrapper class for ex: TDT RPvds ActiveX control
        Info % epsych.Info
    end
    
    events
        PreStateChange
        PostStateChange
    end
    
    methods
        function obj = Runtime(Hardware,varargin)
            fn = sprintf('EPsychLog_%s.txt',datestr(now,30));
            obj.Log = log.Log(fullfile(obj.Info.LogDirectory,fn));

            obj.Hardware = Hardware;
            obj.Info = epsych.Info;


            % elevate Matlab.exe process to a high priority in Windows
            pid = feature('getpid');
            [~,~] = dos(sprintf('wmic process where processid=%d CALL setpriority 128',pid));
        end
                
        % Destructor
        function delete(obj)
            delete(obj.Log);
            
            try
                stop(obj.Timer);
                delete(obj.Timer);
            end

            % be nice and return Matlab.exe process to normal priority in Windows
            pid = feature('getpid');
            [~,~] = dos(sprintf('wmic process where processid=%d CALL setpriority 32',pid));
        end








        % TIMER FUNCTIONS -----------------------------------------------------------------
        function call_StartFcn(obj,varargin)            
            obj.Log.write(log.Verbosity.Debug,'Calling Runtime.StartFcn: "%s"',func2str(obj.StartFcn));

            feval(obj.StartFcn,obj)
        end

        function call_TimerFcn(obj,varargin)
            obj.Log.write(log.Verbosity.Debug,'Calling Runtime.TimerFcn: "%s"',func2str(obj.TimerFcn));

            feval(obj.TimerFcn,obj)
        end
        
        function call_StopFcn(obj,varargin)
            % timer is stopped on pause and started again on resume
            if obj.State == epsych.State.Pause, return; end

            obj.Log.write(log.Verbosity.Debug,'Calling Runtime.StopFcn: "%s"',func2str(obj.StopFcn));

            feval(obj.StopFcn,obj)
        end
        
        function call_ErrorFcn(obj,varargin)
            obj.Log.write(log.Verbosity.Debug,'Calling Runtime.ErrorFcn: "%s"',func2str(obj.ErrorFcn));

            feval(obj.ErrorFcn,obj)
        end
        




        
        function set.State(obj,newState)
            timestamp = now;

            prevState = obj.State;
            obj.State = newState;

            ev = epsych.evProgramState(newState,prevState,timestamp);
            notify(obj,'PreStateChange',ev);
            
            try

                switch newState
                    case epsych.State.Prep
                        
                        
                        
                    case [epsych.State.Run, epsych.State.Preview]
                        obj.Log.write(log.Verbosity.Debug,'Initializing Hardware')
                        obj.Hardware.initialize;

                        obj.Log.write(log.Verbosity.Debug,'Preparing Hardware')
                        obj.Hardware.prepare;

                        obj.Log.write(log.Verbosity.Debug,'Creating Runtime Timer')
                        obj.create_timer;

                        start(obj.Timer);
                        
                    
                    case epsych.State.Halt
                        stop(obj.Timer);
                        
                        
                    case epsych.State.Pause
                        stop(obj.Timer);

                    case epsych.State.Resume
                        start(obj.Timer);
                        
                    case epsych.State.Error
                        stop(obj.Timer);
                        rethrow(obj.ErrorMException);
                end
            
            catch me
                obj.Log.write(me);
                obj.ErrorMException = me;
                obj.State = epsych.State.Error;
                return
            end
            
            ev = epsych.evProgramState(newState,prevState,timestamp);
            notify(obj,'PostStateChange',ev);

            obj.Log.write(log.Verbosity.Debug,'Runtime.State updated from "%s" to "%s"',prevState,newState);
        end % set.State
        
        
        function d = get.DataDir(obj)
            if isempty(obj.DataDir)
                obj.DataDir = fullfile(fileparts(obj.Info.root),'DATA');
            end
            if ~isfolder(obj.DataDir), mkdir(RUNTIME.DataDir); end
            d = obj.DataDir;
        end % get.DataDir
                
        function n = get.nSubjects(obj)
            n = length(obj.Subject);
        end
    end % methods (Access = public)




    
    methods (Access = protected)
        function create_timer(obj)
             % Create new timer for RPvds control of experiment
            T = timerfind('Name','EPsychRuntime');
            if ~isempty(T)
                try delete(T); end
            end
            T = timer('Name','EPsychRuntime');
            T.BusyMode = 'queue';
            T.ExecutionMode = 'fixedRate';
            T.TasksToExecute = inf;
            T.Period = 0.01;
            T.TimerFcn = @obj.call_TimerFcn;
            T.StartFcn = @obj.call_StartFcn;
            T.StopFcn  = @obj.call_StopFcn;
            T.ErrorFcn = @obj.call_ErrorFcn;
            
            obj.Timer = T;
        end
    end % methods (Access = protected)
   
    methods (Static)
        function obj = loadobj(s)
            
        end
    end % methods (Static)
    
end
    
classdef (ConstructOnLoad) Runtime < handle & dynamicprops
    
    properties
        ErrorMException (:,1) MException
    end
    
    properties (SetObservable,AbortSet)
        Config          (1,1) epsych.RuntimeConfig
        Hardware        (1,:) % epsych.hw.(Abstraction)
        Subject         (1,:) % epsych.Subject
    end

    properties (SetAccess = private)
        ConfigIsSaved     (1,1) logical = true;
    end

    properties (Dependent)
        nSubjects
    end
    
    properties (Transient)
        Timer
        State   (1,1) epsych.State = epsych.State.Prep;
    end
    
    properties (Access = private,Transient)
        el_PostSet
    end
    
    properties (SetAccess = immutable)
        Info       % epsych.Info
    end
    
    events
        ConfigChange
        PreStateChange
        PostStateChange
    end
    
    methods
        function obj = Runtime
            % monitor changes in SetObservable hardware properties and notify anyone listening
            m = metaclass(obj);
            ind = [m.PropertyList.SetObservable];
            psp = {m.PropertyList(ind).Name};
            obj.el_PostSet = cellfun(@(a) addlistener(obj,a,'PostSet',@obj.runtime_updated),psp);

            obj.Info = epsych.Info;

            % elevate Matlab.exe process to a high priority in Windows
            pid = feature('getpid');
            [~,~] = dos(sprintf('wmic process where processid=%d CALL setpriority 128',pid));
        end
                
        % Destructor
        function delete(obj)            
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
            obj.epsych.log.write(epsych.log.Verbosity.Debug,'Calling Runtime.StartFcn: "%s"',func2str(obj.StartFcn));

            feval(obj.StartFcn,obj)
        end

        function call_TimerFcn(obj,varargin)
            obj.epsych.log.write(epsych.log.Verbosity.Debug,'Calling Runtime.TimerFcn: "%s"',func2str(obj.TimerFcn));

            feval(obj.TimerFcn,obj)
        end
        
        function call_StopFcn(obj,varargin)
            % timer is stopped on pause and started again on resume
            if obj.State == epsych.State.Pause, return; end

            obj.epsych.log.write(epsych.log.Verbosity.Debug,'Calling Runtime.StopFcn: "%s"',func2str(obj.StopFcn));

            feval(obj.StopFcn,obj)
        end
        
        function call_ErrorFcn(obj,varargin)
            obj.epsych.log.write(epsych.log.Verbosity.Debug,'Calling Runtime.ErrorFcn: "%s"',func2str(obj.ErrorFcn));

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
                        obj.epsych.log.write(epsych.log.Verbosity.Debug,'Initializing Hardware')
                        obj.Hardware.initialize;

                        obj.epsych.log.write(epsych.log.Verbosity.Debug,'Preparing Hardware')
                        obj.Hardware.prepare;

                        obj.epsych.log.write(epsych.log.Verbosity.Debug,'Creating Runtime Timer')
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
                obj.epsych.log.write(me);
                obj.ErrorMException = me;
                obj.State = epsych.State.Error;
                return
            end
            
            ev = epsych.evProgramState(newState,prevState,timestamp);
            notify(obj,'PostStateChange',ev);

            obj.epsych.log.write(epsych.log.Verbosity.Debug,'Runtime.State updated from "%s" to "%s"',prevState,newState);
        end % set.State
        
        
        function n = get.nSubjects(obj)
            n = length(obj.Config.Subject);
        end
        
        function sobj = saveobj(obj)
            obj.ConfigIsSaved = true;
            sobj = obj;
            notify(obj,'ConfigChange');
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

    methods (Access = private)
        
    end % methods (Access = private)
   
    methods (Static)
        function obj = loadobj(s)
            obj = s;
            notify(obj,'ConfigChange');
        end

        function runtime_updated(obj,hObj,event)
            global RUNTIME LOG
            
            RUNTIME.ConfigIsSaved = false;

            if nargin < 3
                notify(RUNTIME,'ConfigChange');    
            else
                notify(RUNTIME,'ConfigChange',event);
            end

            LOG.write('Verbose','Runtime Object Updated "%s"',hObj.Source.Name);
        end
    end % methods (Static)
    
end
    
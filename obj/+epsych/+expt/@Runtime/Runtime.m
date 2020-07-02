classdef (ConstructOnLoad) Runtime < handle & dynamicprops
    
    properties
        ErrorMException (:,1) MException
    end
    
    properties (SetObservable,AbortSet)
        Config          (1,1) epsych.expt.Config
        Hardware        (1,:) % epsych.hw.(Abstraction); 
        Subject         (1,:) % epsych.Subject
    end

    properties (Transient,SetObservable,AbortSet)
        State           (1,1) epsych.enState
        ReadyToBegin    (1,1) logical = false;
    end
    
    properties (SetAccess = private)
        ConfigIsSaved   (1,1) logical = true;
    end

    properties (Dependent)
        nSubjects
        isRunning
    end
    
    properties (Transient)
        Timer
    end

    properties (Access = private,Transient)
        el_PostSet
    end
    
    properties (SetAccess = immutable)
        Info       % epsych.Info
    end
    
    events
        RuntimeConfigChange
        RuntimeIsReady
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
            global LOG

            LOG.write(epsych.log.Verbosity.Debug,'Calling Runtime.StartFcn: "%s"',func2str(obj.Config.StartFcn));

            feval(obj.Config.StartFcn,obj)
        end

        function call_TimerFcn(obj,varargin)
            % global LOG

            % LOG.write(epsych.log.Verbosity.Insanity,'Calling Runtime.TimerFcn: "%s"',func2str(obj.Config.TimerFcn));

            feval(obj.Config.TimerFcn,obj)
        end
        
        function call_StopFcn(obj,varargin)
            global LOG

            % timer is stopped on pause and started again on resume
            if obj.State == epsych.enState.Pause, return; end

            LOG.write(epsych.log.Verbosity.Debug,'Calling Runtime.StopFcn: "%s"',func2str(obj.Config.StopFcn));

            feval(obj.Config.StopFcn,obj)
        end
        
        function call_ErrorFcn(obj,varargin)
            global RUNTIME LOG

            LOG.write(epsych.log.Verbosity.Debug,'Calling Runtime.ErrorFcn: "%s"',func2str(obj.Config.ErrorFcn));

            feval(obj.Config.ErrorFcn,obj)
            
            RUNTIME.State = epsych.enState.Error;
        end
        




        
        function set.State(obj,newState)
            global LOG

            timestamp = now;

            prevState = obj.State;
            obj.State = newState;

            ev = epsych.evProgramState(newState,prevState,timestamp);
            notify(obj,'PreStateChange',ev);
            
            try

                switch newState
                    case epsych.enState.Prep
                        LOG.write('Important','Need more info to begin experiment')
                        
                    case epsych.enState.Ready
                        LOG.write('Important','Ready to begin experiment')
                        
                    case {epsych.enState.Run, epsych.enState.Preview}
                        for i = 1:numel(obj.Hardware)
                            LOG.write('Important','Preparing Hardware: "%s"',obj.Hardware(i).Name)
                            
                            e = obj.Hardware(i).prepare;

                            if e
                                LOG.write('Critical','Failed to prepare hardware: "%s"',obj.Hardware(i).Name)
                                LOG.write('Error',obj.ErrorME);
                                obj.State = epsych.enState.Error;
                                return
                            end
                        end

                        LOG.write('Verbose','Creating Runtime Timer')
                        obj.create_timer;

                        start(obj.Timer);
                    
                    case epsych.enState.Halt
                        stop(obj.Timer);
                        
                    case epsych.enState.Pause
                        stop(obj.Timer);

                    case epsych.enState.Resume
                        start(obj.Timer);
                        
                    case epsych.enState.Error
                        stop(obj.Timer);
                        rethrow(obj.ErrorMException);
                end
            
            catch me
                newState = epsych.enState.Error;
                LOG.write(me);
                obj.ErrorMException = me;
                obj.State = newState;
            end
            
            ev = epsych.evProgramState(newState,prevState,timestamp);
            notify(obj,'PostStateChange',ev);

            LOG.write('Verbose','Runtime.State updated from "%s" to "%s"',prevState,newState);
        end % set.State
        
        
        function n = get.nSubjects(obj)
            n = length(obj.Config.Subject);
        end

        function tf = get.isRunning(obj)
            tf = any(obj.State == [epsych.enState.Run, epsych.enState.Preview]);
        end
        
        function sobj = saveobj(obj)
            obj.ConfigIsSaved = true;
            sobj = obj;
            notify(obj,'RuntimeConfigChange');
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
        function runtime_updated(obj,hObj,event)
            global LOG
            
            LOG.write('Verbose','Runtime Object Updated "%s"',hObj.Name);

            obj.ConfigIsSaved = false;
            
            % Test whether Runtime is ready to begin
            h = false; s = false;
            if ~isempty(obj.Hardware)
                h = cellfun(@(a) a.Status == epsych.hw.enStatus.Ready,obj.Hardware);
            end
            
            if ~isempty(obj.Subject)
                s = [obj.Subject.isReady];
            end
            
            obj.ReadyToBegin = all(h) && all(s);

            for i = 1:length(obj.Hardware)
                LOG.write('Verbose','Hardware: %s; status = %s',obj.Hardware{i}.Name,char(obj.Hardware{i}.Status))
            end

            for i = 1:length(obj.Subject)
                if obj.Subject(i).isReady
                    LOG.write('Verbose','Subject: %s [ID %s] is ready',obj.Subject(i).Name,obj.Subject(i).ID)
                else
                    LOG.write('Verbose','Subject: %s [ID %s] is not ready',obj.Subject(i).Name,obj.Subject(i).ID)
                end
            end

            if obj.ReadyToBegin
                LOG.write('Important','Runtime is ready to begin');
            else
                LOG.write('Important','Runtime is not ready to begin');
            end

            if nargin < 3
                notify(obj,'RuntimeConfigChange');    
            else
                notify(obj,'RuntimeConfigChange',event);
            end

        end
    end % methods (Access = private)
   
    methods (Static)
        startFcn(obj)
        timerFcn(obj)
        stopFcn(obj)
        errorFcn(obj)

        function obj = loadobj(s)
            obj = s;
            notify(obj,'RuntimeConfigChange');
        end

    end % methods (Static)
    
end
    
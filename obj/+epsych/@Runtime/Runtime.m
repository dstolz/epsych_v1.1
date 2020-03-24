classdef Runtime < handle & dynamicprops
    
    properties
        
    end
    
    
    properties (Dependent)
        
    end
    
    properties (Transient)
        Timer
        State   (1,1) epsych.State = epsych.State.Prep;
    end
    
    properties (SetAccess = immutable)
        Connector   % wrapper class for ex: TDT RPvds ActiveX control
    end
    
    events
        StateChange
    end
    
    methods
        function obj = Runtime(Connector,varargin)
            obj.Connector = Connector;
           
        end
        
        function call_TimerFcn(obj,varargin)
            
        end
        
        function call_StartFcn(obj,varargin)
            
        end
        
        function call_StopFcn(obj,varargin)
            
        end
        
        function call_ErrorFcn(obj,varargin)
            
        end
        
        
        function set.State(obj,newState)
            timestamp = now;
            
            switch newState
                case epsych.State.Prep
                    
                    
                    
                case [epsych.State.Run, epsych.State.Preview]
                    obj.Connector.initialize;

                    obj.Connector.prepare;

                    obj.create_timer;

                    start(obj.Timer);
                    
                    
                case epsych.State.Halt
                    stop(obj.Timer);
                    
                    
                case epsych.State.Pause
                    
                    
                case epsych.State.Error
            end
            
            prevState = obj.State;
            obj.State = newState;
            
            ev = epsych.ProgramState(newState,prevState,timestamp);
            notify(obj,'StateChange',ev);
        end
        
        
        
                
    end
    
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
    end
   
    methods (Static)
        function obj = loadobj(s)
            
        end
    end
    
end
    
classdef StimType < handle
    
    properties (SetObservable = true)
        Duration     (1,1) double {mustBePositive,mustBeFinite} = 0.1;  % seconds
        
        GateDuration (1,1) double {mustBeNonnegative,mustBeFinite} = 0.002; % seconds
        GateFcn      (1,1) string = "cos2";
        
        Fs           (1,1) double {mustBePositive,mustBeFinite} = 48828.125; % Hz
        
        Normalization (1,1) string {mustBeMember(Normalization,["none","absmax","rms","max","min"])} = "absmax"
        
    end
    
    properties (SetAccess = protected, SetObservable)
        Signal       (1,:) = [];
    end
    
    
    properties (Dependent)
        N
        Time
        Gate
    end
    

    properties (Hidden,Access = protected)
        temporarilyDisableSignalMods (1,1) logical = false;
        els
    end
    
    methods (Abstract)
        obj = update_signal(obj,src,evnt); % updates obj.Signal
    end
    
    methods
    
        function obj = StimType(varargin)
            % does no property name case matching
            for i = 1:2:length(varargin)
                obj.(varargin{i}) = varargin{i+1};
            end
            
            obj.create_listeners;
        end
        
        function t = get.Time(obj)
            t = linspace(0,obj.Duration-1./obj.Fs,obj.N);
        end
        
        function n = get.N(obj)
            n = round(obj.Fs*obj.Duration);
        end
       
        
        function g = get.Gate(obj)
            n = round(obj.GateDuration.*obj.Fs);
            n = n + rem(n,2);
            
            switch obj.GateFcn
                case ""
                    g = [1 1];
                case "cos2"
                    g = hann(n);
                otherwise
                    g = feval(obj.GateFcn,n);
            end
            g = g(:)';
        end
        
        function h = plot(obj,ax)
            if nargin < 2 || isempty(ax), ax = gca; end
            
            h = plot(ax,obj.Time,obj.Signal);
            grid(ax,'on');
            xlabel('time (s)');
            ylabel('amplitude');
        end
    end
    
    methods (Access = protected)
        
        
        function apply_gate(obj)
            if obj.temporarilyDisableSignalMods, return; end
            
            g = obj.Gate;
            
            n = length(g);
            ga = g(1:n/2);
            gb = g(n/2+1:end);
            
            obj.Signal(1:n/2) = obj.Signal(1:n/2) .* ga;
            obj.Signal(end-n/2+1:end) = obj.Signal(end-n/2+1:end) .* gb;
        end
        
        function apply_normalization(obj)
            if obj.temporarilyDisableSignalMods, return; end
            
            switch obj.Normalization
                case "absmax"
                    obj.Signal = obj.Signal ./ max(abs(obj.Signal));
                    
                case "max"
                    obj.Signal = obj.Signal ./ max(obj.Signal);
                    
                case "min"
                    obj.Signal = obj.Signal ./ min(obj.Signal);
                    
                case "rms"
                    obj.Signal = obj.Signal ./ sqrt(mean(obj.Signal.^2));                
            end
        end
        
        function create_listeners(obj)            
            m = metaclass(obj);
            p = m.PropertyList;
            ind = [p.SetObservable] & string({p.SetAccess}) == "public";
            p(~ind) = [];
            
            for i = 1:length(p)
                e(i) = addlistener(obj,p(i).Name,'PostSet',@(~,~) obj.update_signal);
            end
            obj.els = e;
        end
    end
end
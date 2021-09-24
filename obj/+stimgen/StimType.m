classdef (Hidden) StimType < handle & matlab.mixin.Heterogeneous & matlab.mixin.Copyable
    
    properties (SetObservable,AbortSet)
        Duration     (1,1) double {mustBePositive,mustBeFinite} = 0.1;  % seconds
        
        WindowDuration (1,1) double {mustBeNonnegative,mustBeFinite} = 0.002; % seconds
        WindowFcn      (1,1) string = "cos2";
        ApplyWindow    (1,1) logical = true;
        
        Fs           (1,1) double {mustBePositive,mustBeFinite} = 97656.25; % Hz
        
        Normalization (1,1) string {mustBeMember(Normalization,["none","absmax","rms","max","min"])} = "absmax"
    end
    
    properties (SetAccess = protected, SetObservable)
        Signal       (1,:) = [];
    end
    
    
    properties (Dependent)
        N
        Time
        Window
    end
    

    properties (Hidden,Access = protected)
        temporarilyDisableSignalMods (1,1) logical = false;
        els
        GUIHandles
    end
    
    
    methods (Abstract)
        update_signal(obj,src,evnt); % updates obj.Signal
        h = create_gui(obj,src,evnt);
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
       
        
        function g = get.Window(obj)
            n = round(obj.WindowDuration.*obj.Fs);
            n = n + rem(n,2);
            
            if obj.ApplyWindow
                switch obj.WindowFcn
                    case ""
                        g = ones(1,n);
                    case "cos2"
                        g = hann(n);
                    otherwise
                        g = feval(obj.WindowFcn,n);
                end
                g = g(:)'; % conform to row vector
            else
                g = ones(1,n);
            end
        end
        
        function h = plot(obj,ax)
            if nargin < 2 || isempty(ax), ax = gca; end
            
            h = plot(ax,obj.Time,obj.Signal);
            grid(ax,'on');
            xlabel(ax,'time (s)');
        end
        
        function play(obj)
            ap = audioplayer(obj.Signal./max(abs(obj.Signal)),obj.Fs);
            playblocking(ap);
            delete(ap);
        end
    end
    
    methods (Access = protected)
        
        
        function apply_gate(obj)
            if obj.temporarilyDisableSignalMods, return; end
            
            g = obj.Window;
            
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
        
%         function create_handle_listeners(obj)
%             m = metaclass(obj);
%             p = m.PropertyList;
%             ind = [p.SetObservable] & string({p.SetAccess}) == "public";
%             p(~ind) = [];
%             
% 
%             for i = 1:length(p)
%                 e(i) = addlistener(obj,p(i).Name,'PostSet',@obj.update_handle_value);
%             end
%             obj.hels = e;       
%         end
        
        function update_handle_value(obj,src,event)
            h = obj.GUIHandles;
                        
            h.(src.Name).Value = obj.(src.Name);
        end
        
        function interpret_gui(obj,src,event)
            try
                obj.(src.Tag) = event.Value;
                obj.update_signal;
            catch
                obj.(src.Tag) = event.PreviousValue;
            end
        end
    end
    
    methods (Static)
        function c = list
            r = which('stimgen.StimType');
            pth = fileparts(r);
            d = dir(fullfile(pth,'*.m'));
            f = {d.name};
            f(ismember(f,{'StimType.m','StimPlay.m'})) = [];
            c = cellfun(@(a) a(1:end-2),f,'uni',0);
        end
    end
end
classdef Tone < stimgen.StimType
    
    properties
        Frequency (1,1) double {mustBePositive,mustBeFinite} = 1000; % Hz
        OnsetPhase (1,1) double = 0;
    end
    
    methods
        function obj = Tone(varargin)
            obj = obj@stimgen.StimType(varargin{:});
        end
        
        function update_signal(obj)
            t = obj.Time;
            
            obj.Signal = sin(2.*pi.*obj.Frequency.*t+obj.OnsetPhase);
            
            obj.apply_gate;
            
            obj.apply_normalization;
        end
        
        function h = create_gui(obj,src,evnt)
            g = uigridlayout(src);
            g.ColumnWidth = {'1x','1x',50};
            g.RowHeight = repmat({25},1,8);
            
            R = 1;
            x = uieditfield(g,'numeric','Tag','Frequency');
            x.Layout.Column = 2;
            x.Layout.Row = R;
            x.Limits = [100 40000];
            x.ValueDisplayFormat = '%.1f Hz';
            h.Frequency = x;
            
            R = R + 1;
            
            x = uieditfield(g,'numeric','Tag','Duration');
            x.Layout.Column = 2;
            x.Layout.Row = R;
            x.Limits = [0.01 10000];
            x.ValueDisplayFormat = '%.1f ms';
            h.Duration = x;
                        
            R = R + 1;
            
            x = uieditfield(g,'numeric','Tag','GateDuration');
            x.Layout.Column = 2;
            x.Layout.Row = R;
            x.Limits = [1e-3 100];
            x.ValueDisplayFormat = '%.3f ms';
            h.GateDuration = x;
            
            x = uidropdown(g,'Tag','GateDurationMethod');
            x.Layout.Column = 3;
            x.Layout.Row = R;
            x.Items = ["Absolute" "Proportional" "#Periods"];
            x.Value = "#Periods";
            
            structfun(@(a) set(a,'ValueChangedFcn',obj.interpret_gui),h);
        end
        
        
        function interpret_gui(obj,src,evnt)
           
            
        end
        
    end
end
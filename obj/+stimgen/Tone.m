classdef Tone < stimgen.StimType
    
    properties (SetObservable,AbortSet)
        Frequency (1,1) double {mustBePositive,mustBeFinite} = 1000; % Hz
        OnsetPhase (1,1) double = 0;
        
        GateMethod   (1,1) string {mustBeMember(GateMethod,["Duration" "Proportional" "#Periods"])} = "Duration"
    end
    
    methods
        function obj = Tone(varargin)
            obj = obj@stimgen.StimType(varargin{:});
        end
        
        function update_signal(obj)
            t = obj.Time;
            
            obj.Signal = sin(2.*pi.*obj.Frequency.*t+obj.OnsetPhase);
            
            
            switch obj.GateMethod
                case 'Duration'
                    % no conversion needed
                case 'Proportional'
                    obj.GateDuration = obj.GateDuration/100*t(end);
                case '#Periods'
                    obj.GateDuration = 2*obj.GateDuration/obj.Frequency;
            end
            
            
            obj.apply_gate;
            
            obj.apply_normalization;
        end
        
        function h = create_gui(obj,src,evnt)
            g = uigridlayout(src);
            g.ColumnWidth = {'1x','1x','1x'};
            g.RowHeight = repmat({25},1,8);
            
            R = 1;
            x = uilabel(g,'Text','Frequency:');
            x.Layout.Column = 1;
            x.Layout.Row    = R;
            x.HorizontalAlignment = 'right';
            
            x = uieditfield(g,'numeric','Tag','Frequency');
            x.Layout.Column = 2;
            x.Layout.Row = R;
            x.Limits = [100 40000];
            x.ValueDisplayFormat = '%.1f Hz';
            x.Value = obj.Frequency;
            h.Frequency = x;
            
            R = R + 1;
            
            x = uilabel(g,'Text','Duration:');
            x.Layout.Column = 1;
            x.Layout.Row    = R;
            x.HorizontalAlignment = 'right';
            
            x = uieditfield(g,'numeric','Tag','Duration');
            x.Layout.Column = 2;
            x.Layout.Row = R;
            x.Limits = [0.001 10];
            x.ValueDisplayFormat = '%.3f s';
            x.Value = obj.Duration;
            h.Duration = x;
                        
            R = R + 1;
            
            x = uilabel(g,'Text','Gate Duration:');
            x.Layout.Column = 1;
            x.Layout.Row    = R;
            x.HorizontalAlignment = 'right';
            
            x = uieditfield(g,'numeric','Tag','GateDuration');
            x.Layout.Column = 2;
            x.Layout.Row = R;
            x.Limits = [1e-6 10];
            x.ValueDisplayFormat = '%.4f s';
            x.Value = obj.GateDuration;
            h.GateDuration = x;
            
            x = uidropdown(g,'Tag','GateMethod');
            x.Layout.Column = 3;
            x.Layout.Row = R;
            x.Items = ["Duration" "Proportional" "#Periods"];
            x.Value = obj.GateMethod;
            h.GateDurationMethod = x;
            
            structfun(@(a) set(a,'ValueChangedFcn',@obj.interpret_gui),h);
            
            obj.GUIHandles = h;
            
            obj.create_handle_listeners;
        end
        
    end
    
    methods (Access = protected)
        function interpret_gui(obj,src,event)
            try
                obj.(src.Tag) = event.Value;
            catch
                obj.(src.Tag) = event.PreviousValue;
            end
            
            if isequal(src.Tag,'GateMethod')
                switch src.Value
                    case 'Proportional'
                        fmt = '%.2f%%';
                    case 'Duration'
                        fmt = '%.4f s';
                    case '#Periods'
                        fmt = '%.1f periods';
                end
                obj.GUIHandles.GateDuration.ValueDisplayFormat = fmt;
            end
        end
        
    end
end
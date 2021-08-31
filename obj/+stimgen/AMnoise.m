classdef AMnoise < stimgen.Noise
    
    properties (SetObservable,AbortSet)
        AMDepth (1,1) double {mustBeGreaterThanOrEqual(AMDepth,0),mustBeLessThanOrEqual(AMDepth,1)} = 1; % [0 1] 
        AMRate  (1,1) double {mustBePositive,mustBeFinite} = 5; % Hz
        OnsetPhase (1,1) double = 0; % degrees
        
        ApplyViemeisterCorrection (1,1) logical = true;
    end
    
    
    methods
                
        function obj = AMnoise(varargin)
            obj = obj@stimgen.Noise(varargin{:});
            
            obj.create_listeners;
            
            obj.Duration = 1;
        end
        
        
        function update_signal(obj)
            obj.temporarilyDisableSignalMods = true;
            
            update_signal@stimgen.Noise(obj);
            noise = obj.Signal;
            
            obj.temporarilyDisableSignalMods = false;

            
            am = cos(2.*pi.*obj.AMRate.*obj.Time+deg2rad(obj.OnsetPhase));
            am = (am + 1)./2;
            am = am .* obj.AMDepth + 1 - obj.AMDepth;
            
            if obj.ApplyViemeisterCorrection
                am = am .* sqrt(1/(obj.AMDepth^2/2+1));
            end
            
            obj.Signal = noise .* am;
            
            obj.apply_gate;
            
            obj.apply_normalization;
        end
    
        function create_gui(obj,src,evnt)
            g = uigridlayout(src);
            g.ColumnWidth = {'1x','1x','1x'};
            g.RowHeight = repmat({25},1,8);
            
            R = 1;
            x = uilabel(g,'Text','AM Depth:');
            x.Layout.Column = 1;
            x.Layout.Row    = R;
            x.HorizontalAlignment = 'right';
            
            x = uieditfield(g,'numeric','Tag','AMDepth');
            x.Layout.Column = 2;
            x.Layout.Row = R;
            x.Limits = [0 1];
            x.ValueDisplayFormat = '%.2f';
            x.Value = obj.AMDepth;
            h.AMDepth = x;
            
            R = R + 1;
            
            x = uilabel(g,'Text','Onset Phase:');
            x.Layout.Column = 1;
            x.Layout.Row    = R;
            x.HorizontalAlignment = 'right';
            
            x = uieditfield(g,'numeric','Tag','OnsetPhase');
            x.Layout.Column = 2;
            x.Layout.Row = R;
            x.Limits = [-180 180];
            x.ValueDisplayFormat = '%.2f deg';
            x.Value = obj.OnsetPhase;
            h.OnsetPhase = x;
            
            R = R + 1;
            
            
            
            x = uilabel(g,'Text','HighPass Fc:');
            x.Layout.Column = 1;
            x.Layout.Row    = R;
            x.HorizontalAlignment = 'right';
            
            x = uieditfield(g,'numeric','Tag','HighPass');
            x.Layout.Column = 2;
            x.Layout.Row = R;
            x.Limits = [100 40000];
            x.ValueDisplayFormat = '%.1f Hz';
            x.Value = obj.HighPass;
            h.HighPass = x;
            
            R = R + 1;
            x = uilabel(g,'Text','LowPass Fc:');
            x.Layout.Column = 1;
            x.Layout.Row    = R;
            x.HorizontalAlignment = 'right';
            
            x = uieditfield(g,'numeric','Tag','LowPass');
            x.Layout.Column = 2;
            x.Layout.Row = R;
            x.Limits = [100 40000];
            x.ValueDisplayFormat = '%.1f Hz';
            x.Value = obj.LowPass;
            h.LowPass = x;
                        
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
            
            structfun(@(a) set(a,'ValueChangedFcn',@obj.interpret_gui),h);
            
            obj.GUIHandles = h;
        end
        
    end
    
end

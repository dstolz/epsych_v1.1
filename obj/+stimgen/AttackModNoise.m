classdef AttackModNoise < stimgen.Noise
    
    properties (SetObservable,AbortSet)
        AMDepth (1,1) double {mustBeGreaterThanOrEqual(AMDepth,0),mustBeLessThanOrEqual(AMDepth,1)} = 1; % [0 1] 
        AMRate  (1,1) double {mustBePositive,mustBeFinite} = 5; % Hz
        OnsetPhase (1,1) double = 0; % degrees
        
        Z     (1,1) double {mustBeGreaterThanOrEqual(Z,-1),mustBeLessThanOrEqual(Z,1)} = 1; % note that this gets converted to ramped/damped z = [1 2]
        
        AddOnOffperiods (1,1) logical = false;
        
        EnvelopeOnly (1,1) logical = false;
        
        ApplyViemeisterCorrection (1,1) logical = true;
    end
    
    
    methods
                
        function obj = AttackModNoise(varargin)
            obj = obj@stimgen.Noise(varargin{:});
            
            obj.create_listeners;
        end
        
        
        function update_signal(obj)
            if ~obj.EnvelopeOnly
                
                obj.temporarilyDisableSignalMods = true;
                
                update_signal@stimgen.Noise(obj);
                noise = obj.Signal;
                obj.temporarilyDisableSignalMods = false;
                
            end

            z = obj.Z;
            isRamped = z < 0;
            
            period = 1/obj.AMRate;
            t = linspace(0,1,round(period*obj.Fs));
            am = t.^(abs(z)+1).*(1-t);
            
            
            if isRamped
                am = fliplr(am);
            end

            am = am ./ max(am);
            
            nperiods = ceil(obj.Duration/period);
            
            am = repmat(am,1,nperiods);
            
            am(obj.N+1:end) = [];
            
            if obj.AddOnOffperiods
                [~,i] = max(am);
                am = [am(i+1:end) am am(1:i)];
            end


            if obj.ApplyViemeisterCorrection
                am = am .* sqrt(1/(obj.AMDepth^2/2+1));
            end
            
            if obj.EnvelopeOnly
                obj.Signal = am;
            else
                obj.Signal = noise .* am;
            end
            
            obj.apply_gate;
            
            obj.apply_normalization;
        end
    
        function create_gui(obj,src,evnt)
            g = uigridlayout(src);
            g.ColumnWidth = {'1x','1x','1x'};
            g.RowHeight = repmat({25},1,8);
            
            R = 1;
            
            x = uilabel(g,'Text','Z:');
            x.Layout.Column = 1;
            x.Layout.Row    = R;
            x.HorizontalAlignment = 'right';
            
            x = uieditfield(g,'numeric','Tag','Z');
            x.Layout.Column = 2;
            x.Layout.Row = R;
            x.Limits = [-1 1];
            x.ValueDisplayFormat = '%.3f';
            x.Value = obj.Z;
            h.Z = x;
            
            R = R + 1;
            
            
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
        
        
        function interpret_gui(obj,src,event)
            try
                obj.(src.Tag) = event.Value;
            catch
                obj.(src.Tag) = event.PreviousValue;
            end
        end
    end
    
end

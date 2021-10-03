classdef ClickTrain < stimgen.StimType
    
    properties (AbortSet,SetObservable)
        Rate        (1,1) double {mustBePositive,mustBeFinite} = 20; % Hz
        Polarity    (1,1) {mustBeMember(Polarity,[-1 0 1])} = 1;
        ClickDuration (1,1) double {mustBePositive} = .1e-3; % s
    end
    
    
    properties (Constant)
        CalibrationType = "click";
    end
    
    methods
        
        function obj = ClickTrain(varargin)
            
            obj = obj@stimgen.StimType(varargin{:});

            obj.Duration = 1;
            obj.ApplyWindow = false;
            obj.WindowFcn = "";
            
            obj.create_listeners;
            
        end
        
        function set.ClickDuration(obj,d)
            p = 1/obj.Rate;
            
            assert(d <= p,'stimgen:ClickTrain:ClickDuration:InvalidValue', ...
                'Click duration is too long for the current click Rate');
            
            assert(round(obj.Fs*d) > 0,'stimgen:ClickTrain:ClickDuration:InvalidValue', ...
                'Click duration is less than 1 sample at the current sampling rate');
            
            obj.ClickDuration = d;
        end
        
        function update_signal(obj)
            d = obj.Duration;
            p = 1 / obj.Rate;
            
            y = ones(1,round(obj.Fs*obj.ClickDuration));
            
            y = [y zeros(1,round(obj.Fs*p)-length(y))];
            yd = length(y)/obj.Fs;
            n = floor(d / yd);
            
            if obj.Polarity == 0
                x = -1;
                yx = y;
                for i = 2:n
                    y = [y x*yx];
                    x = -x;
                end
            else
                y = obj.Polarity .* y;
                y = repmat(y,1,n);
            end
            
            if obj.N > length(y)
                y = [y,zeros(1,obj.N-length(y))];
            end
            
            obj.Signal = y;
            
            obj.apply_normalization;
        end
        
        
        function h = create_gui(obj,src,evnt)
            g = uigridlayout(src);
            g.ColumnWidth = {'1x','1x','1x'};
            g.RowHeight = repmat({25},1,8);
            
            R = 1;
            x = uilabel(g,'Text','Rate:');
            x.Layout.Column = 1;
            x.Layout.Row    = R;
            x.HorizontalAlignment = 'right';
            
            x = uieditfield(g,'numeric','Tag','Rate');
            x.Layout.Column = 2;
            x.Layout.Row = R;
            x.Limits = [.1 1e6];
            x.ValueDisplayFormat = '%.1f Hz';
            x.Value = obj.Rate;
            h.Rate = x;
            
            R = R + 1;
            
            x = uilabel(g,'Text','Click Duration:');
            x.Layout.Column = 1;
            x.Layout.Row    = R;
            x.HorizontalAlignment = 'right';
            
            x = uieditfield(g,'numeric','Tag','ClickDuration');
            x.Layout.Column = 2;
            x.Layout.Row = R;
            x.Limits = [1e-6 1];
            x.ValueDisplayFormat = '%.6f s';
            x.Value = obj.ClickDuration;
            h.ClickDuration = x;
                        
            R = R + 1;
            
            x = uilabel(g,'Text','Train Duration:');
            x.Layout.Column = 1;
            x.Layout.Row    = R;
            x.HorizontalAlignment = 'right';
            
            x = uieditfield(g,'numeric','Tag','Duration');
            x.Layout.Column = 2;
            x.Layout.Row = R;
            x.Limits = [1e-6 10];
            x.ValueDisplayFormat = '%.3f s';
            x.Value = obj.Duration;
            h.Duration = x;
            
            R = R + 1;
            
            x = uilabel(g,'Text','Polarity:');
            x.Layout.Column = 1;
            x.Layout.Row    = R;
            x.HorizontalAlignment = 'right';
            
            x = uidropdown(g,'Tag','Polarity');
            x.Layout.Column = 2;
            x.Layout.Row = R;
            x.Items = ["+ Positive","+/- Alternate","- Negative"];
            x.ItemsData = {1, 0, -1};
            x.Value = obj.Polarity;
            h.Polarity = x;
            
            
            
            R = R + 1;
            
            x = uilabel(g,'Text','Normalization:');
            x.Layout.Column = 1;
            x.Layout.Row    = R;
            x.HorizontalAlignment = 'right';
            
            x = uidropdown(g,'Tag','Normalization');
            x.Layout.Column = 2;
            x.Layout.Row = R;
            x.Items = ["none","absmax","rms","max","min"];
            x.Value = obj.Normalization;
            h.Normalization = x;
            
            
            
            structfun(@(a) set(a,'ValueChangedFcn',@obj.interpret_gui),h);
            
            obj.GUIHandles = h;
            
%             obj.create_handle_listeners;
        end
        
    end
    
end
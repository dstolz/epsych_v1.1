classdef SignalPlot < gui.PlotHelper
% obj = SignalPlot(watchedParams,[ax],[BoxID])

    properties 
        yScaleMode (1,:) char {mustBeMember(yScaleMode,{'Auto','Equal'})} = 'Equal';
        lineColor = lines;
    end

    properties (SetAccess = protected)
        menuYScalingAuto
        menuYScalingEqual
    end
    
    properties (Constant)
        style = 'Signal';
    end

    methods
        function obj = SignalPlot(watchedParams,varargin)
            narginchk(1,2);
            
            obj = obj@gui.PlotHelper('SignalPlot',varargin{:});
            
            obj.watchedParams = watchedParams;
            
            obj.add_context_menu; % function inherited from gui.PlotHelper
            
            obj.more_context_menus;
            
            % assign local functions to timer inherited from gui.PlotHelper
            obj.timer_StartFcn = @obj.setup;
            obj.timer_TimerFcn = @obj.update;
            
            start(obj.Timer);

        end

    end

    

    methods (Access = private)
        function more_context_menus(obj)
            h = obj.ax.UIContextMenu;
            y = uimenu(h,'Label','Y-Axis Scaling');
            obj.menuYScalingAuto  = uimenu(y,'Label','Auto','Callback',@obj.yscaling);
            obj.menuYScalingEqual = uimenu(y,'Label','Equal','Callback',@obj.yscaling);
            obj.yscaling(obj.(sprintf('menuYScaling%s',obj.yScaleMode)));
        end
    end




    methods (Access = protected)
        
        function yscaling(obj,hObj,event)
            obj.yScaleMode = hObj.Label;
            setpref('epsych_gui_SignalPlot','yScaleMode',obj.yScaleMode);
        end

        function setup(obj,varargin)
            delete(obj.lineH);

            for i = 1:length(obj.watchedParams)
                obj.add_param(obj.watchedParams{i});
            end
            set(obj.lineH,'LineWidth',2);
            
            grid(obj.ax,'on');
            obj.ax.Box = 'on';
            obj.ax.XAxis.Label.String = 'time since start (mm:ss)';                     
            
            xtickformat(obj.ax,'mm:ss.S');
        end
        
        function update(obj,varargin)
            
            if ~isempty(obj.trialParam)
                try
                    obj.trialBuffer(end+1) = obj.getParamVals(obj.TDTActiveX,obj.trialParam);
                catch
                    vprintf(0,1,'Unable to read the RPvds parameter: %s\nUpdate the trialParam to an existing parameter in the RPvds circuit', ...
                        obj.trialParam)
                end
            end
            
            obj.Buffers(:,end+1) = obj.getParamVals(obj.TDTActiveX,obj.watchedParams);
            if obj.setZeroToNan, obj.Buffers(obj.Buffers(:,end)==0,end) = nan; end
            
            obj.Time(end+1) = seconds(etime(clock,obj.startTime));
            
            if obj.paused, return; end
            
            for i = 1:obj.N
                obj.lineH(i).XData = obj.Time;
                obj.lineH(i).YData = obj.Buffers(i,:);
            end
            
            % adjust X axis
            if obj.trialLocked && ~isempty(obj.trialParam)
                obj.ax.XLim = obj.latest_trial_onset + obj.timeWindow;
            else
                obj.ax.XLim = obj.Time(end) + obj.timeWindow;
            end

            % adjust Y scaling
            switch obj.yScaleMode
                case 'Equal'
                    ind = obj.Time >= obj.ax.XLim(1) & obj.Time <= obj.ax.XLim(2);
                    y = obj.Buffers(:,ind);
                    obj.ax.YLim = [-1.1 1.1].*max(abs(y(:)));

                case 'Auto'
                    obj.ax.YLimMode = 'auto';
            end
            
            obj.plot_trial_onset;
            
            drawnow limitrate
        end
        
        
        function add_param(obj,param)
            idx = find(ismember(obj.watchedParams,param));
            if isempty(idx)
                idx = length(obj.lineH) + 1;
            end
            
            % initialize new line object
            obj.lineH(idx) = line(obj.ax, ...
                seconds(0),nan, ...
                'LineWidth',2, ...
                'Color',obj.lineColor(idx,:));
            
            if idx > length(obj.watchedParams)
                obj.watchedParams{idx} = param;
            end
        end
    end
    
    

end
classdef SignalPlot < gui.PlotHelper
% obj = SignalPlot(watchedParams,[ax],[BoxID])

    properties
        yScaleMode (1,:) char {mustBeMember(yScaleMode,{'Auto','Equal'})} = 'Equal';
    end

    methods
        function obj = SignalPlot(watchedParams,varargin)
            narginchk(1,2);
            
            obj = obj@gui.PlotHelper('SignalPlot',varargin{:});
            
            obj.watchedParams = watchedParams;
            
            obj.add_context_menu; % function inherited from gui.PlotHelper
            
            obj.more_context_menus;

            start(obj.Timer);

        end

    end

    

    methods (Access = private)
        function more_context_menus(obj)
            h = obj.ax.UIContextMenu;
            y = uimenu(h,'Tag','uic_yAxisScaling','Label','Y-Axis Scaling');
            uimenu(y,'Tag','uic_yScaleAuto','Label','Auto','Callback',@obj.yscaling);
            uimenu(y,'Tag','uic_yScaleEqual','Label','Equal','Callback',@obj.yscaling);
        end
    end




    methods (Access = protected)
        
        function yscaling(obj,hObj,event)
            obj.yScaleMode = hObj.Label;
            setpref('epsych_gui_SignalPlot','yScaleMode',obj.yScaleMode);
        end

        function setup_plot(obj,varargin)
            delete(obj.lineH);
            
            colors = lines(numel(obj.watchedParams));
            for i = 1:length(obj.watchedParams)
                obj.lineH(i) = line(obj.ax,seconds(0),0, ...
                    'color',colors(i,:), ...
                    'linewidth',2);
            end 

            xtickformat(obj.ax,'mm:ss.S');

            grid(obj.ax,'on');
            obj.ax.Box = 'on';
            wp = obj.watchedParams;
            for i = 1:length(wp)
                if wp{i}(1) == '~',wp{i}(1) = []; end
            end
            obj.ax.XAxis.Label.String = 'time since start (mm:ss)';
            
            obj.startTime = clock;
        end
        
        
        function update(obj,varargin)
            global PRGMSTATE
            
            % stop if the program state has changed
            if ismember(PRGMSTATE,{'STOP','ERROR'}), stop(obj.Timer); return; end
            
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
                obj.ax.XLim = obj.last_trial_onset + obj.timeWindow;
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



            drawnow limitrate
            
        end
        
        function error(obj,varargin)
            vprintf(-1,'SignalPlot closed with error')
            vprintf(-1,varargin{2}.Data.messageID)
            vprintf(-1,varargin{2}.Data.message)
        end
    end
end
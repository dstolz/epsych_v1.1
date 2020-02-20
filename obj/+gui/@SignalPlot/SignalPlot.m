classdef SignalPlot < gui.PlotHelper
% obj = SignalPlot(watchedParams,[ax],[BoxID])

    methods
        function obj = SignalPlot(watchedParams,varargin)
            narginchk(1,2);
            
            obj = obj@gui.PlotHelper('SignalPlot',varargin{:});
            
            obj.watchedParams = watchedParams;
            
            obj.add_context_menu;

            start(obj.Timer);

            

        end
    end

    






    methods (Access = protected)
        function setup_plot(obj,varargin)
            delete(obj.lineH);
            

            for i = 1:length(obj.watchedParams)
                obj.lineH(i) = line(obj.ax,seconds(0),0, ...
                    'color',obj.lineColors(i,:), ...
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
        
        
        function stay_on_top(obj,varargin)
            obj.stayOnTop = ~obj.stayOnTop;
            c = findobj('Tag','uic_stayOnTop');
            if obj.stayOnTop
                c.Label = 'Don''t Keep Window on Top';
                obj.figH.Name = [obj.figName ' - *On Top*'];
            else
                c.Label = 'Keep Window on Top';
                obj.figH.Name = obj.figName;
            end
            FigOnTop(obj.figH,obj.stayOnTop);
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
            
            if obj.trialLocked && ~isempty(obj.trialParam)
                obj.ax.XLim = obj.last_trial_onset + obj.timeWindow;
            else
                obj.ax.XLim = obj.Time(end) + obj.timeWindow;
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
classdef OnlinePlot < gui.PlotHelper
% obj = OnlinePlot(watchedParams,[ax],[BoxID])

    properties (Access = protected)
        yPositions  (:,1) double {mustBeFinite}
        lineColors  (:,3) = lines;
    end
    
    properties (Constant)
        style = 'Online';
    end
    
    methods
        
        % Constructor
        function obj = OnlinePlot(watchedParams,varargin)
            narginchk(1,2);
            
            obj = obj@gui.PlotHelper('OnlinePlot',varargin{:});
                        
            obj.watchedParams = watchedParams;
            
            obj.add_context_menu;

            obj.setZeroToNan = true; 
            
            
            % assign local functions to timer inherited from gui.PlotHelper
            obj.timer_StartFcn = @obj.setup;
            obj.timer_TimerFcn = @obj.update;
            
            start(obj.Timer);
            
        end
        
        % Destructor
        function delete(obj)
            try
                stop(obj.Timer);
            end
        end
        
        function set.yPositions(obj,y)
            assert(length(y) == obj.N,'epsych:OnlinePlot:set.yPositions', ...
                'Must set all yPositions at once');
            obj.yPositions = y;
        end
        
        function y = get.yPositions(obj)
            if isempty(obj.yPositions)
                y = 1:obj.N;
            else
                y = obj.yPositions;
                if length(y) < obj.N
                    y = [y; y(end)+(1:obj.N-length(y))'+max(diff(y))];
                else
                    y = y(1:obj.N);
                end
                
            end
        end
        

    end
    
    
    
    
    
    methods (Access = protected)
        function update(obj,varargin)
            persistent P_currentTrialIndex
            if isempty(P_currentTrialIndex), P_currentTrialIndex = 0; end
            
            
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
                obj.lineH(i).YData = obj.yPositions(i).*obj.Buffers(i,:);
            end
            
            if obj.trialLocked && ~isempty(obj.trialParam)
                obj.ax.XLim = obj.latest_trial_onset + obj.timeWindow;
            else
                obj.ax.XLim = obj.Time(end) + obj.timeWindow;
            end
            
            obj.plot_trial_onset;
            
            if obj.currentTrialIndex > P_currentTrialIndex
                obj.ax.Title.String = sprintf('Trial #%d - Trial Type %d', ...
                    obj.currentTrialIndex,obj.currentTrialType);
                P_currentTrialIndex = obj.currentTrialIndex;
            end
            
            drawnow limitrate
        end
        
        function setup(obj,varargin)
            delete(obj.lineH);
            
           
            wp = obj.watchedParams;
            for i = 1:length(wp)
                obj.add_param(wp{i});
                if wp{i}(1) == '~',wp{i}(1) = []; end
            end
             
            grid(obj.ax,'on');
            
            obj.ax.XMinorGrid = 'on';
            obj.ax.Box = 'on';
            obj.ax.YAxis.Limits = [.8 obj.yPositions(end)+.2];
            obj.ax.YAxis.TickValues = obj.yPositions;
            obj.ax.YAxis.TickLabelInterpreter = 'none';
            obj.ax.XAxis.Label.String = 'session time (mm:ss)';
           
            obj.ax.YAxis.TickLabels = wp;
            
            xtickformat(obj.ax,'mm:ss.S');
        end

        
        function add_param(obj,param)
            idx = find(ismember(obj.watchedParams,param));
            if isempty(idx)
                idx = length(obj.lineH) + 1;
            end
            
            % initialize new line object
            obj.lineH(idx) = line(obj.ax, ...
                seconds(0),obj.yPositions(idx), ...
                'LineWidth',10, ...
                'Color',obj.lineColors(idx,:));
            
            if idx > length(obj.watchedParams)
                obj.watchedParams{idx} = param;
            end
        end
    end
    
    
end











classdef OnlinePlot < gui.PlotHelper
% obj = OnlinePlot(watchedParams,[ax],[BoxID])

    properties
        yPositions  (:,1) double {mustBeFinite}
        
    end
    
    
    methods
        
        % Constructor
        function obj = OnlinePlot(watchedParams,varargin)
            narginchk(1,2);
            
            obj = obj@gui.PlotHelper('OnlinePlot',varargin{:});
                        
            obj.watchedParams = watchedParams;
            
            obj.add_context_menu;

            obj.setZeroToNan = true; 
            
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
        
        
        
        function to = last_trial_onset(obj)
            B = obj.trialBuffer;
            idx = find(B(2:end) > B(1:end-1),1,'last'); % find onsets
            if isempty(idx)
                to = obj.Time(end);
            else
                to = obj.Time(idx);
            end                
        end
        


    end
    
    
    
    
    
    
    
    
    
    
    methods (Access = protected)
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
                    c = findobj(obj.figH,'Tag','uic_plotType');
                    delete(c);
                    obj.trialParam = '';
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
                obj.ax.XLim = obj.last_trial_onset + obj.timeWindow;
            else
                obj.ax.XLim = obj.Time(end) + obj.timeWindow;
            end
            drawnow limitrate
            
        end
        
        function error(obj,varargin)
            vprintf(-1,'OnlinePlot closed with error')
            vprintf(-1,varargin{2}.Data.messageID)
            vprintf(-1,varargin{2}.Data.message)
        end

        function setup_plot(obj,varargin)
            delete(obj.lineH);
            
            for i = 1:length(obj.watchedParams)
                obj.lineH(i) = line(obj.ax,seconds(0),obj.yPositions(i), ...
                    'color',obj.lineColors(i,:), ...
                    'linewidth',11);
            end
            
            
            xtickformat(obj.ax,'mm:ss.S');
            grid(obj.ax,'on');
            
            obj.ax.XMinorGrid = 'on';
            obj.ax.Box = 'on';
            obj.ax.YAxis.Limits = [.8 obj.yPositions(end)+.2];
            obj.ax.YAxis.TickValues = obj.yPositions;
            obj.ax.YAxis.TickLabelInterpreter = 'none';
            wp = obj.watchedParams;
            for i = 1:length(wp)
                if wp{i}(1) == '~',wp{i}(1) = []; end
            end
            obj.ax.YAxis.TickLabels = wp;
            obj.ax.XAxis.Label.String = 'time since start (mm:ss)';
            
            obj.startTime = clock;
        end
        
        
        
    end
    
    
end











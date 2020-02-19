classdef OnlinePlot < gui.PlotHelper
    
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
        
        function pause(obj,varargin)
            obj.paused = ~obj.paused;
            
            c = findobj('tag','uic_pause');
            if obj.paused
                c(1).Label = 'Catch up >';
            else
                c(1).Label = 'Pause ||';
            end
        end
%         
%         function c = get.figH(obj)
%             c = ancestor(obj.ax,'figure');
%         end
%         
%         function s = get.figName(obj)
%             s = sprintf('Online Plot | Box %d',obj.BoxID);
%         end
        
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
                    c = findobj('Tag','uic_plotType');
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
        
        
        function add_context_menu(obj)
            c = uicontextmenu;
            c.Parent = obj.figH;
            uimenu(c,'Tag','uic_stayOnTop','Label','Keep Window on Top','Callback',@obj.stay_on_top);
            uimenu(c,'Tag','uic_pause','Label','Pause ||','Callback',@obj.pause);
            uimenu(c,'Tag','uic_plotType','Label','Set Plot to Trial-Locked','Callback',@obj.plot_type);
            uimenu(c,'Tag','uic_timeWindow','Label',sprintf('Time Window = [%.1f %.1f] seconds',obj.timeWindow2number),'Callback',@obj.update_window);
            obj.ax.UIContextMenu = c;
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
        
        function plot_type(obj,varargin)
            obj.trialLocked = ~obj.trialLocked;
            c = findobj('Tag','uic_plotType');
            atw = abs(obj.timeWindow);
            if isempty(obj.trialParam)
                vprintf(0,1,'Unable to set the plot to Trial-Locked mode because the trialParam is empty')
            elseif obj.trialLocked
                obj.timeWindow = [-min(atw) max(atw)];
                c.Label = 'Set Plot to Free-Running';
            else
                obj.timeWindow = [-max(atw) min(atw)];
                c.Label = 'Set Plot to Trial-Locked';
            end
        end
        
        function update_window(obj,varargin)
            % temporarily disable stay on top if selected
            FigOnTop(obj.figH,false);
            r = inputdlg('Adjust time windpw (seconds)','Online Plot', ...
                1,{sprintf('[%.1f %.1f]',obj.timeWindow2number)});
            if isempty(r), return; end
            r = str2num(char(r)); %#ok<ST2NM>
            if numel(r) ~= 2
                vprintf(0,1,'Must enter 2 values for the time window')
                return
            end
            obj.timeWindow = seconds(r(:)');
            c = findobj('Tag','uic_timeWindow');
            c.Label = sprintf('Time Window = [%.1f %.1f] seconds',obj.timeWindow2number);
            FigOnTop(obj.figH,obj.stayOnTop);
        end
        
        function s = timeWindow2number(obj)
            s = cellstr(char(obj.timeWindow));
            s = cellfun(@(a) str2double(a(1:find(a==' ',1,'last')-1)),s);
        end
    end
    
    
end











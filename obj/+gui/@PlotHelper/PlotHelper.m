classdef PlotHelper < gui.Helper

    properties        
        
        watchedParams (:,1)  cell
        
        trialParam  (1,:) char

        timeWindow  (1,2) duration = seconds([-10 1]);

        stayOnTop   (1,1) logical = false;
        
        paused      (1,1) logical = false;
        
        trialLocked (1,1) logical = false;

        setZeroToNan (1,1) logical = false;


        timer_StartFcn
        timer_TimerFcn
        timer_StopFcn 
        timer_ErrorFcn

    end

    properties (SetAccess = protected)
        figName     (1,:)  char
        lineH       (:,1)  matlab.graphics.primitive.Line % handles to line objects [obj.N,1]
        
        startTime   (1,6)  double % = clock
        
        BoxID       (1,1)  uint8 = 1;
        
        Buffers     (:,:) single
        trialBuffer (1,:) single
        Time        (:,1) duration
    end

    properties (SetAccess = protected,Hidden)
        Timer       (1,1)
    end
    
    properties (Dependent)
        figH       %matlab.ui.Figure
        N          % number of watched parameters
    end

    properties (SetAccess = immutable)
        ax (1,1)
    end
    
    methods (Abstract, Access = protected)
        setup(obj,varargin)
        update(obj,varargin)
    end

    methods
        % Constructor
        function obj = PlotHelper(subName,ax,BoxID)
            narginchk(1,3);
            
            if nargin < 2 || isempty(ax), ax = gca;     end
            if nargin < 3 || isempty(BoxID), BoxID = 1; end
            
            
            
            obj.ax = ax;
            
            global AX
            
            obj.TDTActiveX = AX;
            obj.ax         = ax;
            obj.BoxID      = BoxID;
            
            % set default trial-based parameter tag to use.
            % > #TrigState~1 is contained in the standard epsych RPvds
            % macros and is assigned an integer id after the ~ based on the
            % macros settings.  Default = 1.
            obj.trialParam = sprintf('#TrigState~%d',BoxID);
            
            
            obj.Timer = ep_GenericGUITimer(obj.figH,subName);
            obj.Timer.StartFcn = @obj.call_timer_StartFcn;
            obj.Timer.TimerFcn = @obj.call_timer_TimerFcn;
            obj.Timer.StopFcn  = @obj.call_timer_StopFcn;
            obj.Timer.ErrorFcn = @obj.call_timer_ErrorFcn;
            obj.Timer.Period = 0.05;
        end
        
        % Destructor
        function delete(obj)
            try
                stop(obj.Timer);
            end

            try
                delete(obj.Timer);
            end
        end



        function call_timer_StartFcn(obj,varargin)
            global PRGMSTATE

            % stop if the program state has changed
            if ismember(PRGMSTATE,{'STOP','ERROR'}), stop(obj.Timer); return; end
            
            feval(obj.timer_StartFcn,varargin{:});            
        end

        function call_timer_TimerFcn(obj,varargin)
            global PRGMSTATE

            % stop if the program state has changed
            if ismember(PRGMSTATE,{'STOP','ERROR'}), stop(obj.Timer); return; end
            
            feval(obj.timer_TimerFcn,varargin{:});            
        end

        function call_timer_StopFcn(obj,varargin)
            if isempty(obj.timer_StopFcn), return; end
            feval(obj.timer_StopFcn,varargin{:});            
        end

        function call_timer_ErrorFcn(obj,varargin)
            if isempty(obj.timer_ErrorFcn), return; end
            feval(obj.timer_ErrorFcn,varargin{:});            
        end






        
        
        function remove_param(obj,param)
            ind = ismember(obj.watchedParams,param);
            obj.lineH(ind) = [];
            obj.ax.YAxis.TickLabels(ind) = [];
            obj.watchedParams(ind) = [];
        end

        



        function s = get.N(obj)
            s = numel(obj.watchedParams);
        end
        

        function h = get.figH(obj)
            h = ancestor(obj.ax,'figure');
            if isempty(h)
                h = figure;
            end
        end

        
        
        
        function add_context_menu(obj)
            c = uicontextmenu(obj.figH);
%             uimenu(c,'Tag','uic_stayOnTop','Label','Keep Window on Top','Callback',@obj.stay_on_top);
            uimenu(c,'Tag','uic_pause','Label','Pause ||','Callback',@obj.pause);
            uimenu(c,'Tag','uic_plotType','Label','Set Plot to Trial-Locked','Callback',@obj.plot_type);
            uimenu(c,'Tag','uic_timeWindow','Label',sprintf('Time Window = [%.1f %.1f] seconds',obj.timeWindow2number),'Callback',@obj.update_window);
            uimenu(h,'Tag','uic_AddParam','Label','Add Parameter','Callback',@obj.addremove_param);
            uimenu(h,'Tag','uic_RemoveParam','Label','Remove Parameter','Callback',@obj.addremove_param);
            obj.ax.UIContextMenu = c;
        end

        function pause(obj,varargin)
            obj.paused = ~obj.paused;
            
            c = findobj(obj.figH,'tag','uic_pause');
            if obj.paused
                c(1).Label = 'Catch up >';
            else
                c(1).Label = 'Pause ||';
            end
        end
        
        function stay_on_top(obj,varargin)
            obj.stayOnTop = ~obj.stayOnTop;
            c = findobj(obj.figH,'Tag','uic_stayOnTop');
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
            c = findobj(obj.figH,'Tag','uic_plotType');
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
            c = findobj(obj.figH,'Tag','uic_timeWindow');
            c.Label = sprintf('Time Window = [%.1f %.1f] seconds',obj.timeWindow2number);
            FigOnTop(obj.figH,obj.stayOnTop);
        end
        
        function s = timeWindow2number(obj)
            s = cellstr(char(obj.timeWindow));
            s = cellfun(@(a) str2double(a(1:find(a==' ',1,'last')-1)),s);
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
end
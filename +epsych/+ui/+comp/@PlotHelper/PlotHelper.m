classdef PlotHelper < epsych.ui.comp.Helper

    properties        
        
        watchedParams (:,1)  cell
        
        trialParam  (1,:) char

        timeWindow  (1,2) duration = seconds([-10 0]);

        
        paused      (1,1) logical = false;
        
        trialLocked (1,1) logical = false;

        setZeroToNan (1,1) logical = false;

        BoxID       (1,1)  uint8 {mustBeNonempty,mustBeNonNan} = 1;

        timer_StartFcn
        timer_TimerFcn
        timer_StopFcn 
        timer_ErrorFcn


        new_trial_Callback

    end

    properties (SetAccess = protected)
        figName     (1,:)  char
        lineH       (:,1)  matlab.graphics.primitive.Line % handles to line objects [obj.N,1]
        
        startTime   (1,6)  double % = clock
        
        
        Buffers     (:,:) single
        trialBuffer (1,:) single
        Time        (:,1) duration

        menuPause
        menuTrialType
        menuTimeWindow
    end
    
    properties (Constant, Abstract)
        style
    end

    properties (SetAccess = protected,Hidden)
        Timer       (1,1)
    end

    properties (Access = private)
        prefName
        lastTrialOnset = seconds(0);
    end

    properties (SetAccess = private)
        currentTrialIndex
        currentTrialType
        
        el_NewTrial % event listener
    end
    
    properties (Dependent)
        figH       %matlab.ui.Figure
        N          % number of watched parameters
        timeWindow2number
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
            
            
            obj.prefName = sprintf('PlotHelper_%s',obj.style);
            obj.timeWindow  = getpref(obj.prefName,'timeWindow',seconds([-10 0]));
            obj.trialLocked = getpref(obj.prefName,'trialLocked',false);
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
            global RUNTIME

            obj.startTime = RUNTIME.StartTime;
            
            feval(obj.timer_StartFcn,varargin{:});            
        end

        function call_timer_TimerFcn(obj,varargin)
            global PRGMSTATE

            % stop if the program state has changed
            if ismember(PRGMSTATE,{'STOP','ERROR'}), stop(obj.Timer); return; end
            
            feval(obj.timer_TimerFcn,varargin{:});            
        end

        function call_timer_StopFcn(obj,varargin)
            if isempty(obj.timer_StopFcn)
                stop(obj.Timer)
            else
                feval(obj.timer_StopFcn,varargin{:});
            end

            try, delete(obj.Timer); end
        end

        function call_timer_ErrorFcn(obj,varargin)
            if isempty(obj.timer_ErrorFcn)
                stop(obj.Timer)
            else
                feval(obj.timer_ErrorFcn,varargin{:});
            end

            try, delete(obj.Timer); end
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
            obj.menuPause      = uimenu(c,'Label','Pause ||','Callback',@obj.toggle_Paused);
            if obj.trialLocked
                str = 'Set Plot to Free-Running';
            else
                str = 'Set Plot to Trial-Locked';
            end
            obj.menuTrialType  = uimenu(c,'Label',str,'Callback',@obj.toggle_trialLocked);
            obj.menuTimeWindow = uimenu(c,'Label',sprintf('Time Window = [%.1f %.1f] seconds',obj.timeWindow2number),'Callback',@obj.update_timeWindow);
            obj.ax.UIContextMenu = c;
        end
        
        function set.paused(obj,p)
            obj.paused = p;
            if obj.paused
                obj.menuPause.Label = 'Resume >';
            else
                obj.menuPause.Label = 'Pause ||';
            end
        end

        function toggle_Paused(obj,varargin)
            obj.paused = ~obj.paused;
        end
        
        
        function set.trialLocked(obj,t)
            obj.trialLocked = t;
            atw = abs(obj.timeWindow);
            if isempty(obj.trialParam)
                vprintf(0,1,'Unable to set the plot to Trial-Locked mode because the trialParam is empty')
            elseif obj.trialLocked
                obj.timeWindow = [-min(atw) max(atw)];
                obj.menuTrialType.Label = 'Set Plot to Free-Running';
            else
                obj.timeWindow = [-max(atw) min(atw)];
                obj.menuTrialType.Label = 'Set Plot to Trial-Locked';
            end
            
            setpref(obj.prefName,'trialLocked',obj.trialLocked);
        end
        
        function toggle_trialLocked(obj,varargin)
            obj.trialLocked = ~obj.trialLocked;
        end
        
        function set.timeWindow(obj,w)
            if isa(w,'duration')
                obj.timeWindow = w;
            else
                obj.timeWindow = seconds(w);
            end
            obj.menuTimeWindow.Label = sprintf('Time Window = [%.1f %.1f] seconds',obj.timeWindow2number);            
            setpref(obj.prefName,'timeWindow',obj.timeWindow);
        end
        
        function update_timeWindow(obj,varargin)
            % temporarily disable stay on top if selected
            curState = FigOnTop(obj.figH,false);
            w = inputdlg('Adjust time window (seconds)','Online Plot', ...
                1,{sprintf('[%.1f %.1f]',obj.timeWindow2number)});
            FigOnTop(obj.figH,curState);
            if isempty(w), return; end
            obj.timeWindow = seconds(str2num(char(w))); %#ok<ST2NM>
        end
        
        function s = get.timeWindow2number(obj)
            s = seconds(obj.timeWindow);
        end
        
        
        function to = latest_trial_onset(obj)
            B = obj.trialBuffer;
            idx = find(B(2:end) > B(1:end-1),1,'last'); % find onsets of "InTrial" parameter
            if isempty(idx)
                to = seconds(0);
            else
                to = obj.Time(idx);
            end                
        end
        
        
        function h = plot_trial_onset(obj)
            h = [];
            lo = obj.latest_trial_onset;
            
            if isempty(lo) || obj.lastTrialOnset == lo, return; end
                            
            h = line(obj.ax,[lo lo],[-1 1].*1e6,'color',[1 0.2 0.2]);
            obj.lastTrialOnset = lo;
        end
        
        function new_trial(obj,~,trialData)
            obj.currentTrialIndex = trialData.Data.TrialIndex;
            obj.currentTrialType  = trialData.Data.NextTrialID;

            if ~isempty(obj.new_trial_Callback)
                feval(obj.new_trial_Callback,obj);
            end
        end


        function set.BoxID(obj,id)
            global RUNTIME
            obj.BoxID = id;
            delete(obj.el_NewTrial); % destroy old listener and create a new one for the new BoxID
            obj.el_NewTrial = addlistener(RUNTIME.HELPER(obj.BoxID),'NewTrial',@obj.new_trial);
        end
    end
end
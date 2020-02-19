classdef PlotHelper < gui.Helper

    properties        
        
        watchedParams (:,1)  cell
        
        trialParam  (1,:) char

        timeWindow  (1,2) duration = seconds([-10 1]);

        lineWidth   (:,1) double {mustBePositive,mustBeFinite} % line plot width [obj.N,1]
        lineColors  (:,3) double {mustBeNonnegative,mustBeLessThanOrEqual(lineColors,1)} % line colors [obj.N,3]
        
        stayOnTop   (1,1) logical = false;
        
        
        paused      (1,1) logical = false;
        
        trialLocked (1,1) logical = false;

        setZeroToNan (1,1) logical = false;

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

    properties (SetAccess = private,Hidden)
        Timer       (1,1)
    end
    
    properties (Dependent)
        figH        (1,1)  %matlab.ui.Figure
        N           (1,:)  double % number of watched parameters
    end

    properties (SetAccess = immutable)
        ax (1,1)
    end
    
    methods (Abstract, Access = protected)
        setup_plot(obj,varargin)
        update(obj,varargin)
        error(obj,varargin)
    end

    methods
        % Constructor
        function obj = PlotHelper(TDTActiveX,ax,BoxID)
            narginchk(1,3);
            
            if nargin < 2 || isempty(ax), ax = gca;     end
            if nargin < 3 || isempty(BoxID), BoxID = 1; end
            
            obj.ax = ax;
            
            
            obj.TDTActiveX = TDTActiveX;
            obj.ax         = ax;
            obj.BoxID      = BoxID;
            
            % set default trial-based parameter tag to use.
            % > #TrigState~1 is contained in the standard epsych RPvds
            % macros and is assigned an integer id after the ~ based on the
            % macros settings.  Default = 1.
            obj.trialParam = sprintf('#TrigState~%d',BoxID);
            
            
            obj.Timer = ep_GenericGUITimer(obj.figH,'SignalPlot');
            obj.Timer.StartFcn = @obj.setup_plot;
            obj.Timer.TimerFcn = @obj.update;
            obj.Timer.ErrorFcn = @obj.error;
            obj.Timer.Period = 0.05;
        end
        
        % Destructor
        function delete(obj)
            try
                stop(obj.Timer);
            end
        end

        function s = get.N(obj)
            s = numel(obj.watchedParams);
        end
        
        function w = get.lineWidth(obj)
            if isempty(obj.lineWidth)
                w = repmat(11,obj.N,1);
            else
                w = obj.lineWidth;
                if length(w) < obj.N
                    w = [w; repmat(10,obj.N-length(w),1)];
                else
                    w = w(1:obj.N);
                end
            end
        end

        function set.lineWidth(obj,w)
            % sets all lines to a width w
            set(obj.lineH,'LineWidth',w);
        end

        
        function c = get.lineColors(obj)
            if isempty(obj.lineColors)
                c = lines(obj.N);
            else
                c = obj.lineColors;
                if size(c,1) < obj.N
                    x = lines(obj.N);
                    c = [c; x(size(c,1)+1:obj.N,:)];
                else
                    c = c(1:obj.N);
                end
            end 
        end

        function h = get.figH(obj)
            h = ancestor(obj.ax,'figure');
        end
    end
end
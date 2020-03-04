classdef PsychPlot < gui.Helper
    
    properties
        ax       (1,1)
        
        ParameterName (1,:) char
        
        metricsObj     (1,1) % metrics.Metrics object
        
        % must jive with obj.metricsObj.ValidPlotTypes
        PlotType    (1,:) char = 'Hit Rate';
        
        LineColor   (:,:) double {mustBeNonnegative,mustBeLessThanOrEqual(LineColor,1)}   = [.2 .6 1; 1 .6 .2];
        MarkerColor (:,:) double {mustBeNonnegative,mustBeLessThanOrEqual(MarkerColor,1)} = [0 .4 .8; .8 .4 0];

        BoxID       (1,1)  uint8 {mustBeNonempty,mustBeNonNan} = 1;
    end
    
    properties (SetAccess = private)
        LineH
        ScatterH
        TextH
        
        el_NewPhysData
    end
    
    
    methods
        function obj = PsychPlot(pObj,ax,BoxID)
            narginchk(1,3);

            if nargin < 2 || isempty(ax), ax = gca; end
            if nargin < 3 || isempty(BoxID), BoxID = 1; end

            obj.metricsObj = pObj;

            obj.ax = ax;
            
            obj.build;
            obj.BoxID = BoxID;
            obj.update;
            
        end
        
        
        
        function set.ParameterName(obj,name)
            ind = ismember(obj.ValidParameters,name);
            assert(any(ind),'ep_phys_Detection:set.ParameterName','Invalid parameter name: %s',name);
            obj.ParameterName = name;
            obj.update;
        end
        
        
        function build(obj)
            cla(obj.ax);
            
            obj.ScatterH = scatter(nan,nan,100,'filled','Parent',obj.ax,'Marker','s');
            % 'MarkerFaceColor','flat');
            
            obj.LineH = line(obj.ax,nan,nan,'Marker','none', ...
                'AlignVertexCenters','on', ...
                'LineWidth',2,'Color',obj.LineColor(1,:));
            grid(obj.ax,'on');
            
            obj.ax.TickLabelInterpreter = 'none';
            obj.ax.XTickLabelRotation = 45;
            
            obj.setup_xaxis_label;
            obj.setup_yaxis_label;
        end
        
        function update(obj,src,event)
            % although data is updated in src and event, just use the obj.metricsObj
            lh = obj.LineH;
            sh = obj.ScatterH;
            
            if isempty(obj.metricsObj.TRIALS), return; end
                       
            X = 1:length(obj.metricsObj.TrialTypesChar);
            P = obj.metricsObj.compute_performance;
            
            yLimits = [];
            switch obj.PlotType
                case 'd-prime'
                    Y = [P.DPrime];
                    
                case 'Hit Rate'
                    Y = [P.HitRate];
                    yLimits = [0 1];
                    
                case 'FA Rate'
                    Y = [P.FalseAlarmRate];
                    yLimits = [0 1];
                    
                case 'Miss Rate'
                    Y = [P.MissRate];
                    yLimits = [0 1];
                    
                case 'Bias c'
                    Y = [P.c];
                    
                case 'Bias ln(beta)'
                    Y = [P.beta];

                case 'Lapse Rate'
                    Y = [P.LapseRate];
                    yLimits = [0 1];
                    
                case 'Abort Rate'
                    Y = [P.AbortRate];
                    yLimits = [0 1];
            end
            
            lh.XData = X;
            lh.YData = Y;
                        
            sh.XData = X;
            sh.YData = Y;

            sh.SizeData = repmat(180,size(X));

            c = repmat(obj.MarkerColor(1,:),length(X),1);
            sh.CData = c;
            
            uistack(sh,'top');
            
            if isempty(yLimits)
                obj.ax.YLimMode = 'auto';
            else
                obj.ax.YLim = yLimits;
            end
            
            obj.ax.XLim = [1 length(P)];
            obj.ax.XTick = 1:length(P);
            obj.ax.XTickLabel = {P.TrialType};
            
            for i = 1:length(X)
                try delete(obj.TextH(i)); end %#ok<TRYNC> % lazy
                obj.TextH(i) = text(obj.ax,X(i),Y(i),num2str(P(i).N,'%d'), ...
                    'HorizontalAlignment','center','VerticalAlignment','middle', ...
                    'Color',[0 0 0],'FontSize',12,'FontWeight','bold','Color','w');
            end
            
            obj.setup_xaxis_label;
            obj.setup_yaxis_label;
            

            tstr = sprintf('%s [%d] - Trial %d', ...
                obj.metricsObj.Subject.Name, ...
                obj.metricsObj.BoxID, ...
                obj.metricsObj.TrialIndex);
            
            title(obj.ax,tstr);
            
            
        end
        
        function update_parameter(obj,hObj,mouse)
            % TO DO: support multiple parameters at a time
            switch hObj.Tag
                case 'abscissa'
                    vp = obj.metricsObj.ValidParameters;
                    i = find(ismember(vp,obj.metricsObj.ParameterName));
                    [sel,ok] = listdlg('ListString',vp, ...
                        'SelectionMode','single', ...
                        'InitialValue',i,'Name','Plot', ...
                        'PromptString','Select Independent Variable:', ...
                        'ListSize',[180 150]);
                    if ~ok, return; end
                    obj.metricsObj.ParameterName = vp{sel};
                    try
                        delete(obj.TextH);
                    end
                    
                case 'ordinate'
                    i = find(ismember(obj.metricsObj.ValidPlotTypes,obj.PlotType));
                    [sel,ok] = listdlg('ListString',obj.metricsObj.ValidPlotTypes, ...
                        'SelectionMode','single', ...
                        'InitialValue',i,'Name','Plot', ...
                        'PromptString','Select Plot Type:', ...
                        'ListSize',[180 150]);
                    if ~ok, return; end
                    obj.PlotType = obj.metricsObj.ValidPlotTypes{sel};
                    
            end
            obj.update;
        end
        
        
        function setup_xaxis_label(obj)
            x = xlabel(obj.ax,obj.metricsObj.ParameterName, ...
                'Tag','abscissa','Interpreter','none');
            x.ButtonDownFcn = @obj.update_parameter;
        end
        
        function setup_yaxis_label(obj)
            y = ylabel(obj.ax,obj.PlotType, ...
                'Tag','ordinate','Interpreter','none');
            y.ButtonDownFcn = @obj.update_parameter;
        end
        
        
        function set.BoxID(obj,id)
            obj.BoxID = id;
            delete(obj.el_NewPhysData); % destroy old listener and create a new one for the new BoxID
            obj.el_NewPhysData = addlistener(obj.metricsObj,'NewPhysData',@obj.update);
        end
    end
    
end
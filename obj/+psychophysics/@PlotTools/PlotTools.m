classdef PlotTools < handle
    
    properties
        AxesH       (1,1)
        
        
        % must jive with obj.ValidPlotTypes
        PlotType    (1,:) char {mustBeMember(PlotType,{'DPrime','Hit_Rate','FA_Rate','Bias'})} = 'DPrime';
        
        LineColor   (:,:) double {mustBeNonnegative,mustBeLessThanOrEqual(LineColor,1)}   = [.2 .6 1; 1 .6 .2];
        MarkerColor (:,:) double {mustBeNonnegative,mustBeLessThanOrEqual(MarkerColor,1)} = [0 .4 .8; .8 .4 0];
    end
    
    properties (SetAccess = private)
        LineH
        ScatterH
        TextH
    end
    
    properties (Access = private)
        listener_ParameterUpdate
    end
    
    properties (Constant)
        ValidPlotTypes = {'DPrime','Hit_Rate','FA_Rate','Bias'};
    end
    
    methods
        function obj = PlotTools(src,ax)
            if nargin < 2 || isempty(ax), ax = gca; end

            obj.AxesH = ax;
            
            obj.setup_xaxis_label(src,[]);
            obj.setup_yaxis_label(src,[]);
            
            obj.listener_ParameterUpdate = addlistener(src,'ParameterUpdate',@obj.setup_xaxis_label);
            
        end
        

        function h = get.LineH(obj)
            h = findobj(obj.AxesH,'type','line');
        end

       
        
        function update_plot(obj,src,event)
            lh = obj.LineH;
            sh = obj.ScatterH;
            if isempty(lh) || isempty(sh) || ~isvalid(lh) || ~isvalid(sh)
                sh = scatter(nan,nan,100,'filled','Parent',obj.AxesH,'Marker','o', ...
                    'MarkerFaceColor','flat');
                
                lh = line(obj.AxesH,nan,nan,'Marker','none', ...
                    'AlignVertexCenters','on', ...
                    'LineWidth',2,'Color',obj.LineColor(1,:));
                
                grid(obj.AxesH,'on');
            end
            
            X = src.ParameterValues;
            Y = src.(obj.PlotType);
            C = src.Trial_Count;
            
            lh.XData = X;
            lh.YData = Y;
            
            
            sh.XData = X;
            sh.YData = Y;
            s = repmat(120,size(X));
            ind = C == 0;
            s(ind) = 30;
            sh.SizeData = s;
            c = repmat(obj.MarkerColor(1,:),length(X),1);
            sh.CData = c;
            
            uistack(sh,'top');
            
            for i = 1:length(X)
                if C(i) == 0, continue; end
                obj.TextH(i) = text(obj.AxesH,X(i),Y(i),num2str(C(i),'%d'), ...
                    'HorizontalAlignment','center','VerticalAlignment','middle', ...
                    'Color',[1 1 1],'FontSize',8);
            end
            
            obj.setup_xaxis_label(src,[]);
            obj.setup_yaxis_label(src,[]);
            
            if exist('event','var') && isfield(event,'Subject')
                tstr = sprintf('"%s" - Trial %d',event.Subject.Name,src.Trial_Index);
            else
                tstr = sprintf('Box ID %d - Trial %d',src.BoxID,src.Trial_Index);
            end
            title(obj.AxesH,tstr);
        end
        
        function update_parameter(obj,hObj,mouse,src)
            % TO DO: support multiple parameters at a time
            
            switch hObj.Tag
                case 'abscissa'
                    i = find(ismember(src.ValidParameters,src.ParameterName));
                    [sel,ok] = listdlg('ListString',src.ValidParameters, ...
                        'SelectionMode','single', ...
                        'InitialValue',i,'Name','Plot', ...
                        'PromptString','Select Independent Variable:', ...
                        'ListSize',[180 150]);
                    if ~ok, return; end
                    src.ParameterName = src.ValidParameters{sel};
                    try
                        delete(obj.TextH(length(src.ParameterValues)+1:end));
                    end
                    
                case 'ordinate'
                    i = find(ismember(obj.ValidPlotTypes,obj.PlotType));
                    [sel,ok] = listdlg('ListString',obj.ValidPlotTypes, ...
                        'SelectionMode','single', ...
                        'InitialValue',i,'Name','Plot', ...
                        'PromptString','Select Plot Type:', ...
                        'ListSize',[180 150]);
                    if ~ok, return; end
                    obj.PlotType = obj.ValidPlotTypes{sel};
                    
            end
            obj.update_plot(src);
        end
        
        
        function setup_xaxis_label(obj,src,event)
            x = xlabel(obj.AxesH,src.ParameterName,'Tag','abscissa','Interpreter','none');
            x.ButtonDownFcn = {@obj.update_parameter,src};
        end
        
        function setup_yaxis_label(obj,src,event)
            y = ylabel(obj.AxesH,obj.PlotType,'Tag','ordinate','Interpreter','none');
            y.ButtonDownFcn = {@obj.update_parameter,src};
        end
    end
    
end
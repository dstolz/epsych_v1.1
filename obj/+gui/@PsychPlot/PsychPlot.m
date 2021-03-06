classdef PsychPlot < handle
    
    properties
        AxesH       (1,1)
        
        ParameterName (1,:) char
        
        PsychophysicsObj
        
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
        listener_NewData
    end
    
    properties (Constant)
        ValidPlotTypes = {'DPrime','Hit_Rate','FA_Rate','Bias'};
    end
    
    
    events (ListenAccess = 'public', NotifyAccess = 'protected')
        PsychPlot_ParameterUpdate
    end
    
    
    methods
        function obj = PsychPlot(pObj,Helper,ax)
            if nargin < 3 || isempty(ax), ax = gca; end
            
            obj.AxesH = ax;
            
            if nargin >= 1 && ~isempty(pObj)
                obj.PsychophysicsObj = pObj;
                obj.setup_xaxis_label;
                obj.setup_yaxis_label;
                obj.update_plot;
            end
            
            if nargin > 1 && ~isempty(Helper)
                obj.link_with_helper(Helper);
            end
        end
        
        
        
        function set.ParameterName(obj,name)
            ind = ismember(obj.ValidParameters,name);
            assert(any(ind),'ep_Psychophysics_Detection:set.ParameterName','Invalid parameter name: %s',name);
            obj.ParameterName = name;
            obj.update_plot;
        end
        
        function link_with_helper(obj,Helper)
            if isempty(Helper) || isempty(Helper), return; end
            obj.listener_NewData = addlistener(Helper,'NewData',@obj.update_plot);
        end
        
        

        function h = get.LineH(obj)
            h = findobj(obj.AxesH,'type','line');
        end

       
        
        function update_plot(obj,src,event)
            % although data is updated in src and event, just use the obj.PsychophysicsObj
            lh = obj.LineH;
            sh = obj.ScatterH;
            if isempty(lh) || isempty(sh) || ~isvalid(lh) || ~isvalid(sh)
                sh = scatter(nan,nan,100,'filled','Parent',obj.AxesH,'Marker','s');
%                     'MarkerFaceColor','flat');
                
                lh = line(obj.AxesH,nan,nan,'Marker','none', ...
                    'AlignVertexCenters','on', ...
                    'LineWidth',2,'Color',obj.LineColor(1,:));
                
                grid(obj.AxesH,'on');
            end
            
            
            X = obj.PsychophysicsObj.ParameterValues;
            Y = obj.PsychophysicsObj.(obj.PlotType);
            %C = obj.PsychophysicsObj.Trial_Count;
            C = [obj.PsychophysicsObj.Go_Count' obj.PsychophysicsObj.NoGo_Count'];
            
            lh.XData = X;
            lh.YData = Y;
            
            
            sh.XData = X;
            sh.YData = Y;
            s = repmat(120,size(X));
            ind = sum(C,2) == 0;
            s(ind) = 30;
            sh.SizeData = s;
            c = repmat(obj.MarkerColor(1,:),length(X),1);
            sh.CData = c;
            
            uistack(sh,'top');
            
            for i = 1:length(X)
                if i > size(C,1), break; end
                if nnz(C(i,:)) == 0, continue; end
                obj.TextH(i) = text(obj.AxesH,X(i),Y(i),num2str(C(i,:),'%d/%d'), ...
                    'HorizontalAlignment','center','VerticalAlignment','middle', ...
                    'Color',[0 0 0],'FontSize',9);
            end
            
            obj.setup_xaxis_label;
            obj.setup_yaxis_label;
            

            tstr = sprintf('%s [%d] - Trial %d', ...
                obj.PsychophysicsObj.SUBJECT.Name, ...
                obj.PsychophysicsObj.BoxID, ...
                obj.PsychophysicsObj.Trial_Index);
            
            title(obj.AxesH,tstr);
        end
        
        function update_parameter(obj,hObj,mouse)
            % TO DO: support multiple parameters at a time
            switch hObj.Tag
                case 'abscissa'
                    i = find(ismember(obj.PsychophysicsObj.ValidParameters,obj.PsychophysicsObj.ParameterName));
                    [sel,ok] = listdlg('ListString',obj.PsychophysicsObj.ValidParameters, ...
                        'SelectionMode','single', ...
                        'InitialValue',i,'Name','Plot', ...
                        'PromptString','Select Independent Variable:', ...
                        'ListSize',[180 150]);
                    if ~ok, return; end
                    obj.PsychophysicsObj.ParameterName = obj.PsychophysicsObj.ValidParameters{sel};
                    try
                        delete(obj.TextH(length(obj.PsychophysicsObj.ParameterValues)+1:end));
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
            obj.update_plot;
        end
        
        
        function setup_xaxis_label(obj)
            x = xlabel(obj.AxesH,obj.PsychophysicsObj.ParameterName,'Tag','abscissa','Interpreter','none');
            x.ButtonDownFcn = @obj.update_parameter;
        end
        
        function setup_yaxis_label(obj)
            y = ylabel(obj.AxesH,obj.PlotType,'Tag','ordinate','Interpreter','none');
            y.ButtonDownFcn = @obj.update_parameter;
        end
        
        function set.PsychophysicsObj(obj,pobj)
            assert(epsych.Helper.valid_psych_obj(pobj), ...
                'gui.History:set.PsychophysiccsObj', ...
                'PsychophysicsObj must be from the toolbox "psychophysics"');
            obj.PsychophysicsObj = pobj;
            obj.update_plot;
        end
    end
    
end
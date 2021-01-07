classdef DigIO < handle & dynamicprops
    
    
    properties (SetAccess = private)
        Hardware     (1,1)
        digLines     (1,:)   epsych.hw.comp.DigitalLine
        hIndicator   (1,:)   matlab.ui.control.Lamp
        hOutputState (1,:)   matlab.ui.control.StateButton
    end
    
    properties (SetAccess = immutable)
        parent
        N
        nOut
        nIn
    end
    
    methods
        function obj = DigIO(Hardware,parent)
            narginchk(1,2);

            if isempty(parent), parent = gcf; end

            obj.Hardware = Hardware;
            obj.digLines = Hardware.digLines(:)';
                        
            obj.parent = parent;
            
            obj.N    = numel(obj.digLines);
            obj.nOut = sum([obj.digLines.isOutput]);
            obj.nIn  = sum(~[obj.digLines.isOutput]);

            obj.create;
        end
        
        function update(obj,src,event)
            h = event.AffectedObject;
            h.hIndicator.Enable = event.AffectedObject.StateStr;
            h.hIndicator.Tooltip = sprintf('%s - %s', ...
                    h.Alias,h.StateStr);
        end
        
        function set_state(obj,src,event)
            src.UserData.State = event.Value;
            if event.Value
                src.Text = '1';
            else
                src.Text = '0';
            end
            
        end
    end
    
    methods (Access = private)
        function create(obj)
            g = uigridlayout(obj.parent);
            g.ColumnWidth = repmat({15},1,obj.N);
            g.RowHeight   = {15,15};
            for i = 1:obj.N
                D = obj.digLines(i);
                h = uilamp(g);
                h.Layout.Column = i;
                h.Layout.Row    = 1;
                h.Enable = D.StateStr;
                h.Tooltip = sprintf('%s - %s', ...
                    D.Alias,D.StateStr);
                
                addlistener(D,'State','PostSet',@obj.update);
                
                if D.isOutput
                    h.Color = [1 0 0];
                    
                    s = uibutton(g,'state','text','','FontName','Courier', ...
                        'FontSize',10,'FontWeight','bold', ...
                        'HorizontalAlignment','left', ...
                        'VerticalAlignment','top');
                    s.Layout.Column = i;
                    s.Layout.Row    = 2;
                    s.UserData = D;
                    s.ValueChangedFcn = @obj.set_state;
                else
                    h.Color = [0 1 0];
                end
                
                D.hIndicator = h;

                p = matlab.lang.makeValidName(D.Alias);
                obj.addprop(p);
                obj.(p) = D;
            end
        end
    end
    
end
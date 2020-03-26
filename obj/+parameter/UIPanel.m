classdef UIPanel < handle & matlab.mixin.SetGet
    
    properties
        Position        (1,4) double {mustBeFinite,mustBeNonNan}
        PositionX       (1,1) double {mustBeFinite,mustBeNonNan}
        PositionY       (1,1) double {mustBeFinite,mustBeNonNan}
        Width           (1,1) double {mustBeFinite,mustBeNonNan}
        Height          (1,1) double {mustBeFinite,mustBeNonNan}
    end
    
    properties (SetAccess = private)
        hPanel
        hItems
        hVerticalSlider
        Styles          (1,:) cell
    end
    
    properties (SetAccess = private, GetAccess = private)
        OriginalPosition
    end

    properties (SetAccess = immutable)
        Group    (1,1) parameter.ItemSet
        parent
    end
    
    methods
        % Constructor
        function obj = UIPanel(Group,Styles,parent,varargin)
            narginchk(1,3);
            
            if nargin < 3 || isempty(parent), parent = gcf; end
            if nargin < 2 || isempty(Styles), Styles = 'auto'; end

            obj.Group = Group;
            obj.parent = parent;

            if ischar(Styles) && isequal(Styles,'auto')
                obj.Styles = repmat({'auto'},1,Group.N);
            end
            
            obj.create;
            
            p = properties(obj);
            for i = 1:2:length(varargin)
                ind = strcmpi(p,varargin{i});
                assert(any(ind),'gui.UIPanel:UIPanel:InvalidParameter', ...
                    'Invalid property "%s"',varargin{i})
                obj.(p{ind}) = varargin{i+1};
            end
        end
        
        % Destructor
        function delete(obj)
            cellfun(@delete,obj.hItems);
            delete(obj.hVerticalSlider);
        end
        
        
        function create(obj)
            obj.hPanel = UIPanel(obj.parent);
            obj.hPanel.Position = obj.Position;

            obj.hPanel.Units = 'pixels';

            w = obj.hPanel.Position(3);
            h = obj.hPanel.Position(4)-5;

            a = 22;
            d = 3;

            position = [w/2-22 h w/2-22 a];

            for i = 1:obj.Group.N
                if isequal(obj.Styles{i},'auto')
                    obj.Styles{i} = parameter.UIControl.guess_uistyle(obj.Group.Parameters(i));
                end
                
                switch obj.Styles{i}
                    case 'listbox'
                        position(2) = position(2) - 50 - d;
                        position(4) = 50;
                        
                    otherwise
                        position(2) = position(2) - 22 - d;
                        position(4) = 22;
                end
                
                h = gui.(['ui' obj.Styles{i}])(obj.Group.Parameters(i), ...
                    obj.parent, ...
                    'Position',position);

                obj.OriginalPosition{i} = h.Position;

                obj.hItems{i} = h;
            
            end

            if position(2) < 0 % do we need a slider?
                pos = obj.parent.Position;
                obj.hVerticalSlider = uicontrol( ...
                    'Style',     'slider', ...
                    'Parent',    obj.parent, ...
                    'Value',     pos(4)-position(2), ...
                    'Units',     'pixels', ...
                    'Position',  [pos(3)-25 5 20 pos(4)-10], ...
                    'Min',       pos(4)-position(4), ...
                    'Max',       pos(4)-position(2), ...
                    'SliderStep',[0.05 0.20], ...
                    'Callback',  @obj.vertical_slider);
            end


        end
        
        function set.Position(obj,pos)
            obj.hPanel.Position = pos;
        end
        
        function pos = get.Position(obj)
            pos = obj.hPanel.Position;
        end
        
        function set.PositionX(obj,x)
            obj.hPanel.Position(1) = x;
        end
        
        function set.PositionY(obj,y)
            obj.hPanel.Position(2) = y;
        end
        
        function set.Width(obj,w)
            obj.hPanel.Position(3) = w;
        end
        
        function set.Height(obj,h)
            obj.hPanel.Position(4) = h;
        end
        
        function x = get.PositionX(obj)
            x = obj.hPanel.Position(1);
        end
        
        function y = get.PositionY(obj)
            y = obj.hPanel.Position(2);
        end
        
        function w = get.Width(obj)
            w = obj.hPanel.Position(3);
        end
        
        function h = get.Height(obj)
            h = obj.hPanel.Position(4);
        end
        
    end

    methods (Access = private)
        function vertical_slider(obj,hObj,event)
            v = hObj.Max - hObj.Value;
            for i = 1:obj.Group.N
                obj.hItems{i}.PositionY = obj.OriginalPosition{i}(2) + v;
            end
        end
    end

end
classdef uipanel < handle & matlab.mixin.SetGet
    
    properties
        Position        (1,4) double {mustBeFinite,mustBeNonNan}
        PositionX       (1,1) double {mustBeFinite,mustBeNonNan}
        PositionY       (1,1) double {mustBeFinite,mustBeNonNan}
        Width           (1,1) double {mustBeFinite,mustBeNonNan}
        Height          (1,1) double {mustBeFinite,mustBeNonNan}
    end
    
    properties (SetAccess = private)
        hPanel
        hParameters     (1,:) 
    end
    
    properties (SetAccess = private, GetAccess = private)
        OriginalPosition
    end

    properties (SetAccess = immutable)
        ParameterSet    (1,1) epsych.ParameterSet
        Styles          (1,:) cell
        parent
        
    end
    
    methods
        % Constructor
        function obj = uipanel(ParameterSet,Styles,parent,varargin)
            narginchk(1,3);
            
            if nargin < 3 || isempty(parent), parent = gcf; end
            if nargin < 2 || isempty(parent), Styles = 'auto'; end

            obj.ParameterSet = ParameterSet;
            obj.parent = parent;

            if ischar(Styles) && isequal(Styles,'auto')
                obj.Styles = rempat({'auto'},1,ParameterSet.N);
            end
            
            obj.create;
            
            p = properties(obj);
            for i = 1:2:length(varargin)
                ind = strcmpi(p,varargin{i});
                assert(any(ind),'gui.uipanel:uipanel:InvalidParameter', ...
                    'Invalid property "%s"',varargin{i})
                obj.(p{ind}) = varargin{i+1};
            end

                       
        end
        
        % Destructor
        function delete(obj)
            delete(obj.hPanel);
        end
        
        
        function create(obj)
            obj.hPanel = uipanel(obj.parent);
            obj.hPanel.Position = obj.Position;

            obj.hPanel.Units = 'pixels';

            w = obj.hPanel.Position(3);
            h = obj.hPanel.Position(4);

            a = 25;
            d = 5;

            position = [w/2-20 h-a-d w/2-20 a];

            for i = 1:obj.ParameterSet.N
                if isequal(obj.Styles{i},'auto')
                    obj.Styles{i} = gui.uipanel.guess_uistyle(obj.ParameterSet.Parameters(i));
                end

                h = gui.ParameterControl(obj.ParameterSet.Parameters(i),obj.parent, ...
                    'Style',obj.Styles{i},'Position',position);

                obj.OriginalPosition(i) = h.Position;

                a = h.Position(2);

                position(1) = position(1) - a - d;

                obj.hParameters(i) = h;
            end

            if position(1) < 0
                pos = obj.parent.Position;
                obj.hVerticalSlider = uicontrol( ...
                    'Style',     'slider', ...
                    'Parent',    obj.parent, ...
                    'Tag',       'StimControlProperties_slider', ...
                    'Value',     position(1), ...
                    'Units',     'pixels', ...
                    'Position',  [pos(3)-1 5 20 pos(4)-10], ...
                    'Min',       0, ...
                    'Max',       position(1), ...
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

            for i = 1:obj.ParameterSet.N
                pos = obj.hParameters(i),'UserData');
                pos(2) = pos(2) + v;
                obj.hParameters(i).Position = pos;
            end
        end
    end
    
    methods (Static)
        function style = guess_uistyle(P)
            if P.N == 1
                style = 'edit';

            elseif P.isLogical
                style = 'checkbox';

            elseif P.isMultiselect
                style = 'listbox';

            elseif P.isContinuous
                style = 'slider';

            else
                style = 'popupmenu';
            end
        end
    end
    
end
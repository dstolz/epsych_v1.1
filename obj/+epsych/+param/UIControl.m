classdef UIControl < handle & matlab.mixin.SetGet
    
    properties
        Value
        
        LabelString     (1,:) char
        LabelPosition   (1,:) char {mustBeMember(LabelPosition,{'left','right','above','below','none'})} = 'left';

        Parameter       (1,1) epsych.param.Parameter
        
        Position        (1,4) double {mustBeFinite,mustBeNonNan}
        
        PositionX       (1,1) double {mustBeFinite,mustBeNonNan}
        PositionY       (1,1) double {mustBeFinite,mustBeNonNan}
        Width           (1,1) double {mustBeFinite,mustBeNonNan}
        Height          (1,1) double {mustBeFinite,mustBeNonNan}
    end
    
    properties (Abstract)
        ValueType
    end
    

    properties (SetAccess = protected)
        hLabel
    end
    
    properties (SetAccess = private)
        hControl
    end
    
    properties (SetAccess = immutable)
        parent
    end
    
    
    methods
        % Constructor
        function obj = UIControl(Parameter,parent,varargin)            
            obj.Parameter = Parameter;
            
            if nargin < 2 || isempty(parent), parent = gcf; end

            obj.parent = parent;
            
            obj.create;
            
            p = properties(obj);
            for i = 1:2:length(varargin)
                ind = strcmpi(p,varargin{i});
                assert(any(ind),'epsych.ui.comp.UIControl:UIControl:InvalidParameter', ...
                    'Invalid property "%s"',varargin{i})
                obj.(p{ind}) = varargin{i+1};
            end
        end
        
        % Destructor
        function delete(obj)
            delete(obj.hControl);
            delete(obj.hLabel);
        end
        
        function set.Position(obj,pos)
            obj.hControl.Position = pos;
            obj.update_position;
        end
        
        function pos = get.Position(obj)
            pos = obj.hControl.Position;
        end
        
        function set.PositionX(obj,x)
            obj.hControl.Position(1) = x;
            obj.update_position;
        end
        
        function set.PositionY(obj,y)
            obj.hControl.Position(2) = y;
            obj.update_position;
        end
        
        function set.Width(obj,w)
            obj.hControl.Position(3) = w;
            obj.update_position;
        end
        
        function set.Height(obj,h)
            obj.hControl.Position(4) = h;
            obj.update_position;
        end
        
        function x = get.PositionX(obj)
            x = obj.hControl.Position(1);
        end
        
        function y = get.PositionY(obj)
            y = obj.hControl.Position(2);
        end
        
        function w = get.Width(obj)
            w = obj.hControl.Position(3);
        end
        
        function h = get.Height(obj)
            h = obj.hControl.Position(4);
        end
        
        function set.LabelPosition(obj,pos)
            obj.LabelPosition = pos;
            obj.update_position;
        end
        
    end
    
    methods (Access = protected)
                
        function modify_parameter(obj,hObj,event)
            str = sprintf('Modify Parameter Expression for "%s":',obj.epsych.param.Name);
            
            options.Resize='on';
            options.WindowStyle='normal';
            options.Interpreter='none';
            
            a = inputdlg(str,obj.epsych.param.Name,1, ...
                {obj.epsych.param.Expression},options);
            if isempty(a), return; end
            
            obj.epsych.param.Expression = char(a);
           
            obj.ValueType = obj.ValueType;
            
            obj.create;
            
            obj.hControl.Tooltip = sprintf('%s: %s',obj.epsych.param.Name,obj.epsych.param.Expression);
        end
        
        function Callback(obj,hObj,event)
            disp(event)
        end
        
        function update_position(obj)
            hp = obj.hControl.Position;
            obj.hLabel.Visible = 'on';
            switch obj.LabelPosition
                case 'left'
                    obj.hLabel.Position(1) = hp(1)-obj.hLabel.Position(3);
                    obj.hLabel.Position(2) = hp(2) + hp(4)./2 - obj.hLabel.Position(4)./2;
                    obj.hLabel.HorizontalAlignment = 'right';

                case 'right'
                    obj.hLabel.Position(1) = sum(hp([1 3]));
                    obj.hLabel.Position(2) = hp(2) + hp(4)./2 - obj.hLabel.Position(4)./2;
                    obj.hLabel.HorizontalAlignment = 'left';

                case 'above'
                    obj.hLabel.Position(1) = hp(1);
                    obj.hLabel.Position(2) = sum(hp([2 4]));
                    obj.hLabel.Position(3) = hp(3);
                    obj.hLabel.HorizontalAlignment = 'left';

                case 'below'
                    obj.hLabel.Position(1) = hp(1);
                    obj.hLabel.Position(2) = hp(2)-obj.hLabel.Position(4);
                    obj.hLabel.Position(3) = hp(3);
                    obj.hLabel.HorizontalAlignment = 'left';
                    
                case 'none'
                    obj.hLabel.Visible = 'off';
            end
        end
    end
    
    methods (Access = private)
        function create(obj)
            if isempty(obj.hControl)
                obj.hControl = uicontrol(obj.parent, ...
                    'Style',        obj.Style, ...
                    'Callback',     @obj.Callback, ...
                    'Tooltip',      sprintf('%s: %s',obj.epsych.param.Name,obj.epsych.param.Expression));
%                     'ButtonDownFcn',@obj.modify_parameter);
                
                if ~isequal(obj.LabelPosition,'none')
                    obj.hLabel = uicontrol(obj.parent, ...
                        'Style',   'text', ...
                        'String',   obj.epsych.param.Name);
%                         'ButtonDownFcn',@obj.modify_parameter);
                    obj.hLabel.Position([1 2]) = obj.hControl.Position([1 2]);
                end
                obj.update_position;
            else
                style = epsych.ui.comp.UIControl.guess_uistyle(obj.Parameter);
                if isequal(obj.hControl.Style,style), return; end
                position = obj.Position;
                delete(obj.hControl);
                delete(obj.hLabel);
                obj.hControl = [];
                obj.create;
                obj.hControl.Position = position;
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